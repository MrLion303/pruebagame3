// Solo dibuja si hay tiempo acumulado
if (hold_timer > 0) {
    draw_set_alpha(close_alpha);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    // Dibujar en la esquina superior izquierda con un pequeño margen (10, 10)
    draw_text(10, 10, scr_loc(close_text));
    
    // Restablecer la opacidad global para evitar afectar otros elementos de dibujo
    draw_set_alpha(1);
}