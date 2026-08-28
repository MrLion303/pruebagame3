/// =========================================================
/// SISTEMA DE LOCALIZACIÓN
/// Español = texto fuente dentro del código.
/// Inglés = idioma_en.json (Included File).
/// =========================================================

function scr_loc_src(_texto) {
    // Marcador para el generador externo. En ejecución conserva el español fuente.
    return _texto;
}

function scr_loc_load(_idioma) {
    if (_idioma != "en") _idioma = "es";

    var _archivo = (_idioma == "en") ? "idioma_en.json" : "idioma_es.json";
    var _tabla = {};

    if (file_exists(_archivo)) {
        var _buffer = buffer_load(_archivo);

        if (_buffer != -1) {
            buffer_seek(_buffer, buffer_seek_start, 0);
            var _json = buffer_read(_buffer, buffer_text);
            buffer_delete(_buffer);

            if (string_length(_json) > 0) {
                try {
                    var _parseado = json_parse(_json, undefined, true);
                    if (is_struct(_parseado)) {
                        _tabla = _parseado;
                    }
                }
                catch (_err) {
                    show_debug_message("[LOCALIZACION] JSON invalido en " + _archivo + ". Se usara el español fuente como respaldo.");
                    _tabla = {};
                }
            }
        }
    }

    global.idioma = _idioma;
    global.loc_data = _tabla;
    global.loc_loaded_language = _idioma;

    return true;
}

function scr_loc_init() {
    if (!variable_global_exists("idioma")) {
        var _guardado = "es";

        ini_open("idioma_config.ini");
        _guardado = ini_read_string("Localizacion", "idioma", "es");
        ini_close();

        if (_guardado != "en") _guardado = "es";
        global.idioma = _guardado;
    }

    if (!variable_global_exists("loc_data") ||
        !variable_global_exists("loc_loaded_language") ||
        global.loc_loaded_language != global.idioma) {
        scr_loc_load(global.idioma);
    }
}

function scr_loc(_texto_fuente) {
    if (!is_string(_texto_fuente)) return _texto_fuente;

    scr_loc_init();

    if (is_struct(global.loc_data) && struct_exists(global.loc_data, _texto_fuente)) {
        var _traducido = struct_get(global.loc_data, _texto_fuente);

        // Cadena vacía = todavía no traducida: vuelve al español fuente.
        if (is_string(_traducido) && string_length(_traducido) > 0) {
            return _traducido;
        }
    }

    return _texto_fuente;
}

function scr_locf(_texto_fuente, _valores) {
    var _resultado = scr_loc(_texto_fuente);

    if (!is_struct(_valores)) return _resultado;

    var _nombres = struct_get_names(_valores);

    for (var i = 0; i < array_length(_nombres); i++) {
        var _nombre = _nombres[i];
        var _valor = struct_get(_valores, _nombre);
        _resultado = string_replace_all(_resultado, "{" + _nombre + "}", string(_valor));
    }

    return _resultado;
}

function scr_language_set(_idioma) {
    if (_idioma != "en") _idioma = "es";

    scr_loc_load(_idioma);

    ini_open("idioma_config.ini");
    ini_write_string("Localizacion", "idioma", _idioma);
    ini_close();

    return global.idioma;
}

function scr_language_toggle() {
    scr_loc_init();
    return scr_language_set((global.idioma == "en") ? "es" : "en");
}

function scr_language_is_english() {
    scr_loc_init();
    return global.idioma == "en";
}

function scr_language_sprite(_sprite_es, _sprite_en) {
    return scr_language_is_english() ? _sprite_en : _sprite_es;
}