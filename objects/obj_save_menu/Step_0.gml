// Bloquear teclas C y Ctrl para evitar abrir el menú de pausa
keyboard_clear(ord("C"));
keyboard_clear(vk_control);

if (state == 0) {
    // --- NAVEGAR POR ACCIONES ---
    var min_idx = from_title ? 1 : 0;
    
    if (keyboard_check_pressed(vk_down)) { 
        action_index++;
        if (action_index > 2) { action_index = min_idx; }
        audio_play_sound(snd_menumove, 10, false);
    }
    
    if (keyboard_check_pressed(vk_up)) { 
        action_index--;
        if (action_index < min_idx) { action_index = 2; }
        audio_play_sound(snd_menumove, 10, false);
    }
    
    // Seleccionar acción
    if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
        audio_play_sound(snd_menumove, 10, false);
        state = 1;
    }
    
    // Salir del menú
    if (keyboard_check_pressed(ord("X"))) {
        audio_play_sound(snd_menumove, 10, false);
        instance_destroy();
    }
} 
else if (state == 1) {
    // --- NAVEGAR POR ARCHIVOS ---
    if (keyboard_check_pressed(vk_down)) { 
        slot_index = (slot_index + 1) % 3; 
        audio_play_sound(snd_menumove, 10, false);
    }
    if (keyboard_check_pressed(vk_up)) { 
        slot_index = (slot_index - 1 + 3) % 3; 
        audio_play_sound(snd_menumove, 10, false);
    }
    
    // Volver a las acciones
    if (keyboard_check_pressed(ord("X"))) {
        audio_play_sound(snd_menumove, 10, false);
        state = 0;
    }
    
    // Ejecutar acción
    if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
        var _accion = action_options[action_index];
        var _seccion_actual = "Save" + string(slot_index + 1); 
        
        if (_accion == "Salvar") {
            if (instance_exists(obj_player)) {
                audio_play_sound(snd_save, 10, false);
                scr_guardar_juego(_seccion_actual);
                slots_data[slot_index].lugar = get_room_name(room);
                slots_data[slot_index].tiempo = scr_format_playtime(global.playtime_frames);
                instance_destroy(); 
            }
        } 
        else if (_accion == "Cargar") {
            if (scr_cargar_juego(_seccion_actual)) {
                // REPRODUCIR SONIDO AL CARGAR EXITOSAMENTE
                audio_play_sound(snd_shineselect, 10, false);
                
                ini_open("save.ini");
                var _rm = ini_read_real(_seccion_actual, "room", global.rm1);
                var _px = ini_read_real(_seccion_actual, "x", 668);
                var _py = ini_read_real(_seccion_actual, "y", 194);
                ini_close();
                
                global.new_game = false;
                room_goto(_rm);
                
                if (!instance_exists(obj_player)) {
                    instance_create_layer(_px, _py, "Player", obj_player);
                } else {
                    obj_player.x = _px;
                    obj_player.y = _py;
                }
                
                instance_destroy();
            }
        }
        else if (_accion == "Borrar") {
            audio_play_sound(snd_trashsave, 10, false);
            ini_open("save.ini");
            ini_section_delete(_seccion_actual);
            ini_close();
            
            slots_data[slot_index].lugar = scr_loc_src("Datos vacios");
            slots_data[slot_index].tiempo = "--:--:--";
        }
    }
}
