// Tiempo total necesario para cerrar (5 segundos)
hold_time_max = 5 * game_get_speed(gamespeed_fps); 
hold_timer = 0;

// Variables de dibujo y texto
close_alpha = 0;
close_text = "";

// Si ya existe otro controlador de juego previo, destruye este duplicado
if (instance_number(object_index) > 1) {
    instance_destroy();
}