// =========================================================
// DERROTA / GAME OVER
// =========================================================
//
// Durante el segundo congelado:
//
//     controller no avanza turnos ni aplica más acciones,
//     pero NO se destruye todavía.
//
// Al entrar a game_over se elimina.
// =========================================================

if (room == game_over)
{
    persistent =
        false;

    instance_destroy();

    exit;
}


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


// =========================================================
// VERIFICAR CINEMÁTICAS
// =========================================================
//
// No se interrumpen:
// - la introducción inicial;
// - otra cinemática;
// - huida/victoria;
// - timing de ataque del jugador;
// - parry del turno enemigo;
// - textos de resultado/victoria.
// =========================================================

if (
    fase_actual != FASE_BATALLA.INICIO
    &&
    fase_actual != FASE_BATALLA.CINEMATICA
    &&
    fase_actual != FASE_BATALLA.HUIR
    &&
    fase_actual != FASE_BATALLA.VICTORIA
)
{
    var _ui_ocupada =
        parry_waiting;


    if (instance_exists(obj_batalla_ui))
    {
        var _leyendo_resultado =
            variable_instance_exists(
                obj_batalla_ui,
                "en_resultado_ataque"
            )
            ?
            obj_batalla_ui.en_resultado_ataque
            :
            false;


        var _leyendo_victoria =
            variable_instance_exists(
                obj_batalla_ui,
                "en_dialogo_victoria_final"
            )
            ?
            obj_batalla_ui.en_dialogo_victoria_final
            :
            false;


        var _timing_ataque =
            variable_instance_exists(
                obj_batalla_ui,
                "attack_timing_active"
            )
            &&
            obj_batalla_ui.attack_timing_active;


        var _timing_detenido =
            variable_instance_exists(
                obj_batalla_ui,
                "attack_timing_stopped"
            )
            &&
            obj_batalla_ui.attack_timing_stopped;


        var _feedback_ataque =
            variable_instance_exists(
                obj_batalla_ui,
                "attack_feedback_active"
            )
            &&
            obj_batalla_ui.attack_feedback_active;


        if (
            _leyendo_resultado
            ||
            _leyendo_victoria
            ||
            _timing_ataque
            ||
            _timing_detenido
            ||
            _feedback_ataque
        )
        {
            _ui_ocupada =
                true;
        }
    }


    if (!_ui_ocupada)
    {
        if (f_verificar_cinematicas())
        {
            exit;
        }
    }
}


if (!variable_instance_exists(id, "_debug_fase_anterior"))
{
    _debug_fase_anterior = fase_actual;
}

if (_debug_fase_anterior != fase_actual)
{
    show_debug_message(
        "[FASE] cambio de "
        +
        string(_debug_fase_anterior)
        +
        " -> "
        +
        string(fase_actual)
    );

    _debug_fase_anterior =
        fase_actual;
}


switch (fase_actual)
{
    // =====================================================
    // INICIO
    // =====================================================

    case FASE_BATALLA.INICIO:

        if (
            audio_exists(snd_bbs_start)
            &&
            !audio_is_playing(snd_bbs_start)
        )
        {
            audio_play_sound(
                snd_bbs_start,
                15,
                false
            );
        }


        if (!instance_exists(obj_batalla_ui))
        {
            instance_create_layer(
                x,
                y,
                layer,
                obj_batalla_ui
            );
        }


        fase_actual =
            FASE_BATALLA.JUGADOR_MENU;

        break;


    // =====================================================
    // MENÚ DEL JUGADOR
    // =====================================================

    case FASE_BATALLA.JUGADOR_MENU:

        if (
            instance_exists(obj_batalla_ui)
            &&
            obj_batalla_ui.enemigos != enemigos
        )
        {
            obj_batalla_ui.enemigos =
                enemigos;
        }


        for (var i = 0; i < array_length(enemigos); i++)
        {
            if (enemigos[i].vida_actual <= 0)
            {
                scr_marcar_enemigo_muerto(
                    mapa_enemigos_muertos,
                    i
                );

                enemigos[i].derrotado =
                    true;
            }
        }

        break;


    // =====================================================
    // TURNO ENEMIGO
    // =====================================================

    case FASE_BATALLA.ENEMIGO_TURNO:

        var _total_en =
            array_length(enemigos);

        var _en_actual =
            noone;


        while (turno_enemigo_idx < _total_en)
        {
            if (enemigos[turno_enemigo_idx].vida_actual <= 0)
            {
                scr_marcar_enemigo_muerto(
                    mapa_enemigos_muertos,
                    turno_enemigo_idx
                );

                enemigos[turno_enemigo_idx].derrotado =
                    true;
            }


            var _esta_muerto =
                scr_esta_enemigo_muerto(
                    mapa_enemigos_muertos,
                    turno_enemigo_idx
                );


            if (_esta_muerto)
            {
                turno_enemigo_idx++;
            }
            else
            {
                _en_actual =
                    enemigos[turno_enemigo_idx];

                break;
            }
        }


        // =================================================
        // TERMINÓ LA RONDA DE TODOS LOS ENEMIGOS
        // =================================================

        if (
            turno_enemigo_idx >= _total_en
            ||
            _en_actual == noone
        )
        {
            turno_enemigo_idx =
                0;

            fase_actual =
                FASE_BATALLA.JUGADOR_MENU;


            primer_turno_pasado =
                true;


            // Comienza un nuevo turno completo de batalla.
            turno_batalla++;


            exito_escape_turno =
                (random(1.0) < probabilidad_escapar);


            var _texto_a_usar =
                "";


            if (
                primer_turno_pasado
                &&
                array_length(dialogos_turno_actual) > 0
            )
            {
                var _indice_azar =
                    irandom(
                        array_length(dialogos_turno_actual) - 1
                    );

                _texto_a_usar =
                    dialogos_turno_actual[_indice_azar];
            }
            else
            {
                _texto_a_usar =
                    obj_batalla_ui.texto_inicio_batalla;
            }


            if (instance_exists(obj_batalla_ui))
            {
                obj_batalla_ui.en_resultado_ataque =
                    false;

                obj_batalla_ui.f_procesar_dialogo(
                    _texto_a_usar
                );
            }


            break;
        }


        // =================================================
        // STUN
        // =================================================

        if (!variable_struct_exists(_en_actual, "turnos_stun"))
        {
            _en_actual.turnos_stun =
                0;
        }


        if (_en_actual.turnos_stun > 0)
        {
            _en_actual.turnos_stun--;


            if (instance_exists(obj_batalla_ui))
            {
                obj_batalla_ui.en_resultado_ataque =
                    true;

                obj_batalla_ui.f_procesar_dialogo(
                    scr_locf(
                        "* {enemy} está aturdido y no puede atacar!",
                        {
                            enemy:
                                scr_loc(
                                    _en_actual.nombre
                                )
                        }
                    )
                );
            }


            fase_actual =
                FASE_BATALLA.ENEMIGO_ATACANDO;

            break;
        }


        // =================================================
        // CALCULAR DAÑO DEL ENEMIGO
        // =================================================

        var _ataque_base_enemigo =
            variable_struct_exists(
                _en_actual,
                "ataque"
            )
            ?
            _en_actual.ataque
            :
            irandom_range(5, 12);


        var _reduccion_ataque =
            variable_struct_exists(
                _en_actual,
                "ataque_reducido"
            )
            ?
            _en_actual.ataque_reducido
            :
            0;


        var _multiplicador_ataque =
            max(
                0,
                1 - (_reduccion_ataque * 0.08)
            );


        var _ataque_real =
            max(
                0,
                round(
                    _ataque_base_enemigo
                    *
                    _multiplicador_ataque
                )
            );


        var _dano_enemigo =
            max(
                0,
                _ataque_real
                +
                irandom_range(0, 3)
            );


        // =================================================
        // ARMA CON PARRY
        // =================================================
        //
        // El controller ya no crea ningún objeto auxiliar.
        // Guarda el daño pendiente e inicia directamente el
        // minijuego de diana/aro.
        // =================================================

        if (f_player_can_parry())
        {
            f_parry_start(
                turno_enemigo_idx,
                _dano_enemigo,
                _en_actual.nombre
            );

            show_debug_message(
                "[PARRY] Iniciado. Arma="
                +
                string(parry_weapon_id)
                +
                " enemigo="
                +
                string(turno_enemigo_idx)
            );

            break;
        }


        // =================================================
        // ATAQUE NORMAL SIN PARRY
        // =================================================

        if (instance_exists(obj_player))
        {
            obj_player.hp =
                max(
                    0,
                    obj_player.hp - _dano_enemigo
                );
        }


        // Screen shake universal.
        if (_dano_enemigo > 0)
        {
            scr_screen_shake_start(
                3,
                8
            );
        }


        if (audio_is_playing(snd_atacado))
        {
            audio_stop_sound(
                snd_atacado
            );
        }


        audio_play_sound(
            snd_atacado,
            10,
            false
        );


        if (instance_exists(obj_batalla_ui))
        {
            obj_batalla_ui.en_resultado_ataque =
                true;

            obj_batalla_ui.f_procesar_dialogo(
                scr_locf(
                    "* {enemy} ataca y te causa {damage} de daño!",
                    {
                        enemy:
                            scr_loc(
                                _en_actual.nombre
                            ),

                        damage:
                            string(
                                _dano_enemigo
                            )
                    }
                )
            );
        }


        fase_actual =
            FASE_BATALLA.ENEMIGO_ATACANDO;

        break;


    // =====================================================
    // ENEMIGO ATACANDO
    // =====================================================

    case FASE_BATALLA.ENEMIGO_ATACANDO:

        // Esperar a que termine el texto del ataque/parry.
        if (instance_exists(obj_batalla_ui))
        {
            if (
                obj_batalla_ui.draw_char
                >=
                obj_batalla_ui.text_length
            )
            {
                if (_accept_key)
                {
                    turno_enemigo_idx++;

                    fase_actual =
                        FASE_BATALLA.ENEMIGO_TURNO;
                }
            }
        }

        break;


    // =====================================================
    // CINEMÁTICA DE BATALLA
    // =====================================================

    case FASE_BATALLA.CINEMATICA:

        // =================================================
        // PARRY ACTIVO
        // =================================================

        if (parry_waiting)
        {
            // =============================================
            // 1. ANIMACIÓN DE ENTRADA
            // =============================================
            //
            // La diana nace muy pequeña y crece hasta su
            // tamaño final. Mientras esto ocurre:
            //
            // - el aro NO se encoge;
            // - Z / Enter no pueden resolver el parry.
            // =============================================

            if (!parry_intro_finished)
            {
                parry_visual_factor =
                    min(
                        1,
                        parry_visual_factor
                        +
                        parry_intro_speed
                    );


                keyboard_clear(ord("Z"));
                keyboard_clear(vk_enter);


                if (parry_visual_factor >= 1)
                {
                    parry_visual_factor = 1;
                    parry_intro_finished = true;

                    // Dos frames limpios antes de aceptar input.
                    parry_input_lock = 2;
                }


                break;
            }


            // =============================================
            // 2. PARRY ACTIVO - DOS AROS
            // =============================================
            //
            // Los dos aros se encogen al mismo tiempo.
            //
            // Primero hay que acertar el aro 1. Al acertarlo
            // desaparece y el input pasa al aro 2.
            //
            // Solo si ambos se aciertan se evita el daño.
            // Fallar cualquiera resuelve TODO el parry como
            // fallo inmediatamente.
            // =============================================

            if (!parry_resolved)
            {
                if (parry_input_lock > 0)
                {
                    parry_input_lock--;

                    keyboard_clear(ord("Z"));
                    keyboard_clear(vk_enter);

                    break;
                }


                var _parry_confirm =
                    keyboard_check_pressed(ord("Z"))
                    ||
                    keyboard_check_pressed(vk_enter);


                // Radio del aro que TOCA acertar ahora.
                var _current_ring_radius =
                    (parry_ring_target == 1)
                    ?
                    parry_ring_1_radius_px
                    :
                    parry_ring_2_radius_px;


                if (_parry_confirm)
                {
                    // Ventana válida para cada aro:
                    //
                    //     radio > 1 px
                    //     radio <= 14 px
                    //
                    // Si ya toca el centro 2x2, no cuenta.
                    var _ring_hit_success =
                        _current_ring_radius
                        >
                        parry_center_fail_radius_px
                        &&
                        _current_ring_radius
                        <=
                        parry_valid_radius_px;


                    if (!_ring_hit_success)
                    {
                        // Pulsaste demasiado pronto o demasiado tarde.
                        f_parry_resolve(false);
                    }
                    else
                    {
                        // Sonido de acierto para CADA aro.
                        if (audio_exists(snd_shineselect))
                        {
                            if (audio_is_playing(snd_shineselect))
                            {
                                audio_stop_sound(snd_shineselect);
                            }

                            audio_play_sound(snd_shineselect, 10, false);
                        }


                        if (parry_ring_target == 1)
                        {
                            // Primer aro acertado.
                            // Se oculta y ahora toca acertar el segundo.
                            parry_ring_1_hit = true;
                            parry_ring_target = 2;
                        }
                        else
                        {
                            // Segundo aro acertado: parry completo.
                            parry_ring_2_hit = true;
                            f_parry_resolve(true);
                        }
                    }


                    keyboard_clear(ord("Z"));
                    keyboard_clear(vk_enter);

                    break;
                }


                // Los DOS aros avanzan hacia el centro al mismo tiempo.
                if (!parry_ring_1_hit)
                {
                    parry_ring_1_radius_px -=
                        parry_ring_shrink_speed_px;
                }

                if (!parry_ring_2_hit)
                {
                    parry_ring_2_radius_px -=
                        parry_ring_shrink_speed_px;
                }


                // Solo nos importa si toca el centro el aro que
                // actualmente estamos obligados a acertar.
                _current_ring_radius =
                    (parry_ring_target == 1)
                    ?
                    parry_ring_1_radius_px
                    :
                    parry_ring_2_radius_px;


                if (
                    _current_ring_radius
                    <=
                    parry_center_fail_radius_px
                )
                {
                    if (parry_ring_target == 1)
                    {
                        parry_ring_1_radius_px =
                            parry_center_fail_radius_px;
                    }
                    else
                    {
                        parry_ring_2_radius_px =
                            parry_center_fail_radius_px;
                    }

                    f_parry_resolve(false);
                }


                break;
            }


            // =============================================
            // 3. PEQUEÑA PAUSA CON EL ARO CONGELADO
            // =============================================

            if (parry_result_timer > 0)
            {
                parry_result_timer--;

                keyboard_clear(ord("Z"));
                keyboard_clear(vk_enter);

                break;
            }


            // =============================================
            // 4. ANIMACIÓN DE SALIDA
            // =============================================
            //
            // La diana y el aro se hacen pequeños juntos.
            // El resultado se aplica solo cuando ya terminó
            // esta animación.
            // =============================================

            if (parry_visual_factor > 0)
            {
                parry_visual_factor =
                    max(
                        0,
                        parry_visual_factor
                        -
                        parry_outro_speed
                    );


                keyboard_clear(ord("Z"));
                keyboard_clear(vk_enter);


                if (parry_visual_factor > 0)
                {
                    break;
                }
            }


            var _parry_success = parry_success;

            parry_waiting = false;


            // =============================================
            // PARRY EXITOSO
            // =============================================

            if (_parry_success)
            {
                if (instance_exists(obj_batalla_ui))
                {
                    obj_batalla_ui.en_resultado_ataque = true;

                    obj_batalla_ui.f_procesar_dialogo(
                        scr_locf(
                            "* ¡Hiciste parry al ataque de {enemy}!",
                            {
                                enemy:
                                    scr_loc(
                                        parry_pending_enemy_name
                                    )
                            }
                        )
                    );
                }
            }


            // =============================================
            // PARRY FALLIDO
            // =============================================

            else
            {
                if (instance_exists(obj_player))
                {
                    obj_player.hp =
                        max(
                            0,
                            obj_player.hp
                            -
                            parry_pending_damage
                        );
                }


                // Screen shake también cuando fallas el parry.
                if (parry_pending_damage > 0)
                {
                    scr_screen_shake_start(
                        3,
                        8
                    );
                }


                if (audio_is_playing(snd_atacado))
                {
                    audio_stop_sound(snd_atacado);
                }


                audio_play_sound(
                    snd_atacado,
                    10,
                    false
                );


                if (instance_exists(obj_batalla_ui))
                {
                    obj_batalla_ui.en_resultado_ataque = true;

                    obj_batalla_ui.f_procesar_dialogo(
                        scr_locf(
                            "* {enemy} ataca y te causa {damage} de daño!",
                            {
                                enemy:
                                    scr_loc(
                                        parry_pending_enemy_name
                                    ),

                                damage:
                                    string(
                                        parry_pending_damage
                                    )
                            }
                        )
                    );
                }
            }


            parry_pending_enemy_idx = -1;
            parry_pending_damage = 0;
            parry_pending_enemy_name = "";

            parry_resolved = false;
            parry_success = false;
            parry_result_timer = 0;

            parry_ring_1_radius_px = parry_ring_source_radius_px;
            parry_ring_2_radius_px = parry_ring_2_start_radius_px;
            parry_ring_1_hit = false;
            parry_ring_2_hit = false;
            parry_ring_target = 1;

            parry_visual_factor = 0;
            parry_intro_finished = false;

            fase_actual = FASE_BATALLA.ENEMIGO_ATACANDO;

            keyboard_clear(ord("Z"));
            keyboard_clear(vk_enter);

            break;
        }



        keyboard_clear(ord("C"));
        keyboard_clear(vk_control);


        var _skip_anim_key =
            keyboard_check_pressed(ord("X"))
            ||
            keyboard_check_pressed(vk_shift);


        var _accept_key_cine =
            keyboard_check_pressed(ord("Z"))
            ||
            keyboard_check_pressed(vk_enter);


        if (instance_exists(obj_batalla_ui))
        {
            if (
                obj_batalla_ui.draw_char
                <
                obj_batalla_ui.text_length
            )
            {
                keyboard_clear(ord("Z"));
                keyboard_clear(vk_enter);


                var _char_previo =
                    floor(
                        obj_batalla_ui.draw_char
                    );


                obj_batalla_ui.draw_char +=
                    0.5;


                var _char_actual =
                    floor(
                        obj_batalla_ui.draw_char
                    );


                if (_char_actual > _char_previo)
                {
                    var _dialogo_struct =
                        cinematica_dialogos[cinematica_idx];


                    var _snd_a_reproducir =
                        snd_text;


                    if (
                        is_struct(_dialogo_struct)
                        &&
                        variable_struct_exists(
                            _dialogo_struct,
                            "snd"
                        )
                        &&
                        _dialogo_struct.snd != noone
                    )
                    {
                        _snd_a_reproducir =
                            _dialogo_struct.snd;
                    }


                    if (audio_exists(_snd_a_reproducir))
                    {
                        audio_stop_sound(
                            _snd_a_reproducir
                        );

                        audio_play_sound(
                            _snd_a_reproducir,
                            10,
                            false
                        );
                    }
                }


                if (_skip_anim_key)
                {
                    obj_batalla_ui.draw_char =
                        obj_batalla_ui.text_length;

                    keyboard_clear(ord("X"));
                    keyboard_clear(vk_shift);
                }
            }
            else if (_accept_key_cine)
            {
                cinematica_idx++;


                if (
                    cinematica_idx
                    <
                    array_length(cinematica_dialogos)
                )
                {
                    var _dialogo_actual =
                        cinematica_dialogos[cinematica_idx];


                    obj_batalla_ui.f_procesar_dialogo(
                        _dialogo_actual
                    );

                    obj_batalla_ui.draw_char =
                        0;

                    obj_batalla_ui.setup =
                        false;


                    // --- SISTEMA DE CONTROL DE MÚSICA ---
                    if (
                        is_struct(_dialogo_actual)
                        &&
                        variable_struct_exists(
                            _dialogo_actual,
                            "music"
                        )
                    )
                    {
                        // Detener la música actual de batalla.
                        if (
                            variable_instance_exists(
                                id,
                                "musica_batalla_actual"
                            )
                            &&
                            musica_batalla_actual != noone
                        )
                        {
                            if (
                                audio_is_playing(
                                    musica_batalla_actual
                                )
                            )
                            {
                                audio_stop_sound(
                                    musica_batalla_actual
                                );
                            }
                        }


                        // Reproducir la nueva si corresponde.
                        if (
                            _dialogo_actual.music != "stop"
                            &&
                            audio_exists(
                                _dialogo_actual.music
                            )
                        )
                        {
                            musica_batalla_actual =
                                audio_play_sound(
                                    _dialogo_actual.music,
                                    10,
                                    true
                                );
                        }
                    }


                    keyboard_clear(ord("Z"));
                    keyboard_clear(vk_enter);
                }
                else
                {
                    cinematica_activa =
                        false;


                    if (cinematica_terminar_batalla)
                    {
                        for (
                            var _j = 0;
                            _j < array_length(enemigos);
                            _j++
                        )
                        {
                            if (
                                !variable_struct_exists(
                                    enemigos[_j],
                                    "derrotado"
                                )
                                ||
                                !enemigos[_j].derrotado
                            )
                            {
                                enemigos[_j].vida_actual =
                                    0;

                                enemigos[_j].derrotado =
                                    true;

                                scr_marcar_enemigo_muerto(
                                    mapa_enemigos_muertos,
                                    _j
                                );
                            }
                        }


                        if (audio_exists(snd_enemy_killed))
                        {
                            audio_play_sound(
                                snd_enemy_killed,
                                15,
                                false
                            );
                        }


                        if (audio_is_playing(snd_bbs_start))
                        {
                            audio_stop_sound(
                                snd_bbs_start
                            );
                        }


                        if (
                            variable_instance_exists(
                                id,
                                "musica_batalla_actual"
                            )
                            &&
                            musica_batalla_actual != noone
                            &&
                            audio_is_playing(
                                musica_batalla_actual
                            )
                        )
                        {
                            audio_stop_sound(
                                musica_batalla_actual
                            );
                        }


                        if (instance_exists(obj_batalla_ui))
                        {
                            obj_batalla_ui.f_iniciar_victoria();
                        }


                        fase_actual =
                            FASE_BATALLA.VICTORIA;
                    }
                    else
                    {
                        fase_actual =
                            FASE_BATALLA.JUGADOR_MENU;


                        if (instance_exists(obj_batalla_ui))
                        {
                            obj_batalla_ui.en_resultado_ataque =
                                false;

                            obj_batalla_ui.en_menu_fight =
                                false;

                            obj_batalla_ui.en_seleccion_enemigo =
                                false;


                            if (
                                variable_instance_exists(
                                    obj_batalla_ui,
                                    "en_menu_act"
                                )
                            )
                            {
                                obj_batalla_ui.en_menu_act =
                                    false;
                            }


                            if (
                                variable_instance_exists(
                                    obj_batalla_ui,
                                    "en_menu_item"
                                )
                            )
                            {
                                obj_batalla_ui.en_menu_item =
                                    false;
                            }


                            if (
                                variable_instance_exists(
                                    obj_batalla_ui,
                                    "en_menu_mercy"
                                )
                            )
                            {
                                obj_batalla_ui.en_menu_mercy =
                                    false;
                            }


                            var _txt =
                                array_length(dialogos_turno_actual) > 0
                                ?
                                dialogos_turno_actual[
                                    irandom(
                                        array_length(dialogos_turno_actual) - 1
                                    )
                                ]
                                :
                                obj_batalla_ui.texto_inicio_batalla;


                            obj_batalla_ui.f_procesar_dialogo(
                                _txt
                            );
                        }
                    }
                }
            }
        }

        break;


    // =====================================================
    // VICTORIA
    // =====================================================

    case FASE_BATALLA.VICTORIA:

        if (victoria_finalizada)
        {
            fase_actual =
                FASE_BATALLA.HUIR;
        }

        break;


    // =====================================================
    // HUIR / SALIR
    // =====================================================

    case FASE_BATALLA.HUIR:

        if (
            variable_instance_exists(
                id,
                "mapa_enemigos_muertos"
            )
            &&
            ds_exists(
                mapa_enemigos_muertos,
                ds_type_map
            )
        )
        {
            ds_map_destroy(
                mapa_enemigos_muertos
            );
        }


        if (audio_is_playing(snd_bbs_start))
        {
            audio_stop_sound(
                snd_bbs_start
            );
        }


        if (
            variable_instance_exists(
                id,
                "musica_batalla_actual"
            )
            &&
            musica_batalla_actual != noone
            &&
            audio_is_playing(
                musica_batalla_actual
            )
        )
        {
            audio_stop_sound(
                musica_batalla_actual
            );
        }


        audio_resume_all();


        if (!instance_exists(obj_transicion_salida_bbs))
        {
            instance_create_layer(
                x,
                y,
                layer,
                obj_transicion_salida_bbs
            );
        }
        else
        {
            instance_destroy();
        }

        break;


    // =====================================================
    // DERROTA
    // =====================================================

    case FASE_BATALLA.DERROTA:

        break;
}
