var _ultimo_frame = sprite_get_number(sprite_index) - 1;

if (image_speed > 0 && !fase_salida && image_index >= _ultimo_frame) {
    fase_salida = true;
    
    // Forzamos la destrucción de la UI y el controlador por si seguían vivos
    if (instance_exists(obj_batalla_ui)) instance_destroy(obj_batalla_ui);
    if (instance_exists(obj_batalla_controller)) instance_destroy(obj_batalla_controller);
    
    // Al cubrir la pantalla por completo en 'bbs', regresamos a la room guardada
    if (variable_global_exists("return_room")) {
        room_goto(global.return_room);
    } else {
        room_goto(pasillo_school);
    }
    
    // Invertimos la animación y la mandamos al último frame para que haga el fade out (abrirse) en la nueva room
    image_speed = -0.5;
    image_index = _ultimo_frame;
}