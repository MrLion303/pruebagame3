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
    draw_text(m_x + 16, m_y + 12 + (i * 46), scr_loc(main_options[i]));
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
    draw_text(close_box_x + (close_box_w / 2), close_box_y + 20, scr_loc("Estas seguro?"));
    
    var options_close = [scr_loc_src("Si"), scr_loc_src("No")];
    var total_options = array_length(options_close);
    var spacing = 90;
    
    for (var c = 0; c < total_options; c++) {
        var col_c = (close_confirm_index == c) ? c_yellow : c_white;
        draw_set_color(col_c);
        var btn_x = close_box_x + (close_box_w / 2) + ((c - 0.5) * spacing);
        draw_text(btn_x, close_box_y + 65, scr_loc(options_close[c]));
    }
    draw_set_halign(fa_left);
}
// CASO B: Menú STAD (Estadísticas)
else if (state == MENU_STATE.INFO_MENU) {
    draw_set_halign(fa_left);
    var info_box_x = m_x + m_w + 12;
    var info_box_y = m_y;
    var info_box_w = 346;

    // El panel STAD es más alto que el menú izquierdo
    // para dejar espacio a la moneda SO debajo de la armadura.
    var info_box_h = m_h + 55;
    
    draw_sprite_stretched(spr_textbox, 0, info_box_x, info_box_y, info_box_w, info_box_h);
    
    var sx = info_box_x + 24;
    var sy = info_box_y + 24;
    var _p = obj_player; 
    
    draw_set_color(c_orange);
    draw_text(sx, sy, scr_loc("LV ") + string(_p.nivel));
    draw_text(sx + 150, sy, scr_loc("HP ") + string(_p.hp) + "/" + string(_p.hp_max));
    
    var _atk_visual = _p.ataque_base;
    if (_p.equipo_arma != -1 && variable_global_exists("equip_db")) {
        var _arma_data = global.equip_db[$ _p.equipo_arma];
        if (_arma_data != undefined && struct_exists(_arma_data, "ataque")) {
            _atk_visual += _arma_data.ataque;
        }
    }
    
    draw_text(sx, sy + 50, scr_loc("AT  ") + string(_atk_visual));
    draw_text(sx + 150, sy + 50, scr_loc("EXP: ") + string(_p.exp_actual));
    
    var _def_total = _p.defensa_base;
    if (_p.equipo_armadura != -1 && variable_global_exists("equip_db")) {
        var _armadura_data = global.equip_db[$ _p.equipo_armadura];
        if (_armadura_data != undefined && struct_exists(_armadura_data, "defensa")) {
            _def_total += _armadura_data.defensa;
        }
    }
    draw_text(sx, sy + 100, scr_loc("DF  ") + string(_def_total));
    draw_text(sx + 150, sy + 100, scr_loc("LVL SUB: ") + string(_p.exp_siguiente));
    
    var _nombre_arma = scr_loc_src("Ninguna");
    if (_p.equipo_arma != -1 && variable_global_exists("equip_db")) {
        var _arma_info = global.equip_db[$ _p.equipo_arma];
        if (_arma_info != undefined) _nombre_arma = _arma_info.nombre;
    }
    draw_text(sx, sy + 160, scr_loc("Arma: ") + scr_loc(_nombre_arma));
    
    var _nombre_armadura = scr_loc_src("Ninguna");
    if (_p.equipo_armadura != -1 && variable_global_exists("equip_db")) {
        var _armadura_info = global.equip_db[$ _p.equipo_armadura];
        if (_armadura_info != undefined) _nombre_armadura = _armadura_info.nombre;
    }
    draw_text(sx, sy + 210, scr_loc("Armadura: ") + scr_loc(_nombre_armadura));


    // =====================================================
    // SUEÑOS / SO
    // =====================================================
    //
    // Una sola línea:
    // SO: 100
    //
    // Mismo tamaño normal del resto del panel y color morado.
    // =====================================================

    var _suenos_actuales = 0;

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

        _suenos_actuales =
            max(
                0,
                round(global.level_data.suenos)
            );
    }

    draw_set_color(c_purple);

    draw_text(
        sx,
        sy + 260,
        "SO: " + string(_suenos_actuales)
    );

    draw_set_color(c_white);
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
                    draw_text_ext_transformed(cx, cy, scr_loc(item.nombre), 23, 120, 0.66, 0.66, 0);
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
            draw_text(box_inf_x + 16 + (a * 95), box_inf_y + 16, scr_loc(action_options[a]));
        }
        draw_set_color(c_ltgray);
        draw_text(box_inf_x + 16, box_inf_y + 65, scr_loc("Z: Selecc | X: Volver"));
    } 
    else if (state == MENU_STATE.ITEM_INFO) {
        if (instance_exists(obj_player)) {
            var inv_index = min((inv_y + inv_scroll) * 3 + inv_x, array_length(obj_player.inventory) - 1);
            var selected_item_key = obj_player.inventory[inv_index];
            var item_info = global.item_db[$ selected_item_key];
            
            draw_set_color(c_yellow);
            draw_text(box_inf_x + 16, box_inf_y + 16, scr_loc(item_info.nombre));
            draw_set_color(c_white);
            draw_text_ext(box_inf_x + 16, box_inf_y + 45, scr_loc(item_info.descripcion), 25, 280);
        }
    }
    else if (state == MENU_STATE.ITEM_DROP_CONFIRM) {
        draw_set_halign(fa_center);
        draw_set_color(c_yellow);
        draw_text(box_inf_x + (box_inf_w / 2), box_inf_y + 20, scr_loc("Estas seguro?"));
        
        var options_drop = [scr_loc_src("Si"), scr_loc_src("No")];
        var total_drop = array_length(options_drop);
        var drop_spacing = 90;
        
        for (var d = 0; d < total_drop; d++) {
            var col_d = (drop_confirm_index == d) ? c_yellow : c_white;
            draw_set_color(col_d);
            var btn_dx = box_inf_x + (box_inf_w / 2) + ((d - 0.5) * drop_spacing);
            draw_text(btn_dx, box_inf_y + 65, scr_loc(options_drop[d]));
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
                draw_text_ext(box_inf_x + 16, box_inf_y + 20, scr_loc(item_info.descripcion), 25, 280);
            } else {
                draw_text(box_inf_x + 16, box_inf_y + 25, scr_loc("Espacio vacio."));
            }
        }
    }
}
// CASO D: MENÚ DE TOYS (30 slots)
else if (state >= MENU_STATE.TOY_MENU && state <= MENU_STATE.TOY_DROP_CONFIRM) {
    draw_set_halign(fa_left);

    var toy_box_x = m_x + m_w + 12;
    var toy_box_y = m_y;
    var toy_box_w = 346;
    var toy_box_h = m_h;

    draw_sprite_stretched(spr_textbox, 0, toy_box_x, toy_box_y, toy_box_w, toy_box_h);

    var toy_start_x = toy_box_x + 24;
    var toy_start_y = toy_box_y + 20;
    var toy_cell_w = 100;
    var toy_cell_h = 45;

    for (var yy = 0; yy < 3; yy++) {
        for (var xx = 0; xx < 3; xx++) {
            var toy_index = (yy + toy_scroll) * 3 + xx;
            var toy_cx = toy_start_x + (xx * toy_cell_w);
            var toy_cy = toy_start_y + (yy * toy_cell_h);

            if (state == MENU_STATE.TOY_MENU && toy_x == xx && toy_y == yy) {
                draw_set_color(c_yellow);
                draw_rectangle(toy_cx - 4, toy_cy - 4, toy_cx + toy_cell_w - 18, toy_cy + toy_cell_h - 10, true);
            }

            var toy_key = -1;
            if (variable_global_exists("toy_inventory") && toy_index < array_length(global.toy_inventory)) {
                toy_key = global.toy_inventory[toy_index];
            }

            if (toy_key != -1 && toy_key != undefined && variable_global_exists("toy_db")) {
                var toy_item = global.toy_db[$ toy_key];
                if (toy_item != undefined) {
                    draw_set_color(c_orange);
                    draw_text_ext_transformed(toy_cx, toy_cy, scr_loc(toy_item.nombre), 23, 120, 0.66, 0.66, 0);
                } else {
                    draw_set_color(c_dkgray);
                    draw_text_transformed(toy_cx, toy_cy, "-----", 0.66, 0.66, 0);
                }
            } else {
                draw_set_color(c_dkgray);
                draw_text_transformed(toy_cx, toy_cy, "-----", 0.66, 0.66, 0);
            }
        }
    }

    var toy_bar_x = toy_box_x + 322;
    var toy_bar_y = toy_start_y;
    var toy_bar_h = 120;

    draw_set_color(c_dkgray);
    draw_line_width(toy_bar_x, toy_bar_y, toy_bar_x, toy_bar_y + toy_bar_h, 2);

    var toy_max_scroll = 7;
    var toy_dot_y = toy_bar_y + (toy_max_scroll > 0 ? (toy_scroll / toy_max_scroll) * toy_bar_h : 0);
    var toy_sq_size = 4;

    draw_set_color(c_white);
    draw_rectangle(toy_bar_x - toy_sq_size, toy_dot_y - toy_sq_size, toy_bar_x + toy_sq_size, toy_dot_y + toy_sq_size, false);

    var toy_inf_x = toy_box_x + 16;
    var toy_inf_y = toy_box_y + 175;
    var toy_inf_w = 314;
    var toy_inf_h = 115;

    draw_sprite_stretched(spr_textbox, 0, toy_inf_x, toy_inf_y, toy_inf_w, toy_inf_h);

    var toy_info_index = (toy_y + toy_scroll) * 3 + toy_x;
    var toy_info_key = -1;

    if (variable_global_exists("toy_inventory") &&
        toy_info_index >= 0 &&
        toy_info_index < array_length(global.toy_inventory)) {
        toy_info_key = global.toy_inventory[toy_info_index];
    }

    var toy_info = (toy_info_key != -1 && toy_info_key != undefined && variable_global_exists("toy_db"))
        ? global.toy_db[$ toy_info_key]
        : undefined;

    if (state == MENU_STATE.TOY_ACTION) {
        var toy_actions = [scr_loc_src("Usar"), scr_loc_src("Tirar"), scr_loc_src("Info")];
        for (var a = 0; a < array_length(toy_actions); a++) {
            var toy_col_a = (toy_action_index == a) ? c_yellow : c_white;
            draw_set_color(toy_col_a);
            draw_text(toy_inf_x + 12 + (a * 102), toy_inf_y + 16, scr_loc(toy_actions[a]));
        }
        draw_set_color(c_ltgray);
        draw_text(toy_inf_x + 16, toy_inf_y + 65, scr_loc("Z: Selecc | X: Volver"));
    }
    else if (state == MENU_STATE.TOY_INFO) {
        if (toy_info != undefined) {
            draw_set_color(c_yellow);
            draw_text(toy_inf_x + 16, toy_inf_y + 16, scr_loc(toy_info.nombre));
            draw_set_color(c_white);
            draw_text_ext(toy_inf_x + 16, toy_inf_y + 45, scr_loc(toy_info.descripcion), 25, 280);
        }
    }
    else if (state == MENU_STATE.TOY_DROP_CONFIRM) {
        draw_set_halign(fa_center);
        draw_set_color(c_yellow);
        draw_text(toy_inf_x + (toy_inf_w / 2), toy_inf_y + 20, scr_loc("Estas seguro?"));

        var toy_options_drop = [scr_loc_src("Si"), scr_loc_src("No")];
        for (var d = 0; d < 2; d++) {
            var toy_col_d = (toy_drop_confirm_index == d) ? c_yellow : c_white;
            draw_set_color(toy_col_d);
            var toy_btn_x = toy_inf_x + (toy_inf_w / 2) + ((d - 0.5) * 90);
            draw_text(toy_btn_x, toy_inf_y + 65, scr_loc(toy_options_drop[d]));
        }
        draw_set_halign(fa_left);
    }
    else {
        if (toy_info != undefined) {
            draw_set_color(c_white);
            draw_text_ext(toy_inf_x + 16, toy_inf_y + 20, scr_loc(toy_info.descripcion), 25, 280);
        } else {
            draw_set_color(c_white);
            draw_text(toy_inf_x + 16, toy_inf_y + 25, scr_loc("Espacio vacio."));
        }
    }
}
// CASO E: MENÚ DE EQUIPAMIENTO (51 slots)
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
                    draw_text_ext_transformed(cx, cy, scr_loc(eq_item.nombre), 23, 120, 0.66, 0.66, 0);
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
            draw_text(box_inf_x + 12 + (a * 102), box_inf_y + 16, scr_loc(equip_action_options[a]));
        }
        draw_set_color(c_ltgray);
        draw_text(box_inf_x + 16, box_inf_y + 65, scr_loc("Z: Selecc | X: Volver"));
    } 
    else if (state == MENU_STATE.EQUIP_INFO) {
        var eq_index = min((equip_y + equip_scroll) * 3 + equip_x, array_length(equipment) - 1);
        var selected_eq_key = equipment[eq_index];
        var eq_info = global.equip_db[$ selected_eq_key];
        
        draw_set_color(c_yellow);
        draw_text(box_inf_x + 16, box_inf_y + 16, scr_loc(eq_info.nombre));
        draw_set_color(c_white);
        draw_text_ext(box_inf_x + 16, box_inf_y + 45, scr_loc(eq_info.descripcion), 25, 280);
    }
    else if (state == MENU_STATE.EQUIP_DROP_CONFIRM) {
        draw_set_halign(fa_center);
        draw_set_color(c_yellow);
        draw_text(box_inf_x + (box_inf_w / 2), box_inf_y + 20, scr_loc("Estas seguro?"));
        
        var options_drop_eq = [scr_loc_src("Si"), scr_loc_src("No")];
        var total_drop_eq = array_length(options_drop_eq);
        var drop_eq_spacing = 90;
        
        for (var d = 0; d < total_drop_eq; d++) {
            var col_d = (drop_confirm_index == d) ? c_yellow : c_white;
            draw_set_color(col_d);
            var btn_deq_x = box_inf_x + (box_inf_w / 2) + ((d - 0.5) * drop_eq_spacing);
            draw_text(btn_deq_x, box_inf_y + 65, scr_loc(options_drop_eq[d]));
        }
        draw_set_halign(fa_left);
    }
    else {
        var eq_index = min((equip_y + equip_scroll) * 3 + equip_x, array_length(equipment) - 1);
        var selected_eq_key = equipment[eq_index];
        draw_set_color(c_white);
        if (selected_eq_key != -1) {
            var eq_info = global.equip_db[$ selected_eq_key];
            draw_text_ext(box_inf_x + 16, box_inf_y + 20, scr_loc(eq_info.descripcion), 25, 280);
        } else {
            draw_text(box_inf_x + 16, box_inf_y + 25, scr_loc("Espacio vacio."));
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
    draw_text(cfg_box_x + 32, cfg_box_y + 21, scr_loc("General"));
    
    draw_set_color(config_tab == 1 ? (is_on_tabs ? c_yellow : c_orange) : c_dkgray);
    draw_rectangle(cfg_box_x + 155, cfg_box_y + 14, cfg_box_x + 310, cfg_box_y + 50, true);
    draw_set_color(tab_ctrl_col);
    draw_text(cfg_box_x + 167, cfg_box_y + 21, scr_loc("Controles"));
    
    var start_y = cfg_box_y + 72;
    var line_spacing = 38;
    
    if (config_tab == 0) {
        var options_general = [
            { name: scr_loc_src("Volumen General"), val: string(round(master_volume * 100)) + "%" },
            { name: scr_loc_src("Pantalla Comp"),    val: fullscreen_enabled ? scr_loc_src("Si") : scr_loc_src("No") },
            { name: scr_loc_src("Auto-correr"),      val: global.autocorrer_enabled ? scr_loc_src("Si") : scr_loc_src("No") },
            { name: scr_loc_src("Volver"),           val: "" }
        ];
        
        for (var i = 0; i < array_length(options_general); i++) {
            var col_item = (!is_on_tabs && config_index == i) ? c_yellow : c_orange;
            draw_set_color(col_item);
            
            draw_text(cfg_box_x + 24, start_y + (i * line_spacing), scr_loc(options_general[i].name));
            
            if (options_general[i].val != "") {
                draw_text(cfg_box_x + 240, start_y + (i * line_spacing), scr_loc(options_general[i].val));
            }
        }
    } 
    else {
        draw_set_color(c_ltgray);
        draw_text(cfg_box_x + 24, start_y, scr_loc("Configuracion de controles"));
        draw_text(cfg_box_x + 24, start_y + 40, scr_loc("Proximamente..."));
    }
}

draw_set_halign(fa_left);
draw_set_color(c_white);
