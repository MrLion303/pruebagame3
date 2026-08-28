// =========================================================
// OBJ_BUTTONS_CONTINUE
// EVENTO: STEP
// =========================================================


// =========================================================
// FADE IN
// =========================================================

if (image_alpha < 1) {

    image_alpha += 0.05;

    if (image_alpha > 1) {

        image_alpha = 1;

    }

}


// =========================================================
// BLOQUEAR INTERACCIÓN SI EL MENÚ DE GUARDADO ESTÁ ABIERTO
// =========================================================

if (!instance_exists(obj_save_menu)) {


    // =====================================================
    // NAVEGACIÓN
    //
    // 0 = NUEVO JUEGO
    // 1 = CONTINUAR
    // 2 = SALIR
    // 3 = ENGLISH / ESPAÑOL
    // =====================================================


    // -----------------------------------------------------
    // ABAJO
    // -----------------------------------------------------

    if (keyboard_check_pressed(vk_down)) {

        if (image_index != 3) {

            image_index += 1;

        }
        else {

            image_index = 0;

        }

        audio_play_sound(
            snd_menumove,
            10,
            false
        );

    }


    // -----------------------------------------------------
    // ARRIBA
    // -----------------------------------------------------

    if (keyboard_check_pressed(vk_up)) {

        if (image_index != 0) {

            image_index -= 1;

        }
        else {

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
        keyboard_check_pressed(ord("Z")) ||
        keyboard_check_pressed(vk_enter);


    if (key_confirm) {


        // =================================================
        // FRAME 0
        // NUEVO JUEGO
        // =================================================

        if (image_index == 0) {

            if (file_exists("save.ini")) {

                file_delete("save.ini");

            }


            scr_init_playtime();


            global.start_room = pasillo_school;

            global.start_x = 668;
            global.start_y = 194;

            global.new_game = true;


            room_goto(
                global.start_room
            );


            instance_create_layer(
                global.start_x,
                global.start_y,
                "Player",
                obj_player
            );

        }


        // =================================================
        // FRAME 1
        // CONTINUAR
        // =================================================

        else if (image_index == 1) {

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
        // FRAME 2
        // SALIR
        // =================================================

        else if (image_index == 2) {

            game_end();

        }


        // =================================================
        // FRAME 3
        // CAMBIAR IDIOMA
        // =================================================

        else if (image_index == 3) {


            // ---------------------------------------------
            // CAMBIAR Y GUARDAR EL IDIOMA
            // ---------------------------------------------

            scr_language_toggle();


            audio_play_sound(
                snd_menumove,
                10,
                false
            );


            // ---------------------------------------------
            // REINICIAR TODO EL JUEGO
            // ---------------------------------------------
            //
            // Al volver a arrancar:
            //
            // obj_title
            //      ↓
            // scr_loc_init()
            //      ↓
            // lee el nuevo idioma
            //      ↓
            // crea DIRECTAMENTE
            // spr_buttons_continue_english
            // o el sprite español original.
            //
            // Por eso nunca existen visualmente ambos.
            // ---------------------------------------------

            game_restart();

            exit;

        }

    }

}