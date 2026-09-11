/// =========================================================
/// SCR_BATTLE_MODIFIERS
/// NUEVO SCRIPT
/// =========================================================
/// Capa común para debuffs temporales, Toys enemigos y
/// modificadores modulares de armas.
/// =========================================================

function scr_battle_runtime_ensure(_controller)
{
    if (_controller == noone || !instance_exists(_controller))
        return false;

    if (!variable_instance_exists(_controller, "player_turnos_stun"))
        _controller.player_turnos_stun = 0;

    if (!variable_instance_exists(_controller, "player_ataque_reducido"))
        _controller.player_ataque_reducido = 0;

    if (!variable_instance_exists(_controller, "player_defensa_reducida"))
        _controller.player_defensa_reducida = 0;

    if (!variable_instance_exists(_controller, "player_precision_reducida"))
        _controller.player_precision_reducida = 0;

    return true;
}


/// Toys que pueden lanzar los enemigos:
/// "bloqueo_jugador"      -> pierde próximo turno.
/// "debilitador_jugador"  -> baja AT o DEF durante BBS.
/// "confusor_jugador"     -> +30% fallo del ataque del jugador.
function scr_enemy_toy_apply(_controller, _toy_id, _enemy_name = "Enemigo")
{
    if (!scr_battle_runtime_ensure(_controller))
        return "* El enemigo intentó usar algo, pero no pasó nada.";

    switch (_toy_id)
    {
        case "bloqueo_jugador":
            _controller.player_turnos_stun =
                max(_controller.player_turnos_stun, 1);

            return
                "* " + string(_enemy_name)
                + " lanza un Toy pegajoso. ¡Perderás tu próximo turno!";


        case "debilitador_jugador":
            if (irandom(1) == 0)
            {
                _controller.player_ataque_reducido += 1;

                return
                    "* " + string(_enemy_name)
                    + " usa un Toy debilitador. Tu ataque baja durante esta batalla.";
            }
            else
            {
                _controller.player_defensa_reducida += 1;

                return
                    "* " + string(_enemy_name)
                    + " usa un Toy debilitador. Tu defensa baja durante esta batalla.";
            }


        case "confusor_jugador":
            _controller.player_precision_reducida =
                clamp(
                    _controller.player_precision_reducida + 0.30,
                    0,
                    0.95
                );

            return
                "* " + string(_enemy_name)
                + " lanza un Toy confusor. Ahora puedes fallar incluso un ataque perfecto.";
    }

    return
        "* " + string(_enemy_name)
        + " intenta usar un Toy desconocido.";
}


function scr_battle_get_weapon_data()
{
    if (!instance_exists(obj_player))
        return undefined;

    if (!variable_global_exists("equip_db") || !is_struct(global.equip_db))
        scr_equips_data();

    var _arma_equipada = obj_player.equipo_arma;

    if (is_struct(_arma_equipada))
        return _arma_equipada;

    if (_arma_equipada == -1 || _arma_equipada == "")
        return undefined;

    if (variable_struct_exists(global.equip_db, _arma_equipada))
        return variable_struct_get(global.equip_db, _arma_equipada);

    return undefined;
}


/// Campos combinables:
/// ataque_modo: "lineal" / "circular_carga"
/// ataque_golpes
/// ataque_cura
/// ataque_ancho_centro_mult
/// ataque_confirmar_despues_centro
/// carga_*
function scr_battle_get_weapon_mods()
{
    var _w = scr_battle_get_weapon_data();

    var _mods =
    {
        modo: "lineal",
        golpes: 1,
        cura: 0,
        ancho_centro_mult: 1.0,
        confirmar_despues_centro: false,

        carga_tiempo_frames: 24,
        carga_velocidad_radio: 5.5,
        carga_radio_inicial: 4,
        carga_radio_objetivo: 64,
        carga_radio_max: 90,
        carga_tolerancia_perfecta: 5
    };

    if (!is_struct(_w))
        return _mods;

    if (variable_struct_exists(_w, "ataque_modo"))
        _mods.modo = string_lower(string(_w.ataque_modo));

    if (variable_struct_exists(_w, "ataque_golpes"))
        _mods.golpes = max(1, round(_w.ataque_golpes));

    if (variable_struct_exists(_w, "ataque_cura"))
        _mods.cura = max(0, round(_w.ataque_cura));

    if (variable_struct_exists(_w, "ataque_ancho_centro_mult"))
        _mods.ancho_centro_mult = max(0.25, _w.ataque_ancho_centro_mult);

    if (variable_struct_exists(_w, "ataque_confirmar_despues_centro"))
        _mods.confirmar_despues_centro = _w.ataque_confirmar_despues_centro;

    if (variable_struct_exists(_w, "carga_tiempo_frames"))
        _mods.carga_tiempo_frames = max(8, round(_w.carga_tiempo_frames));

    if (variable_struct_exists(_w, "carga_velocidad_radio"))
        _mods.carga_velocidad_radio = max(0.1, _w.carga_velocidad_radio);

    if (variable_struct_exists(_w, "carga_radio_inicial"))
        _mods.carga_radio_inicial = max(0, _w.carga_radio_inicial);

    if (variable_struct_exists(_w, "carga_radio_objetivo"))
        _mods.carga_radio_objetivo = max(1, _w.carga_radio_objetivo);

    if (variable_struct_exists(_w, "carga_radio_max"))
        _mods.carga_radio_max =
            max(_mods.carga_radio_objetivo, _w.carga_radio_max);

    if (variable_struct_exists(_w, "carga_tolerancia_perfecta"))
        _mods.carga_tolerancia_perfecta =
            max(0, _w.carga_tolerancia_perfecta);

    return _mods;
}


function scr_battle_player_attack_multiplier(_controller)
{
    if (!scr_battle_runtime_ensure(_controller))
        return 1;

    return max(
        0,
        1 - (_controller.player_ataque_reducido * 0.08)
    );
}


function scr_battle_player_received_damage_multiplier(_controller)
{
    if (!scr_battle_runtime_ensure(_controller))
        return 1;

    return
        1
        + (max(0, _controller.player_defensa_reducida) * 0.08);
}
