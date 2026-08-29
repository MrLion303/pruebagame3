/// =========================================================
/// OBJ_CUTSCENE_CONTROLLER
/// DESTROY
/// =========================================================


// =========================================================
// LIMPIAR MOVIMIENTOS
// =========================================================

if (is_array(move_tasks))
{
    for (
        var _i = 0;
        _i < array_length(move_tasks);
        _i++
    )
    {
        var _task =
            move_tasks[_i];


        var _actor =
            scr_cutscene_actor(
                _task.actor
            );


        if (
            _actor != noone
            &&
            instance_exists(_actor)
        )
        {
            // Restaurar la velocidad de animación que
            // tenía antes del movimiento de cinemática.
            if (
                variable_struct_exists(
                    _task,
                    "old_image_speed"
                )
            )
            {
                _actor.image_speed =
                    _task.old_image_speed;
            }
        }
    }
}


// =========================================================
// PLAYER
// =========================================================

if (instance_exists(obj_player))
{
    var _player =
        instance_find(
            obj_player,
            0
        );


    // =====================================================
    // DETENER MOVIMIENTO CONTROLADO POR CINEMÁTICA
    // =====================================================

    if (
        variable_instance_exists(
            _player,
            "cutscene_motion_active"
        )
    )
    {
        _player.cutscene_motion_active =
            false;
    }


    // =====================================================
    // SUSPENDIDA POR BATALLA
    // =====================================================
    //
    // Esto NO es el final de la cinemática.
    //
    // No:
    //
    // - mirar al frente
    // - devolver movimiento
    // - modificar image_speed
    //
    // La cinemática continuará después de la batalla.
    // =====================================================

    if (suspended_for_battle)
    {
        global.cutscene_active =
            false;


        exit;
    }


    // =====================================================
    // FINAL REAL POR CS_END()
    // =====================================================

    if (cutscene_finished)
    {
        // =================================================
        // QUITAR SPRITE OVERRIDE
        // =================================================

        if (
            variable_instance_exists(
                _player,
                "cutscene_sprite_override_active"
            )
        )
        {
            _player.cutscene_sprite_override_active =
                false;
        }


        // =================================================
        // MIRAR SIEMPRE HACIA EL FRENTE
        // =================================================

        scr_cutscene_face_actor(
            _player,
            "abajo"
        );


        // =================================================
        // FRAME QUIETO
        // =================================================
        //
        // Lo ponemos inicialmente en frame 0...
        //
        // PERO NO TOCAMOS image_speed.
        //
        // De esta manera, cuando vuelva a caminar,
        // GameMaker podrá continuar normalmente con
        // los frames de caminata.
        // =================================================

        _player.image_index =
            0;


        // =================================================
        // DEVOLVER CONTROL
        // =================================================

        if (restore_player_movement)
        {
            if (
                variable_instance_exists(
                    _player,
                    "puede_moverse"
                )
            )
            {
                _player.puede_moverse =
                    true;
            }


            if (
                variable_instance_exists(
                    _player,
                    "can_move"
                )
            )
            {
                _player.can_move =
                    true;
            }
        }
    }
}


// =========================================================
// ESTADO GLOBAL
// =========================================================

if (cutscene_finished)
{
    global.cutscene_active =
        false;
}