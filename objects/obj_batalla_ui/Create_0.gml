opcion_seleccionada = 0;
opciones = [spr_bbs_fight, spr_bbs_item, spr_bbs_toy, spr_bbs_huir];
en_menu_fight = false;
en_seleccion_enemigo = false;
enemigo_seleccionado_idx = 0;
opcion_fight_seleccionada = 0;
en_modo_info = false;

// VARIABLES DE INVENTARIO EN BATALLA
en_menu_inventario = false;
inv_x = 0;
inv_y = 0;
inv_scroll = 0;
en_item_resultado = false;

// VARIABLES DE FADE OUT DE SALIDA Y VICTORIA
fade_salida_activa = false;
alpha_salida = 1.0;
en_dialogo_victoria_final = false;

ui_x_caja_izq = 30;
ui_y_caja_izq = 640;
ui_x_caja_der = 420;
ui_y_caja_der = 640;

// =========================================================
// OBTENER DATOS DE ENEMIGOS Y PAUSAR MÚSICA ANTERIOR
// =========================================================
audio_pause_all();

if (!variable_global_exists("enemigo_actual_id")) {
    global.enemigo_actual_id = "variante 1";
}

var _datos_variante = scr_enemigos_data(global.enemigo_actual_id);
enemigos = _datos_variante.enemigos;
musica_batalla_actual = _datos_variante.musica;

if (instance_exists(obj_batalla_controller) && variable_instance_exists(obj_batalla_controller, "enemigos")) {
    if (is_array(obj_batalla_controller.enemigos) && array_length(obj_batalla_controller.enemigos) > 0) {
        enemigos = obj_batalla_controller.enemigos;
    } else {
        obj_batalla_controller.enemigos = enemigos;
    }
}

// Reproducir música de batalla
if (audio_exists(musica_batalla_actual)) {
    if (!audio_is_playing(musica_batalla_actual)) {
        audio_play_sound(musica_batalla_actual, 10, true);
    } else {
        audio_resume_sound(musica_batalla_actual);
    }
}

texto_inicio_batalla = (array_length(enemigos) > 0) ? enemigos[0].texto_inicio : "Un combate comienza!";
text_to_draw = texto_inicio_batalla;
text_to_draw = string_replace_all(text_to_draw, "\n", " ");
text_to_draw = string_replace_all(text_to_draw, "\r", " ");
text_length = string_length(text_to_draw);
draw_char = 0;
text_spd = 1;
setup = false;

text_sound_timer = 0;
text_sound_delay = 2;
line_break_num = 0;