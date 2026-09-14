/// =========================================================
/// SCR_RANDOM_ROOM_ENCOUNTERS
/// =========================================================
///
/// Encuentros aleatorios basados EXCLUSIVAMENTE en distancia
/// recorrida dentro de una habitación.
///
/// NO usa alarms.
/// NO usa tiempo.
/// NO tira probabilidad cada frame.
///
/// Flujo:
///
///     Maya recorre X píxeles
///         -> se hace 1 tirada
///         -> si falla, vuelve a contar otros X píxeles
///
/// Toda la configuración de habitaciones se hace en:
///
///     scr_random_encounter_config()
///
/// =========================================================


// =========================================================
// CONFIGURACIÓN POR ROOM
// =========================================================
//
// chance_percent:
//     0 a 100.
//
// pixels_per_check:
//     píxeles reales que Maya debe recorrer antes de cada tirada.
//
// enemy_id:
//     ID que recibe global.enemigo_actual_id.
//
// allow_platformer:
//     false = no contar movimiento en modo plataformero.
//     true  = también contar movimiento en modo plataformero.
//
// Añade tantos "case" como habitaciones quieras.
//
// =========================================================

function scr_random_encounter_config(_room)
{
    switch (_room)
    {
        // -------------------------------------------------
        // EJEMPLO
        // -------------------------------------------------
        //
        // Está DESACTIVADO para no meter encuentros en una room
        // existente sin que tú lo decidas.
        //
        // Para usarlo cambia enabled a true y personaliza todo.
        //
        case pasillo_school:
            return {
                enabled: true,
                pixels_per_check: 50,
                chance_percent: 100,
                enemy_id: "toby",
                allow_platformer: false
            };


        // -------------------------------------------------
        // EJEMPLO PARA AÑADIR OTRA ROOM:
        // -------------------------------------------------
        //
        // case pasillo_school:
        //     return {
        //         enabled: true,
        //         pixels_per_check: 128,
        //         chance_percent: 8,
        //         enemy_id: "toby",
        //         allow_platformer: false
        //     };
        //
    }


    // Room sin configuración = sin encuentros.
    return undefined;
}


// =========================================================
// RUNTIME
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
// ¿EL MUNDO PERMITE UN ENCUENTRO AHORA?
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
    )
    {
        return false;
    }


    if (
        variable_global_exists(
            "viajando_a_batalla"
        )
        &&
        global.viajando_a_batalla
    )
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
        instance_exists(obj_menu_manager)
        ||
        instance_exists(obj_pauser)
        ||
        instance_exists(obj_hoja_problema_ui)
    )
    {
        return false;
    }


    return true;
}


// =========================================================
// INICIAR BATALLA
// =========================================================
//
// Replica el flujo que ya usa obj_batalla_prob.
//
// =========================================================

function scr_random_encounter_start(_enemy_id)
{
    if (!instance_exists(obj_player))
    {
        return false;
    }


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


    // =====================================================
    // DATOS DE RETORNO
    // =====================================================
    //
    // Mismos nombres que usa obj_batalla_prob.
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
    // BATALLA CONFIGURADA
    // =====================================================
    //
    // El controller de batalla hace:
    //
    //     scr_enemigos_data(global.enemigo_actual_id)
    //
    // así que "toby" cargará directamente el case "toby"
    // definido en scr_enemigos_data.
    // =====================================================

    global.enemigo_actual_id =
        string(_enemy_id);


    global.viajando_a_batalla =
        true;


    // =====================================================
    // BLOQUEAR MOVIMIENTO
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
    // SONIDO DE BATALLA
    // =====================================================
    //
    // Es el mismo sonido que usa obj_batalla_prob.
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
    // Antes se intentaba crear en una layer fija por nombre.
    // Esa layer no existe necesariamente en todas las rooms,
    // por lo que GameMaker terminaba recibiendo -1.
    //
    // El jugador ya está en una layer válida de la room,
    // así que usamos su layer real.
    //
    // obj_transicion_bbs establece su propio depth en Create,
    // es persistent y después ejecuta room_goto(bbs).
    // =====================================================

    instance_create_layer(
        0,
        0,
        _p.layer,
        obj_transicion_bbs
    );


    return true;
}

// =========================================================
// UPDATE GLOBAL
// =========================================================
//
// Llamar 1 vez por Step desde obj_game.
//
// =========================================================

function scr_random_encounter_update()
{
    var _rt =
        scr_random_encounter_prepare();


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
    // NUEVA ROOM / PRIMER FRAME
    // =====================================================

    if (
        !_rt.initialized
        ||
        _rt.room_id != room
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


        return false;
    }


    var _dx =
        _p.x
        -
        _rt.last_x;


    var _dy =
        _p.y
        -
        _rt.last_y;


    var _frame_distance =
        point_distance(
            _rt.last_x,
            _rt.last_y,
            _p.x,
            _p.y
        );


    // SIEMPRE sincronizamos la última posición, incluso si
    // actualmente no se permiten encuentros.
    _rt.last_x =
        _p.x;


    _rt.last_y =
        _p.y;


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


    var _pixels_per_check =
        max(
            1,
            real(
                _cfg.pixels_per_check
            )
        );


    // Warp / teleport / reposicionamiento:
    //
    // no convertir un salto gigante de coordenadas en decenas
    // de tiradas de encuentro.
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


    // No hubo movimiento real.
    if (_frame_distance <= 0.001)
    {
        return false;
    }


    _rt.distance_accum +=
        _frame_distance;


    var _chance =
        clamp(
            real(
                _cfg.chance_percent
            ),
            0,
            100
        );


    // Puede haber más de una tirada si un movimiento externo
    // recorrió muchos píxeles de golpe.
    while (
        _rt.distance_accum
        >=
        _pixels_per_check
    )
    {
        _rt.distance_accum -=
            _pixels_per_check;


        if (
            random(100)
            <
            _chance
        )
        {
            _rt.distance_accum =
                0;


            return
                scr_random_encounter_start(
                    _cfg.enemy_id
                );
        }
    }


    return false;
}
