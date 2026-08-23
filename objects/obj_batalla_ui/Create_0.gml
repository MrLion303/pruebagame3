// =========================================================
// EVENTO: CREAR
// =========================================================
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

// =========================================================
// INVENTARIO DE TOYS EN BATALLA
// =========================================================
en_menu_toys = false;
toy_x = 0;
toy_y = 0;
toy_scroll = 0;
toy_selected_slot = -1;
toy_selected_key = -1;

if (!variable_global_exists("toy_db")) {
    scr_toys_data();
}

if (!variable_global_exists("toy_inventory")) {
    global.toy_inventory = array_create(30, -1);
    global.toy_inventory[0] = "brillitos";
}

// VARIABLES DE FADE OUT DE SALIDA Y VICTORIA
fade_salida_activa = false;
alpha_salida = 1.0;
en_dialogo_victoria_final = false;
victoria_etapa = 0;
victoria_xp = 0;
victoria_nivel_antes = 1;
victoria_sonido_nivel_reproducido = false;

ui_x_caja_izq = 30;
ui_y_caja_izq = 640;
ui_x_caja_der = 420;
ui_y_caja_der = 640;

// =========================================================
// CONTROL DE CABEZA DEL PROTAGONISTA
// =========================================================
head_sprite = noone;
head_visible = false;

// =========================================================
// MÉTODO GLOBAL DE INSTANCIA PARA PROCESAR DIÁLOGOS
// =========================================================
f_procesar_dialogo = function(_entrada) {
    head_sprite = noone;
    head_visible = false;
    text_sound_custom = snd_text;

    if (is_struct(_entrada)) {
        var _txt = variable_struct_exists(_entrada, "texto") ? _entrada.texto : "";
        text_to_draw = is_string(_txt) ? _txt : string(_txt);
        
        if (variable_struct_exists(_entrada, "head")) {
            if (_entrada.head != noone && sprite_exists(_entrada.head)) {
                head_sprite = _entrada.head;
                head_visible = true;
            }
        }
        
        if (variable_struct_exists(_entrada, "snd")) {
            text_sound_custom = _entrada.snd;
        }
    } else {
        text_to_draw = string(_entrada);
        head_sprite = noone;
        head_visible = false;
    }
    
    if (string_length(text_to_draw) <= 0) {
        head_sprite = noone;
        head_visible = false;
    }
    
    text_to_draw = string_replace_all(text_to_draw, "\n", " ");
    text_to_draw = string_replace_all(text_to_draw, "\r", " ");
    
    text_length = string_length(text_to_draw);
    draw_char = 0;
    setup = false;
};

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

if (audio_exists(musica_batalla_actual)) {
    if (!audio_is_playing(musica_batalla_actual)) {
        audio_play_sound(musica_batalla_actual, 10, true);
    } else {
        audio_resume_sound(musica_batalla_actual);
    }
}

head_sprite = noone;
head_visible = false;
text_sound_custom = snd_text;

var _raw_inicio = (array_length(enemigos) > 0 && variable_struct_exists(enemigos[0], "texto_inicio")) ? enemigos[0].texto_inicio : "¡Un combate comienza!";

f_procesar_dialogo(_raw_inicio);
texto_inicio_batalla = text_to_draw; 

text_spd = 1;
text_sound_timer = 0;
text_sound_delay = 2;
line_break_num = 0;