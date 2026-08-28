// =========================================================
// OBJ_BUTTONS
// EVENTO: STEP
// =========================================================


// =========================================================
// FADE IN
// =========================================================

// El obj_title crea esta instancia con:
//
// image_alpha = 0;
//
// Aquí hacemos que aparezca progresivamente.

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
    // 1 = SALIR
    // 2 = ENGLISH / ESPAÑOL
    // =====================================================


    // -----------------------------------------------------
    // ABAJO
    // -----------------------------------------------------

    if (keyboard_check_pressed(vk_down)) {

        if (image_index != 2) {

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

            image_index = 2;

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


            // Reiniciar contador de tiempo
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
        // SALIR
        // =================================================

        else if (image_index == 1) {

            game_end();

        }


        // =================================================
        // FRAME 2
        // CAMBIAR IDIOMA
        // =================================================

        else if (image_index == 2) {


            // ---------------------------------------------
            // CAMBIAR Y GUARDAR IDIOMA
            // ---------------------------------------------

            scr_language_toggle();


            // Sonido de selección
            audio_play_sound(
                snd_menumove,
                10,
                false
            );


            // ---------------------------------------------
            // REINICIAR EL JUEGO COMPLETO
            // ---------------------------------------------
            //
            // NO cambiamos sprite_index aquí.
            //
            // El juego vuelve a iniciar y obj_title
            // crea DIRECTAMENTE el sprite correspondiente
            // al nuevo idioma.
            //
            // Esto evita completamente que el sprite
            // anterior quede dibujado debajo.
            // ---------------------------------------------

            game_restart();

            exit;

        }

    }

}