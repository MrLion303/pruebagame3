if (image_speed > 0 && !fase_salida) {
    fase_salida = true;
    room_goto(bbs);
    image_speed = -0.5; 
    image_index = sprite_get_number(sprite_index) - 1;  
}   
else if (image_speed < 0) {
    // Al terminar la transición de vuelta, verificamos que suelte las teclas para liberar al jugador
    instance_destroy();
}