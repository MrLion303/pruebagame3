// =========================================================
// OBJ_SAVE
// STEP
// =========================================================


// Comprobar Z o Enter.
if (
    keyboard_check_pressed(ord("Z"))
    ||
    keyboard_check_pressed(vk_enter)
)
{
    // Interacción cercana.
    if (distance_to_object(obj_player) < 8)
    {
        // No crear otro menú.
        if (!instance_exists(obj_save_menu))
        {
            // El menú de pausa debe estar cerrado.
            if (
                instance_exists(obj_menu_manager)
                &&
                obj_menu_manager.state == MENU_STATE.CLOSED
            )
            {
                instance_create_depth(
                    0,
                    0,
                    -9999,
                    obj_save_menu
                );

                audio_play_sound(
                    snd_menumove,
                    10,
                    false
                );
            }
        }
    }
}