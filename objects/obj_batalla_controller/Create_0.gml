// =========================================================
// EVENTO: CREAR
// =========================================================
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
dialogos_turno_actual = _datos_variante.dialogos_turno;
experiencia_batalla = variable_struct_exists(_datos_variante, "experiencia") ? _datos_variante.experiencia : 0;

// SISTEMA DE PROBABILIDAD DE ESCAPE
probabilidad_escapar = variable_struct_exists(_datos_variante, "probabilidad_escapar") ? _datos_variante.probabilidad_escapar : 0.5;
exito_escape_turno = (random(1.0) < probabilidad_escapar);

victoria_finalizada = false;

primer_turno_pasado = false;
mapa_enemigos_muertos = scr_inicializar_muertes_enemigos(enemigos);

if (audio_exists(musica_batalla_actual)) {
    var _snd_batalla = audio_play_sound(musica_batalla_actual, 10, true);
    audio_resume_sound(_snd_batalla);
}

turno_enemigo_idx = 0;
temporizador_turno_enemigo = 0;
esperando_input_texto_enemigo = false;