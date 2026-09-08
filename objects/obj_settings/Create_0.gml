// =========================================================
// FUENTE PRINCIPAL DEL JUEGO
// =========================================================

global.font_main = font_add_sprite_ext(
    spr_main_font,
    " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ÁÉÍÓÚÜÑáéíóúüñ¿¡",
    true,
    1
);

// =========================================================
// BASE DE DATOS UNIVERSAL
// =========================================================

// Items
scr_item_db();

// Equipamiento
scr_equips_data();

// Toys
scr_toys_data();

// Party
scr_party_init();


// =========================================================
// SCREEN SHAKE UNIVERSAL
// =========================================================

scr_screen_shake_init();


if (!instance_exists(obj_screen_shake))
{
    instance_create_depth(
        0,
        0,
        -100000000,
        obj_screen_shake
    );
}


// =========================================================
// AUTO-CORRER
// =========================================================

if (!variable_global_exists("autocorrer_enabled")) {
    global.autocorrer_enabled = false;
}

// =========================================================
// CREAR GESTOR DE MENÚ
// =========================================================

if (!instance_exists(obj_menu_manager)) {
    instance_create_layer(0, 0, "Instances", obj_menu_manager);
}
