enum FASE_BATALLA {
    INICIO,
    JUGADOR_MENU,
    JUGADOR_ACCION,
    ENEMIGO_TURNO,
    ENEMIGO_ATACANDO,
    VICTORIA,
    DERROTA,
    HUIR
}

fase_actual = FASE_BATALLA.INICIO;

if (!variable_global_exists("enemigo_actual_id")) {
    global.enemigo_actual_id = "variante 1";
}

var _datos_variante = scr_enemigos_data(global.enemigo_actual_id);
enemigos = _datos_variante.enemigos;
musica_batalla_actual = _datos_variante.musica;

// Inicializamos el registro de enemigos muertos con nuestro nuevo script
mapa_enemigos_muertos = scr_inicializar_muertes_enemigos(enemigos);

if (audio_exists(musica_batalla_actual)) {
    var _snd_batalla = audio_play_sound(musica_batalla_actual, 10, true);
    audio_resume_sound(_snd_batalla);
}

// Variables de control para el turno de los enemigos
turno_enemigo_idx = 0;
temporizador_turno_enemigo = 0;
esperando_input_texto_enemigo = false;