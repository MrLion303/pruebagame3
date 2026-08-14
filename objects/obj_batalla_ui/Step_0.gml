// =========================================================
// EVENTO: STEP (CORREGIDO PARA EVITAR BORRADO ERRÓNEO DE CABEZA)
// =========================================================
accept_key = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);
skip_key = keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_shift) || keyboard_check_pressed(vk_control);
var _fast_skip_key = keyboard_check(ord("C")) || keyboard_check_pressed(vk_control);

if (instance_exists(obj_batalla_controller)) {
    if (obj_batalla_controller.fase_actual == FASE_BATALLA.VICTORIA || obj_batalla_controller.fase_actual == FASE_BATALLA.HUIR) {
        fade_salida_activa = true;
    }
}

if (fade_salida_activa) {
    alpha_salida -= 0.05;
    if (alpha_salida <= 0) {
        alpha_salida = 0;
        instance_destroy();
        exit;
    }
}

if (!variable_instance_exists(id, "en_resultado_ataque")) en_resultado_ataque = false;
if (!variable_instance_exists(id, "en_dialogo_victoria_final")) en_dialogo_victoria_final = false;

for (var i = 0; i < array_length(enemigos); i++) {
    if (!variable_struct_exists(enemigos[i], "shake_timer")) enemigos[i].shake_timer = 0;
    if (enemigos[i].shake_timer > 0) enemigos[i].shake_timer--;
    
    if (variable_struct_exists(enemigos[i], "derrotado") && enemigos[i].derrotado) {
        enemigos[i].anim_index = 0;
    } else {
        if (!variable_struct_exists(enemigos[i], "anim_index")) enemigos[i].anim_index = 0;
        enemigos[i].anim_index += 0.15;
    }
}

var _todos_derrotados = true;
for (var i = 0; i < array_length(enemigos); i++) {
    if (!variable_struct_exists(enemigos[i], "derrotado") || !enemigos[i].derrotado) {
        _todos_derrotados = false;
        break;
    }
}

if (_todos_derrotados && en_dialogo_victoria_final) {
    if (draw_char < text_length) {
        var _actual_speed = _fast_skip_key ? 999 : text_spd;
        var _char_anterior = floor(draw_char);
        draw_char += _actual_speed;
        draw_char = clamp(draw_char, 0, text_length);
        if (skip_key || _fast_skip_key || accept_key) draw_char = text_length;
        
        if (!_fast_skip_key) {
            text_sound_timer++;
            if (text_sound_timer >= text_sound_delay) {
                text_sound_timer = 0;
                var _char_actual = floor(draw_char);
                if (_char_actual > _char_anterior) {
                    var _letra = string_char_at(text_to_draw, _char_actual);
                    var _es_letra = (_letra >= "a" && _letra <= "z") || (_letra >= "A" && _letra <= "Z");
                    if (_es_letra) {
                        var _snd_voz = audio_exists(text_sound_custom) ? text_sound_custom : snd_text;
                        audio_play_sound(_snd_voz, 10, false);
                    }
                }
            }
        }
    } else {
        if (accept_key) {
            if (audio_is_playing(snd_bbs_start)) {
                audio_stop_sound(snd_bbs_start);
            }
            if (variable_instance_exists(id, "musica_batalla_actual") && audio_exists(musica_batalla_actual)) {
                if (audio_is_playing(musica_batalla_actual)) {
                    audio_stop_sound(musica_batalla_actual);
                }
            }
            audio_resume_all();
            if (instance_exists(obj_batalla_controller)) obj_batalla_controller.fase_actual = FASE_BATALLA.VICTORIA;
        }
    }
    exit;
}

if (!en_resultado_ataque && !en_dialogo_victoria_final) {
    if (en_menu_inventario) {
        if (keyboard_check_pressed(vk_right)) { inv_x = (inv_x + 1) % 2; audio_play_sound(snd_menumove, 10, false); }
        if (keyboard_check_pressed(vk_left)) { inv_x = (inv_x - 1 + 2) % 2; audio_play_sound(snd_menumove, 10, false); }
        if (keyboard_check_pressed(vk_down)) {
            var _total_items = (instance_exists(obj_player) && variable_instance_exists(obj_player, "inventory")) ? array_length(obj_player.inventory) : 0;
            var _filas_totales = ceil(_total_items / 2);
            var _max_scroll = max(0, _filas_totales - 2);
            inv_y++;
            if (inv_y > 1) { inv_y = 1; if (inv_scroll < _max_scroll) inv_scroll++; }
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(vk_up)) {
            inv_y--;
            if (inv_y < 0) { inv_y = 0; if (inv_scroll > 0) inv_scroll--; }
            audio_play_sound(snd_menumove, 10, false);
        }
        if (skip_key) { en_menu_inventario = false; audio_play_sound(snd_menumove, 10, false); }
    } else if (!en_menu_fight && !en_seleccion_enemigo) {
        if (keyboard_check_pressed(vk_right)) { opcion_seleccionada++; if (opcion_seleccionada > 3) opcion_seleccionada = 0; audio_play_sound(snd_menumove, 10, false); }
        if (keyboard_check_pressed(vk_left)) { opcion_seleccionada--; if (opcion_seleccionada < 0) opcion_seleccionada = 3; audio_play_sound(snd_menumove, 10, false); }
    } else if (en_seleccion_enemigo) {
        var _total_en = array_length(enemigos);
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(vk_down)) {
            enemigo_seleccionado_idx = (enemigo_seleccionado_idx + 1) % _total_en;
            var _inicio = enemigo_seleccionado_idx;
            while (variable_struct_exists(enemigos[enemigo_seleccionado_idx], "derrotado") && enemigos[enemigo_seleccionado_idx].derrotado) {
                enemigo_seleccionado_idx = (enemigo_seleccionado_idx + 1) % _total_en;
                if (enemigo_seleccionado_idx == _inicio) break;
            }
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_up)) {
            enemigo_seleccionado_idx--;
            if (enemigo_seleccionado_idx < 0) enemigo_seleccionado_idx = _total_en - 1;
            var _inicio = enemigo_seleccionado_idx;
            while (variable_struct_exists(enemigos[enemigo_seleccionado_idx], "derrotado") && enemigos[enemigo_seleccionado_idx].derrotado) {
                enemigo_seleccionado_idx--;
                if (enemigo_seleccionado_idx < 0) enemigo_seleccionado_idx = _total_en - 1;
                if (enemigo_seleccionado_idx == _inicio) break;
            }
            audio_play_sound(snd_menumove, 10, false);
        }
    } else if (!en_modo_info) {
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(vk_down)) {
            opcion_fight_seleccionada++; if (opcion_fight_seleccionada > 1) opcion_fight_seleccionada = 0; audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_up)) {
            opcion_fight_seleccionada--; if (opcion_fight_seleccionada < 0) opcion_fight_seleccionada = 1; audio_play_sound(snd_menumove, 10, false);
        }
    }
}

if (draw_char < text_length) {
    var _actual_speed = _fast_skip_key ? 999 : text_spd;
    var _char_anterior = floor(draw_char);
    draw_char += _actual_speed;
    draw_char = clamp(draw_char, 0, text_length);
    if (skip_key || _fast_skip_key) draw_char = text_length;
    
    if (!_fast_skip_key) {
        text_sound_timer++;
        if (text_sound_timer >= text_sound_delay) {
            text_sound_timer = 0;
            var _char_actual = floor(draw_char);
            if (_char_actual > _char_anterior) {
                var _letra = string_char_at(text_to_draw, _char_actual);
                var _es_letra = (_letra >= "a" && _letra <= "z") || (_letra >= "A" && _letra <= "Z");
                if (_es_letra) {
                    var _snd_voz = audio_exists(text_sound_custom) ? text_sound_custom : snd_text;
                    audio_play_sound(_snd_voz, 10, false);
                }
            }
        }
    }
} else {
    if (accept_key) {
        // ELIMINADA la línea de limpieza manual (head_sprite = noone;) que generaba el error
		
        if (en_menu_inventario) {
            if (instance_exists(obj_player) && variable_instance_exists(obj_player, "inventory")) {
                var _inv_index = inv_x + (inv_y * 2) + (inv_scroll * 2);
                if (_inv_index < array_length(obj_player.inventory)) {
                    var _item_key = obj_player.inventory[_inv_index];
                    if (_item_key != -1 && _item_key != undefined) {
                        if (variable_global_exists("item_db") && global.item_db[$ _item_key] != undefined) {
                            var _item_data = global.item_db[$ _item_key];
                            var _es_consumible = variable_struct_exists(_item_data, "tipo") ? (_item_data.tipo == "consumible") : true;
                            if (_es_consumible) {
                                var _hp_antes = 0;
                                if (instance_exists(obj_player)) _hp_antes = obj_player.hp;
                                if (variable_struct_exists(_item_data, "efecto")) _item_data.efecto();
                                var _hp_curado = 0;
                                if (instance_exists(obj_player)) _hp_curado = obj_player.hp - _hp_antes;
                                obj_player.inventory[_inv_index] = -1;
                                
                                var _texto_item = "";
                                if (_hp_curado > 0) _texto_item = "* Consumiste " + _item_data.nombre + "! Te curaste " + string(_hp_curado) + " de vida!";
                                else if (instance_exists(obj_player) && _hp_antes >= obj_player.hp_max) _texto_item = "* Consumiste " + _item_data.nombre + ", pero ya tienes la vida llena!";
                                else _texto_item = "* Consumiste " + _item_data.nombre + "!";
                                
                                f_procesar_dialogo(_texto_item);
                                
                                en_resultado_ataque = true;
                                en_menu_inventario = false;
                                audio_play_sound(snd_menumove, 10, false);
                            }
                        }
                    }
                }
            }
        } else if (en_resultado_ataque) {
            en_resultado_ataque = false;
            
            var _chequear_todos = true;
            for (var i = 0; i < array_length(enemigos); i++) {
                if (!variable_struct_exists(enemigos[i], "derrotado") || !enemigos[i].derrotado) {
                    _chequear_todos = false;
                    break;
                }
            }
            
            if (_chequear_todos) {
                en_dialogo_victoria_final = true;
                f_procesar_dialogo("* ¡Has ganado la batalla!");
                audio_play_sound(snd_menumove, 10, false);
            } else {
                en_menu_fight = false;
                en_seleccion_enemigo = false;
                en_modo_info = false;
                opcion_seleccionada = 0;
                setup = false;
                audio_play_sound(snd_menumove, 10, false);
                
                if (instance_exists(obj_batalla_controller)) {
                    if (obj_batalla_controller.fase_actual == FASE_BATALLA.JUGADOR_MENU) {
                        obj_batalla_controller.turno_enemigo_idx = 0;
                        obj_batalla_controller.fase_actual = FASE_BATALLA.ENEMIGO_TURNO;
                    }
                }
                
                var _siguiente_origen = texto_inicio_batalla;
                
                if (instance_exists(obj_batalla_controller)) {
                    if (variable_instance_exists(obj_batalla_controller, "primer_turno_pasado") && obj_batalla_controller.primer_turno_pasado) {
                        if (variable_instance_exists(obj_batalla_controller, "dialogos_turno_actual") && array_length(obj_batalla_controller.dialogos_turno_actual) > 0) {
                            var _idx_azar = irandom(array_length(obj_batalla_controller.dialogos_turno_actual) - 1);
                            _siguiente_origen = obj_batalla_controller.dialogos_turno_actual[_idx_azar];
                        }
                    }
                }
                
                f_procesar_dialogo(_siguiente_origen);
            }
            
        } else if (!en_menu_fight && !en_seleccion_enemigo) {
            if (opcion_seleccionada == 0) {
                en_seleccion_enemigo = true;
                for (var i = 0; i < array_length(enemigos); i++) {
                    if (!variable_struct_exists(enemigos[i], "derrotado") || !enemigos[i].derrotado) {
                        enemigo_seleccionado_idx = i;
                        break;
                    }
                }
                audio_play_sound(snd_menumove, 10, false);
            } else if (opcion_seleccionada == 1) {
                en_menu_inventario = true; inv_x = 0; inv_y = 0; inv_scroll = 0; 
                audio_play_sound(snd_menumove, 10, false);
            } else if (opcion_seleccionada == 3) {
                if (audio_is_playing(snd_bbs_start)) {
                    audio_stop_sound(snd_bbs_start);
                }
                if (variable_instance_exists(id, "musica_batalla_actual") && audio_exists(musica_batalla_actual)) {
                    if (audio_is_playing(musica_batalla_actual)) {
                        audio_stop_sound(musica_batalla_actual);
                    }
                }
                audio_resume_all(); 
                audio_play_sound(snd_board_escaped, 10, false);
                if (instance_exists(obj_batalla_controller)) obj_batalla_controller.fase_actual = FASE_BATALLA.HUIR;
            }
        } else if (en_seleccion_enemigo) {
            var _en_sel = enemigos[enemigo_seleccionado_idx];
            if (variable_struct_exists(_en_sel, "derrotado") && _en_sel.derrotado) {
                if (audio_is_playing(snd_error)) audio_stop_sound(snd_error);
                audio_play_sound(snd_error, 10, false);
            } else {
                en_seleccion_enemigo = false; en_menu_fight = true; en_modo_info = false; opcion_fight_seleccionada = 0;
                audio_play_sound(snd_menumove, 10, false);
            }
        } else if (en_modo_info) {
            en_modo_info = false; en_menu_fight = false;
            f_procesar_dialogo(texto_inicio_batalla);
            audio_play_sound(snd_menumove, 10, false);
        } else {
            var _en_actual = enemigos[enemigo_seleccionado_idx];
            if (opcion_fight_seleccionada == 0) {
                var _atk_base = 0;
                if (instance_exists(obj_player)) {
                    _atk_base = obj_player.ataque_base;
                    if (variable_global_exists("equip_db")) {
                        if (is_struct(obj_player.equipo_arma) && variable_struct_exists(obj_player.equipo_arma, "ataque")) _atk_base += obj_player.equipo_arma.ataque;
                        else if (obj_player.equipo_arma != -1) {
                            var _arma = global.equip_db[$ obj_player.equipo_arma];
                            if (_arma != undefined && struct_exists(_arma, "ataque")) _atk_base += _arma.ataque;
                        }
                    }
                }
                
                var _dano = 10 + (_atk_base * 2);
                _en_actual.vida_actual -= _dano;
                _en_actual.shake_timer = 15;
                
                if (audio_is_playing(snd_shake)) audio_stop_sound(snd_shake);
                audio_play_sound(snd_shake, 10, false);
                
                var _texto_ataque = "";
                if (_en_actual.vida_actual <= 0) {
                    _en_actual.vida_actual = 0;
                    _en_actual.derrotado = true;
                    
                    if (instance_exists(obj_batalla_controller) && variable_instance_exists(obj_batalla_controller, "mapa_enemigos_muertos")) {
                        scr_marcar_enemigo_muerto(obj_batalla_controller.mapa_enemigos_muertos, enemigo_seleccionado_idx);
                    }
                    
                    audio_play_sound(snd_enemy_killed, 10, false);
                    _texto_ataque = variable_struct_exists(_en_actual, "texto_muerte") ? string_replace_all(_en_actual.texto_muerte, "\n", " ") : "* Venciste a " + _en_actual.nombre + "!";
                    
                    var _chequear_todos_muertos = true;
                    for (var i = 0; i < array_length(enemigos); i++) {
                        if (!variable_struct_exists(enemigos[i], "derrotado") || !enemigos[i].derrotado) {
                            _chequear_todos_muertos = false;
                            break;
                        }
                    }
                    
                    if (_chequear_todos_muertos) {
                        if (audio_is_playing(snd_bbs_start)) {
                            audio_stop_sound(snd_bbs_start);
                        }
                        if (variable_instance_exists(id, "musica_batalla_actual") && audio_exists(musica_batalla_actual)) {
                            if (audio_is_playing(musica_batalla_actual)) {
                                audio_stop_sound(musica_batalla_actual);
                            }
                        }
                    }
                    
                } else {
                    _texto_ataque = "* Hiciste " + string(_dano) + " de daño a " + _en_actual.nombre + "!";
                }
                
                f_procesar_dialogo(_texto_ataque);
                
                en_resultado_ataque = true;
                en_menu_fight = false;
                en_seleccion_enemigo = false;
                en_modo_info = false;
                audio_play_sound(snd_menumove, 10, false);
            } else {
                en_modo_info = true;
                f_procesar_dialogo(string_replace_all(_en_actual.descripcion, "\n", " "));
                audio_play_sound(snd_menumove, 10, false);
            }
        }
    }
}

if (skip_key && !en_resultado_ataque && !en_dialogo_victoria_final) {
    if (en_menu_inventario) {
        en_menu_inventario = false; audio_play_sound(snd_menumove, 10, false);
    } else if (en_modo_info) {
        en_modo_info = false; en_menu_fight = false;
        f_procesar_dialogo(texto_inicio_batalla);
        audio_play_sound(snd_menumove, 10, false);
    } else if (en_menu_fight) {
        en_menu_fight = false; en_seleccion_enemigo = true; audio_play_sound(snd_menumove, 10, false);
    } else if (en_seleccion_enemigo) {
        en_seleccion_enemigo = false; audio_play_sound(snd_menumove, 10, false);
    }
}