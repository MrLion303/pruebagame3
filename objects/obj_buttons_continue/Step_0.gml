// 1. Efecto de Fade In al aparecer
if (image_alpha < 1) {
    image_alpha += 0.05;
    if (image_alpha > 1) { image_alpha = 1; }
}

// Bloqueamos TODA la interacción con el título si el menú de guardado está abierto
if (!instance_exists(obj_save_menu)) {
    
    // --- NAVEGACIÓN Y SONIDO (0: Nuevo, 1: Continuar, 2: Salir, 3: English) ---
    // Tecla Abajo (Baja visualmente de opción, aumenta el frame)
    if (keyboard_check_pressed(vk_down)) {
        if (image_index != 3) {
            image_index += 1;
        } else {
            image_index = 0;
        }
        audio_play_sound(snd_menumove, 10, false);
    }
    
    // Tecla Arriba (Sube visualmente de opción, disminuye el frame)
    if (keyboard_check_pressed(vk_up)) {
        if (image_index != 0) {
            image_index -= 1;
        } else {
            image_index = 3;
        }
        audio_play_sound(snd_menumove, 10, false);
    }

    // 2. Selección de Opciones
    var key_confirm = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);

    if (key_confirm) {
        // Frame 0: NUEVO JUEGO
        if (image_index == 0) {
            if (file_exists("prueba.ini")) {
                file_delete("prueba.ini");
            }
            
            // Iniciar el reloj de juego a 0
            scr_init_playtime();
            
            global.start_room = pasillo_school;
            global.start_x = 668;
            global.start_y = 194;
            global.new_game = true;
            
            room_goto(global.start_room);
            instance_create_layer(global.start_x, global.start_y, "Player", obj_player);
        }
        // Frame 1: CONTINUAR
        else if (image_index == 1) {
            // Abrimos nuestra nueva interfaz de guardado y suena al abrir
            audio_play_sound(snd_menumove, 10, false);
            instance_create_depth(0, 0, -9999, obj_save_menu);
        }
        // Frame 2: SALIR
        else if (image_index == 2) {
            game_end();
        }
        // Frame 3: ENGLISH
        else if (image_index == 3) {
            // Código futuro
        }
    }
}