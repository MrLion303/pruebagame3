#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Sincronizador de localización para GameMaker.

- Escanea recursivamente todos los .gml del proyecto.
- Auto-instrumenta patrones de texto visibles comunes para que pasen por scr_loc().
- Genera/actualiza datafiles/idioma_es.json desde el español que sigue viviendo en el GML.
- Conserva las traducciones existentes de datafiles/idioma_en.json.
- Añade nuevas entradas inglesas como "" (fallback automático al español en el juego).
- Archiva traducciones que dejan de existir en .localizacion/idioma_en_obsoletos.json.
- --watch vuelve a sincronizar cuando se guarda cualquier .gml.

Uso recomendado:
    python localizacion_sync.py --watch

Una sola pasada:
    python localizacion_sync.py --once
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import sys
import time
from pathlib import Path
from typing import Iterable

ENCODING = "utf-8"
SKIP_DIRS = {
    ".git", ".svn", ".hg", ".localizacion", "datafiles", "build", "cache",
    "Temp", "temp", "output", "bin", "obj", "node_modules"
}

# Literal GML de comillas dobles. Soporta escapes \" y \\.
STRING_LITERAL = r'"(?:\\.|[^"\\])*"'
LOC_CALL_RE = re.compile(
    rf'\b(?:scr_loc|scr_loc_src|scr_locf)\s*\(\s*({STRING_LITERAL})',
    re.MULTILINE,
)

VISIBLE_FIELD_RE = re.compile(
    rf'(?P<prefix>\b(?:texto|nombre|descripcion|texto_inicio|texto_muerte|lugar|name)\s*:\s*)'
    rf'(?P<lit>{STRING_LITERAL})'
)

TEXT_ASSIGN_RE = re.compile(
    rf'(?P<prefix>\b(?:close_text|text_to_draw|texto|mensaje|message|label|title|titulo|caption)\s*=\s*)'
    rf'(?P<lit>{STRING_LITERAL})'
)

# Funciones donde el primer parámetro es texto visible.
FIRST_TEXT_ARG_FUNCS = {
    "scr_text": "scr_loc",
    "scr_option": "scr_loc",
    "f_procesar_dialogo": "scr_loc",
}

# Funciones draw_* donde el tercer argumento es el texto visible.
DRAW_TEXT_FUNCS = {
    "draw_text": 2,
    "draw_text_ext": 2,
    "draw_text_transformed": 2,
    "draw_text_color": 2,
    "draw_text_transformed_color": 2,
    "draw_text_ext_transformed": 2,
    "draw_text_ext_transformed_color": 2,
}


def find_project_root(start: Path) -> Path:
    start = start.resolve()
    candidates = [start, *start.parents]
    for base in candidates:
        if any(base.glob("*.yyp")):
            return base
    # Si el .py se deja en la raíz del proyecto, este fallback es correcto.
    return start


def iter_gml(root: Path) -> list[Path]:
    out: list[Path] = []
    for path in root.rglob("*.gml"):
        try:
            rel_parts = path.relative_to(root).parts
        except ValueError:
            continue
        if any(part in SKIP_DIRS for part in rel_parts[:-1]):
            continue
        out.append(path)
    return sorted(out, key=lambda p: str(p).lower())


def decode_gml_literal(lit: str) -> str:
    # Los strings generados/esperados aquí usan el subconjunto compatible con JSON.
    try:
        return json.loads(lit)
    except Exception:
        body = lit[1:-1]
        body = body.replace(r'\"', '"').replace(r'\\', '\\')
        body = body.replace(r'\n', '\n').replace(r'\r', '\r').replace(r'\t', '\t')
        return body


def is_quoted_literal(expr: str) -> bool:
    return re.fullmatch(rf'\s*{STRING_LITERAL}\s*', expr, flags=re.DOTALL) is not None


def starts_with_literal(expr: str):
    m = re.match(rf'(?P<lead>\s*)(?P<lit>{STRING_LITERAL})', expr, flags=re.DOTALL)
    return m


def split_top_level_args(text: str, open_paren: int, close_paren: int) -> list[tuple[int, int]]:
    """Devuelve rangos [start,end) de argumentos sin entrar en (), [], {}, strings o comentarios."""
    ranges: list[tuple[int, int]] = []
    start = open_paren + 1
    i = start
    p = b = c = 0
    in_string = False
    esc = False
    line_comment = False
    block_comment = False

    while i < close_paren:
        ch = text[i]
        nxt = text[i + 1] if i + 1 < close_paren else ""

        if line_comment:
            if ch == "\n":
                line_comment = False
            i += 1
            continue
        if block_comment:
            if ch == "*" and nxt == "/":
                block_comment = False
                i += 2
            else:
                i += 1
            continue
        if in_string:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == '"':
                in_string = False
            i += 1
            continue

        if ch == "/" and nxt == "/":
            line_comment = True
            i += 2
            continue
        if ch == "/" and nxt == "*":
            block_comment = True
            i += 2
            continue
        if ch == '"':
            in_string = True
            i += 1
            continue
        if ch == "(": p += 1
        elif ch == ")": p -= 1
        elif ch == "[": b += 1
        elif ch == "]": b -= 1
        elif ch == "{": c += 1
        elif ch == "}": c -= 1
        elif ch == "," and p == 0 and b == 0 and c == 0:
            ranges.append((start, i))
            start = i + 1
        i += 1
    ranges.append((start, close_paren))
    return ranges


def find_matching_paren(text: str, open_pos: int) -> int | None:
    depth = 0
    in_string = False
    esc = False
    line_comment = False
    block_comment = False
    i = open_pos
    n = len(text)
    while i < n:
        ch = text[i]
        nxt = text[i + 1] if i + 1 < n else ""
        if line_comment:
            if ch == "\n": line_comment = False
            i += 1; continue
        if block_comment:
            if ch == "*" and nxt == "/": block_comment = False; i += 2
            else: i += 1
            continue
        if in_string:
            if esc: esc = False
            elif ch == "\\": esc = True
            elif ch == '"': in_string = False
            i += 1; continue
        if ch == "/" and nxt == "/": line_comment = True; i += 2; continue
        if ch == "/" and nxt == "*": block_comment = True; i += 2; continue
        if ch == '"': in_string = True; i += 1; continue
        if ch == "(": depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0: return i
        i += 1
    return None


def instrument_function_args(text: str) -> str:
    """Envuelve literales visibles en llamadas conocidas sin tocar identificadores/keys técnicas."""
    # Hacemos varias pasadas porque las posiciones cambian al insertar wrappers.
    names = sorted(set(FIRST_TEXT_ARG_FUNCS) | set(DRAW_TEXT_FUNCS), key=len, reverse=True)
    pattern = re.compile(r'\b(' + '|'.join(map(re.escape, names)) + r')\s*\(')
    cursor = 0
    while True:
        m = pattern.search(text, cursor)
        if not m:
            break
        fname = m.group(1)
        open_pos = text.find("(", m.start(1) + len(fname))
        close_pos = find_matching_paren(text, open_pos)
        if close_pos is None:
            cursor = m.end()
            continue
        ranges = split_top_level_args(text, open_pos, close_pos)
        arg_index = 0 if fname in FIRST_TEXT_ARG_FUNCS else DRAW_TEXT_FUNCS[fname]
        if arg_index >= len(ranges):
            cursor = close_pos + 1
            continue
        a, b = ranges[arg_index]
        expr = text[a:b]

        # Ya localizado: no tocar.
        if re.match(r'\s*(?:scr_loc|scr_locf)\s*\(', expr):
            cursor = close_pos + 1
            continue

        sm = starts_with_literal(expr)
        if sm:
            # Si es literal completo o literal + concatenación, localizamos el literal inicial.
            lit_start = a + sm.start("lit")
            lit_end = a + sm.end("lit")
            lit = text[lit_start:lit_end]
            replacement = f"scr_loc({lit})"
            text = text[:lit_start] + replacement + text[lit_end:]
            cursor = lit_start + len(replacement)
        else:
            cursor = close_pos + 1
    return text


def instrument_visible_fields(text: str) -> str:
    def repl_field(m: re.Match) -> str:
        prefix, lit = m.group("prefix"), m.group("lit")
        # Evita doble instrumentación si un regex queda sobre texto ya cambiado.
        return prefix + f"scr_loc_src({lit})"

    # Solo aplica si el valor empieza directamente con literal, no si ya es scr_loc_src(...)
    text = VISIBLE_FIELD_RE.sub(repl_field, text)
    text = TEXT_ASSIGN_RE.sub(repl_field, text)
    return text


def instrument_option_arrays(text: str) -> str:
    """Marca strings crudos en asignaciones *_options = [ ... ]; para que entren al JSON."""
    pat = re.compile(r'\b([A-Za-z_]\w*options\w*)\s*=\s*\[', re.IGNORECASE)
    cursor = 0
    while True:
        m = pat.search(text, cursor)
        if not m: break
        open_pos = text.find("[", m.end() - 1)
        # Buscar ] correspondiente con parser simple.
        depth = 0; i = open_pos; in_string=False; esc=False
        close = None
        while i < len(text):
            ch = text[i]
            if in_string:
                if esc: esc=False
                elif ch == "\\": esc=True
                elif ch == '"': in_string=False
            else:
                if ch == '"': in_string=True
                elif ch == "[": depth += 1
                elif ch == "]":
                    depth -= 1
                    if depth == 0:
                        close = i; break
            i += 1
        if close is None:
            cursor = m.end(); continue
        block = text[open_pos+1:close]
        # No envolver strings ya contenidas dentro de scr_loc_src(...): tokenización ligera.
        out=[]; j=0
        for sm in re.finditer(STRING_LITERAL, block):
            before = block[max(0, sm.start()-40):sm.start()]
            out.append(block[j:sm.start()])
            lit=sm.group(0)
            if re.search(r'(?:scr_loc|scr_loc_src|scr_locf)\s*\(\s*$', before):
                out.append(lit)
            else:
                out.append(f"scr_loc_src({lit})")
            j=sm.end()
        out.append(block[j:])
        new_block=''.join(out)
        if new_block != block:
            text = text[:open_pos+1] + new_block + text[close:]
            cursor = open_pos + 1 + len(new_block)
        else:
            cursor = close + 1
    return text


def instrument_source(text: str) -> str:
    # Evitar autoeditar el propio script de localización: sus strings son técnicos.
    if "function scr_loc_src(" in text and "function scr_language_set(" in text:
        return text
    before = None
    current = text
    # Dos vueltas cubren patrones que quedan expuestos por una primera instrumentación.
    for _ in range(2):
        before = current
        current = instrument_function_args(current)
        current = instrument_visible_fields(current)
        current = instrument_option_arrays(current)
        if current == before:
            break
    return current


def backup_once(root: Path, path: Path):
    rel = path.relative_to(root)
    dst = root / ".localizacion" / "backups" / rel
    if not dst.exists():
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, dst)


def extract_keys(text: str) -> list[str]:
    keys: list[str] = []
    seen = set()
    for m in LOC_CALL_RE.finditer(text):
        value = decode_gml_literal(m.group(1))
        if value == "":
            continue
        if value not in seen:
            seen.add(value)
            keys.append(value)
    return keys


def read_json_object(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    try:
        data = json.loads(path.read_text(encoding=ENCODING))
        return data if isinstance(data, dict) else {}
    except Exception as exc:
        print(f"[LOCALIZACION] ADVERTENCIA: no pude leer {path}: {exc}")
        return {}


def write_json(path: Path, data: dict):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding=ENCODING)
    os.replace(tmp, path)


def synchronize(root: Path, auto_patch: bool = True) -> tuple[int, int, int]:
    gml_files = iter_gml(root)
    if not gml_files:
        print(f"[LOCALIZACION] No encontré .gml dentro de: {root}")
        return (0, 0, 0)

    changed_files = []
    all_keys: list[str] = []
    seen = set()
    locations: dict[str, list[str]] = {}

    for path in gml_files:
        raw = path.read_text(encoding=ENCODING, errors="replace")
        patched = instrument_source(raw) if auto_patch else raw
        if patched != raw:
            backup_once(root, path)
            path.write_text(patched, encoding=ENCODING)
            changed_files.append(path.relative_to(root).as_posix())
        for key in extract_keys(patched):
            if key not in seen:
                seen.add(key)
                all_keys.append(key)
            # Línea aproximada de primera aparición por archivo.
            lit = json.dumps(key, ensure_ascii=False)
            pos = patched.find(lit)
            line = patched.count("\n", 0, pos) + 1 if pos >= 0 else 0
            locations.setdefault(key, []).append(f"{path.relative_to(root).as_posix()}:{line}")

    data_dir = root / "datafiles"
    es_path = data_dir / "idioma_es.json"
    en_path = data_dir / "idioma_en.json"
    state_dir = root / ".localizacion"
    state_dir.mkdir(parents=True, exist_ok=True)

    old_es = read_json_object(es_path)
    old_en = read_json_object(en_path)

    es = {key: key for key in all_keys}
    en = {key: old_en.get(key, "") if isinstance(old_en.get(key, ""), str) else "" for key in all_keys}

    removed = [k for k in old_en.keys() if k not in es]
    if removed:
        archive_path = state_dir / "idioma_en_obsoletos.json"
        archive = read_json_object(archive_path)
        for k in removed:
            archive[k] = old_en[k]
        write_json(archive_path, archive)

    write_json(es_path, es)
    write_json(en_path, en)

    manifest = {
        "total": len(all_keys),
        "fuentes": {key: locations.get(key, []) for key in all_keys},
    }
    write_json(state_dir / "manifest.json", manifest)

    pending = [k for k, v in en.items() if not isinstance(v, str) or v == ""]
    report_lines = [
        "REPORTE DE LOCALIZACION",
        "=======================",
        f"Textos españoles detectados: {len(all_keys)}",
        f"Traducciones inglesas pendientes: {len(pending)}",
        f"Entradas inglesas obsoletas archivadas en esta pasada: {len(removed)}",
        f"Archivos GML auto-instrumentados en esta pasada: {len(changed_files)}",
        "",
    ]
    if changed_files:
        report_lines += ["GML MODIFICADOS AUTOMATICAMENTE:", *[f"- {x}" for x in changed_files], ""]
    if pending:
        report_lines += ["PENDIENTES EN idioma_en.json:", *[f"- {x}" for x in pending], ""]
    if removed:
        report_lines += ["OBSOLETOS ARCHIVADOS:", *[f"- {x}" for x in removed], ""]
    (state_dir / "reporte.txt").write_text("\n".join(report_lines), encoding=ENCODING)

    print(
        f"[LOCALIZACION] OK | {len(all_keys)} textos | "
        f"{len(pending)} pendientes EN | {len(changed_files)} GML auto-instrumentados"
    )
    return len(all_keys), len(pending), len(changed_files)


def snapshot(root: Path) -> dict[str, tuple[int, int]]:
    snap = {}
    for p in iter_gml(root):
        try:
            st = p.stat()
            snap[str(p)] = (st.st_mtime_ns, st.st_size)
        except FileNotFoundError:
            pass
    return snap


def main() -> int:
    parser = argparse.ArgumentParser(description="Sincroniza localización ES/EN de un proyecto GameMaker.")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--watch", action="store_true", help="vigila cambios .gml y sincroniza automáticamente")
    mode.add_argument("--once", action="store_true", help="hace una sola sincronización")
    parser.add_argument("--no-patch", action="store_true", help="solo extrae scr_loc/scr_loc_src/scr_locf; no autoedita GML")
    parser.add_argument("--root", type=Path, default=None, help="raíz del proyecto (carpeta que contiene el .yyp)")
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    root = args.root.resolve() if args.root else find_project_root(script_dir)
    print(f"[LOCALIZACION] Proyecto: {root}")

    synchronize(root, auto_patch=not args.no_patch)
    if not args.watch:
        return 0

    print("[LOCALIZACION] Vigilando .gml. Puedes dejar esta ventana abierta mientras trabajas.")
    last = snapshot(root)
    try:
        while True:
            time.sleep(1.0)
            now = snapshot(root)
            if now != last:
                # Espera corta para evitar leer mientras GameMaker sigue escribiendo el archivo.
                time.sleep(0.20)
                synchronize(root, auto_patch=not args.no_patch)
                last = snapshot(root)
    except KeyboardInterrupt:
        print("\n[LOCALIZACION] Vigilancia detenida.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
