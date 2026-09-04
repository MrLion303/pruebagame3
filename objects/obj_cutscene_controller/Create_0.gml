/// =========================================================
/// OBJ_CUTSCENE_CONTROLLER
/// CREATE
/// =========================================================

// El controller también dibuja la imagen cinemática.
// -90000: por encima del gameplay.
// Los textboxes se fuerzan a -100000 para quedar encima.
depth =
    -90000;

cutscene_id =
    "";

actions =
    [];

action_index =
    0;

ready =
    false;

player_can_move =
    false;

wait_timer =
    0;

waiting_dialogue =
    false;

dialogue_seen =
    false;

dialogue_grace =
    0;

waiting_sound_instance =
    -1;


// Sonido largo asociado al cuadro de diálogo.
dialog_extra_sound_instance =
    -1;

dialog_extra_sound_stop_with_dialog =
    true;


move_tasks =
    [];

next_task_id =
    0;

waiting_task_id =
    -1;


restore_player_movement =
    true;

cutscene_finished =
    false;

suspended_for_battle =
    false;

missing_end_warned =
    false;


// =========================================================
// CÁMARA
// =========================================================

cutscene_camera =
    view_camera[0];

camera_valid =
    (cutscene_camera != -1);

camera_origin_x =
    0;

camera_origin_y =
    0;

camera_original_target =
    noone;

camera_custom_active =
    false;

camera_task_active =
    false;

camera_waiting =
    false;

camera_target_x =
    0;

camera_target_y =
    0;

camera_move_speed =
    2;

camera_restore_target_when_done =
    false;


if (camera_valid)
{
    camera_origin_x =
        camera_get_view_x(
            cutscene_camera
        );

    camera_origin_y =
        camera_get_view_y(
            cutscene_camera
        );

    camera_original_target =
        camera_get_view_target(
            cutscene_camera
        );
}


// =========================================================
// IMAGEN FULLSCREEN
// =========================================================

cutscene_image_sprite =
    noone;

cutscene_image_alpha =
    0;

cutscene_image_target_alpha =
    0;

cutscene_image_fade_speed =
    0;

cutscene_image_transition_active =
    false;

cutscene_image_waiting =
    false;

cutscene_image_remove_when_done =
    false;


// =========================================================
// BLOQUEO UNIVERSAL DE MUNDO
// =========================================================
//
// CUALQUIER cinemática:
//
//     obj_batalla
//     obj_damage_test
//     obj_music_trigger
//     obj_warp_block
//
// deja de responder.
//
// =========================================================

scr_cutscene_world_lock();
