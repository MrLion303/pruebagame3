// Comprobamos si el jugador presiona Z o Enter
if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
    
    // Distancia reducida a 8 para una interacción más cercana
    if (distance_to_object(obj_player) < 8) {
        
        // Evitamos crear múltiples menús si ya hay uno abierto
        if (!instance_exists(obj_save_menu)) {
            
            // Condicionamos a que el menú de pausa esté completamente cerrado
            if (instance_exists(obj_menu_manager) && obj_menu_manager.state == MENU_STATE.CLOSED) {
                
                // Creamos el menú de guardado
                instance_create_depth(0, 0, -9999, obj_save_menu);
                
                // Sonido de apertura del menú
                audio_play_sound(snd_menumove, 10, false); 
            }
        }
    }
}