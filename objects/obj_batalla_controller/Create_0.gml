// =========================================================
// EVENTO: CREAR
// =========================================================
enum FASE_BATALLA {
    INICIO,
    JUGADOR_MENU,
    JUGADOR_ACCION,
    ENEMIGO_TURNO,
    ENEMIGO_ATACANDO,
    CINEMATICA,
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

// Música base definida por la batalla.
// musica_batalla_actual puede convertirse después en un ID de instancia
// si una cinemática interna cambia la canción.
musica_batalla_asset_base = _datos_variante.musica;
musica_batalla_actual = _datos_variante.musica;

dialogos_turno_actual = _datos_variante.dialogos_turno;

experiencia_batalla =
    variable_struct_exists(_datos_variante, "experiencia")
    ? max(0, round(_datos_variante.experiencia))
    : 0;

suenos_batalla =
    variable_struct_exists(_datos_variante, "suenos")
    ? max(0, round(_datos_variante.suenos))
    : 0;

fondo_batalla =
    variable_struct_exists(_datos_variante, "fondo")
    ? _datos_variante.fondo
    : noone;

cinematicas =
    variable_struct_exists(_datos_variante, "cinematicas")
    ? _datos_variante.cinematicas
    : [];
 
show_debug_message("[CINEMATICAS] enemigo_actual_id=" + string(global.enemigo_actual_id) + " -> cinematicas cargadas: " + string(array_length(cinematicas)));
 
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
 
// VARIABLES CONTROL CINEMÁTICA
cinematica_activa = false;
cinematica_dialogos = [];
cinematica_idx = 0;
cinematica_terminar_batalla = false;
fase_pre_cinematica = FASE_BATALLA.INICIO; 
 
// MÉTODO PARA VERIFICAR SI ALGUNA CINEMÁTICA DEBE ACTIVARSE
f_verificar_cinematicas = function() {
    if (array_length(cinematicas) <= 0) return false;
    
    for (var i = 0; i < array_length(cinematicas); i++) {
        var _cin = cinematicas[i];
        
        if (!variable_struct_exists(_cin, "activada") || !_cin.activada) {
            var _en_idx = _cin.enemigo;
            if (_en_idx >= 0 && _en_idx < array_length(enemigos)) {
                var _en = enemigos[_en_idx];
                var _pct_hp = _en.vida_actual / _en.vida_max;
                
                if (_pct_hp <= _cin.porcentaje_vida && _en.vida_actual > 0) {
                    _cin.activada = true;
                    cinematicas[i] = _cin;
                    
                    show_debug_message("[CINEMATICAS] Activando '" + string(_cin.id) + "' -> enemigo " + string(_en_idx) + " a " + string(round(_pct_hp * 100)) + "% de vida");
                    
                    var _dialogos = scr_bosses_cinematica_bbs(_cin.id);
                    if (array_length(_dialogos) > 0) {
                        cinematica_activa = true;
                        cinematica_dialogos = _dialogos;
                        cinematica_idx = 0;
                        cinematica_terminar_batalla = _cin.terminar_batalla;
                        
                        fase_pre_cinematica = fase_actual; 
                        fase_actual = FASE_BATALLA.CINEMATICA;
                        
                        if (instance_exists(obj_batalla_ui)) {
                            obj_batalla_ui.en_resultado_ataque = false; 
                            obj_batalla_ui.en_menu_fight = false;
                            obj_batalla_ui.en_seleccion_enemigo = false;
                            if (variable_instance_exists(obj_batalla_ui, "en_menu_act")) obj_batalla_ui.en_menu_act = false;
                            if (variable_instance_exists(obj_batalla_ui, "en_menu_item")) obj_batalla_ui.en_menu_item = false;
                            if (variable_instance_exists(obj_batalla_ui, "en_menu_mercy")) obj_batalla_ui.en_menu_mercy = false;
                            
                            // Enviamos el primer diálogo
                            obj_batalla_ui.f_procesar_dialogo(cinematica_dialogos[0]);
                            
                            // FORZAMOS EL REINICIO DE LA MÁQUINA DE ESCRIBIR
                            obj_batalla_ui.draw_char = 0;
                            obj_batalla_ui.setup = false; 
                        }
                        return true;
                    }
                }
            }
        }
    }
    return false;
};

// =========================================================
// DUCKING DE MÚSICA CUANDO SUENA CUALQUIER snd_
// =========================================================
//
// 0.86 = la música baja un poco mientras suena un SFX.
// Puedes acercarlo a 1.0 si lo quieres todavía más sutil.
// =========================================================

duck_music_gain = 0.86;
duck_snd_assets = [];

var _audio_assets = asset_get_ids(asset_sound);

for (var _a = 0; _a < array_length(_audio_assets); _a++)
{
    var _asset_audio = _audio_assets[_a];
    var _audio_name = audio_get_name(_asset_audio);

    if (string_copy(_audio_name, 1, 4) == "snd_")
    {
        array_push(
            duck_snd_assets,
            _asset_audio
        );
    }
}
