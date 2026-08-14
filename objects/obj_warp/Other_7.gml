// --- LIMPIEZA DE ENEMIGOS DESTRUIDOS (SOLO EN CAMBIOS DE MAPA REALES) ---
if (!variable_global_exists("viajando_a_batalla") || !global.viajando_a_batalla) {
    // Si cambiamos a una habitación normal (no batalla), reiniciamos el struct de enemigos destruidos
    // asignándole una estructura vacía para que todos los enemigos vuelvan a nacer en los mapas.
    global.enemigos_destruidos = {};
} else {
    // Si veníamos de la batalla, apagamos el indicador temporalmente para el próximo viaje
    global.viajando_a_batalla = false;
}

// --- CAMBIO DE HABITACIÓN Y POSICIÓN DEL JUGADOR ---
room_goto(target_rm);

obj_player.x = target_x;
obj_player.y = target_y;
obj_player.face = target_face;

// --- GESTIÓN DE MÚSICA ---
if (!keep_music) 
{
    audio_stop_all();

    if (target_music != -1)
    {
        var _new_audio = audio_play_sound(target_music, 1, true);
        audio_sound_gain(_new_audio, 0, 0); 
        audio_sound_gain(_new_audio, 1, 1000); 
    }
}

image_speed = -1;