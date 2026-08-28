// =========================================================
// OBJ_BUTTONS_CONTINUE
// STEP
// =========================================================


// =========================================================
// LOCALIZACIÓN DEL TÍTULO
// =========================================================

scr_loc_init();


if (!variable_instance_exists(id, "_sprite_spanish"))
{
    _sprite_spanish =
        sprite_index;

    image_speed =
        0;
}


// Mantener frame.
var _frame_actual =
    floor(image_index);


var _sprite_deseado =
    scr_language_is_english()
    ?
    spr_buttons_continue_english
    :
    _sprite_spanish;


if (sprite_index != _sprite_deseado)
{
    sprite_index =
        _sprite_deseado;

    image_index =
        _frame_actual;

    image_speed =
        0;
}


// =========================================================
// FADE IN
// =========================================================

if (image_alpha < 1)
{
    image_alpha += 0.05;

    if (image_alpha > 1)
    {
        image_alpha = 1;
    }
}


// =========================================================
// INTERACCIÓN
// =========================================================

if (
    !instance_exists(obj_save_menu)
    &&
    !instance_exists(obj_new_game_transition)
)
{
    // =====================================================
    // ABAJO
    //
    // 0 = Nuevo
    // 1 = Continuar
    // 2 = Salir
    // 3 = Idioma
    // =====================================================

    if (keyboard_check_pressed(vk_down))
    {
        if (image_index != 3)
        {
            image_index += 1;
        }
        else
        {
            image_index = 0;
        }

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // =====================================================
    // ARRIBA
    // =====================================================

    if (keyboard_check_pressed(vk_up))
    {
        if (image_index != 0)
        {
            image_index -= 1;
        }
        else
        {
            image_index = 3;
        }

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // =====================================================
    // CONFIRMAR
    // =====================================================

    var key_confirm =
        keyboard_check_pressed(ord("Z"))
        ||
        keyboard_check_pressed(vk_enter);


    if (key_confirm)
    {
        // =================================================
        // NUEVO JUEGO
        // =================================================

        if (image_index == 0)
        {
            // save.ini NO se borra.

            audio_play_sound(
                snd_shineselect,
                10,
                false
            );


            instance_create_depth(
                0,
                0,
                -9999,
                obj_new_game_transition
            );
        }


        // =================================================
        // CONTINUAR
        // =================================================

        else if (image_index == 1)
        {
            // ESTE FUNCIONAMIENTO QUEDA EXACTAMENTE
            // COMO ESTABA.

            audio_play_sound(
                snd_menumove,
                10,
                false
            );


            instance_create_depth(
                0,
                0,
                -9999,
                obj_save_menu
            );
        }


        // =================================================
        // SALIR
        // =================================================

        else if (image_index == 2)
        {
            game_end();
        }


        // =================================================
        // IDIOMA
        // =================================================

        else if (image_index == 3)
        {
            var _seleccion =
                floor(image_index);


            scr_language_toggle();


            sprite_index =
                scr_language_is_english()
                ?
                spr_buttons_continue_english
                :
                _sprite_spanish;


            image_index =
                _seleccion;


            image_speed =
                0;


            audio_play_sound(
                snd_menumove,
                10,
                false
            );
        }
    }
}