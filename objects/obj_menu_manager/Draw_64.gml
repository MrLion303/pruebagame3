var _room_actual = room_get_name(room);
if (_room_actual == "bbs" || _room_actual == "rm_title") {
    exit; 
}

if (state == MENU_STATE.CLOSED || state == MENU_STATE.EXITING) exit;

if (variable_global_exists("font_main")) {
    draw_set_font(global.font_main);
}

var gui_x = 64;
var gui_y = 64;
var gui_w = 520;
var gui_h = 340;

// Menú Izquierdo (5 opciones)
var m_x = gui_x + 16;
var m_y = gui_y + 16;
var m_w = 130;
var m_h = 308;
draw_sprite_stretched(spr_textbox, 0, m_x, m_y, m_w, m_h);

draw_set_halign(fa_left); 
for (var i = 0; i < array_length(main_options); i++) {
    var col = (state == MENU_STATE.MAIN && main_index == i) ? c_yellow : c_orange;
    draw_set_color(col);
    draw_text(m_x + 16, m_y + 12 + (i * 46), main_options[i]);
}

// CASO A: Confirmar cierre de juego
if (state == MENU_STATE.GAME_CLOSE_CONFIRM) {
    var close_box_w = 314;
    var close_box_h = 115;
    var close_box_x = m_x + m_w + 12;
    var close_box_y = gui_y + (gui_h / 2) - (close_box_h / 2);
    
    draw_sprite_stretched(spr_textbox, 0, close_box_x, close_box_y, close_box_w, close_box_h);
    
    draw_set_halign(fa_center);
    draw_set_color(c_yellow);
    draw_text(close_box_x + (close_box_w / 2), close_box_y + 20, "Estas seguro?");
    
    var options_close = ["Si", "No"];
    var total_options = array_length(options_close);
    var spacing = 90;
    
    for (var c = 0; c < total_options; c++) {
        var col_c = (close_confirm_index == c) ? c_yellow : c_white;
        draw_set_color(col_c);
        var btn_x = close_box_x + (close_box_w / 2) + ((c - 0.5) * spacing);
        draw_text(btn_x, close_box_y + 65, options_close[c]);
    }
    draw_set_halign(fa_left);
}
// CASO B: Menú STAD (Estadísticas)
else if (state == MENU_STATE.INFO_MENU) {
    draw_set_halign(fa_left);
    var info_box_x = m_x + m_w + 12;
    var info_box_y = m_y;
    var info_box_w = 346;
    var info_box_h = m_h;
    
    draw_sprite_stretched(spr_textbox, 0, info_box_x, info_box_y, info_box_w, info_box_h);
    
    var sx = info_box_x + 24;
    var sy = info_box_y + 24;
    var _p = obj_player; 
    
    draw_set_color(c_orange);
    draw_text(sx, sy, "LV " + string(_p.nivel));
    draw_text(sx + 150, sy, "HP " + string(_p.hp) + "/" + string(_p.hp_max));
    
    var _atk_visual = _p.ataque_base;
    if (_p.equipo_arma != -1 && variable_global_exists("equip_db")) {
        var _arma_data = global.equip_db[$ _p.equipo_arma];
        if (_arma_data != undefined && struct_exists(_arma_data, "ataque")) {
            _atk_visual += _arma_data.ataque;
        }
    }
    
    draw_text(sx, sy + 50, "AT  " + string(_atk_visual));
    draw_text(sx + 150, sy + 50, "EXP: " + string(_p.exp_actual));
    
    var _def_total = _p.defensa_base;
    if (_p.equipo_armadura != -1 && variable_global_exists("equip_db")) {
        var _armadura_data = global.equip_db[$ _p.equipo_armadura];
        if (_armadura_data != undefined && struct_exists(_armadura_data, "defensa")) {
            _def_total += _armadura_data.defensa;
        }
    }
    draw_text(sx, sy + 100, "DF  " + string(_def_total));
    draw_text(sx + 150, sy + 100, "LVL SUB: " + string(_p.exp_siguiente));
    
    var _nombre_arma = "Ninguna";
    if (_p.equipo_arma != -1 && variable_global_exists("equip_db")) {
        var _arma_info = global.equip_db[$ _p.equipo_arma];
        if (_arma_info != undefined) _nombre_arma = _arma_info.nombre;
    }
    draw_text(sx, sy + 160, "Arma: " + _nombre_arma);
    
    var _nombre_armadura = "Ninguna";
    if (_p.equipo_armadura != -1 && variable_global_exists("equip_db")) {
        var _armadura_info = global.equip_db[$ _p.equipo_armadura];
        if (_armadura_info != undefined) _nombre_armadura = _armadura_info.nombre;
    }
    draw_text(sx, sy + 210, "Armadura: " + _nombre_armadura);
}
// CASO C: INVENTARIO DE CURACIÓN (Leyendo de obj_player.inventory)
else if (state >= MENU_STATE.INVENTORY && state <= MENU_STATE.ITEM_DROP_CONFIRM) {
    draw_set_halign(fa_left);
    var inv_box_x = m_x + m_w + 12;
    var inv_box_y = m_y;
    var inv_box_w = 346;
    var inv_box_h = m_h;
    
    draw_sprite_stretched(spr_textbox, 0, inv_box_x, inv_box_y, inv_box_w, inv_box_h);
    
    var start_x = inv_box_x + 24;
    var start_y = inv_box_y + 20;
    var cell_w = 100;
    var cell_h = 45;
    
    for (var yy = 0; yy < 3; yy++) {
        for (var xx = 0; xx < 3; xx++) {
            var index = (yy + inv_scroll) * 3 + xx;
            var cx = start_x + (xx * cell_w);
            var cy = start_y + (yy * cell_h);
            
            if (state == MENU_STATE.INVENTORY && inv_x == xx && inv_y == yy) {
                draw_set_color(c_yellow);
                draw_rectangle(cx - 4, cy - 4, cx + cell_w - 18, cy + cell_h - 10, true);
            }
            
            if (instance_exists(obj_player) && index < array_length(obj_player.inventory)) {
                var item_key = obj_player.inventory[index];
                if (item_key != -1) {
                    var item = global.item_db[$ item_key];
                    draw_set_color(c_orange);
                    draw_text_ext_transformed(cx, cy, item.nombre, 23, 120, 0.66, 0.66, 0);
                } else {
                    draw_set_color(c_dkgray);
                    draw_text_transformed(cx, cy, "-----", 0.66, 0.66, 0);
                }
            }
        }
    }
    
    var bar_x = inv_box_x + 322;
    var bar_y = start_y;
    var bar_h = 120;
    draw_set_color(c_dkgray);
    draw_line_width(bar_x, bar_y, bar_x, bar_y + bar_h, 2);
    
    var dot_y = bar_y + (inv_scroll / 1) * bar_h;
    var sq_size = 4;
    draw_set_color(c_white);
    draw_rectangle(bar_x - sq_size, dot_y - sq_size, bar_x + sq_size, dot_y + sq_size, false);
    
    var box_inf_x = inv_box_x + 16;
    var box_inf_y = inv_box_y + 175;
    var box_inf_w = 314;
    var box_inf_h = 115;
    
    draw_sprite_stretched(spr_textbox, 0, box_inf_x, box_inf_y, box_inf_w, box_inf_h);
    
    if (state == MENU_STATE.ITEM_ACTION) {
        for (var a = 0; a < array_length(action_options); a++) {
            var col_a = (action_index == a) ? c_yellow : c_white;
            draw_set_color(col_a);
            draw_text(box_inf_x + 16 + (a * 95), box_inf_y + 16, action_options[a]);
        }
        draw_set_color(c_ltgray);
        draw_text(box_inf_x + 16, box_inf_y + 65, "Z: Selecc | X: Volver");
    } 
    else if (state == MENU_STATE.ITEM_INFO) {
        if (instance_exists(obj_player)) {
            var inv_index = min((inv_y + inv_scroll) * 3 + inv_x, array_length(obj_player.inventory) - 1);
            var selected_item_key = obj_player.inventory[inv_index];
            var item_info = global.item_db[$ selected_item_key];
            
            draw_set_color(c_yellow);
            draw_text(box_inf_x + 16, box_inf_y + 16, item_info.nombre);
            draw_set_color(c_white);
            draw_text_ext(box_inf_x + 16, box_inf_y + 45, item_info.descripcion, 25, 280);
        }
    }
    else if (state == MENU_STATE.ITEM_DROP_CONFIRM) {
        draw_set_halign(fa_center);
        draw_set_color(c_yellow);
        draw_text(box_inf_x + (box_inf_w / 2), box_inf_y + 20, "Estas seguro?");
        
        var options_drop = ["Si", "No"];
        var total_drop = array_length(options_drop);
        var drop_spacing = 90;
        
        for (var d = 0; d < total_drop; d++) {
            var col_d = (drop_confirm_index == d) ? c_yellow : c_white;
            draw_set_color(col_d);
            var btn_dx = box_inf_x + (box_inf_w / 2) + ((d - 0.5) * drop_spacing);
            draw_text(btn_dx, box_inf_y + 65, options_drop[d]);
        }
        draw_set_halign(fa_left);
    }
    else {
        if (instance_exists(obj_player)) {
            var inv_index = min((inv_y + inv_scroll) * 3 + inv_x, array_length(obj_player.inventory) - 1);
            var selected_item_key = obj_player.inventory[inv_index];
            draw_set_color(c_white);
            if (selected_item_key != -1) {
                var item_info = global.item_db[$ selected_item_key];
                draw_text_ext(box_inf_x + 16, box_inf_y + 20, item_info.descripcion, 25, 280);
            } else {
                draw_text(box_inf_x + 16, box_inf_y + 25, "Espacio vacio.");
            }
        }
    }
}
// CASO D: MENÚ DE EQUIPAMIENTO (51 slots)
else if (state >= MENU_STATE.EQUIP_MENU && state <= MENU_STATE.EQUIP_DROP_CONFIRM) {
    draw_set_halign(fa_left);
    var eq_box_x = m_x + m_w + 12;
    var eq_box_y = m_y;
    var eq_box_w = 346;
    var eq_box_h = m_h;
    
    draw_sprite_stretched(spr_textbox, 0, eq_box_x, eq_box_y, eq_box_w, eq_box_h);
    
    var start_x = eq_box_x + 24;
    var start_y = eq_box_y + 20;
    var cell_w = 100;
    var cell_h = 45;
    
    for (var yy = 0; yy < 3; yy++) {
        for (var xx = 0; xx < 3; xx++) {
            var index = (yy + equip_scroll) * 3 + xx;
            var cx = start_x + (xx * cell_w);
            var cy = start_y + (yy * cell_h);
            
            if (state == MENU_STATE.EQUIP_MENU && equip_x == xx && equip_y == yy) {
                draw_set_color(c_yellow);
                draw_rectangle(cx - 4, cy - 4, cx + cell_w - 18, cy + cell_h - 10, true);
            }
            
            if (index < array_length(equipment)) {
                var eq_key = equipment[index];
                if (eq_key != -1) {
                    var eq_item = global.equip_db[$ eq_key];
                    draw_set_color(c_orange);
                    draw_text_ext_transformed(cx, cy, eq_item.nombre, 23, 120, 0.66, 0.66, 0);
                } else {
                    draw_set_color(c_dkgray);
                    draw_text_transformed(cx, cy, "-----", 0.66, 0.66, 0);
                }
            }
        }
    }
    
    var bar_x = eq_box_x + 322;
    var bar_y = start_y;
    var bar_h = 120;
    draw_set_color(c_dkgray);
    draw_line_width(bar_x, bar_y, bar_x, bar_y + bar_h, 2);
    
    var dot_y = bar_y + (max_equip_scroll > 0 ? (equip_scroll / max_equip_scroll) * bar_h : 0);
    var sq_size = 4;
    draw_set_color(c_white);
    draw_rectangle(bar_x - sq_size, dot_y - sq_size, bar_x + sq_size, dot_y + sq_size, false);
    
    var box_inf_x = eq_box_x + 16;
    var box_inf_y = eq_box_y + 175;
    var box_inf_w = 314;
    var box_inf_h = 115;
    
    draw_sprite_stretched(spr_textbox, 0, box_inf_x, box_inf_y, box_inf_w, box_inf_h);
    
    if (state == MENU_STATE.EQUIP_ACTION) {
        for (var a = 0; a < array_length(equip_action_options); a++) {
            var col_a = (equip_action_index == a) ? c_yellow : c_white;
            draw_set_color(col_a);
            draw_text(box_inf_x + 12 + (a * 102), box_inf_y + 16, equip_action_options[a]);
        }
        draw_set_color(c_ltgray);
        draw_text(box_inf_x + 16, box_inf_y + 65, "Z: Selecc | X: Volver");
    } 
    else if (state == MENU_STATE.EQUIP_INFO) {
        var eq_index = min((equip_y + equip_scroll) * 3 + equip_x, array_length(equipment) - 1);
        var selected_eq_key = equipment[eq_index];
        var eq_info = global.equip_db[$ selected_eq_key];
        
        draw_set_color(c_yellow);
        draw_text(box_inf_x + 16, box_inf_y + 16, eq_info.nombre);
        draw_set_color(c_white);
        draw_text_ext(box_inf_x + 16, box_inf_y + 45, eq_info.descripcion, 25, 280);
    }
    else if (state == MENU_STATE.EQUIP_DROP_CONFIRM) {
        draw_set_halign(fa_center);
        draw_set_color(c_yellow);
        draw_text(box_inf_x + (box_inf_w / 2), box_inf_y + 20, "Estas seguro?");
        
        var options_drop_eq = ["Si", "No"];
        var total_drop_eq = array_length(options_drop_eq);
        var drop_eq_spacing = 90;
        
        for (var d = 0; d < total_drop_eq; d++) {
            var col_d = (drop_confirm_index == d) ? c_yellow : c_white;
            draw_set_color(col_d);
            var btn_deq_x = box_inf_x + (box_inf_w / 2) + ((d - 0.5) * drop_eq_spacing);
            draw_text(btn_deq_x, box_inf_y + 65, options_drop_eq[d]);
        }
        draw_set_halign(fa_left);
    }
    else {
        var eq_index = min((equip_y + equip_scroll) * 3 + equip_x, array_length(equipment) - 1);
        var selected_eq_key = equipment[eq_index];
        draw_set_color(c_white);
        if (selected_eq_key != -1) {
            var eq_info = global.equip_db[$ selected_eq_key];
            draw_text_ext(box_inf_x + 16, box_inf_y + 20, eq_info.descripcion, 25, 280);
        } else {
            draw_text(box_inf_x + 16, box_inf_y + 25, "Espacio vacio.");
        }
    }
}
// CASO E: MENÚ CONFIG
else if (state == MENU_STATE.CONFIG_MENU || state == MENU_STATE.CONFIG_ACTION) {
    draw_set_halign(fa_left);
    var cfg_box_x = m_x + m_w + 12;
    var cfg_box_y = m_y;
    var cfg_box_w = 346;
    var cfg_box_h = m_h;
    
    draw_sprite_stretched(spr_textbox, 0, cfg_box_x, cfg_box_y, cfg_box_w, cfg_box_h);
    
    var is_on_tabs = (state == MENU_STATE.CONFIG_MENU);
    
    var tab_gen_col = (config_tab == 0) ? c_yellow : c_white;
    var tab_ctrl_col = (config_tab == 1) ? c_yellow : c_white;
    
    draw_set_color(config_tab == 0 ? (is_on_tabs ? c_yellow : c_orange) : c_dkgray);
    draw_rectangle(cfg_box_x + 20, cfg_box_y + 14, cfg_box_x + 145, cfg_box_y + 50, true);
    draw_set_color(tab_gen_col);
    draw_text(cfg_box_x + 32, cfg_box_y + 21, "General");
    
    draw_set_color(config_tab == 1 ? (is_on_tabs ? c_yellow : c_orange) : c_dkgray);
    draw_rectangle(cfg_box_x + 155, cfg_box_y + 14, cfg_box_x + 310, cfg_box_y + 50, true);
    draw_set_color(tab_ctrl_col);
    draw_text(cfg_box_x + 167, cfg_box_y + 21, "Controles");
    
    var start_y = cfg_box_y + 72;
    var line_spacing = 38;
    
    if (config_tab == 0) {
        var options_general = [
            { name: "Volumen General", val: string(round(master_volume * 100)) + "%" },
            { name: "Pantalla Comp",    val: fullscreen_enabled ? "Si" : "No" },
            { name: "Auto-correr",      val: global.autocorrer_enabled ? "Si" : "No" },
            { name: "Volver",           val: "" }
        ];
        
        for (var i = 0; i < array_length(options_general); i++) {
            var col_item = (!is_on_tabs && config_index == i) ? c_yellow : c_orange;
            draw_set_color(col_item);
            
            draw_text(cfg_box_x + 24, start_y + (i * line_spacing), options_general[i].name);
            
            if (options_general[i].val != "") {
                draw_text(cfg_box_x + 240, start_y + (i * line_spacing), options_general[i].val);
            }
        }
    } 
    else {
        draw_set_color(c_ltgray);
        draw_text(cfg_box_x + 24, start_y, "Configuracion de controles");
        draw_text(cfg_box_x + 24, start_y + 40, "Proximamente...");
    }
}

draw_set_halign(fa_left);
draw_set_color(c_white);