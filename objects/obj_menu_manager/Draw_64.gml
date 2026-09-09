

var _room_actual = room_get_name(room);
if (_room_actual == "bbs" || _room_actual == "rm_title") {
    exit; 
}

if (state == MENU_STATE.CLOSED || state == MENU_STATE.EXITING) exit;

if (variable_global_exists("font_main")) {
    draw_set_font(global.font_main);
}


// =========================================================
// ANIMACIÓN DE LA VENTANA EXTRA DE ESTADÍSTICA
// =========================================================
//
// Solo ITEM_INFO y EQUIP_INFO tienen esta ventana.
// Al entrar en Info avanza de 0 a 1; al salir se reinicia.
//
// ease-out cúbico: sale rápido de detrás del inventario y
// frena suavemente al llegar a su posición final.
// =========================================================

var _info_stat_active =
    (
        state == MENU_STATE.ITEM_INFO
        ||
        state == MENU_STATE.EQUIP_INFO
    );


if (_info_stat_active)
{
    info_stat_slide =
        min(
            1,
            info_stat_slide
            +
            info_stat_slide_speed
        );
}
else
{
    info_stat_slide =
        0;
}


var _info_stat_t =
    1
    -
    power(
        1 - info_stat_slide,
        3
    );


var gui_x = 64;
var gui_y = 64;
var gui_w = 520;
var gui_h = 340;

// Menú Izquierdo (5 opciones)
var m_x = gui_x + 16;
var m_y = gui_y + 16;
var m_w = 130;
var m_h = 308;
draw_sprite_stretched(spr_textbox, scr_ui_box_frame(spr_textbox), m_x, m_y, m_w, m_h);

draw_set_halign(fa_left); 
for (var i = 0; i < array_length(main_options); i++) {
    var col = (state == MENU_STATE.MAIN && main_index == i) ? c_yellow : c_orange;
    draw_set_color(col);
    draw_text(m_x + 16, m_y + 12 + (i * 46), scr_loc(main_options[i]));
}


// =========================================================
// PESTAÑAS SUPERIORES DE INVENTARIO
// INV / EQUIP / CLAVE
// =========================================================

var _show_inventory_tabs =
(
    (
        state >= MENU_STATE.INVENTORY
        &&
        state <= MENU_STATE.ITEM_DROP_CONFIRM
    )
    ||
    (
        state >= MENU_STATE.EQUIP_MENU
        &&
        state <= MENU_STATE.EQUIP_DROP_CONFIRM
    )
    ||
    state == MENU_STATE.CLAVE_MENU
);


// =========================================================
// ANIMACIÓN HACIA ARRIBA
// =========================================================
//
// Igual que la ventana HP / AT / DEF:
// ease-out cúbico durante 12 frames.
//
// La caja se dibuja ANTES del panel grande. Su posición
// inicial queda detrás de él; al subir parece salir de la
// propia interfaz.
// =========================================================

if (_show_inventory_tabs)
{
    inventory_tab_slide =
        min(
            1,
            inventory_tab_slide
            +
            inventory_tab_slide_speed
        );
}
else
{
    inventory_tab_slide =
        0;
}


var _inventory_tab_t =
    1
    -
    power(
        1 - inventory_tab_slide,
        3
    );


if (_show_inventory_tabs)
{
    var _tab_box_x =
        m_x + m_w + 12;

    var _tab_box_final_y =
        m_y - 52;

    var _tab_box_hidden_y =
        m_y + 8;

    var _tab_box_y =
        lerp(
            _tab_box_hidden_y,
            _tab_box_final_y,
            _inventory_tab_t
        );

    var _tab_box_w =
        346;

    var _tab_box_h =
        44;


    draw_sprite_stretched(
        spr_textbox,
        scr_ui_box_frame(spr_textbox),
        _tab_box_x,
        _tab_box_y,
        _tab_box_w,
        _tab_box_h
    );


    var _active_inventory_tab =
        0;


    if (
        state >= MENU_STATE.EQUIP_MENU
        &&
        state <= MENU_STATE.EQUIP_DROP_CONFIRM
    )
    {
        _active_inventory_tab =
            1;
    }
    else if (state == MENU_STATE.CLAVE_MENU)
    {
        _active_inventory_tab =
            2;
    }


    var _tab_names =
    [
        scr_loc_src("INV"),
        scr_loc_src("EQUIP"),
        scr_loc_src("CLAVE")
    ];


    // Tres zonas exactamente iguales.
    var _tab_slot_w =
        _tab_box_w / 3;


    for (var _tab_i = 0; _tab_i < 3; _tab_i++)
    {
        var _slot_left =
            _tab_box_x
            +
            (_tab_i * _tab_slot_w);

        var _slot_right =
            _slot_left
            +
            _tab_slot_w;


        if (
            inventory_tab_focus
            &&
            _tab_i == _active_inventory_tab
        )
        {
            draw_set_color(
                c_yellow
            );

            draw_rectangle(
                _slot_left + 6,
                _tab_box_y + 7,
                _slot_right - 6,
                _tab_box_y + 36,
                true
            );
        }


        draw_set_color(
            (_tab_i == _active_inventory_tab)
            ?
            c_yellow
            :
            c_orange
        );


        // =================================================
        // TEXTO CENTRADO DENTRO DE CADA TERCIO
        // =================================================
        //
        // Cada pestaña ocupa exactamente 1/3 de la caja.
        // INV, EQUIP y CLAVE se dibujan en el centro real de
        // su propia zona para que queden simétricos.
        // =================================================

        draw_set_halign(
            fa_center
        );


        draw_text(
            (_slot_left + _slot_right) * 0.5,
            _tab_box_y + 11,
            scr_loc(_tab_names[_tab_i])
        );
    }


    draw_set_halign(
        fa_left
    );
}


// CASO A: Confirmar cierre de juego
if (state == MENU_STATE.GAME_CLOSE_CONFIRM) {
    var close_box_w = 314;
    var close_box_h = 115;
    var close_box_x = m_x + m_w + 12;
    var close_box_y = gui_y + (gui_h / 2) - (close_box_h / 2);
    
    draw_sprite_stretched(spr_textbox, scr_ui_box_frame(spr_textbox), close_box_x, close_box_y, close_box_w, close_box_h);
    
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
    
    draw_sprite_stretched(spr_textbox, scr_ui_box_frame(spr_textbox), info_box_x, info_box_y, info_box_w, info_box_h);
    
    var sx = info_box_x + 24;
    var sy = info_box_y + 24;
    var _p = obj_player; 
    
    draw_set_color(c_orange);
    draw_text(sx, sy, scr_loc("LV ") + string(_p.nivel));
    draw_text(sx + 150, sy, scr_loc("HP ") + string(_p.hp) + "/" + string(_p.hp_max));
    
    var _atk_visual = _p.ataque_base;
    if (_p.equipo_arma != -1 && variable_global_exists("equip_db")) {
        var _arma_data = variable_struct_get(
                        global.equip_db,
                        _p.equipo_arma
                    );
        if (_arma_data != undefined && variable_struct_exists(_arma_data, "ataque")) {
            _atk_visual += _arma_data.ataque;
        }
    }
    
    draw_text(sx, sy + 50, scr_loc("AT  ") + string(_atk_visual));
    draw_text(sx + 150, sy + 50, scr_loc("EXP: ") + string(_p.exp_actual));
    
    var _def_total = _p.defensa_base;
    if (_p.equipo_armadura != -1 && variable_global_exists("equip_db")) {
        var _armadura_data = variable_struct_get(
                        global.equip_db,
                        _p.equipo_armadura
                    );
        if (_armadura_data != undefined && variable_struct_exists(_armadura_data, "defensa")) {
            _def_total += _armadura_data.defensa;
        }
    }
    draw_text(sx, sy + 100, scr_loc("DF  ") + string(_def_total));
    draw_text(sx + 150, sy + 100, scr_loc("LVL SUB: ") + string(_p.exp_siguiente));
    
    var _nombre_arma = scr_loc_src("Ninguna");
    if (_p.equipo_arma != -1 && variable_global_exists("equip_db")) {
        var _arma_info = variable_struct_get(
                        global.equip_db,
                        _p.equipo_arma
                    );
        if (_arma_info != undefined) _nombre_arma = _arma_info.nombre;
    }
    draw_text(sx, sy + 160, scr_loc("Arma: ") + scr_loc(_nombre_arma));
    
    var _nombre_armadura = scr_loc_src("Ninguna");
    if (_p.equipo_armadura != -1 && variable_global_exists("equip_db")) {
        var _armadura_info = variable_struct_get(
                        global.equip_db,
                        _p.equipo_armadura
                    );
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
        "SO: $" + string(_suenos_actuales)
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


    // =====================================================
    // VENTANA EXTRA DE ITEM - DIBUJAR PRIMERO
    // =====================================================
    //
    // Se dibuja ANTES del panel grande para que la parte que
    // todavía se superpone quede visualmente detrás de él.
    // =====================================================

    if (
        state == MENU_STATE.ITEM_INFO
        &&
        instance_exists(obj_player)
    )
    {
        var _item_stat_x =
            inv_box_x;

        var _item_stat_w =
            inv_box_w;

        var _item_stat_h =
            48;


        var _item_stat_hidden_y =
            inv_box_y
            +
            inv_box_h
            -
            _item_stat_h;

        var _item_stat_final_y =
            inv_box_y
            +
            inv_box_h
            +
            8;


        var _item_stat_y =
            lerp(
                _item_stat_hidden_y,
                _item_stat_final_y,
                _info_stat_t
            );


        var _item_stat_index =
            min(
                (inv_y + inv_scroll) * 3 + inv_x,
                array_length(obj_player.inventory) - 1
            );


        var _item_stat_key =
            obj_player.inventory[_item_stat_index];


        if (
            _item_stat_key != -1
            &&
            !is_undefined(_item_stat_key)
        )
        {
            var _item_stat_info =
                variable_struct_get(
                        global.item_db,
                        _item_stat_key
                    );


            if (_item_stat_info != undefined)
            {
                draw_sprite_stretched(
                    spr_textbox,
                    scr_ui_box_frame(spr_textbox),
                    _item_stat_x,
                    _item_stat_y,
                    _item_stat_w,
                    _item_stat_h
                );


                var _item_hp =
                    (
                        variable_struct_exists(
                            _item_stat_info,
                            "curacion_hp"
                        )
                    )
                    ?
                    _item_stat_info.curacion_hp
                    :
                    0;


                draw_set_color(
                    c_yellow
                );


                draw_text(
                    _item_stat_x + 16,
                    _item_stat_y + 9,
                    "HP +" + string(_item_hp)
                );
            }
        }
    }
    
    // El panel grande se dibuja DESPUÉS para tapar la parte
    // de la ventana extra que aún está saliendo desde atrás.
    draw_sprite_stretched(spr_textbox, scr_ui_box_frame(spr_textbox), inv_box_x, inv_box_y, inv_box_w, inv_box_h);
    
    var start_x = inv_box_x + 24;
    var start_y = inv_box_y + 20;
    var cell_w = 100;
    var cell_h = 45;
    
    for (var yy = 0; yy < 3; yy++) {
        for (var xx = 0; xx < 3; xx++) {
            var index = (yy + inv_scroll) * 3 + xx;
            var cx = start_x + (xx * cell_w);
            var cy = start_y + (yy * cell_h);
            
            if (
                state == MENU_STATE.INVENTORY
                && !inventory_tab_focus
                && inv_x == xx
                && inv_y == yy
            ) {
                draw_set_color(c_yellow);
                draw_rectangle(cx - 4, cy - 4, cx + cell_w - 18, cy + cell_h - 10, true);
            }
            
            if (instance_exists(obj_player) && index < array_length(obj_player.inventory)) {
                var item_key = obj_player.inventory[index];
                if (item_key != -1) {
                    var item = variable_struct_get(
                        global.item_db,
                        item_key
                    );
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
    
    draw_sprite_stretched(spr_textbox, scr_ui_box_frame(spr_textbox), box_inf_x, box_inf_y, box_inf_w, box_inf_h);
    
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
            var item_info = variable_struct_get(
                        global.item_db,
                        selected_item_key
                    );
            
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
    else if (!inventory_tab_focus) {
        if (instance_exists(obj_player)) {
            var inv_index = min((inv_y + inv_scroll) * 3 + inv_x, array_length(obj_player.inventory) - 1);
            var selected_item_key = obj_player.inventory[inv_index];
            draw_set_color(c_white);
            if (selected_item_key != -1) {
                var item_info = variable_struct_get(
                        global.item_db,
                        selected_item_key
                    );
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

    draw_sprite_stretched(spr_textbox, scr_ui_box_frame(spr_textbox), toy_box_x, toy_box_y, toy_box_w, toy_box_h);

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
                var toy_item = variable_struct_get(
                        global.toy_db,
                        toy_key
                    );
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

    draw_sprite_stretched(spr_textbox, scr_ui_box_frame(spr_textbox), toy_inf_x, toy_inf_y, toy_inf_w, toy_inf_h);

    var toy_info_index = (toy_y + toy_scroll) * 3 + toy_x;
    var toy_info_key = -1;

    if (variable_global_exists("toy_inventory") &&
        toy_info_index >= 0 &&
        toy_info_index < array_length(global.toy_inventory)) {
        toy_info_key = global.toy_inventory[toy_info_index];
    }

    var toy_info = (toy_info_key != -1 && toy_info_key != undefined && variable_global_exists("toy_db"))
        ? variable_struct_get(
                        global.toy_db,
                        toy_info_key
                    )
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


    // =====================================================
    // VENTANA EXTRA DE EQUIP - DIBUJAR PRIMERO
    // =====================================================
    //
    // Igual que en INV: nace totalmente detrás del panel
    // grande y va apareciendo por su borde inferior.
    // =====================================================

    if (state == MENU_STATE.EQUIP_INFO)
    {
        var _eq_stat_x =
            eq_box_x;

        var _eq_stat_w =
            eq_box_w;

        var _eq_stat_h =
            48;


        var _eq_stat_hidden_y =
            eq_box_y
            +
            eq_box_h
            -
            _eq_stat_h;

        var _eq_stat_final_y =
            eq_box_y
            +
            eq_box_h
            +
            8;


        var _eq_stat_y =
            lerp(
                _eq_stat_hidden_y,
                _eq_stat_final_y,
                _info_stat_t
            );


        var _eq_stat_index =
            min(
                (equip_y + equip_scroll) * 3 + equip_x,
                array_length(equipment) - 1
            );


        var _eq_stat_key =
            equipment[_eq_stat_index];


        if (
            _eq_stat_key != -1
            &&
            !is_undefined(_eq_stat_key)
        )
        {
            var _eq_stat_info =
                variable_struct_get(
                        global.equip_db,
                        _eq_stat_key
                    );


            if (_eq_stat_info != undefined)
            {
                draw_sprite_stretched(
                    spr_textbox,
                    scr_ui_box_frame(spr_textbox),
                    _eq_stat_x,
                    _eq_stat_y,
                    _eq_stat_w,
                    _eq_stat_h
                );


                var _eq_at =
                    (
                        variable_struct_exists(
                            _eq_stat_info,
                            "ataque"
                        )
                    )
                    ?
                    _eq_stat_info.ataque
                    :
                    0;

                var _eq_df =
                    (
                        variable_struct_exists(
                            _eq_stat_info,
                            "defensa"
                        )
                    )
                    ?
                    _eq_stat_info.defensa
                    :
                    0;


                var _eq_stat_text =
                    "";


                if (_eq_at > 0)
                {
                    _eq_stat_text =
                        "AT +" + string(_eq_at);
                }


                if (_eq_df > 0)
                {
                    if (_eq_stat_text != "")
                    {
                        _eq_stat_text +=
                            "    ";
                    }

                    _eq_stat_text +=
                        "DEF +" + string(_eq_df);
                }


                if (_eq_stat_text == "")
                {
                    _eq_stat_text =
                        scr_loc(
                            scr_loc_src(
                                "Sin bonificacion"
                            )
                        );
                }


                draw_set_color(
                    c_yellow
                );


                draw_text(
                    _eq_stat_x + 16,
                    _eq_stat_y + 9,
                    _eq_stat_text
                );
            }
        }
    }
    
    // Dibujado después = efecto real de salir desde atrás.
    draw_sprite_stretched(spr_textbox, scr_ui_box_frame(spr_textbox), eq_box_x, eq_box_y, eq_box_w, eq_box_h);
    
    var start_x = eq_box_x + 24;
    var start_y = eq_box_y + 20;
    var cell_w = 100;
    var cell_h = 45;
    
    for (var yy = 0; yy < 3; yy++) {
        for (var xx = 0; xx < 3; xx++) {
            var index = (yy + equip_scroll) * 3 + xx;
            var cx = start_x + (xx * cell_w);
            var cy = start_y + (yy * cell_h);
            
            if (
                state == MENU_STATE.EQUIP_MENU
                && !inventory_tab_focus
                && equip_x == xx
                && equip_y == yy
            ) {
                draw_set_color(c_yellow);
                draw_rectangle(cx - 4, cy - 4, cx + cell_w - 18, cy + cell_h - 10, true);
            }
            
            if (index < array_length(equipment)) {
                var eq_key = equipment[index];
                if (eq_key != -1) {
                    var eq_item = variable_struct_get(
                        global.equip_db,
                        eq_key
                    );
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
    
    draw_sprite_stretched(spr_textbox, scr_ui_box_frame(spr_textbox), box_inf_x, box_inf_y, box_inf_w, box_inf_h);
    
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
        var eq_info = variable_struct_get(
                        global.equip_db,
                        selected_eq_key
                    );
        
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
    else if (!inventory_tab_focus) {
        var eq_index = min((equip_y + equip_scroll) * 3 + equip_x, array_length(equipment) - 1);
        var selected_eq_key = equipment[eq_index];
        draw_set_color(c_white);
        if (selected_eq_key != -1) {
            var eq_info = variable_struct_get(
                        global.equip_db,
                        selected_eq_key
                    );
            draw_text_ext(box_inf_x + 16, box_inf_y + 20, scr_loc(eq_info.descripcion), 25, 280);
        } else {
            draw_text(box_inf_x + 16, box_inf_y + 25, scr_loc("Espacio vacio."));
        }
    }
}
// CASO F: OBJETOS CLAVE
else if (state == MENU_STATE.CLAVE_MENU)
{
    draw_set_halign(
        fa_left
    );


    scr_inventarios_data();

    if (!variable_global_exists("itemclave_db"))
    {
        src_itemclave_data();
    }


    var clave_box_x =
        m_x + m_w + 12;

    var clave_box_y =
        m_y;

    var clave_box_w =
        346;

    var clave_box_h =
        m_h;


    draw_sprite_stretched(
        spr_textbox,
        scr_ui_box_frame(spr_textbox),
        clave_box_x,
        clave_box_y,
        clave_box_w,
        clave_box_h
    );


    var clave_start_x =
        clave_box_x + 24;

    var clave_start_y =
        clave_box_y + 20;

    var clave_cell_w =
        100;

    var clave_cell_h =
        45;


    var _clave_count =
        array_length(
            global.itemclave_inventory
        );


    var _clave_rows =
        max(
            1,
            ceil(
                _clave_count / 3
            )
        );


    var _clave_max_scroll =
        max(
            0,
            _clave_rows - 3
        );


    clave_scroll =
        clamp(
            clave_scroll,
            0,
            _clave_max_scroll
        );


    for (var _ky = 0; _ky < 3; _ky++)
    {
        for (var _kx = 0; _kx < 3; _kx++)
        {
            var _key_index =
                (_ky + clave_scroll) * 3 + _kx;

            var _key_cx =
                clave_start_x + (_kx * clave_cell_w);

            var _key_cy =
                clave_start_y + (_ky * clave_cell_h);


            if (
                !inventory_tab_focus
                &&
                clave_x == _kx
                &&
                clave_y == _ky
            )
            {
                draw_set_color(
                    c_yellow
                );

                draw_rectangle(
                    _key_cx - 4,
                    _key_cy - 4,
                    _key_cx + clave_cell_w - 18,
                    _key_cy + clave_cell_h - 10,
                    true
                );
            }


            var _key_id =
                -1;


            if (
                _key_index >= 0
                &&
                _key_index < _clave_count
            )
            {
                _key_id =
                    global.itemclave_inventory[_key_index];
            }


            if (
                _key_id != -1
                &&
                !is_undefined(_key_id)
                &&
                is_string(_key_id)
                &&
                variable_struct_exists(
                    global.itemclave_db,
                    _key_id
                )
            )
            {
                var _key_data =
                    variable_struct_get(
                        global.itemclave_db,
                        _key_id
                    );


                draw_set_color(
                    c_orange
                );


                draw_text_ext_transformed(
                    _key_cx,
                    _key_cy,
                    scr_loc(
                        _key_data.nombre
                    ),
                    23,
                    120,
                    0.66,
                    0.66,
                    0
                );
            }
            else
            {
                draw_set_color(
                    c_dkgray
                );


                draw_text_transformed(
                    _key_cx,
                    _key_cy,
                    "-----",
                    0.66,
                    0.66,
                    0
                );
            }
        }
    }


    // -----------------------------------------------------
    // SCROLL
    // -----------------------------------------------------

    var clave_bar_x =
        clave_box_x + 322;

    var clave_bar_y =
        clave_start_y;

    var clave_bar_h =
        120;


    draw_set_color(
        c_dkgray
    );


    draw_line_width(
        clave_bar_x,
        clave_bar_y,
        clave_bar_x,
        clave_bar_y + clave_bar_h,
        2
    );


    var clave_dot_y =
        clave_bar_y
        +
        (
            _clave_max_scroll > 0
            ?
            (clave_scroll / _clave_max_scroll) * clave_bar_h
            :
            0
        );


    var clave_sq_size =
        4;


    draw_set_color(
        c_white
    );


    draw_rectangle(
        clave_bar_x - clave_sq_size,
        clave_dot_y - clave_sq_size,
        clave_bar_x + clave_sq_size,
        clave_dot_y + clave_sq_size,
        false
    );


    // -----------------------------------------------------
    // INFORMACIÓN
    // -----------------------------------------------------

    var clave_inf_x =
        clave_box_x + 16;

    var clave_inf_y =
        clave_box_y + 175;

    var clave_inf_w =
        314;

    var clave_inf_h =
        115;


    draw_sprite_stretched(
        spr_textbox,
        scr_ui_box_frame(spr_textbox),
        clave_inf_x,
        clave_inf_y,
        clave_inf_w,
        clave_inf_h
    );


    var _selected_key_index =
        (clave_y + clave_scroll) * 3 + clave_x;


    var _selected_key_id =
        -1;


    if (
        _selected_key_index >= 0
        &&
        _selected_key_index < _clave_count
    )
    {
        _selected_key_id =
            global.itemclave_inventory[
                _selected_key_index
            ];
    }


    if (
        !inventory_tab_focus
        &&
        _selected_key_id != -1
        &&
        !is_undefined(_selected_key_id)
        &&
        is_string(_selected_key_id)
        &&
        variable_struct_exists(
            global.itemclave_db,
            _selected_key_id
        )
    )
    {
        var _selected_key_data =
            variable_struct_get(
                        global.itemclave_db,
                        _selected_key_id
                    );


        draw_set_color(
            c_yellow
        );


        draw_text(
            clave_inf_x + 16,
            clave_inf_y + 12,
            scr_loc(
                _selected_key_data.nombre
            )
        );


        draw_set_color(
            c_white
        );


        draw_text_ext(
            clave_inf_x + 16,
            clave_inf_y + 40,
            scr_loc(
                _selected_key_data.descripcion
            ),
            20,
            280
        );


        if (
            variable_struct_exists(
                _selected_key_data,
                "uso"
            )
            &&
            is_string(
                _selected_key_data.uso
            )
            &&
            _selected_key_data.uso != ""
        )
        {
            draw_set_color(
                c_orange
            );


            draw_text_ext(
                clave_inf_x + 16,
                clave_inf_y + 78,
                scr_loc(
                    scr_loc_src("Uso: ")
                )
                +
                scr_loc(
                    _selected_key_data.uso
                ),
                20,
                280
            );
        }
    }
    else
    {
        draw_set_color(
            c_white
        );


        draw_text(
            clave_inf_x + 16,
            clave_inf_y + 25,
            scr_loc(
                scr_loc_src(
                    "Espacio vacio."
                )
            )
        );
    }
}


// CASO G: MENÚ CONFIG
else if (state == MENU_STATE.CONFIG_MENU || state == MENU_STATE.CONFIG_ACTION) {
    draw_set_halign(fa_left);
    var cfg_box_x = m_x + m_w + 12;
    var cfg_box_y = m_y;
    var cfg_box_w = 346;
    var cfg_box_h = m_h;
    
    draw_sprite_stretched(spr_textbox, scr_ui_box_frame(spr_textbox), cfg_box_x, cfg_box_y, cfg_box_w, cfg_box_h);
    
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
        draw_text(cfg_box_x + 24, start_y, scr_loc("easter"));
        draw_text(cfg_box_x + 24, start_y + 40, scr_loc("egg"));
    }
}

draw_set_halign(fa_left);
draw_set_color(c_white);
