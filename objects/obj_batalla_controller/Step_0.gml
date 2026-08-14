// =========================================================
// EVENTO: STEP
// =========================================================
var _accept_key = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);

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
        
        var _dano_enemigo = variable_struct_exists(_en_actual, "ataque") ? (_en_actual.ataque + irandom_range(0, 3)) : irandom_range(5, 12);
        
        if (instance_exists(obj_player)) {
            obj_player.hp = max(0, obj_player.hp - _dano_enemigo);
        }
        
        if (audio_is_playing(snd_atacado)) {
            audio_stop_sound(snd_atacado);
        }
        audio_play_sound(snd_atacado, 10, false);
        
        if (instance_exists(obj_batalla_ui)) {
            obj_batalla_ui.en_resultado_ataque = true;
            obj_batalla_ui.f_procesar_dialogo("* " + _en_actual.nombre + " ataca y te causa " + string(_dano_enemigo) + " de daño!");
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
        
    case FASE_BATALLA.VICTORIA:
    case FASE_BATALLA.HUIR:
        if (variable_instance_exists(id, "mapa_enemigos_muertos") && ds_exists(mapa_enemigos_muertos, ds_type_map)) {
            ds_map_destroy(mapa_enemigos_muertos);
        }
        
        if (audio_is_playing(snd_bbs_start)) {
            audio_stop_sound(snd_bbs_start);
        }
        if (variable_instance_exists(id, "musica_batalla_actual") && audio_exists(musica_batalla_actual)) {
            if (audio_is_playing(musica_batalla_actual)) {
                audio_stop_sound(musica_batalla_actual);
            }
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