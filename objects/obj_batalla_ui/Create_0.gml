
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


// =========================================================
// TIMING DE ATAQUE ESTILO UNDERTALE
// =========================================================
//
// Flujo:
//
// seleccionar enemigo
//     -> Atacar
//     -> aparece spr_target_bbs
//     -> spr_barra_bbs cruza la caja
//     -> Z / Enter detiene la barra
//     -> daño según cercanía al centro
//
// Si no se pulsa nada y la barra llega al otro extremo:
//
//     MISS
//
// =========================================================

attack_timing_active = false;
attack_timing_stopped = false;
attack_feedback_active = false;

attack_target_idx = -1;
attack_bar_x = 0;
attack_bar_min_x = 0;
attack_bar_max_x = 0;
attack_bar_center_x = 0;
attack_bar_direction = 1;
attack_bar_anim_index = 0;


// =========================================================
// ESCALA VISUAL DEL TARGET / BARRA
// =========================================================
//
// Se calcula al iniciar cada timing usando el tamaño REAL
// de la caja principal.
//
// Son escalas en coordenadas BASE 320x240.
// Draw GUI después las multiplica por _s.
//
attack_target_scale_base = 1.0;

// Target puede estirarse horizontalmente para ocupar también
// los laterales de la caja sin aumentar su altura.
attack_target_xscale_base = 1.0;
attack_target_yscale_base = 1.0;

attack_bar_scale_base = 1.0;


// Coordenadas en el sistema BASE 320x240.
// Draw GUI las multiplica por _s.
attack_bar_speed = 7.0;

// Radio alrededor del centro que cuenta como golpe perfecto.
// Así no dependemos de acertar literalmente un único píxel.
attack_perfect_radius = 4.0;

// Al pulsar Z / Enter, la barra queda congelada EXACTAMENTE
// 1 segundo antes de aplicar daño y continuar.
//
// Juego a 30 FPS:
//     30 frames = 1 segundo.
attack_stop_hold_frames = 30;
attack_stop_timer = 0;

attack_base_damage = 0;
attack_damage_done = 0;
attack_was_miss = false;
attack_result_text = "";

// =========================================================
// POPUP DE DAÑO / MISS
// =========================================================
//
// Fases:
//
// 1) salto + rebote
// 2) quedarse COMPLETAMENTE visible 1 segundo
// 3) fade out
//
// El juego corre a 30 FPS.
//
attack_feedback_timer = 0;

attack_feedback_bounce_frames = 18;
attack_feedback_hold_frames = 30;
attack_feedback_fade_frames = 12;

attack_feedback_duration =
    attack_feedback_bounce_frames
    +
    attack_feedback_hold_frames
    +
    attack_feedback_fade_frames;

attack_feedback_damage = 0;
attack_feedback_miss = false;

// Números y MISS a la mitad del tamaño anterior.
attack_feedback_scale = 0.5;


// =========================================================
// CALCULAR DAÑO MÁXIMO DEL ATAQUE
// =========================================================
//
// Conserva la fórmula que ya usaba tu batalla:
//
//     10 + ataque * 2 - defensa
//
// Ese es el daño que se consigue en el centro.
// =========================================================

f_calcular_dano_maximo = function(_enemy_idx)
{
    if (
        _enemy_idx < 0
        ||
        _enemy_idx >= array_length(enemigos)
    )
    {
        return 1;
    }


    var _en = enemigos[_enemy_idx];
    var _atk_base = 0;


    if (instance_exists(obj_player))
    {
        _atk_base = obj_player.ataque_base;


        if (variable_global_exists("equip_db"))
        {
            if (
                is_struct(obj_player.equipo_arma)
                &&
                variable_struct_exists(
                    obj_player.equipo_arma,
                    "ataque"
                )
            )
            {
                _atk_base +=
                    obj_player.equipo_arma.ataque;
            }
            else if (obj_player.equipo_arma != -1)
            {
                var _arma =
                    global.equip_db[$ obj_player.equipo_arma];


                if (
                    _arma != undefined
                    &&
                    is_struct(_arma)
                    &&
                    variable_struct_exists(_arma, "ataque")
                )
                {
                    _atk_base +=
                        _arma.ataque;
                }
            }
        }
    }


    var _def_enemigo =
        variable_struct_exists(_en, "defensa")
        ?
        _en.defensa
        :
        0;


    var _reduccion_defensa =
        variable_struct_exists(_en, "defensa_reducida")
        ?
        _en.defensa_reducida
        :
        0;


    var _multiplicador_defensa =
        max(
            0,
            1 - (_reduccion_defensa * 0.08)
        );


    var _defensa_real =
        max(
            0,
            round(
                _def_enemigo
                *
                _multiplicador_defensa
            )
        );


    return max(
        1,
        10 + (_atk_base * 2) - _defensa_real
    );
};


// =========================================================
// INICIAR EL TIMING
// =========================================================

f_iniciar_timing_ataque = function(_enemy_idx)
{
    attack_target_idx =
        clamp(
            _enemy_idx,
            0,
            array_length(enemigos) - 1
        );


    attack_base_damage =
        f_calcular_dano_maximo(
            attack_target_idx
        );


    // =====================================================
    // CAJA PRINCIPAL EN COORDENADAS BASE 320x240
    // =====================================================

    var _box_left = 14;


    var _box_width =
        sprite_get_width(spr_bbs_textbox)
        *
        5.666667;


    var _box_height =
        sprite_get_height(spr_bbs_textbox);


    // =====================================================
    // TARGET AUTOESCALADO A LA CAJA
    // =====================================================
    //
    // Se mantiene su proporción original y se hace tan grande
    // como sea posible SIN salirse del interior del textbox.
    //
    // Dejamos 4 px de margen por cada lado.
    // =====================================================

    var _visual_margin =
        4;


    var _target_w =
        max(
            1,
            sprite_get_width(spr_target_bbs)
        );


    var _target_h =
        max(
            1,
            sprite_get_height(spr_target_bbs)
        );


    var _target_fit_w =
        max(
            1,
            _box_width
            -
            (_visual_margin * 2)
        )
        /
        _target_w;


    var _target_fit_h =
        max(
            1,
            _box_height
            -
            (_visual_margin * 2)
        )
        /
        _target_h;


    // =====================================================
    // TARGET: ALTURA CONTROLADA + ANCHO EXTENDIDO
    // =====================================================
    //
    // Antes usábamos el menor de ambos factores:
    //
    //     min(width_fit, height_fit)
    //
    // Eso preservaba proporción, pero si la altura era el
    // límite el target quedaba corto en los laterales.
    //
    // Ahora:
    //
    //     Y = factor que cabe verticalmente
    //     X = factor que llena horizontalmente
    //
    // Por tanto llega prácticamente a ambos lados de la caja
    // sin hacerse más alto.
    // =====================================================

    attack_target_yscale_base =
        min(
            _target_fit_w,
            _target_fit_h
        );


    attack_target_xscale_base =
        _target_fit_w;


    // Se conserva como referencia uniforme.
    attack_target_scale_base =
        attack_target_yscale_base;


    // =====================================================
    // BARRA
    // =====================================================
    //
    // La barra conserva la escala proporcional que ya se veía
    // bien en V2. El ensanchamiento adicional afecta SOLO al
    // target, no convierte la barra en una franja gruesa.
    // =====================================================

    attack_bar_scale_base =
        attack_target_yscale_base;


    var _bar_half =
        sprite_get_width(spr_barra_bbs)
        *
        attack_bar_scale_base
        *
        0.5;


    var _margin =
        8;


    attack_bar_min_x =
        _box_left
        +
        _margin
        +
        _bar_half;


    attack_bar_max_x =
        _box_left
        +
        _box_width
        -
        _margin
        -
        _bar_half;


    attack_bar_center_x =
        (
            attack_bar_min_x
            +
            attack_bar_max_x
        )
        *
        0.5;


    // 50 / 50: izquierda -> derecha o derecha -> izquierda.
    attack_bar_direction =
        (irandom(1) == 0)
        ?
        1
        :
        -1;


    attack_bar_x =
        (attack_bar_direction > 0)
        ?
        attack_bar_min_x
        :
        attack_bar_max_x;


    attack_bar_anim_index = 0;
    attack_stop_timer = 0;

    attack_damage_done = 0;
    attack_was_miss = false;
    attack_result_text = "";

    attack_feedback_timer = 0;
    attack_feedback_damage = 0;
    attack_feedback_miss = false;

    attack_timing_active = true;
    attack_timing_stopped = false;
    attack_feedback_active = false;


    // Ocultar cualquier contenido de texto mientras aparece
    // la interfaz del timing.
    head_sprite = noone;
    head_visible = false;
    text_to_draw = "";
    text_length = 0;
    draw_char = 0;
    setup = false;


    en_menu_fight = false;
    en_seleccion_enemigo = false;
    en_modo_info = false;


    // La pulsación que eligió "Atacar" no puede detener
    // también la barra en el mismo instante.
    keyboard_clear(ord("Z"));
    keyboard_clear(vk_enter);
};


// =========================================================
// RESOLVER HIT / MISS
// =========================================================

f_resolver_timing_ataque = function(_miss)
{
    if (
        attack_target_idx < 0
        ||
        attack_target_idx >= array_length(enemigos)
    )
    {
        return;
    }


    var _en =
        enemigos[attack_target_idx];


    attack_was_miss =
        _miss;


    // =====================================================
    // MISS
    // =====================================================

    if (_miss)
    {
        attack_damage_done = 0;
        attack_feedback_damage = 0;
        attack_feedback_miss = true;

        attack_result_text =
            scr_loc_src(
                "* Fallaste el ataque."
            );

        return;
    }


    // =====================================================
    // CALIDAD DEL GOLPE
    // =====================================================

    var _distance_center =
        abs(
            attack_bar_x
            -
            attack_bar_center_x
        );


    var _half_range =
        max(
            1,
            attack_bar_max_x
            -
            attack_bar_center_x
        );


    var _quality = 1;


    if (_distance_center > attack_perfect_radius)
    {
        _quality =
            1
            -
            (
                (_distance_center - attack_perfect_radius)
                /
                max(
                    1,
                    _half_range - attack_perfect_radius
                )
            );
    }


    _quality =
        clamp(
            _quality,
            0,
            1
        );


    // Si el jugador sí pulsó Z/Enter, incluso muy cerca del
    // borde se garantiza al menos 1 de daño.
    var _damage =
        max(
            1,
            round(
                attack_base_damage
                *
                _quality
            )
        );


    attack_damage_done =
        _damage;

    attack_feedback_damage =
        _damage;

    attack_feedback_miss =
        false;


    _en.vida_actual -=
        _damage;

    _en.shake_timer =
        15;


    if (audio_is_playing(snd_shake))
    {
        audio_stop_sound(snd_shake);
    }


    audio_play_sound(
        snd_shake,
        10,
        false
    );


    // =====================================================
    // ENEMIGO DERROTADO
    // =====================================================

    if (_en.vida_actual <= 0)
    {
        _en.vida_actual = 0;
        _en.derrotado = true;


        if (
            instance_exists(obj_batalla_controller)
            &&
            variable_instance_exists(
                obj_batalla_controller,
                "mapa_enemigos_muertos"
            )
        )
        {
            scr_marcar_enemigo_muerto(
                obj_batalla_controller.mapa_enemigos_muertos,
                attack_target_idx
            );
        }


        audio_play_sound(
            snd_enemy_killed,
            10,
            false
        );


        attack_result_text =
            variable_struct_exists(_en, "texto_muerte")
            ?
            string_replace_all(
                _en.texto_muerte,
                "\n",
                " "
            )
            :
            scr_locf(
                "* Venciste a {enemy}!",
                {
                    enemy: scr_loc(_en.nombre)
                }
            );


        var _todos_muertos =
            true;


        for (
            var _i = 0;
            _i < array_length(enemigos);
            _i++
        )
        {
            if (
                !variable_struct_exists(
                    enemigos[_i],
                    "derrotado"
                )
                ||
                !enemigos[_i].derrotado
            )
            {
                _todos_muertos = false;
                break;
            }
        }


        if (_todos_muertos)
        {
            if (audio_is_playing(snd_bbs_start))
            {
                audio_stop_sound(snd_bbs_start);
            }


            if (
                instance_exists(obj_batalla_controller)
                &&
                variable_instance_exists(
                    obj_batalla_controller,
                    "musica_batalla_actual"
                )
            )
            {
                var _musica_real =
                    obj_batalla_controller.musica_batalla_actual;


                if (
                    _musica_real != noone
                    &&
                    audio_is_playing(_musica_real)
                )
                {
                    audio_stop_sound(_musica_real);
                }
            }


            if (
                musica_batalla_actual != noone
                &&
                audio_is_playing(musica_batalla_actual)
            )
            {
                audio_stop_sound(musica_batalla_actual);
            }
        }
    }
    else
    {
        attack_result_text =
            scr_locf(
                "* Hiciste {damage} de daño a {enemy}!",
                {
                    damage: string(_damage),
                    enemy: scr_loc(_en.nombre)
                }
            );
    }
};

// VARIABLES DE INVENTARIO EN BATALLA
en_menu_inventario = false;
inv_x = 0;
inv_y = 0;
inv_scroll = 0;
en_item_resultado = false;

// INVENTARIO DE TOYS EN BATALLA
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
victoria_so = 0;
victoria_nivel_antes = 1;
victoria_sonido_nivel_reproducido = false;

// Evita cobrar dos veces si dos caminos llegan a victoria.
victoria_recompensa_aplicada = false;

ui_x_caja_izq = 30;
ui_y_caja_izq = 640;
ui_x_caja_der = 420;
ui_y_caja_der = 640;

// CONTROL DE CABEZA DEL PROTAGONISTA
head_sprite = noone;
head_visible = false;

// MÉTODO GLOBAL DE INSTANCIA PARA PROCESAR DIÁLOGOS
f_procesar_dialogo = function(_entrada) {
    head_sprite = noone;
    head_visible = false;
    text_sound_custom = snd_text;

    if (is_struct(_entrada)) {
        var _txt = variable_struct_exists(_entrada, "texto") ? _entrada.texto : "";
        text_to_draw = scr_loc(is_string(_txt) ? _txt : string(_txt));
        
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
        text_to_draw = scr_loc(string(_entrada));
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
// INICIAR VICTORIA
// =========================================================
//
// Centraliza:
// - XP mostrada
// - SO mostrados
// - entrega de Sueños una sola vez
// - texto final de victoria
// =========================================================

f_iniciar_victoria = function()
{
    en_dialogo_victoria_final = true;
    victoria_etapa = 0;
    victoria_sonido_nivel_reproducido = false;

    victoria_xp = 0;
    victoria_so = 0;

    var _bc =
        instance_find(
            obj_batalla_controller,
            0
        );

    if (_bc != noone)
    {
        if (
            variable_instance_exists(
                _bc,
                "experiencia_batalla"
            )
        )
        {
            victoria_xp =
                max(
                    0,
                    round(_bc.experiencia_batalla)
                );
        }

        if (
            variable_instance_exists(
                _bc,
                "suenos_batalla"
            )
        )
        {
            victoria_so =
                max(
                    0,
                    round(_bc.suenos_batalla)
                );
        }
    }

    // Los Sueños viven dentro de level_data.
    // Así se guardan/cargan con el sistema que ya tienes
    // y una Nueva Partida los reinicia junto con level_data.
    if (
        variable_global_exists("level_data")
        &&
        is_struct(global.level_data)
    )
    {
        if (
            !variable_struct_exists(
                global.level_data,
                "suenos"
            )
        )
        {
            global.level_data.suenos = 0;
        }

        if (!victoria_recompensa_aplicada)
        {
            global.level_data.suenos +=
                victoria_so;

            victoria_recompensa_aplicada =
                true;
        }
    }

    f_procesar_dialogo(
        scr_locf(
            "* ¡Has ganado la batalla! Conseguiste {xp} de XP y {so} de SO",
            {
                xp: string(victoria_xp),
                so: string(victoria_so)
            }
        )
    );
};


audio_pause_all();

if (!variable_global_exists("enemigo_actual_id")) {
    global.enemigo_actual_id = "variante 1";
}

var _datos_variante = scr_enemigos_data(global.enemigo_actual_id);

enemigos = _datos_variante.enemigos;
musica_batalla_actual = _datos_variante.musica;

fondo_batalla =
    variable_struct_exists(_datos_variante, "fondo")
    ? _datos_variante.fondo
    : noone;

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

var _raw_inicio = (array_length(enemigos) > 0 && variable_struct_exists(enemigos[0], "texto_inicio")) ? enemigos[0].texto_inicio : scr_loc_src("¡Un combate comienza!");

f_procesar_dialogo(_raw_inicio);
texto_inicio_batalla = text_to_draw; 

text_spd = 1;
text_sound_timer = 0;
text_sound_delay = 2;
line_break_num = 0;
