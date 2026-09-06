
// =========================================================
// EVENTO: DRAW GUI
// =========================================================
// =========================================================
// NO DIBUJAR BATALLA DENTRO DE GAME OVER
// =========================================================
//
// Durante el segundo congelado seguimos en room bbs y la UI
// permanece visible.
//
// En cuanto room ya ES game_over:
//
//     persistent = false
//     destruir
//     NO dibujar ni un frame de la batalla.
//
// =========================================================

if (room == game_over)
{
    persistent =
        false;

    instance_destroy();

    exit;
}


var _s = 2;

if (!variable_instance_exists(id, "alpha_aparicion")) alpha_aparicion = 0.0;
if (!variable_instance_exists(id, "timer_dolor")) timer_dolor = 0;
if (!variable_instance_exists(id, "hp_anterior")) hp_anterior = -1;

if (alpha_aparicion < 1.0) alpha_aparicion += 0.05;

var _fade_transicion = 1.0;

if (instance_exists(obj_transicion_bbs)) {
    _fade_transicion = obj_transicion_bbs.image_alpha;
}

var _alpha_final = alpha_aparicion * _fade_transicion * alpha_salida;

if (!variable_instance_exists(id, "enemigo_img_index")) {
    enemigo_img_index = 0;
}

var _total_enemigos = array_length(enemigos);
var _centro_pantalla_x = (320 * _s) / 2;

for (var i = 0; i < _total_enemigos; i++) {
    var _en = enemigos[i];
    var _en_x = _centro_pantalla_x;
    var _en_y = 75 * _s;
    
    if (_total_enemigos == 1) {
        _en_x = _centro_pantalla_x;
    } else if (_total_enemigos == 2) {
        if (i == 0) _en_x = _centro_pantalla_x - (50 * _s);
        if (i == 1) _en_x = _centro_pantalla_x + (50 * _s);
    } else if (_total_enemigos >= 3) {
        if (i == 0) _en_x = _centro_pantalla_x - (75 * _s);
        if (i == 1) _en_x = _centro_pantalla_x;
        if (i == 2) _en_x = _centro_pantalla_x + (75 * _s);
    }
    
    var _derrotado = variable_struct_exists(_en, "derrotado") && _en.derrotado;
    
    if (!_derrotado && variable_struct_exists(_en, "shake_timer") && _en.shake_timer > 0) {
        _en_x += irandom_range(-2, 2) * _s;
        _en_y += irandom_range(-2, 2) * _s;
    }
    
    var _en_color = _derrotado ? make_color_rgb(40, 40, 40) : c_white;
    var _img_idx = _derrotado ? 0 : _en.anim_index;
    var _escala = variable_struct_exists(_en, "escala_sprite") ? _en.escala_sprite : 2.0;
    
    draw_sprite_ext(
        _en.sprite,
        _img_idx,
        _en_x,
        _en_y,
        _escala * _s,
        _escala * _s,
        0,
        _en_color,
        _alpha_final
    );
    
    if (en_seleccion_enemigo && enemigo_seleccionado_idx == i) {
        var _txt_color_sel = _derrotado ? c_gray : c_yellow;
        
        draw_text_color(
            _en_x - (string_width(_en.nombre) * 0.5 * 0.7 * _s),
            _en_y - (45 * _s),
            "v " + scr_loc(_en.nombre),
            _txt_color_sel,
            _txt_color_sel,
            _txt_color_sel,
            _txt_color_sel,
            _alpha_final
        );
    }
}


// =========================================================
// POPUP DE DAÑO / MISS JUNTO AL ENEMIGO
// =========================================================

if (
    attack_feedback_active
    &&
    attack_target_idx >= 0
    &&
    attack_target_idx < array_length(enemigos)
)
{
    var _popup_idx =
        attack_target_idx;


    var _popup_enemy =
        enemigos[_popup_idx];


    var _popup_enemy_x =
        _centro_pantalla_x;


    var _popup_enemy_y =
        75 * _s;


    if (_total_enemigos == 2)
    {
        if (_popup_idx == 0)
        {
            _popup_enemy_x =
                _centro_pantalla_x
                -
                (50 * _s);
        }
        else if (_popup_idx == 1)
        {
            _popup_enemy_x =
                _centro_pantalla_x
                +
                (50 * _s);
        }
    }
    else if (_total_enemigos >= 3)
    {
        if (_popup_idx == 0)
        {
            _popup_enemy_x =
                _centro_pantalla_x
                -
                (75 * _s);
        }
        else if (_popup_idx == 1)
        {
            _popup_enemy_x =
                _centro_pantalla_x;
        }
        else if (_popup_idx == 2)
        {
            _popup_enemy_x =
                _centro_pantalla_x
                +
                (75 * _s);
        }
    }


    var _popup_enemy_scale =
        variable_struct_exists(
            _popup_enemy,
            "escala_sprite"
        )
        ?
        _popup_enemy.escala_sprite
        :
        2.0;


    var _enemy_half_w =
        sprite_get_width(_popup_enemy.sprite)
        *
        _popup_enemy_scale
        *
        _s
        *
        0.5;


    var _side =
        (_popup_enemy_x > _centro_pantalla_x)
        ?
        -1
        :
        1;


    var _popup_x =
        _popup_enemy_x
        +
        (
            _side
            *
            (
                _enemy_half_w
                +
                (10 * _s)
            )
        );


    // Evitar que se salga de la pantalla.
    _popup_x =
        clamp(
            _popup_x,
            18 * _s,
            302 * _s
        );


    // =====================================================
    // FASES DEL POPUP
    // =====================================================

    var _popup_timer =
        attack_feedback_timer;


    var _bounce_frames =
        max(
            1,
            attack_feedback_bounce_frames
        );


    var _hold_frames =
        max(
            0,
            attack_feedback_hold_frames
        );


    var _fade_frames =
        max(
            1,
            attack_feedback_fade_frames
        );


    var _bounce_end =
        _bounce_frames;


    var _hold_end =
        _bounce_end
        +
        _hold_frames;


    var _fade_end =
        _hold_end
        +
        _fade_frames;


    // =====================================================
    // ALPHA
    // =====================================================
    //
    // Durante salto/rebote y el segundo de espera:
    //     alpha = 1
    //
    // Solo desaparece al FINAL.
    // =====================================================

    var _popup_alpha =
        1;


    if (_popup_timer >= _hold_end)
    {
        var _fade_t =
            clamp(
                (_popup_timer - _hold_end)
                /
                _fade_frames,
                0,
                1
            );


        _popup_alpha =
            1
            -
            _fade_t;
    }


    // Pequeño fade-in de apenas 3 frames al aparecer.
    if (_popup_timer < 3)
    {
        _popup_alpha *=
            clamp(
                _popup_timer
                /
                3,
                0,
                1
            );
    }


    _popup_alpha *=
        _alpha_final;


    // =====================================================
    // SALTO + REBOTE
    // =====================================================
    //
    // Primera parte:
    //     salto grande y aterrizaje.
    //
    // Segunda parte:
    //     rebote pequeño.
    //
    // Después:
    //     queda inmóvil durante 30 frames.
    // =====================================================

    var _jump_y =
        0;


    if (_popup_timer < _bounce_frames)
    {
        var _first_jump_frames =
            12;


        if (_popup_timer < _first_jump_frames)
        {
            var _jump_t =
                clamp(
                    _popup_timer
                    /
                    _first_jump_frames,
                    0,
                    1
                );


            // Parábola:
            // 0 -> arriba -> vuelve a 0.
            _jump_y =
                -4
                *
                _jump_t
                *
                (1 - _jump_t)
                *
                (18 * _s);
        }
        else
        {
            var _rebound_frames =
                max(
                    1,
                    _bounce_frames
                    -
                    _first_jump_frames
                );


            var _rebound_t =
                clamp(
                    (_popup_timer - _first_jump_frames)
                    /
                    _rebound_frames,
                    0,
                    1
                );


            // Segundo rebote más pequeño.
            _jump_y =
                -4
                *
                _rebound_t
                *
                (1 - _rebound_t)
                *
                (6 * _s);
        }
    }


    var _popup_y =
        _popup_enemy_y
        -
        (18 * _s)
        +
        _jump_y;


    // =====================================================
    // ESCALA FIJA
    // =====================================================
    //
    // Ya NO crece hacia la cámara / "salta al frente".
    //
    // La única animación espacial es:
    //
    //     salto vertical
    //     +
    //     rebote vertical
    //
    // El tamaño permanece siempre al 50% configurado.
    // =====================================================

    var _popup_scale =
        attack_feedback_scale
        *
        _s;


    // =====================================================
    // MISS
    // =====================================================

    if (attack_feedback_miss)
    {
        var _miss_w =
            sprite_get_width(spr_miss_bbs);


        var _miss_h =
            sprite_get_height(spr_miss_bbs);


        var _miss_draw_x =
            _popup_x
            +
            (
                sprite_get_xoffset(spr_miss_bbs)
                -
                (_miss_w * 0.5)
            )
            *
            _popup_scale;


        var _miss_draw_y =
            _popup_y
            +
            (
                sprite_get_yoffset(spr_miss_bbs)
                -
                (_miss_h * 0.5)
            )
            *
            _popup_scale;


        draw_sprite_ext(
            spr_miss_bbs,
            0,
            _miss_draw_x,
            _miss_draw_y,
            _popup_scale,
            _popup_scale,
            0,
            c_white,
            _popup_alpha
        );
    }


    // =====================================================
    // NÚMERO DE DAÑO
    // =====================================================

    else
    {
        var _damage_text =
            string(attack_feedback_damage);


        var _digit_count =
            string_length(_damage_text);


        var _digit_w =
            sprite_get_width(spr_numeros_bbs)
            *
            _popup_scale;


        // Un pequeño solape hace que 201, 999, etc. se lean
        // como un único número y no como sprites separados.
        var _digit_step =
            _digit_w
            *
            0.82;


        var _number_w =
            (_digit_count <= 1)
            ?
            _digit_w
            :
            _digit_w
            +
            ((_digit_count - 1) * _digit_step);


        var _digit_center_start =
            _popup_x
            -
            (_number_w * 0.5)
            +
            (_digit_w * 0.5);


        for (
            var _d = 1;
            _d <= _digit_count;
            _d++
        )
        {
            var _digit_string =
                string_char_at(
                    _damage_text,
                    _d
                );


            var _digit_frame =
                clamp(
                    real(_digit_string),
                    0,
                    9
                );


            var _digit_center_x =
                _digit_center_start
                +
                ((_d - 1) * _digit_step);


            var _digit_draw_x =
                _digit_center_x
                +
                (
                    sprite_get_xoffset(spr_numeros_bbs)
                    -
                    (sprite_get_width(spr_numeros_bbs) * 0.5)
                )
                *
                _popup_scale;


            var _digit_draw_y =
                _popup_y
                +
                (
                    sprite_get_yoffset(spr_numeros_bbs)
                    -
                    (sprite_get_height(spr_numeros_bbs) * 0.5)
                )
                *
                _popup_scale;


            draw_sprite_ext(
                spr_numeros_bbs,
                _digit_frame,
                _digit_draw_x,
                _digit_draw_y,
                _popup_scale,
                _popup_scale,
                0,
                c_white,
                _popup_alpha
            );
        }
    }
}


draw_sprite_ext(
    spr_bbs_textbox,
    0,
    14 * _s,
    125 * _s,
    5.666667 * _s,
    1.0 * _s,
    0,
    c_white,
    _alpha_final
);

if (variable_global_exists("font_main")) {
    draw_set_font(global.font_main);
}

// CAJA PRINCIPAL DE DIÁLOGO / MENÚ
if ((!variable_instance_exists(id, "en_menu_inventario") || !en_menu_inventario) && (!variable_instance_exists(id, "en_menu_toys") || !en_menu_toys)) {
    
    var _tiene_cabeza = false;
    
    if (
        head_visible &&
        head_sprite != noone &&
        sprite_exists(head_sprite) &&
        string_length(text_to_draw) > 0 &&
        draw_char > 0 &&
        !en_seleccion_enemigo &&
        !en_menu_fight &&
        !en_modo_info &&
        !en_menu_inventario
    ) {
        _tiene_cabeza = true;
    }
    
    var _p_left_margin = _tiene_cabeza ? (65 * _s) : (24 * _s);
    var _p_avail_width = _tiene_cabeza ? (200 * _s) : (250 * _s);
    
    if (setup == false) {
        setup = true;
        text_length = string_length(text_to_draw);
        
        var _last_space = -1;
        var _line_start_char = 1;
        line_break_num = 0;
        
        for (var c = 1; c <= text_length; c++) {
            var _char_current = string_char_at(text_to_draw, c);
            
            if (_char_current == " ") {
                _last_space = c;
            }
            
            var _sub_str = string_copy(
                text_to_draw,
                _line_start_char,
                c - _line_start_char + 1
            );
            
            var _str_w = string_width(_sub_str);
            
            if (_str_w > _p_avail_width) {
                if (_last_space != -1 && _last_space >= _line_start_char) {
                    line_break_pos[line_break_num] = _last_space + 1;
                    line_break_num++;
                    _line_start_char = _last_space + 1;
                    _last_space = -1;
                } else {
                    line_break_pos[line_break_num] = c;
                    line_break_num++;
                    _line_start_char = c;
                    _last_space = -1;
                }
            }
        }
        
        for (var c = 0; c < text_length; c++) {
            var _char_pos = c + 1;
            char_array[c] = string_char_at(text_to_draw, _char_pos);
            
            var _txt_x = (14 * _s) + _p_left_margin;
            var _txt_y = (125 * _s) + (8 * _s) + (1 * _s);
            
            var _txt_line = 0;
            var _line_start_pos = 1;
            
            for (var lb = 0; lb < line_break_num; lb++) {
                if (_char_pos >= line_break_pos[lb]) {
                    _txt_line = lb + 1;
                    _line_start_pos = line_break_pos[lb];
                }
            }
            
            if (_line_start_pos == _char_pos && char_array[c] == " ") {
                char_x[c] = -9999;
                char_y[c] = -9999;
                continue;
            }
            
            var _str_copy = string_copy(
                text_to_draw,
                _line_start_pos,
                _char_pos - _line_start_pos + 1
            );
            
            var _current_txt_w = string_width(_str_copy);
            
            char_x[c] = _txt_x + _current_txt_w - string_width(char_array[c]);
            char_y[c] = _txt_y + (_txt_line * (18 * _s));
        }
    }
    
    // DIBUJAR CABEZA
    if (_tiene_cabeza) {
        var _head_scale = 1.35 * _s;
        
        draw_sprite_ext(
            head_sprite,
            0,
            (14 + 10) * _s,
            (125 + 10) * _s,
            _head_scale,
            _head_scale,
            0,
            c_white,
            _alpha_final
        );
    }
    
    // =====================================================
    // TIMING DE ATAQUE
    // =====================================================

    if (attack_timing_active || attack_timing_stopped)
    {
        var _attack_box_left =
            14 * _s;


        var _attack_box_top =
            125 * _s;


        var _attack_box_w =
            sprite_get_width(spr_bbs_textbox)
            *
            5.666667
            *
            _s;


        var _attack_box_h =
            sprite_get_height(spr_bbs_textbox)
            *
            _s;


        var _attack_center_y =
            _attack_box_top
            +
            (_attack_box_h * 0.5);


        var _attack_center_x =
            attack_bar_center_x
            *
            _s;


        // -------------------------------------------------
        // TARGET
        // -------------------------------------------------

        // =================================================
        // TARGET
        // =================================================
        //
        // Y conserva la altura correcta de V2.
        // X se extiende hasta los laterales internos del
        // textbox.
        // =================================================

        var _target_scale_x =
            attack_target_xscale_base
            *
            _s;


        var _target_scale_y =
            attack_target_yscale_base
            *
            _s;


        var _target_draw_x =
            _attack_center_x
            +
            (
                sprite_get_xoffset(spr_target_bbs)
                -
                (sprite_get_width(spr_target_bbs) * 0.5)
            )
            *
            _target_scale_x;


        var _target_draw_y =
            _attack_center_y
            +
            (
                sprite_get_yoffset(spr_target_bbs)
                -
                (sprite_get_height(spr_target_bbs) * 0.5)
            )
            *
            _target_scale_y;


        draw_sprite_ext(
            spr_target_bbs,
            0,
            _target_draw_x,
            _target_draw_y,
            _target_scale_x,
            _target_scale_y,
            0,
            c_white,
            _alpha_final
        );


        // -------------------------------------------------
        // BARRA
        // -------------------------------------------------

        // La barra usa exactamente el mismo factor
        // proporcional que el target.
        var _bar_scale =
            attack_bar_scale_base
            *
            _s;


        var _bar_center_x_gui =
            attack_bar_x
            *
            _s;


        var _bar_draw_x =
            _bar_center_x_gui
            +
            (
                sprite_get_xoffset(spr_barra_bbs)
                -
                (sprite_get_width(spr_barra_bbs) * 0.5)
            )
            *
            _bar_scale;


        var _bar_draw_y =
            _attack_center_y
            +
            (
                sprite_get_yoffset(spr_barra_bbs)
                -
                (sprite_get_height(spr_barra_bbs) * 0.5)
            )
            *
            _bar_scale;


        var _bar_frame =
            clamp(
                floor(attack_bar_anim_index),
                0,
                sprite_get_number(spr_barra_bbs) - 1
            );


        draw_sprite_ext(
            spr_barra_bbs,
            _bar_frame,
            _bar_draw_x,
            _bar_draw_y,
            _bar_scale,
            _bar_scale,
            0,
            c_white,
            _alpha_final
        );
    }

    // SELECCIÓN DE ENEMIGO
    else if (en_seleccion_enemigo) {
        var _texto_seleccion = (toy_selected_key != -1) ? scr_loc("* Elige a quien usar el toy!") : scr_loc("* Elige a quien atacar!");

        draw_text_color(
            (14 + 16) * _s,
            (125 + 10) * _s,
            scr_loc("¡Elige el enemigo!"),
            c_white,
            c_white,
            c_white,
            c_white,
            _alpha_final
        );
        
    // MENÚ FIGHT
    } else if (en_menu_fight && !en_modo_info) {
        var _tx = (14 + 16) * _s;
        var _ty = (125 + 10) * _s;
        var _op = [scr_loc_src("* Atacar"), scr_loc_src("* Info")];
        
        for (var i = 0; i < 2; i++) {
            var _col = (opcion_fight_seleccionada == i) ? c_yellow : c_white;
            
            draw_text_color(
                _tx + (i * 120 * _s),
                _ty,
                scr_loc(_op[i]),
                _col,
                _col,
                _col,
                _col,
                _alpha_final
            );
        }
        
        var _en_activo = enemigos[enemigo_seleccionado_idx];
        var _bar_en_x = _tx;
        var _bar_en_y = _ty + (20 * _s);
        var _bar_en_w = (string_width(scr_loc("* Atacar")) * _s) * 0.75;
        var _bar_en_h = 5 * _s;
        var _vida_act = _en_activo.vida_actual;
        var _vida_max = _en_activo.vida_max;
        
        draw_set_alpha(_alpha_final);
        
        draw_rectangle_color(
            _bar_en_x,
            _bar_en_y,
            _bar_en_x + _bar_en_w,
            _bar_en_y + _bar_en_h,
            c_yellow,
            c_yellow,
            c_yellow,
            c_yellow,
            false
        );
        
        var _porcentaje_vida_en = clamp(_vida_act / _vida_max, 0, 1);
        var _current_en_w = _bar_en_w * _porcentaje_vida_en;
        
        if (_current_en_w > 0) {
            draw_rectangle_color(
                _bar_en_x,
                _bar_en_y,
                _bar_en_x + _current_en_w,
                _bar_en_y + _bar_en_h,
                c_lime,
                c_lime,
                c_lime,
                c_lime,
                false
            );
        }
        
        draw_set_alpha(1.0);
        
    // TEXTO NORMAL O CINEMÁTICA
    } else {
        var _caracteres_visibles = floor(draw_char);
        
        if (
            variable_instance_exists(id, "char_x") &&
            variable_instance_exists(id, "char_array")
        ) {
            for (var c = 0; c < _caracteres_visibles; c++) {
                if (
                    c < array_length(char_x) &&
                    char_x[c] != -9999
                ) {
                    draw_text_color(
                        char_x[c],
                        char_y[c],
                        char_array[c],
                        c_white,
                        c_white,
                        c_white,
                        c_white,
                        _alpha_final
                    );
                }
            }
        }
    }
    
} else if (en_menu_inventario) {
    
    // INVENTARIO
    var _start_x = (14 * _s) + (18 * _s);
    var _start_y = (125 * _s) + (8 * _s);
    
    if (
        instance_exists(obj_player) &&
        variable_instance_exists(obj_player, "inventory")
    ) {
        for (var i = 0; i < 4; i++) {
            var _index = i + (inv_scroll * 2);
            var _col = i % 2;
            var _row = floor(i / 2);
            
            var _cx = _start_x + (_col * (130 * _s));
            var _cy = _start_y + (_row * (18 * _s));
            
            var _is_selected = (inv_x == _col && inv_y == _row);
            
            if (_index < array_length(obj_player.inventory)) {
                var _item_key = obj_player.inventory[_index];
                
                var _nombre_item =
                    (_item_key != -1 && _item_key != undefined)
                    ?
                    (
                        variable_global_exists("item_db") &&
                        global.item_db[$ _item_key] != undefined
                        ?
                        scr_loc(global.item_db[$ _item_key].nombre)
                        :
                        string(_item_key)
                    )
                    :
                    "-----";
                
                var _txt_color = _is_selected ? c_yellow : c_white;
                
                if (_item_key == -1 || _item_key == undefined) {
                    _txt_color = _is_selected ? c_yellow : c_gray;
                }
                
                draw_text_transformed_color(
                    _cx,
                    _cy,
                    "* " + _nombre_item,
                    0.8,
                    0.8,
                    0,
                    _txt_color,
                    _txt_color,
                    _txt_color,
                    _txt_color,
                    _alpha_final
                );
            }
        }
        
        var _total_items = array_length(obj_player.inventory);
        var _items_por_fila = 2;
        var _filas_totales = ceil(_total_items / _items_por_fila);
        var _filas_visibles = 2;
        
        if (_filas_totales > _filas_visibles) {
            var _bar_x = (14 * _s) + (268 * _s);
            var _bar_y = _start_y;
            var _bar_w = 4 * _s;
            var _bar_h = 36 * _s;
            
            draw_set_alpha(_alpha_final * 0.4);
            
            draw_rectangle_color(
                _bar_x,
                _bar_y,
                _bar_x + _bar_w,
                _bar_y + _bar_h,
                c_gray,
                c_gray,
                c_gray,
                c_gray,
                false
            );
            
            var _max_scroll = _filas_totales - _filas_visibles;
            var _thumb_h = max(
                (_filas_visibles / _filas_totales) * _bar_h,
                8 * _s
            );
            
            var _scroll_ratio = 0;
            
            if (_max_scroll > 0) {
                _scroll_ratio = clamp(
                    inv_scroll / _max_scroll,
                    0,
                    1
                );
            }
            
            var _thumb_y = _bar_y + (_scroll_ratio * (_bar_h - _thumb_h));
            
            draw_set_alpha(_alpha_final);
            
            draw_rectangle_color(
                _bar_x,
                _thumb_y,
                _bar_x + _bar_w,
                _thumb_y + _thumb_h,
                c_white,
                c_white,
                c_white,
                c_white,
                false
            );
            
            draw_set_alpha(1.0);
        }
    }
}

else if (en_menu_toys) {

    var _toy_start_x = (14 * _s) + (18 * _s);
    var _toy_start_y = (125 * _s) + (8 * _s);

    if (variable_global_exists("toy_inventory")) {
        for (var i = 0; i < 4; i++) {
            var _toy_index = i + (toy_scroll * 2);
            var _toy_col = i % 2;
            var _toy_row = floor(i / 2);

            var _toy_cx = _toy_start_x + (_toy_col * (130 * _s));
            var _toy_cy = _toy_start_y + (_toy_row * (18 * _s));
            var _toy_is_selected = (toy_x == _toy_col && toy_y == _toy_row);

            var _toy_key_draw = -1;
            if (_toy_index < array_length(global.toy_inventory)) {
                _toy_key_draw = global.toy_inventory[_toy_index];
            }

            var _toy_nombre = "-----";
            if (_toy_key_draw != -1 && _toy_key_draw != undefined && variable_global_exists("toy_db")) {
                var _toy_data_draw = global.toy_db[$ _toy_key_draw];
                if (_toy_data_draw != undefined) {
                    _toy_nombre = scr_loc(_toy_data_draw.nombre);
                }
            }

            var _toy_txt_color = _toy_is_selected ? c_yellow : c_white;
            if (_toy_key_draw == -1 || _toy_key_draw == undefined) {
                _toy_txt_color = _toy_is_selected ? c_yellow : c_gray;
            }

            draw_text_transformed_color(
                _toy_cx,
                _toy_cy,
                "* " + _toy_nombre,
                0.8,
                0.8,
                0,
                _toy_txt_color,
                _toy_txt_color,
                _toy_txt_color,
                _toy_txt_color,
                _alpha_final
            );
        }

        var _toy_total_slots = array_length(global.toy_inventory);
        var _toy_rows_total = max(1, ceil(_toy_total_slots / 2));
        var _toy_visible_rows = 2;

        if (_toy_rows_total > _toy_visible_rows) {
            var _toy_bar_x = (14 * _s) + (268 * _s);
            var _toy_bar_y = _toy_start_y;
            var _toy_bar_w = 4 * _s;
            var _toy_bar_h = 36 * _s;

            draw_set_alpha(_alpha_final * 0.4);
            draw_rectangle_color(
                _toy_bar_x,
                _toy_bar_y,
                _toy_bar_x + _toy_bar_w,
                _toy_bar_y + _toy_bar_h,
                c_gray,
                c_gray,
                c_gray,
                c_gray,
                false
            );

            var _toy_max_scroll_draw = _toy_rows_total - _toy_visible_rows;
            var _toy_scroll_ratio = (_toy_max_scroll_draw > 0) ? clamp(toy_scroll / _toy_max_scroll_draw, 0, 1) : 0;
            var _toy_thumb_h = max((_toy_visible_rows / _toy_rows_total) * _toy_bar_h, 8 * _s);
            var _toy_thumb_y = _toy_bar_y + (_toy_scroll_ratio * (_toy_bar_h - _toy_thumb_h));

            draw_set_alpha(_alpha_final);
            draw_rectangle_color(
                _toy_bar_x,
                _toy_thumb_y,
                _toy_bar_x + _toy_bar_w,
                _toy_thumb_y + _toy_thumb_h,
                c_white,
                c_white,
                c_white,
                c_white,
                false
            );
            draw_set_alpha(1.0);
        }
    }
}

// MONITOREO DE DAÑO Y FRAME DE LA CABEZA DEL PROTAGONISTA
var _hp_actual = 80;
var _hp_max = 80;

if (instance_exists(obj_player)) {
    _hp_actual = obj_player.hp;
    _hp_max = obj_player.hp_max;
}

if (hp_anterior == -1) {
    hp_anterior = _hp_actual;
} else if (_hp_actual < hp_anterior) {
    timer_dolor = game_get_speed(gamespeed_fps) * 0.5;
    hp_anterior = _hp_actual;
} else {
    hp_anterior = _hp_actual;
}

var _prota_head_frame = 0;

if (timer_dolor > 0) {
    timer_dolor--;
    _prota_head_frame = 1;
}

draw_set_alpha(_alpha_final);

draw_sprite_ext(
    spr_bbs_textbox,
    0,
    6 * _s,
    183 * _s,
    2.27451 * _s,
    1.0 * _s,
    0,
    c_white,
    _alpha_final
);

_prota_head_frame = clamp(_prota_head_frame, 0, 1);

draw_sprite_ext(
    spr_bbs_prota_head,
    _prota_head_frame,
    14 * _s,
    195 * _s,
    1.0 * _s,
    1.0 * _s,
    0,
    c_white,
    _alpha_final
);

draw_sprite_ext(
    spr_bbs_textbox,
    0,
    126 * _s,
    183 * _s,
    3.666666 * _s,
    1.0 * _s,
    0,
    c_white,
    _alpha_final
);

var _info_x = 55 * _s;
var _info_y = 189 * _s;

draw_set_halign(fa_left);

draw_text_color(
    _info_x,
    _info_y,
    scr_loc("Noelle"),
    c_white,
    c_white,
    c_white,
    c_white,
    _alpha_final
);

var _hp_label_y = _info_y + 16 * _s;

var _hp_scale = 0.7;

draw_text_transformed_color(
    _info_x,
    _hp_label_y,
    scr_loc("HP"),
    _hp_scale,
    _hp_scale,
    0,
    c_white,
    c_white,
    c_white,
    c_white,
    _alpha_final
);


// =========================================================
// HP CON BORDE DERECHO FIJO
// =========================================================
//
// El layout de referencia es "80 / 80".
// Ese borde derecho queda fijo.
//
// Si HP pasa a:
// 100 / 100
// 999 / 999
// etc.
//
// los números crecen HACIA LA IZQUIERDA y la barra se
// acorta desde su lado izquierdo.
// =========================================================

var _hp_texto =
    string(_hp_actual)
    +
    " / "
    +
    string(_hp_max);

var _hp_texto_referencia =
    "80 / 80";

var _hp_texto_x_base =
    _info_x
    +
    24 * _s;

var _hp_ancho_ref =
    string_width(_hp_texto_referencia)
    *
    _hp_scale;

var _hp_ancho_actual =
    string_width(_hp_texto)
    *
    _hp_scale;

// Este es el borde derecho que NO se moverá.
var _hp_right =
    _hp_texto_x_base
    +
    _hp_ancho_ref;

// Texto alineado a la derecha.
var _hp_texto_x =
    _hp_right
    -
    _hp_ancho_actual;

draw_text_transformed_color(
    _hp_texto_x,
    _hp_label_y,
    _hp_texto,
    _hp_scale,
    _hp_scale,
    0,
    c_white,
    c_white,
    c_white,
    c_white,
    _alpha_final
);

// =========================================================
// BARRA AL MARGEN DEL TEXTO
// =========================================================
//
// El texto de HP puede crecer hacia la izquierda,
// pero la barra NO se extiende exageradamente.
//
// La barra empieza justo en el margen donde comienza "HP"
// y termina justo en el mismo borde derecho de los números.
//
// Resultado:
// HP 71 / 100
// └──────────┘
//
// Así queda contenida visualmente dentro del texto.
// =========================================================

var _bar_left =
    _info_x;

var _bar_right =
    _hp_right;

var _bar_y1 =
    _hp_label_y
    +
    10 * _s;

var _bar_y2 =
    _bar_y1
    +
    6 * _s;

draw_rectangle_color(
    _bar_left,
    _bar_y1,
    _bar_right,
    _bar_y2,
    $202020,
    $202020,
    $202020,
    $202020,
    false
);

var _porcentaje_hp =
    clamp(
        _hp_actual / _hp_max,
        0,
        1
    );

draw_rectangle_color(
    _bar_left,
    _bar_y1,
    _bar_left
    +
    ((_bar_right - _bar_left) * _porcentaje_hp),
    _bar_y2,
    c_yellow,
    c_yellow,
    c_yellow,
    c_yellow,
    false
);

draw_set_alpha(1.0);

// BOTONES PRINCIPALES
var _escala_btn = 1.310613 * _s;
var _pos_x_btn = [132.371, 177.0, 221.0769, 265.0];

for (var i = 0; i < 4; i++) {
    var _frame = (opcion_seleccionada == i) ? 1 : 0;
    
    draw_sprite_ext(
        opciones[i],
        _frame,
        _pos_x_btn[i] * _s,
        192 * _s,
        _escala_btn,
        _escala_btn,
        0,
        c_white,
        _alpha_final
    );
}
