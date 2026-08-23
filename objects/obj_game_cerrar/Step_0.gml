// Si se mantiene presionada la tecla ESC
if (keyboard_check(vk_escape)) {
    hold_timer++;
    
    // Si llega a los 5 segundos, cerrar el juego
    if (hold_timer >= hold_time_max) {
        game_end();
    }
} else {
    // Si se suelta la tecla, reiniciamos el contador
    hold_timer = 0;
}

// Opacidad progresiva (Fade in) de 0 a 1 basada en el tiempo sostenido
close_alpha = hold_timer / hold_time_max;

// Lógica de los puntos suspensivos basada en los segundos transcurridos
var _current_seconds = hold_timer / game_get_speed(gamespeed_fps);

if (_current_seconds >= 4) {
    close_text = "Cerrando...";
} else if (_current_seconds >= 3) {
    close_text = "Cerrando..";
} else if (_current_seconds >= 2) {
    close_text = "Cerrando.";
} else {
    close_text = "Cerrando";
}