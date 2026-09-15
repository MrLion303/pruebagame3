/// =========================================================
/// SCR_RANDOM_ENCOUNTERS - COMPLETO
/// =========================================================
///
/// ENCUENTROS ALEATORIOS EXCLUSIVAMENTE POR MOVIMIENTO.
///
/// NO usa tiempo.
/// NO usa alarms.
/// NO tira probabilidad cada frame.
///
/// FUNCIONAMIENTO:
///
///     Maya camina X píxeles reales dentro de una room
///         -> se hace UNA tirada de probabilidad
///
///     si falla:
///         -> el contador vuelve a empezar para otros X píxeles
///
///     si acierta:
///         -> inicia la batalla configurada
///
/// El ID de batalla debe coincidir EXACTAMENTE con un case de:
///
///     scr_enemigos_data()
///
/// Toda la personalización está en:
///
///     scr_random_encounter_config()
///
/// =========================================================


// =========================================================
// CONFIGURACIÓN POR ROOM
// =========================================================
//
// CAMPOS:
//
// enabled
//     true / false
//
// pixels_per_check
//     Cuántos píxeles reales debe recorrer Maya antes de
//     realizar UNA tirada.
//
// chance_percent
//     Probabilidad de 0 a 100.
//
// battle_id
//     ID exacta de la batalla dentro de scr_enemigos_data.
//
// allow_platformer
//     false = no contar movimiento en modo plataformero.
//     true  = también contar movimiento en modo plataformero.
//
// EJEMPLO ACTUAL:
//
//     pasillo_school
//     cada 50 px
//     100%
//     batalla "toby"
//
// =========================================================

function scr_random_encounter_config(_room)
{
    switch (_room)
    {
        case pasillo_school:
            return {
                enabled: false,
                pixels_per_check: 50,
                chance_percent: 100,
                battle_id: "toby",
                allow_platformer: false
            };


        // =================================================
        // EJEMPLO PARA OTRA ROOM
        // =================================================
        //
        // case toriel_salon:
        //     return {
        //         enabled: true,
        //         pixels_per_check: 120,
        //         chance_percent: 15,
        //         battle_id: "slime",
        //         allow_platformer: false
        //     };
        //
    }


    // Room sin configuración = sin encuentros.
    return undefined;
}


// =========================================================
// RUNTIME GLOBAL
// =========================================================

function scr_random_encounter_prepare()
{
    if (
        !variable_global_exists(
            "random_encounter_runtime"
        )
        ||
        !is_struct(
            global.random_encounter_runtime
        )
    )
    {
        global.random_encounter_runtime = {
            room_id: -1,
            last_x: 0,
            last_y: 0,
            distance_accum: 0,
            initialized: false
        };
    }


    return global.random_encounter_runtime;
}


// =========================================================
// LIMPIAR FLAG DE BATALLA COLGADO
// =========================================================
//
// global.viajando_a_batalla se activa al entrar a BBS.
//
// En el proyecto actual puede seguir en true después de haber
// regresado de una batalla.
//
// Si no estamos en BBS ni existe una transición de batalla,
// ese true ya es viejo y se limpia.
//
// =========================================================

function scr_random_encounter_fix_battle_flag()
{
    if (
        !variable_global_exists(
            "viajando_a_batalla"
        )
    )
    {
        global.viajando_a_batalla =
            false;

        return;
    }


    if (
        room != bbs
        &&
        !instance_exists(
            obj_transicion_bbs
        )
        &&
        !instance_exists(
            obj_transicion_salida_bbs
        )
    )
    {
        global.viajando_a_batalla =
            false;
    }
}


// =========================================================
// ¿EL MENÚ DE PAUSA ESTÁ REALMENTE ABIERTO?
// =========================================================

function scr_random_encounter_menu_open()
{
    if (!instance_exists(obj_menu_manager))
    {
        return false;
    }


    var _menu =
        instance_find(
            obj_menu_manager,
            0
        );


    if (
        _menu == noone
        ||
        !instance_exists(_menu)
    )
    {
        return false;
    }


    return
        _menu.state
        !=
        MENU_STATE.CLOSED;
}


// =========================================================
// ¿SE PUEDE INICIAR UN ENCUENTRO AHORA?
// =========================================================

function scr_random_encounter_world_free()
{
    if (!instance_exists(obj_player))
    {
        return false;
    }


    if (
        room == bbs
        ||
        room == rm_title
        ||
        room == game_over
    )
    {
        return false;
    }


    scr_random_encounter_fix_battle_flag();


    // Ya hay una transición relacionada con batalla.
    if (
        instance_exists(
            obj_transicion_bbs
        )
        ||
        instance_exists(
            obj_transicion_salida_bbs
        )
    )
    {
        return false;
    }


    // Warp normal de room.
    if (instance_exists(obj_warp))
    {
        return false;
    }


    if (
        variable_global_exists(
            "transicionando"
        )
        &&
        global.transicionando
    )
    {
        return false;
    }


    if (
        variable_global_exists(
            "cutscene_active"
        )
        &&
        global.cutscene_active
    )
    {
        return false;
    }


    if (
        instance_exists(obj_textbox)
        ||
        instance_exists(obj_save_menu)
        ||
        instance_exists(obj_hoja_problema_ui)
        ||
        instance_exists(obj_pauser)
    )
    {
        return false;
    }


    // MUY IMPORTANTE:
    //
    // obj_menu_manager puede existir durante el gameplay aunque
    // el menú esté completamente cerrado.
    //
    // Sólo bloqueamos encuentros si de verdad está abierto.
    if (scr_random_encounter_menu_open())
    {
        return false;
    }


    return true;
}


// =========================================================
// INICIAR BATALLA
// =========================================================
//
// battle_id debe ser una ID válida de scr_enemigos_data.
//
// Ejemplo:
//
//     "toby"
//
// =========================================================

function scr_random_encounter_start(_battle_id)
{
    if (!scr_random_encounter_world_free())
    {
        return false;
    }


    var _p =
        instance_find(
            obj_player,
            0
        );


    if (
        _p == noone
        ||
        !instance_exists(_p)
    )
    {
        return false;
    }


    var _battle_string =
        string(
            _battle_id
        );


    if (_battle_string == "")
    {
        show_debug_message(
            "[RANDOM ENCOUNTER] battle_id vacío."
        );

        return false;
    }


    // =====================================================
    // POSICIÓN DE RETORNO
    // =====================================================

    global.return_room =
        room;


    global.return_x =
        _p.x;


    global.return_y =
        _p.y;


    if (
        variable_instance_exists(
            _p,
            "face"
        )
    )
    {
        global.return_face =
            _p.face;
    }


    // =====================================================
    // SELECCIONAR BATALLA
    // =====================================================
    //
    // obj_batalla_controller obtiene los datos con:
    //
    //     scr_enemigos_data(global.enemigo_actual_id)
    //
    // Por eso la ID se establece ANTES de cambiar a BBS.
    //
    // =====================================================

    global.enemigo_actual_id =
        _battle_string;


    // El sistema funcional de enemigos de mapa también
    // conserva esta ID secundaria antes de entrar a BBS.
    global.battle_enemy_id =
        _battle_string;


    global.viajando_a_batalla =
        true;


    // =====================================================
    // DETENER A MAYA
    // =====================================================

    if (
        variable_instance_exists(
            _p,
            "puede_moverse"
        )
    )
    {
        _p.puede_moverse =
            false;
    }


    if (
        variable_instance_exists(
            _p,
            "can_move"
        )
    )
    {
        _p.can_move =
            false;
    }


    if (
        variable_instance_exists(
            _p,
            "movimiento"
        )
    )
    {
        _p.movimiento =
            false;
    }


    if (
        variable_instance_exists(
            _p,
            "hsp"
        )
    )
    {
        _p.hsp =
            0;
    }


    if (
        variable_instance_exists(
            _p,
            "vsp"
        )
    )
    {
        _p.vsp =
            0;
    }


    // =====================================================
    // SONIDO
    // =====================================================

    if (audio_exists(snd_bbs_start))
    {
        audio_play_sound(
            snd_bbs_start,
            10,
            false
        );
    }


    // =====================================================
    // TRANSICIÓN A BBS
    // =====================================================
    //
    // IMPORTANTE:
    //
    // NO usamos instance_create_layer().
    //
    // obj_player puede tener layer == -1 en determinadas
    // situaciones, y GameMaker crashea si se intenta crear una
    // instancia en una layer inexistente.
    //
    // Este es el MISMO método que usa actualmente el sistema
    // funcional obj_enemigo_batalla_mapa_parent:
    //
    //     instance_create_depth(
    //         0,
    //         0,
    //         -1000000,
    //         obj_transicion_bbs
    //     );
    //
    // obj_transicion_bbs además vuelve a fijar su propio depth
    // en su Create y es persistent.
    //
    // =====================================================

    var _transition =
        instance_create_depth(
            0,
            0,
            -1000000,
            obj_transicion_bbs
        );


    if (
        _transition == noone
        ||
        !instance_exists(_transition)
    )
    {
        global.viajando_a_batalla =
            false;


        if (
            variable_instance_exists(
                _p,
                "puede_moverse"
            )
        )
        {
            _p.puede_moverse =
                true;
        }


        if (
            variable_instance_exists(
                _p,
                "can_move"
            )
        )
        {
            _p.can_move =
                true;
        }


        show_debug_message(
            "[RANDOM ENCOUNTER] No se pudo crear obj_transicion_bbs."
        );


        return false;
    }


    show_debug_message(
        "[RANDOM ENCOUNTER] Batalla iniciada: "
        +
        _battle_string
    );


    return true;
}


// =========================================================
// UPDATE
// =========================================================
//
// Llamado UNA VEZ por Step desde el objeto persistente game.
//
// La probabilidad NO depende del Step.
//
// Step sólo sirve para medir cuánta distancia real recorrió
// Maya desde el frame anterior.
//
// =========================================================

function scr_random_encounter_update()
{
    var _rt =
        scr_random_encounter_prepare();


    // =====================================================
    // SIN PLAYER
    // =====================================================

    if (!instance_exists(obj_player))
    {
        _rt.initialized =
            false;


        _rt.distance_accum =
            0;


        return false;
    }


    var _p =
        instance_find(
            obj_player,
            0
        );


    if (
        _p == noone
        ||
        !instance_exists(_p)
    )
    {
        return false;
    }


    // =====================================================
    // PRIMER FRAME / CAMBIO DE ROOM
    // =====================================================

    if (
        !_rt.initialized
        ||
        _rt.room_id
        !=
        room
    )
    {
        _rt.room_id =
            room;


        _rt.last_x =
            _p.x;


        _rt.last_y =
            _p.y;


        _rt.distance_accum =
            0;


        _rt.initialized =
            true;


        // Al entrar a una room normal, cualquier flag antiguo
        // de viaje a batalla se puede limpiar si corresponde.
        scr_random_encounter_fix_battle_flag();


        return false;
    }


    // =====================================================
    // DISTANCIA RECORRIDA EN ESTE FRAME
    // =====================================================

    var _frame_distance =
        point_distance(
            _rt.last_x,
            _rt.last_y,
            _p.x,
            _p.y
        );


    // SIEMPRE actualizar el punto anterior.
    //
    // Esto evita que abrir un menú, una cinemática o una
    // interfaz convierta después ese tiempo en movimiento
    // acumulado falso.
    _rt.last_x =
        _p.x;


    _rt.last_y =
        _p.y;


    // =====================================================
    // CONFIGURACIÓN DE ESTA ROOM
    // =====================================================

    var _cfg =
        scr_random_encounter_config(
            room
        );


    if (is_undefined(_cfg))
    {
        _rt.distance_accum =
            0;


        return false;
    }


    if (
        !variable_struct_exists(
            _cfg,
            "enabled"
        )
        ||
        !_cfg.enabled
    )
    {
        _rt.distance_accum =
            0;


        return false;
    }


    // =====================================================
    // BLOQUEOS TEMPORALES
    // =====================================================
    //
    // NO se pierde la distancia acumulada anterior.
    //
    // Simplemente el movimiento realizado mientras el mundo
    // está bloqueado no cuenta.
    //
    // =====================================================

    if (!scr_random_encounter_world_free())
    {
        return false;
    }


    var _allow_platformer =
        false;


    if (
        variable_struct_exists(
            _cfg,
            "allow_platformer"
        )
    )
    {
        _allow_platformer =
            _cfg.allow_platformer;
    }


    if (
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active
        &&
        !_allow_platformer
    )
    {
        return false;
    }


    // =====================================================
    // PARÁMETROS
    // =====================================================

    var _pixels_per_check =
        max(
            1,
            real(
                _cfg.pixels_per_check
            )
        );


    var _chance =
        clamp(
            real(
                _cfg.chance_percent
            ),
            0,
            100
        );


    var _battle_id =
        _cfg.battle_id;


    // =====================================================
    // IGNORAR TELEPORTS / WARP DE COORDENADAS
    // =====================================================
    //
    // Un salto enorme de coordenadas no debe convertirse en
    // decenas de tiradas.
    //
    // =====================================================

    var _teleport_limit =
        max(
            64,
            _pixels_per_check
            *
            2
        );


    if (_frame_distance > _teleport_limit)
    {
        _rt.distance_accum =
            0;


        return false;
    }


    // Sin movimiento real = no ocurre absolutamente nada.
    if (_frame_distance <= 0.001)
    {
        return false;
    }


    // =====================================================
    // ACUMULAR MOVIMIENTO REAL
    // =====================================================

    _rt.distance_accum +=
        _frame_distance;


    // =====================================================
    // UNA TIRADA POR CADA BLOQUE DE X PÍXELES
    // =====================================================
    //
    // Ejemplo:
    //
    // pixels_per_check = 50
    //
    // 49 px:
    //     0 tiradas.
    //
    // 50 px:
    //     1 tirada.
    //
    // otros 50 px:
    //     otra tirada.
    //
    // =====================================================

    while (
        _rt.distance_accum
        >=
        _pixels_per_check
    )
    {
        _rt.distance_accum -=
            _pixels_per_check;


        var _roll =
            random(100);


        if (_roll < _chance)
        {
            // Al iniciar batalla ya no necesitamos conservar
            // sobrante de distancia.
            _rt.distance_accum =
                0;


            return
                scr_random_encounter_start(
                    _battle_id
                );
        }
    }


    return false;
}
