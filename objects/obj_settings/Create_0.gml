global.font_main = font_add_sprite(spr_main_font, 32, true, 1);

// Inicializamos la base de datos universal de ítems y equipamiento
scr_item_db();
scr_equips_data(); 

// Inicializar variable de auto-correr si no existe
if (!variable_global_exists("autocorrer_enabled")) {
    global.autocorrer_enabled = false; 
}

// Creamos el gestor de menús de forma persistente y automática
if (!instance_exists(obj_menu_manager)) {
    instance_create_layer(0, 0, "Instances", obj_menu_manager);
}