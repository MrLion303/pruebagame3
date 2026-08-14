var _s = 2;
if (!variable_instance_exists(id, "alpha_aparicion")) alpha_aparicion = 0.0;
if (alpha_aparicion < 1.0) alpha_aparicion += 0.05;

var _fade_transicion = 1.0;
if (instance_exists(obj_transicion_bbs)) {
    _fade_transicion = obj_transicion_bbs.image_alpha;
}

// Multiplicamos por alpha_salida para lograr el fundido al terminar la batalla
var _alpha_final = alpha_aparicion * _fade_transicion * alpha_salida;

if (!variable_instance_exists(id, "enemigo_img_index")) {
    enemigo_img_index = 0;
}

// 1. Dibujar enemigos en pantalla con soporte de temblor (shake)
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
    
    var _derrotado = (variable_struct_exists(_en, "derrotado") && _en.derrotado);
    if (!_derrotado && variable_struct_exists(_en, "shake_timer") && _en.shake_timer > 0) {
        _en_x += irandom_range(-2, 2) * _s;
        _en_y += irandom_range(-2, 2) * _s;
    }
    
    var _en_color = _derrotado ? make_color_rgb(40, 40, 40) : c_white;
    var _img_idx = _derrotado ? 0 : (_en.anim_index);
    var _escala = variable_struct_exists(_en, "escala_sprite") ? _en.escala_sprite : 2.0;
    
    draw_sprite_ext(_en.sprite, _img_idx, _en_x, _en_y, _escala * _s, _escala * _s, 0, _en_color, _alpha_final);
    
    if (en_seleccion_enemigo && enemigo_seleccionado_idx == i) {
        var _txt_color_sel = _derrotado ? c_gray : c_yellow;
        draw_text_color(_en_x - (string_width(_en.nombre) * 0.5 * 0.7 * _s), _en_y - (45 * _s), "v " + _en.nombre, _txt_color_sel, _txt_color_sel, _txt_color_sel, _txt_color_sel, _alpha_final);
    }
}

// 2. Lógica de dibujo de Caja de Texto / Inventario
draw_sprite_ext(spr_bbs_textbox, 0, 14 * _s, 125 * _s, 5.666667 * _s, 1.0 * _s, 0, c_white, _alpha_final);

if (variable_global_exists("font_main")) {
    draw_set_font(global.font_main);
}

if (!variable_instance_exists(id, "en_menu_inventario") || !en_menu_inventario) {
    // --- MODO TEXTO DE BATALLA ---
    var _p_left_margin = 16 * _s;
    var _p_avail_width = (260 * _s);
    if (setup == false) {
        setup = true;
        text_length = string_length(text_to_draw);
        var _last_space = -1;
        var _line_start_char = 1;
        line_break_num = 0;
        for(var c = 1; c <= text_length; c++) {
            var _char_current = string_char_at(text_to_draw, c);
            if (_char_current == " ") _last_space = c;
            var _sub_str = string_copy(text_to_draw, _line_start_char, c - _line_start_char + 1);
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
        for(var c = 0; c < text_length; c++) {
            var _char_pos = c + 1;
            char_array[c] = string_char_at(text_to_draw, _char_pos);
            var _txt_x = (14 * _s) + _p_left_margin;
            var _txt_y = (125 * _s) + (8 * _s) + (1 * _s);
            var _txt_line = 0;
            var _line_start_pos = 1;
            for(var lb = 0; lb < line_break_num; lb++) {
                if _char_pos >= line_break_pos[lb] {
                    _txt_line = lb + 1;
                    _line_start_pos = line_break_pos[lb];
                }
            }
            if (_line_start_pos == _char_pos && char_array[c] == " ") {
                char_x[c] = -9999;
                char_y[c] = -9999;
                continue;
            }
            var _str_copy = string_copy(text_to_draw, _line_start_pos, _char_pos - _line_start_pos + 1);
            var _current_txt_w = string_width(_str_copy);
            char_x[c] = _txt_x + _current_txt_w - string_width(char_array[c]);
            char_y[c] = _txt_y + (_txt_line * (18 * _s));
        }
    }
    
    if (en_seleccion_enemigo) {
        draw_text_color((14 + 16) * _s, (125 + 10) * _s, "* Elige a quien atacar!", c_white, c_white, c_white, c_white, _alpha_final);
    } else if (en_menu_fight && !en_modo_info) {
        var _tx = (14 + 16) * _s;
        var _ty = (125 + 10) * _s;
        var _op = ["* Atacar", "* Info"];
        for (var i = 0; i < 2; i++) {
            var _col = (opcion_fight_seleccionada == i) ? c_yellow : c_white;
            draw_text_color(_tx + (i * 120 * _s), _ty, _op[i], _col, _col, _col, _col, _alpha_final);
        }
        
        var _en_activo = enemigos[enemigo_seleccionado_idx];
        var _bar_en_x = _tx;
        var _bar_en_y = _ty + (20 * _s);
        var _bar_en_w = (string_width("* Atacar") * _s) * 0.75;
        var _bar_en_h = 5 * _s;
        var _vida_act = _en_activo.vida_actual;
        var _vida_max = _en_activo.vida_max;
        
        draw_set_alpha(_alpha_final);
        draw_rectangle_color(_bar_en_x, _bar_en_y, _bar_en_x + _bar_en_w, _bar_en_y + _bar_en_h, c_yellow, c_yellow, c_yellow, c_yellow, false);
        var _porcentaje_vida_en = clamp(_vida_act / _vida_max, 0, 1);
        var _current_en_w = _bar_en_w * _porcentaje_vida_en;
        if (_current_en_w > 0) {
            draw_rectangle_color(_bar_en_x, _bar_en_y, _bar_en_x + _current_en_w, _bar_en_y + _bar_en_h, c_lime, c_lime, c_lime, c_lime, false);
        }
        draw_set_alpha(1.0);
    } else {
        var _caracteres_visibles = floor(draw_char);
        if (variable_instance_exists(id, "char_x") && variable_instance_exists(id, "char_array")) {
            for (var c = 0; c < _caracteres_visibles; c++) {
                if (c < array_length(char_x) && char_x[c] != -9999) {
                    draw_text_color(char_x[c], char_y[c], char_array[c], c_white, c_white, c_white, c_white, _alpha_final);
                }
            }
        }
    }
} else {
    // --- MODO INVENTARIO DENTRO DE LA CAJA ---
    var _start_x = (14 * _s) + (18 * _s);
    var _start_y = (125 * _s) + (8 * _s);
    if (instance_exists(obj_player) && variable_instance_exists(obj_player, "inventory")) {
        for (var i = 0; i < 4; i++) {
            var _index = i + (inv_scroll * 2);
            var _col = i % 2;
            var _row = floor(i / 2);
            var _cx = _start_x + (_col * (130 * _s));
            var _cy = _start_y + (_row * (18 * _s));
            var _is_selected = (inv_x == _col && inv_y == _row);
            
            if (_index < array_length(obj_player.inventory)) {
                var _item_key = obj_player.inventory[_index];
                var _nombre_item = (_item_key != -1 && _item_key != undefined) ? (variable_global_exists("item_db") && global.item_db[$ _item_key] != undefined ? global.item_db[$ _item_key].nombre : string(_item_key)) : "-----";
                var _txt_color = _is_selected ? c_yellow : c_white;
                if (_item_key == -1 || _item_key == undefined) _txt_color = _is_selected ? c_yellow : c_gray;
                
                draw_text_transformed_color(_cx, _cy, "* " + _nombre_item, 0.8, 0.8, 0, _txt_color, _txt_color, _txt_color, _txt_color, _alpha_final);
            }
        }
        
        // --- BARRA LATERAL DE SCROLL ---
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
            draw_rectangle_color(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, c_gray, c_gray, c_gray, c_gray, false);
            
            var _max_scroll = _filas_totales - _filas_visibles;
            var _thumb_h = max((_filas_visibles / _filas_totales) * _bar_h, 8 * _s);
            var _scroll_ratio = 0;
            if (_max_scroll > 0) {
                _scroll_ratio = clamp(inv_scroll / _max_scroll, 0, 1);
            }
            var _thumb_y = _bar_y + (_scroll_ratio * (_bar_h - _thumb_h));
            
            draw_set_alpha(_alpha_final);
            draw_rectangle_color(_bar_x, _thumb_y, _bar_x + _bar_w, _thumb_y + _thumb_h, c_white, c_white, c_white, c_white, false);
            draw_set_alpha(1.0);
        }
    }
}

// 4. Paneles inferiores fijos (HP y Botones)
draw_set_alpha(_alpha_final);
draw_sprite_ext(spr_bbs_textbox, 0, 6 * _s, 183 * _s, 2.27451 * _s, 1.0 * _s, 0, c_white, _alpha_final);
draw_sprite_ext(spr_bbs_prota_head, 0, 14 * _s, 195 * _s, 1.0 * _s, 1.0 * _s, 0, c_white, _alpha_final);
draw_sprite_ext(spr_bbs_textbox, 0, 126 * _s, 183 * _s, 3.666666 * _s, 1.0 * _s, 0, c_white, _alpha_final);

var _hp_actual = 80;
var _hp_max = 80;
if (instance_exists(obj_player)) {
    _hp_actual = obj_player.hp;
    _hp_max = obj_player.hp_max;
}

var _info_x = 55 * _s;
var _info_y = 189 * _s;
draw_set_halign(fa_left);
draw_text_color(_info_x, _info_y, "Noelle", c_white, c_white, c_white, c_white, _alpha_final);

var _hp_label_y = _info_y + 16 * _s;
draw_text_transformed_color(_info_x, _hp_label_y, "HP", 0.7, 0.7, 0, c_white, c_white, c_white, c_white, _alpha_final);

var _hp_texto = string(_hp_actual) + " / " + string(_hp_max);
var _hp_texto_x = _info_x + 24 * _s;
draw_text_transformed_color(_hp_texto_x, _hp_label_y, _hp_texto, 0.7, 0.7, 0, c_white, c_white, c_white, c_white, _alpha_final);

var _ancho_total_texto = (_hp_texto_x + (string_width(_hp_texto) * 0.7)) - _info_x;
draw_rectangle_color(_info_x, _hp_label_y + 9 * _s, _info_x + _ancho_total_texto, _hp_label_y + 9 * _s + 6 * _s, $202020, $202020, $202020, $202020, false);

var _porcentaje_hp = clamp(_hp_actual / _hp_max, 0, 1);
draw_rectangle_color(_info_x, _hp_label_y + 9 * _s, _info_x + (_ancho_total_texto * _porcentaje_hp), _hp_label_y + 9 * _s + 6 * _s, c_yellow, c_yellow, c_yellow, c_yellow, false);
draw_set_alpha(1.0);

var _escala_btn = 1.310613 * _s;
var _pos_x_btn = [132.371, 177.0, 221.0769, 265.0];
for (var i = 0; i < 4; i++) {
    var _frame = (opcion_seleccionada == i) ? 1 : 0;
    draw_sprite_ext(opciones[i], _frame, _pos_x_btn[i] * _s, 192 * _s, _escala_btn, _escala_btn, 0, c_white, _alpha_final);
}