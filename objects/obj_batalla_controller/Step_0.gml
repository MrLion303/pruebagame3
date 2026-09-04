if (
    variable_global_exists("gameover_death_freeze_active")
    &&
    global.gameover_death_freeze_active
)
{
    exit;
}


// =========================================================
// EVENTO: STEP  (obj_batalla_controller)
// =========================================================
// =========================================================
// DUCKING DE MÚSICA DE BATALLA
// =========================================================

var _hay_snd_sonando = false;

for (var _duck_i = 0; _duck_i < array_length(duck_snd_assets); _duck_i++)
{
    if (audio_is_playing(duck_snd_assets[_duck_i]))
    {
        _hay_snd_sonando = true;
        break;
    }
}

var _ganancia_musica =
    _hay_snd_sonando
    ? duck_music_gain
    : 1.0;

if (
    musica_batalla_actual != noone
    &&
    audio_is_playing(musica_batalla_actual)
)
{
    audio_sound_gain(
        musica_batalla_actual,
        _ganancia_musica,
        0
    );
}


var _accept_key = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);

// VERIFICAR CINEMÁTICAS (EXCEPTO SI YA ESTAMOS EN UNA O HUYENDO/VICTORIA)
if (fase_actual != FASE_BATALLA.CINEMATICA && fase_actual != FASE_BATALLA.HUIR && fase_actual != FASE_BATALLA.VICTORIA) {
    var _ui_ocupada = false;
    
    if (instance_exists(obj_batalla_ui)) {
        var _leyendo_resultado = variable_instance_exists(obj_batalla_ui, "en_resultado_ataque") ? obj_batalla_ui.en_resultado_ataque : false;
        var _leyendo_victoria = variable_instance_exists(obj_batalla_ui, "en_dialogo_victoria_final") ? obj_batalla_ui.en_dialogo_victoria_final : false;
        
        if (_leyendo_resultado || _leyendo_victoria) {
            _ui_ocupada = true;
        }
    }
    
    if (!_ui_ocupada) {
        if (f_verificar_cinematicas()) {
            exit;
        }
    }
}

if (!variable_instance_exists(id, "_debug_fase_anterior")) {
    _debug_fase_anterior = fase_actual;
}
if (_debug_fase_anterior != fase_actual) {
    show_debug_message("[FASE] cambio de " + string(_debug_fase_anterior) + " -> " + string(fase_actual));
    _debug_fase_anterior = fase_actual;
}

switch (fase_actual) {
    case FASE_BATALLA.INICIO:
        if (audio_exists(snd_bbs_start) && !audio_is_playing(snd_bbs_start)) {
            audio_play_sound(snd_bbs_start, 15, false);
        }
        
        if (!instance_exists(obj_batalla_ui)) {
            instance_create_layer(x, y, layer, obj_batalla_ui);
        }
        fase_actual = FASE_BATALLA.JUGADOR_MENU;
        break;
        
    case FASE_BATALLA.JUGADOR_MENU:
        if (instance_exists(obj_batalla_ui) && obj_batalla_ui.enemigos != enemigos) {
            obj_batalla_ui.enemigos = enemigos;
        }

        for (var i = 0; i < array_length(enemigos); i++) {
            if (enemigos[i].vida_actual <= 0) {
                scr_marcar_enemigo_muerto(mapa_enemigos_muertos, i);
                enemigos[i].derrotado = true;
            }
        }
        break;
        
    case FASE_BATALLA.ENEMIGO_TURNO:
        var _total_en = array_length(enemigos);
        var _en_actual = noone;
        
        while (turno_enemigo_idx < _total_en) {
            if (enemigos[turno_enemigo_idx].vida_actual <= 0) {
                scr_marcar_enemigo_muerto(mapa_enemigos_muertos, turno_enemigo_idx);
                enemigos[turno_enemigo_idx].derrotado = true;
            }
            
            var _esta_muerto = scr_esta_enemigo_muerto(mapa_enemigos_muertos, turno_enemigo_idx);
            
            if (_esta_muerto) {
                turno_enemigo_idx++;
            } else {
                _en_actual = enemigos[turno_enemigo_idx];
                break;
            }
        }
        
        if (turno_enemigo_idx >= _total_en || _en_actual == noone) {
            turno_enemigo_idx = 0;
            fase_actual = FASE_BATALLA.JUGADOR_MENU;
            
            primer_turno_pasado = true;
            exito_escape_turno = (random(1.0) < probabilidad_escapar);
            
            var _texto_a_usar = "";
            if (primer_turno_pasado && array_length(dialogos_turno_actual) > 0) {
                var _indice_azar = irandom(array_length(dialogos_turno_actual) - 1);
                _texto_a_usar = dialogos_turno_actual[_indice_azar];
            } else {
                _texto_a_usar = obj_batalla_ui.texto_inicio_batalla;
            }
            
            if (instance_exists(obj_batalla_ui)) {
                obj_batalla_ui.en_resultado_ataque = false;
                obj_batalla_ui.f_procesar_dialogo(_texto_a_usar);
            }
            break;
        }

        if (!variable_struct_exists(_en_actual, "turnos_stun")) _en_actual.turnos_stun = 0;

        if (_en_actual.turnos_stun > 0) {
            _en_actual.turnos_stun--;

            if (instance_exists(obj_batalla_ui)) {
                obj_batalla_ui.en_resultado_ataque = true;
                obj_batalla_ui.f_procesar_dialogo(scr_locf("* {enemy} está aturdido y no puede atacar!", { enemy: scr_loc(_en_actual.nombre) }));
            }

            fase_actual = FASE_BATALLA.ENEMIGO_ATACANDO;
            break;
        }

        var _ataque_base_enemigo = variable_struct_exists(_en_actual, "ataque") ? _en_actual.ataque : irandom_range(5, 12);
        var _reduccion_ataque = variable_struct_exists(_en_actual, "ataque_reducido") ? _en_actual.ataque_reducido : 0;
        var _multiplicador_ataque = max(0, 1 - (_reduccion_ataque * 0.08));
        var _ataque_real = max(0, round(_ataque_base_enemigo * _multiplicador_ataque));
        var _dano_enemigo = max(0, _ataque_real + irandom_range(0, 3));

        if (instance_exists(obj_player)) obj_player.hp = max(0, obj_player.hp - _dano_enemigo);

        if (audio_is_playing(snd_atacado)) audio_stop_sound(snd_atacado);
        audio_play_sound(snd_atacado, 10, false);

        if (instance_exists(obj_batalla_ui)) {
            obj_batalla_ui.en_resultado_ataque = true;
            obj_batalla_ui.f_procesar_dialogo(scr_locf("* {enemy} ataca y te causa {damage} de daño!", { enemy: scr_loc(_en_actual.nombre), damage: string(_dano_enemigo) }));
        }

        fase_actual = FASE_BATALLA.ENEMIGO_ATACANDO;
        break;
        
    case FASE_BATALLA.ENEMIGO_ATACANDO:
        if (instance_exists(obj_batalla_ui)) {
            if (obj_batalla_ui.draw_char >= obj_batalla_ui.text_length) {
                if (_accept_key) {
                    turno_enemigo_idx++;
                    fase_actual = FASE_BATALLA.ENEMIGO_TURNO;
                }
            }
        }
        break;

    case FASE_BATALLA.CINEMATICA:
        keyboard_clear(ord("C"));
        keyboard_clear(vk_control);
        
        var _skip_anim_key = keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_shift);
        var _accept_key_cine = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);

        if (instance_exists(obj_batalla_ui)) {
            
            if (obj_batalla_ui.draw_char < obj_batalla_ui.text_length) {
                
                keyboard_clear(ord("Z"));
                keyboard_clear(vk_enter);
                
                var _char_previo = floor(obj_batalla_ui.draw_char);
                obj_batalla_ui.draw_char += 0.5; 
                var _char_actual = floor(obj_batalla_ui.draw_char);
                
                if (_char_actual > _char_previo) {
                    var _dialogo_struct = cinematica_dialogos[cinematica_idx];
                    var _snd_a_reproducir = snd_text; 
                    
                    if (is_struct(_dialogo_struct) && variable_struct_exists(_dialogo_struct, "snd")) {
                        if (_dialogo_struct.snd != noone) {
                            _snd_a_reproducir = _dialogo_struct.snd;
                        }
                    }
                    
                    if (audio_exists(_snd_a_reproducir)) {
                        audio_stop_sound(_snd_a_reproducir); 
                        audio_play_sound(_snd_a_reproducir, 10, false);
                    }
                }
                
                if (_skip_anim_key) {
                    obj_batalla_ui.draw_char = obj_batalla_ui.text_length;
                    keyboard_clear(ord("X"));
                    keyboard_clear(vk_shift);
                }
                
            } else {
                if (_accept_key_cine) {
                    cinematica_idx++;
                    
                    if (cinematica_idx < array_length(cinematica_dialogos)) {
                        var _dialogo_actual = cinematica_dialogos[cinematica_idx];
                        
                        obj_batalla_ui.f_procesar_dialogo(_dialogo_actual);
                        obj_batalla_ui.draw_char = 0; 
                        obj_batalla_ui.setup = false;
                        
                        // --- NUEVO: SISTEMA DE CONTROL DE MÚSICA REFINADO ---
                        if (is_struct(_dialogo_actual) && variable_struct_exists(_dialogo_actual, "music")) {
                            
                            // 1. Detenemos ESTRICTAMENTE la canción de la batalla
                            if (variable_instance_exists(id, "musica_batalla_actual") && musica_batalla_actual != noone) {
                                if (audio_is_playing(musica_batalla_actual)) {
                                    audio_stop_sound(musica_batalla_actual);
                                }
                            }
                            
                            // 2. Si hay nueva música, la ponemos y guardamos su ID de Instancia
                            if (_dialogo_actual.music != "stop" && audio_exists(_dialogo_actual.music)) {
                                // Al guardar el resultado de audio_play_sound, guardamos un ID único, no el asset
                                musica_batalla_actual = audio_play_sound(_dialogo_actual.music, 10, true); 
                            }
                        }
                        // ----------------------------------------------------
                        
                        keyboard_clear(ord("Z"));
                        keyboard_clear(vk_enter);
                        
                    } else {
                        cinematica_activa = false;
                        
                        if (cinematica_terminar_batalla) {
                            for (var _j = 0; _j < array_length(enemigos); _j++) {
                                if (!variable_struct_exists(enemigos[_j], "derrotado") || !enemigos[_j].derrotado) {
                                    enemigos[_j].vida_actual = 0;
                                    enemigos[_j].derrotado = true;
                                    scr_marcar_enemigo_muerto(mapa_enemigos_muertos, _j);
                                }
                            }

                            if (audio_exists(snd_enemy_killed)) {
                                audio_play_sound(snd_enemy_killed, 15, false);
                            }

                            if (audio_is_playing(snd_bbs_start)) audio_stop_sound(snd_bbs_start);
                            
                            if (variable_instance_exists(id, "musica_batalla_actual") && musica_batalla_actual != noone) {
                                if (audio_is_playing(musica_batalla_actual)) audio_stop_sound(musica_batalla_actual);
                            }

                            if (instance_exists(obj_batalla_ui)) {
                                obj_batalla_ui.f_iniciar_victoria();
                            }

                            fase_actual = FASE_BATALLA.VICTORIA;
                        } else {
                            fase_actual = FASE_BATALLA.JUGADOR_MENU;
                            
                            if (instance_exists(obj_batalla_ui)) {
                                obj_batalla_ui.en_resultado_ataque = false;
                                obj_batalla_ui.en_menu_fight = false;
                                obj_batalla_ui.en_seleccion_enemigo = false;
                                if (variable_instance_exists(obj_batalla_ui, "en_menu_act")) obj_batalla_ui.en_menu_act = false;
                                if (variable_instance_exists(obj_batalla_ui, "en_menu_item")) obj_batalla_ui.en_menu_item = false;
                                if (variable_instance_exists(obj_batalla_ui, "en_menu_mercy")) obj_batalla_ui.en_menu_mercy = false;
                                
                                var _txt = (array_length(dialogos_turno_actual) > 0) ? dialogos_turno_actual[irandom(array_length(dialogos_turno_actual) - 1)] : obj_batalla_ui.texto_inicio_batalla;
                                obj_batalla_ui.f_procesar_dialogo(_txt);
                            }
                        }
                    }
                }
            }
        }
        break;
        
    case FASE_BATALLA.VICTORIA:
        if (victoria_finalizada) {
            fase_actual = FASE_BATALLA.HUIR;
        }
        break;

    case FASE_BATALLA.HUIR:
        if (variable_instance_exists(id, "mapa_enemigos_muertos") && ds_exists(mapa_enemigos_muertos, ds_type_map)) {
            ds_map_destroy(mapa_enemigos_muertos);
        }
        
        if (audio_is_playing(snd_bbs_start)) audio_stop_sound(snd_bbs_start);
        if (variable_instance_exists(id, "musica_batalla_actual") && musica_batalla_actual != noone) {
            if (audio_is_playing(musica_batalla_actual)) audio_stop_sound(musica_batalla_actual);
        }
        audio_resume_all();
        
        if (!instance_exists(obj_transicion_salida_bbs)) {
            instance_create_layer(x, y, layer, obj_transicion_salida_bbs);
        } else {
            instance_destroy();
        }
        break; 
        
    case FASE_BATALLA.DERROTA:
        break;
}
