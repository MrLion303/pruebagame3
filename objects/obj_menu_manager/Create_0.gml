main_options = ["INV", "TOYS", "EQUIP", "STAD", "CONFIG", "CERRAR"];
main_index = 0;

enum MENU_STATE {
    CLOSED,
    MAIN,
    INVENTORY,
    ITEM_ACTION,
    ITEM_INFO,
    ITEM_DROP_CONFIRM,

    TOY_MENU,
    TOY_ACTION,
    TOY_INFO,
    TOY_DROP_CONFIRM,

    EQUIP_MENU,
    EQUIP_ACTION,
    EQUIP_INFO,
    EQUIP_DROP_CONFIRM,
    
    INFO_MENU,
    CONFIG_MENU,
    CONFIG_ACTION,
    GAME_CLOSE_CONFIRM,
    EXITING 
}

state = MENU_STATE.CLOSED;

// =========================================================
// CONFIG
// =========================================================

config_tab = 0;
config_index = -1;

master_volume = 1.0;
fullscreen_enabled = window_get_fullscreen();

if (!variable_global_exists("autocorrer_enabled")) {
    global.autocorrer_enabled = false;
}

// =========================================================
// DATOS PERSISTENTES DE PARTIDA
// =========================================================

scr_level_data();
scr_inventarios_data();
scr_config_data();

master_volume = global.config_data.master_volume;
fullscreen_enabled = global.config_data.fullscreen_enabled;
global.autocorrer_enabled = global.config_data.autocorrer_enabled;

// =========================================================
// ASEGURAR BASES DE DATOS
// =========================================================

if (!variable_global_exists("equip_db")) {
    scr_equips_data();
}

if (!variable_global_exists("item_db")) {
    scr_item_db();
}

// =========================================================
// SINCRONIZAR INVENTARIO CON PLAYER
// =========================================================

if (instance_exists(obj_player)) {

    if (!variable_instance_exists(obj_player, "inventory")) {
        obj_player.inventory = [
            "agua",
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1
        ];
    }
}

// =========================================================
// INVENTARIO
// =========================================================

inv_x = 0;
inv_y = 0;
inv_scroll = 0;

// =========================================================
// INVENTARIO DE EQUIPAMIENTO PERSISTENTE
// =========================================================

if (!variable_global_exists("equipment_inventory")) {

    global.equipment_inventory = array_create(51, -1);

    global.equipment_inventory[0] = "espada_basica";
    global.equipment_inventory[1] = "armadura_basica";
}

// =========================================================
// EQUIPO ACTUAL: ARMA
// =========================================================

if (!variable_global_exists("equipped_arma")) {

    if (instance_exists(obj_player) &&
        variable_instance_exists(obj_player, "equipo_arma")) {

        global.equipped_arma = obj_player.equipo_arma;

    } else {

        global.equipped_arma = -1;
    }
}

// =========================================================
// EQUIPO ACTUAL: ARMADURA
// =========================================================

if (!variable_global_exists("equipped_armadura")) {

    if (instance_exists(obj_player) &&
        variable_instance_exists(obj_player, "equipo_armadura")) {

        global.equipped_armadura = obj_player.equipo_armadura;

    } else {

        global.equipped_armadura = -1;
    }
}

equipment = global.equipment_inventory;

// =========================================================
// SINCRONIZAR EQUIPO CON PLAYER
// =========================================================

if (instance_exists(obj_player)) {

    if (!variable_instance_exists(obj_player, "equipo_arma")) {
        obj_player.equipo_arma = global.equipped_arma;
    }

    if (!variable_instance_exists(obj_player, "equipo_armadura")) {
        obj_player.equipo_armadura = global.equipped_armadura;
    }
    
    // (Líneas dictadoras eliminadas correctamente de aquí)
}

// =========================================================
// DATOS DE TOYS
// =========================================================

if (!variable_global_exists("toy_db")) {
    scr_toys_data();
}

// =========================================================
// INVENTARIO DE TOYS PERSISTENTE
// =========================================================

scr_inventarios_data();

if (!variable_global_exists("toy_inventory")) {
    global.toy_inventory = array_create(30, -1);
    global.toy_inventory[0] = "brillitos";
}

// =========================================================
// POSICIÓN / SCROLL DE EQUIPAMIENTO
// =========================================================

equip_x = 0;
equip_y = 0;
equip_scroll = 0;

max_equip_scroll = 14;

// =========================================================
// POSICIÓN / SCROLL DE TOYS
// =========================================================

toy_x = 0;
toy_y = 0;
toy_scroll = 0;

toy_action_index = 0;
toy_drop_confirm_index = 1;

// =========================================================
// ACCIONES DE ITEMS
// =========================================================

action_options = ["Usar", "Tirar", "Info"];
action_index = 0;

// =========================================================
// ACCIONES DE EQUIPAMIENTO
// =========================================================

equip_action_options = ["Equip", "Tirar", "Info"];
equip_action_index = 0;

// =========================================================
// CONFIRMACIONES
// =========================================================

drop_confirm_index = 1;
close_confirm_index = 1;