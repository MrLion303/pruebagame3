/// =========================================================
/// OBJ_CUTSCENE_CONTROLLER
/// DESTROY
/// =========================================================


// =========================================================
// SONIDO LARGO DE DIÁLOGO
// =========================================================

if (
    dialog_extra_sound_stop_with_dialog
    &&
    dialog_extra_sound_instance != -1
    &&
    audio_is_playing(dialog_extra_sound_instance)
)
{
    audio_stop_sound(dialog_extra_sound_instance);
}


// =========================================================
// RESTAURAR CÁMARA
// =========================================================

if (camera_valid && camera_custom_active)
{
    camera_set_view_pos(
        cutscene_camera,
        camera_origin_x,
        camera_origin_y
    );

    camera_set_view_target(
        cutscene_camera,
        camera_original_target
    );

    camera_custom_active = false;
}


// =========================================================
// LIMPIAR MOVIMIENTOS ACTIVOS
// =========================================================

if (is_array(move_tasks))
{
    for (var _i = 0; _i < array_length(move_tasks); _i++)
    {
        var _task = move_tasks[_i];
        var _actor = scr_cutscene_actor(_task.actor);

        if (
            _actor != noone
            &&
            instance_exists(_actor)
        )
        {
            if (variable_struct_exists(_task, "old_image_speed"))
                _actor.image_speed = _task.old_image_speed;
        }
    }
}


// =========================================================
// PLAYER
// =========================================================

if (instance_exists(obj_player))
{
    var _player = instance_find(obj_player, 0);

    if (variable_instance_exists(_player, "cutscene_motion_active"))
        _player.cutscene_motion_active = false;


    // -----------------------------------------------------
    // SUSPENDIDA POR BATALLA
    // -----------------------------------------------------
    // No es el final real. No devolver control ni cambiar
    // orientación final.
    // -----------------------------------------------------

    if (suspended_for_battle)
    {
        global.cutscene_active = false;
        global.cutscene_player_can_move = false;
        exit;
    }


    // -----------------------------------------------------
    // FINAL REAL POR CS_END()
    // -----------------------------------------------------

    if (cutscene_finished)
    {
        if (
            variable_instance_exists(
                _player,
                "cutscene_sprite_override_active"
            )
        )
        {
            _player.cutscene_sprite_override_active = false;
        }

        // Universal: termina mirando hacia el frente.
        scr_cutscene_face_actor(
            _player,
            "abajo"
        );

        // Quieto, pero NO cambiamos image_speed.
        // Así no congelamos la animación normal del player.
        _player.image_index = 0;

        if (restore_player_movement)
        {
            if (variable_instance_exists(_player, "puede_moverse"))
                _player.puede_moverse = true;

            if (variable_instance_exists(_player, "can_move"))
                _player.can_move = true;
        }
    }
}


if (cutscene_finished)
{
    global.cutscene_active = false;
    global.cutscene_player_can_move = false;
}
