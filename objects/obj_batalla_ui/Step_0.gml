
// =========================================================
// EVENTO: STEP
// =========================================================
// =========================================================
// GAME OVER - CONGELAR LÓGICA, PERO SEGUIR DIBUJANDO
// =========================================================
//
// Durante el segundo de muerte:
//
//     obj_batalla_ui sigue EXISTIENDO;
//     Draw GUI sigue mostrando batalla/enemigos;
//     Step no cambia nada.
//
// Al entrar a game_over, Draw GUI se autodestruye antes de
// dibujar.
// =========================================================

if (
    variable_global_exists(
        "gameover_death_freeze_active"
    )
    &&
    global.gameover_death_freeze_active
)
{
    exit;
}


accept_key = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);
skip_key = keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_shift) || keyboard_check_pressed(vk_control);
var _fast_skip_key = keyboard_check(ord("C")) || keyboard_check_pressed(vk_control);

if (string_length(text_to_draw) <= 0) {
    head_visible = false;
    head_sprite = noone;
}

if (head_sprite == noone) {
    head_visible = false;
}

if (instance_exists(obj_batalla_controller)) {
    if (obj_batalla_controller.fase_actual == FASE_BATALLA.HUIR) {
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


// =========================================================
// TIMING DE ATAQUE
// =========================================================
//
// Mientras cualquiera de estos estados está activo, la UI
// normal queda completamente bloqueada.
// =========================================================

if (attack_timing_active)
{
    // -----------------------------------------------------
    // ANIMACIÓN DEL SPRITE DE LA BARRA
    // -----------------------------------------------------
    //
    // spr_barra_bbs tiene 2 frames y se reproduce usando
    // el FPS configurado en el propio Sprite Editor.
    // -----------------------------------------------------

    var _bar_frames =
        max(
            1,
            sprite_get_number(spr_barra_bbs)
        );


    var _bar_sprite_fps =
        max(
            0,
            sprite_get_speed(spr_barra_bbs)
        );


    var _game_fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    attack_bar_anim_index +=
        _bar_sprite_fps
        /
        _game_fps;


    if (attack_bar_anim_index >= _bar_frames)
    {
        attack_bar_anim_index =
            attack_bar_anim_index
            mod
            _bar_frames;
    }


    // -----------------------------------------------------
    // DETENER CON Z / ENTER
    // -----------------------------------------------------

    if (accept_key)
    {
        attack_timing_active = false;
        attack_timing_stopped = true;

        // Congelar EXACTAMENTE donde se pulsó.
        attack_stop_timer =
            attack_stop_hold_frames;


        // IMPORTANTE:
        // Todavía NO aplicamos el daño.
        //
        // Durante este segundo:
        //     - la barra no se mueve;
        //     - su POSICIÓN no cambia, pero sus frames sí animan;
        //     - el enemigo todavía no recibe daño;
        //     - no aparece el popup.
        //
        // El golpe se resuelve al terminar el contador.
        keyboard_clear(ord("Z"));
        keyboard_clear(vk_enter);

        exit;
    }


    // -----------------------------------------------------
    // MOVER DE UN EXTREMO AL OTRO
    // -----------------------------------------------------

    attack_bar_x +=
        attack_bar_speed
        *
        attack_bar_direction;


    var _llego_al_final =
        (
            attack_bar_direction > 0
            &&
            attack_bar_x >= attack_bar_max_x
        )
        ||
        (
            attack_bar_direction < 0
            &&
            attack_bar_x <= attack_bar_min_x
        );


    if (_llego_al_final)
    {
        // La barra desaparece inmediatamente y es MISS.
        attack_bar_x =
            (attack_bar_direction > 0)
            ?
            attack_bar_max_x
            :
            attack_bar_min_x;


        attack_timing_active = false;
        attack_timing_stopped = false;


        f_resolver_timing_ataque(true);


        attack_feedback_active = true;
        attack_feedback_timer = 0;

        exit;
    }


    exit;
}


// =========================================================
// BARRA DETENIDA: PEQUEÑA PAUSA VISUAL
// =========================================================

if (attack_timing_stopped)
{
    // =====================================================
    // LA POSICIÓN QUEDA CONGELADA, PERO EL SPRITE NO
    // =====================================================
    //
    // spr_barra_bbs conserva su animación de 2 frames durante
    // todo el segundo de espera.
    //
    // Únicamente NO modificamos attack_bar_x.
    // =====================================================

    var _stop_bar_frames =
        max(
            1,
            sprite_get_number(
                spr_barra_bbs
            )
        );


    var _stop_bar_sprite_fps =
        max(
            0,
            sprite_get_speed(
                spr_barra_bbs
            )
        );


    var _stop_game_fps =
        max(
            1,
            game_get_speed(
                gamespeed_fps
            )
        );


    attack_bar_anim_index +=
        _stop_bar_sprite_fps
        /
        _stop_game_fps;


    if (
        attack_bar_anim_index
        >=
        _stop_bar_frames
    )
    {
        attack_bar_anim_index =
            attack_bar_anim_index
            mod
            _stop_bar_frames;
    }


    attack_stop_timer--;


    if (attack_stop_timer <= 0)
    {
        attack_stop_timer = 0;
        attack_timing_stopped = false;


        // Tras 1 segundo, aplicar el golpe según la posición
        // exacta donde se quedó la barra.
        f_resolver_timing_ataque(
            false
        );


        attack_feedback_active = true;
        attack_feedback_timer = 0;
    }


    exit;
}


// =========================================================
// POPUP DE DAÑO / MISS
// =========================================================

if (attack_feedback_active)
{
    // =====================================================
    // ACELERAR POPUP CON C / CTRL
    // =====================================================
    //
    // Mantener C o Ctrl hace que salto, rebote, segundo visible
    // y fade avancen 4 veces más rápido.
    //
    // No lo salta instantáneamente: simplemente acelera toda
    // la animación de forma consistente.
    // =====================================================

    var _feedback_fast =
        keyboard_check(
            ord("C")
        )
        ||
        keyboard_check(
            vk_control
        );


    attack_feedback_timer +=
        _feedback_fast
        ?
        4
        :
        1;


    if (attack_feedback_timer >= attack_feedback_duration)
    {
        attack_feedback_active = false;


        // Después de la animación se conserva el flujo que ya
        // tenía tu batalla: aparece el resultado y al confirmar
        // comienza el turno enemigo / victoria.
        f_procesar_dialogo(
            attack_result_text
        );


        en_resultado_ataque = true;
        en_menu_fight = false;
        en_seleccion_enemigo = false;
        en_modo_info = false;


        setup = false;
    }


    exit;
}

// SI ESTAMOS EN CINEMÁTICA, EL CONTROLLER SE ENCARGA DE AVANZAR
if (instance_exists(obj_batalla_controller) && obj_batalla_controller.fase_actual == FASE_BATALLA.CINEMATICA) {
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
    }
    exit;
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
                    if (_es_letra) audio_play_sound(snd_text, 10, false);
                }
            }
        }
    } else if (accept_key) {
        if (victoria_etapa == 0) {
            victoria_xp = instance_exists(obj_batalla_controller) ? obj_batalla_controller.experiencia_batalla : 0;
            victoria_nivel_antes = instance_exists(obj_player) && variable_instance_exists(obj_player, "nivel") ? obj_player.nivel : 1;

            // IMPORTANTE:
            // scr_level_ganar_experiencia() devuelve cuántos niveles subió.
            // Usamos ese resultado directamente en vez de deducirlo comparando
            // niveles antes/después. Así la victoria funciona igual aunque la
            // batalla haya sido iniciada desde una cinemática.
            var _subidas_nivel = 0;

            if (victoria_xp > 0) {
                _subidas_nivel = scr_level_ganar_experiencia(victoria_xp);
            }

            var _subio = (_subidas_nivel > 0);
            victoria_etapa = _subio ? 1 : 2;

            if (_subio) {
                if (!victoria_sonido_nivel_reproducido) {
                    victoria_sonido_nivel_reproducido = true;
                    audio_play_sound(snd_levelup, 10, false);
                }

                // Evita que la misma pulsación que confirmó la victoria
                // pueda arrastrarse al nuevo texto.
                keyboard_clear(ord("Z"));
                keyboard_clear(vk_enter);

                f_procesar_dialogo(scr_loc("¡Subiste de nivel!"));
            } else {
                if (instance_exists(obj_batalla_controller)) {
                    obj_batalla_controller.victoria_finalizada = true;
                    obj_batalla_controller.fase_actual = FASE_BATALLA.HUIR;
                }
            }
        } else if (victoria_etapa == 1) {
            victoria_etapa = 2;
            if (instance_exists(obj_batalla_controller)) {
                obj_batalla_controller.victoria_finalizada = true;
                obj_batalla_controller.fase_actual = FASE_BATALLA.HUIR;
            }
        }
    }
    exit;
}

if (!en_resultado_ataque && !en_dialogo_victoria_final) {
    if (en_menu_inventario) {
        if (keyboard_check_pressed(vk_right)) {
            inv_x = (inv_x + 1) % 2;
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(vk_left)) {
            inv_x = (inv_x - 1 + 2) % 2;
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(vk_down)) {
            var _total_items = (instance_exists(obj_player) && variable_instance_exists(obj_player, "inventory")) ? array_length(obj_player.inventory) : 0;
            var _filas_totales = max(1, ceil(_total_items / 2));
            var _max_scroll = max(0, _filas_totales - 2);
            inv_y++;
            if (inv_y > 1) {
                inv_y = 1;
                if (inv_scroll < _max_scroll) inv_scroll++;
            }
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(vk_up)) {
            inv_y--;
            if (inv_y < 0) {
                inv_y = 0;
                if (inv_scroll > 0) inv_scroll--;
            }
            audio_play_sound(snd_menumove, 10, false);
        }
        if (skip_key) {
            en_menu_inventario = false;
            audio_play_sound(snd_menumove, 10, false);
        }
    } else if (en_menu_toys) {
        if (keyboard_check_pressed(vk_right)) {
            toy_x = (toy_x + 1) % 2;
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(vk_left)) {
            toy_x = (toy_x - 1 + 2) % 2;
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(vk_down)) {
            var _toy_total = variable_global_exists("toy_inventory") ? array_length(global.toy_inventory) : 0;
            var _toy_rows = max(1, ceil(_toy_total / 2));
            var _toy_max_scroll = max(0, _toy_rows - 2);
            toy_y++;
            if (toy_y > 1) {
                toy_y = 1;
                if (toy_scroll < _toy_max_scroll) toy_scroll++;
            }
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(vk_up)) {
            toy_y--;
            if (toy_y < 0) {
                toy_y = 0;
                if (toy_scroll > 0) toy_scroll--;
            }
            audio_play_sound(snd_menumove, 10, false);
        }
        if (skip_key) {
            en_menu_toys = false;
            audio_play_sound(snd_menumove, 10, false);
        }
    } else if (!en_menu_fight && !en_seleccion_enemigo) {
        if (keyboard_check_pressed(vk_right)) {
            opcion_seleccionada++;
            if (opcion_seleccionada > 3) opcion_seleccionada = 0;
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(vk_left)) {
            opcion_seleccionada--;
            if (opcion_seleccionada < 0) opcion_seleccionada = 3;
            audio_play_sound(snd_menumove, 10, false);
        }
    } else if (en_seleccion_enemigo) {
        var _total_en = array_length(enemigos);
        if (_total_en > 0) {
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
        }
    } else if (!en_modo_info) {
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(vk_down)) {
            opcion_fight_seleccionada++;
            if (opcion_fight_seleccionada > 1) opcion_fight_seleccionada = 0;
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_up)) {
            opcion_fight_seleccionada--;
            if (opcion_fight_seleccionada < 0) opcion_fight_seleccionada = 1;
            audio_play_sound(snd_menumove, 10, false);
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

        if (en_menu_inventario) {
            var _inv_index = inv_x + (inv_y * 2) + (inv_scroll * 2);

            if (instance_exists(obj_player) && variable_instance_exists(obj_player, "inventory") && _inv_index < array_length(obj_player.inventory)) {
                var _item_key = obj_player.inventory[_inv_index];
                var _item_valido = false;

                if (_item_key != -1 && _item_key != undefined && variable_global_exists("item_db")) {
                    var _item_data = global.item_db[$ _item_key];
                    if (_item_data != undefined) {
                        _item_valido = !variable_struct_exists(_item_data, "tipo") || _item_data.tipo == "consumible";
                    }
                }

                if (_item_valido) {
                    var _item_data = global.item_db[$ _item_key];
                    var _hp_antes = instance_exists(obj_player) ? obj_player.hp : 0;

                    if (variable_struct_exists(_item_data, "efecto")) {
                        _item_data.efecto();
                    }

                    var _hp_curado = instance_exists(obj_player) ? obj_player.hp - _hp_antes : 0;
                    obj_player.inventory[_inv_index] = -1;

                    var _texto_item = "";
                    if (_hp_curado > 0) {
                        _texto_item = scr_locf("* Consumiste {item}! Te curaste {hp} de vida!", { item: scr_loc(_item_data.nombre), hp: string(_hp_curado) });
                    } else if (instance_exists(obj_player) && _hp_antes >= obj_player.hp_max) {
                        _texto_item = scr_locf("* Consumiste {item}, pero ya tienes la vida llena!", { item: scr_loc(_item_data.nombre) });
                    } else {
                        _texto_item = scr_locf("* Consumiste {item}!", { item: scr_loc(_item_data.nombre) });
                    }

                    f_procesar_dialogo(_texto_item);
                    en_resultado_ataque = true;
                    en_menu_inventario = false;
                    audio_play_sound(snd_menumove, 10, false);
                } else {
                    if (audio_is_playing(snd_error)) audio_stop_sound(snd_error);
                    audio_play_sound(snd_error, 10, false);
                }
            } else {
                if (audio_is_playing(snd_error)) audio_stop_sound(snd_error);
                audio_play_sound(snd_error, 10, false);
            }

        } else if (en_menu_toys) {
            var _toy_index = toy_x + (toy_y * 2) + (toy_scroll * 2);
            var _toy_key = -1;
            var _toy_valido = false;

            if (variable_global_exists("toy_inventory") && _toy_index >= 0 && _toy_index < array_length(global.toy_inventory)) {
                _toy_key = global.toy_inventory[_toy_index];

                if (_toy_key != -1 && _toy_key != undefined && variable_global_exists("toy_db")) {
                    var _toy_data = global.toy_db[$ _toy_key];
                    if (_toy_data != undefined) _toy_valido = true;
                }
            }

            if (_toy_valido) {
                toy_selected_slot = _toy_index;
                toy_selected_key = _toy_key;
                en_menu_toys = false;

                enemigo_seleccionado_idx = 0;
                for (var i = 0; i < array_length(enemigos); i++) {
                    if (!variable_struct_exists(enemigos[i], "derrotado") || !enemigos[i].derrotado) {
                        enemigo_seleccionado_idx = i;
                        break;
                    }
                }

                en_seleccion_enemigo = true;
                audio_play_sound(snd_menumove, 10, false);
            } else {
                if (audio_is_playing(snd_error)) audio_stop_sound(snd_error);
                audio_play_sound(snd_error, 10, false);
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
                f_iniciar_victoria();

                audio_play_sound(
                    snd_menumove,
                    10,
                    false
                );
            } else {
                en_menu_fight = false;
                en_seleccion_enemigo = false;
                en_modo_info = false;
                en_menu_toys = false;
                opcion_seleccionada = 0;
                toy_selected_key = -1;
                toy_selected_slot = -1;
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
                toy_selected_key = -1;
                toy_selected_slot = -1;
                audio_play_sound(snd_menumove, 10, false);

            } else if (opcion_seleccionada == 1) {
                var _hay_consumibles = false;

                if (instance_exists(obj_player) && variable_instance_exists(obj_player, "inventory")) {
                    for (var i = 0; i < array_length(obj_player.inventory); i++) {
                        var _key = obj_player.inventory[i];
                        if (_key != -1 && _key != undefined && variable_global_exists("item_db")) {
                            var _data = global.item_db[$ _key];
                            if (_data != undefined && (!variable_struct_exists(_data, "tipo") || _data.tipo == "consumible")) {
                                _hay_consumibles = true;
                                break;
                            }
                        }
                    }
                }

                if (_hay_consumibles) {
                    en_menu_inventario = true;
                    inv_x = 0;
                    inv_y = 0;
                    inv_scroll = 0;
                    audio_play_sound(snd_menumove, 10, false);
                } else {
                    if (audio_is_playing(snd_error)) audio_stop_sound(snd_error);
                    audio_play_sound(snd_error, 10, false);
                }

            } else if (opcion_seleccionada == 2) {
                var _hay_toys = false;

                if (variable_global_exists("toy_inventory")) {
                    for (var i = 0; i < array_length(global.toy_inventory); i++) {
                        var _toy_key_check = global.toy_inventory[i];
                        if (_toy_key_check != -1 && _toy_key_check != undefined && variable_global_exists("toy_db")) {
                            if (global.toy_db[$ _toy_key_check] != undefined) {
                                _hay_toys = true;
                                break;
                            }
                        }
                    }
                }

                if (_hay_toys) {
                    en_menu_toys = true;
                    toy_x = 0;
                    toy_y = 0;
                    toy_scroll = 0;
                    toy_selected_key = -1;
                    toy_selected_slot = -1;
                    audio_play_sound(snd_menumove, 10, false);
                } else {
                    if (audio_is_playing(snd_error)) audio_stop_sound(snd_error);
                    audio_play_sound(snd_error, 10, false);
                }

            } else if (opcion_seleccionada == 3) {
                var _puede_escapar = false;
                if (instance_exists(obj_batalla_controller) && variable_instance_exists(obj_batalla_controller, "exito_escape_turno")) {
                    _puede_escapar = obj_batalla_controller.exito_escape_turno;
                }

                if (_puede_escapar) {
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
                } else {
                    f_procesar_dialogo(scr_loc("* Intentaste huir, ¡pero no pudiste escapar!"));
                    en_resultado_ataque = true;
                    audio_play_sound(snd_menumove, 10, false);
                }
            }

        } else if (en_seleccion_enemigo) {
            var _en_sel = enemigos[enemigo_seleccionado_idx];

            if (variable_struct_exists(_en_sel, "derrotado") && _en_sel.derrotado) {
                if (audio_is_playing(snd_error)) audio_stop_sound(snd_error);
                audio_play_sound(snd_error, 10, false);
            } else if (toy_selected_key != -1) {
                var _toy_data_use = global.toy_db[$ toy_selected_key];

                if (_toy_data_use != undefined) {
                    var _toy_aplicado = false;
                    if (variable_struct_exists(_toy_data_use, "efecto")) {
                        _toy_aplicado = _toy_data_use.efecto(_en_sel, _toy_data_use);
                    }

                    if (_toy_aplicado) {
                        var _texto_toy = scr_locf("* Usaste {toy} en {enemy}!", { toy: scr_loc(_toy_data_use.nombre), enemy: scr_loc(_en_sel.nombre) });
                        f_procesar_dialogo(_texto_toy);

                    if (variable_global_exists("toy_inventory") && toy_selected_slot >= 0 && toy_selected_slot < array_length(global.toy_inventory)) {
                        global.toy_inventory[toy_selected_slot] = -1;
                    }

                    toy_selected_key = -1;
                    toy_selected_slot = -1;
                    en_seleccion_enemigo = false;
                    en_resultado_ataque = true;
                    audio_play_sound(snd_menumove, 10, false);
                    } else {
                        if (audio_is_playing(snd_error)) audio_stop_sound(snd_error);
                        audio_play_sound(snd_error, 10, false);
                    }
                } else {
                    if (audio_is_playing(snd_error)) audio_stop_sound(snd_error);
                    audio_play_sound(snd_error, 10, false);
                }
            } else {
                en_seleccion_enemigo = false;
                en_menu_fight = true;
                en_modo_info = false;
                opcion_fight_seleccionada = 0;
                audio_play_sound(snd_menumove, 10, false);
            }

        } else if (en_modo_info) {
            en_modo_info = false;
            en_menu_fight = false;
            f_procesar_dialogo(texto_inicio_batalla);
            audio_play_sound(snd_menumove, 10, false);

        } else {
            var _en_actual = enemigos[enemigo_seleccionado_idx];

            if (opcion_fight_seleccionada == 0)
            {
                // =============================================
                // ATACAR -> TIMING
                // =============================================
                //
                // Ya NO se aplica daño al seleccionar Atacar.
                // Primero se abre el minijuego de target/barra.
                // =============================================

                f_iniciar_timing_ataque(
                    enemigo_seleccionado_idx
                );


                audio_play_sound(
                    snd_menumove,
                    10,
                    false
                );
            }
            else
            {
                // =============================================
                // INFO TAMBIÉN CONSUME EL TURNO
                // =============================================
                //
                // La descripción se muestra normalmente.
                // Cuando el jugador termine de leerla y confirme,
                // en_resultado_ataque usa el flujo existente para
                // pasar al turno enemigo.
                // =============================================

                en_modo_info = false;
                en_menu_fight = false;
                en_seleccion_enemigo = false;


                f_procesar_dialogo(
                    string_replace_all(
                        _en_actual.descripcion,
                        "\n",
                        " "
                    )
                );


                en_resultado_ataque = true;


                audio_play_sound(
                    snd_menumove,
                    10,
                    false
                );
            }
        }
    }
}

if (
    skip_key
    &&
    !en_resultado_ataque
    &&
    !en_dialogo_victoria_final
    &&
    !attack_timing_active
    &&
    !attack_timing_stopped
    &&
    !attack_feedback_active
) {
    if (en_menu_inventario) {
        en_menu_inventario = false;
        audio_play_sound(snd_menumove, 10, false);
    } else if (en_menu_toys) {
        en_menu_toys = false;
        toy_selected_key = -1;
        toy_selected_slot = -1;
        audio_play_sound(snd_menumove, 10, false);
    } else if (en_modo_info) {
        en_modo_info = false;
        en_menu_fight = false;
        f_procesar_dialogo(texto_inicio_batalla);
        audio_play_sound(snd_menumove, 10, false);
    } else if (en_menu_fight) {
        en_menu_fight = false;
        en_seleccion_enemigo = true;
        audio_play_sound(snd_menumove, 10, false);
    } else if (en_seleccion_enemigo) {
        en_seleccion_enemigo = false;
        toy_selected_key = -1;
        toy_selected_slot = -1;
        audio_play_sound(snd_menumove, 10, false);
    }
}
