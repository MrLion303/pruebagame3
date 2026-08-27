if (variable_global_exists("font_main")) {
    draw_set_font(global.font_main);
}
draw_set_halign(fa_left);

var left_x = 64;
var left_y = 64;
var left_w = 140;
var left_h = 160;

var right_x = left_x + left_w + 16;
var right_y = 64;
var right_w = 340;
var right_h = 80;
var spacing = 10;

// --- DIBUJAR CAJA DE FONDO PRINCIPAL ---
var bg_padding = 24;
var bg_x = left_x - bg_padding;
var bg_y = left_y - bg_padding;
var bg_w = (right_x + right_w + bg_padding) - bg_x;
var bg_h = (right_y + (3 * right_h) + (2 * spacing) + bg_padding) - bg_y;

// >>> CAMBIADO A spr_textbox_save_fondo <<<
draw_sprite_stretched(spr_textbox_save_fondo, 0, bg_x, bg_y, bg_w, bg_h);

// --- DIBUJAR CAJA IZQUIERDA (ACCIONES) ---
draw_sprite_stretched(spr_textbox_save, 0, left_x, left_y, left_w, left_h);

for (var i = 0; i < 3; i++) {
    var _col = c_white;
    
    // Si abrimos desde el título, "Salvar" (índice 0) va en gris
    if (from_title && i == 0) {
        _col = c_dkgray; 
    } 
    // De lo contrario, lo pintamos amarillo si está seleccionado
    else if (state == 0 && action_index == i) {
        _col = c_yellow;
    }
    
    draw_set_color(_col);
    draw_text(left_x + 20, left_y + 20 + (i * 45), action_options[i]);
}

// --- DIBUJAR CAJAS DERECHAS (ARCHIVOS) ---
for (var j = 0; j < 3; j++) {
    var _box_y = right_y + (j * (right_h + spacing));
    
    draw_sprite_stretched(spr_textbox_save, 0, right_x, _box_y, right_w, right_h);
    
    var _col_slot = (state == 1 && slot_index == j) ? c_yellow : c_white;
    draw_set_color(_col_slot);
    
    var _datos = slots_data[j];
    
    draw_text(right_x + 16, _box_y + 10, _datos.nombre);
    
    draw_set_halign(fa_right);
    draw_text(right_x + right_w - 16, _box_y + 10, _datos.tiempo);
    
    draw_set_color(c_dkgray);
    draw_line_width(right_x + 16, _box_y + 40, right_x + right_w - 16, _box_y + 40, 2);
    
    draw_set_halign(fa_left);
    draw_set_color(_col_slot);
    draw_text(right_x + 16, _box_y + 45, _datos.lugar);
}

draw_set_color(c_white);