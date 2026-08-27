/// scr_inventarios_data
/// Fuente central de los inventarios persistentes.
function scr_inventarios_data() {
    if (!variable_global_exists("inventory_data")) {
        global.inventory_data = {
            consumibles: ["agua", -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
            toys: array_create(30, -1),
            equipamiento: array_create(51, -1),
            equipado_arma: -1,
            equipado_armadura: -1
        };
        global.inventory_data.toys[0] = "brillitos";
        global.inventory_data.toys[1] = "pegamento";
        global.inventory_data.equipamiento[0] = "espada_basica";
        global.inventory_data.equipamiento[1] = "armadura_basica";
    }
    if (!variable_global_exists("toy_inventory")) global.toy_inventory = global.inventory_data.toys;
    if (!variable_global_exists("equipment_inventory")) global.equipment_inventory = global.inventory_data.equipamiento;
    return global.inventory_data;
}

function scr_inventarios_sync() {
    scr_inventarios_data();
    
    // Sincronizar arreglos de inventario
    global.inventory_data.toys = global.toy_inventory;
    if (variable_global_exists("equipment_inventory")) {
        global.inventory_data.equipamiento = global.equipment_inventory;
    }
    
    // Sincronizar TODO lo del jugador hacia la base de datos global
    if (instance_exists(obj_player)) {
        if (variable_instance_exists(obj_player, "inventory")) {
            global.inventory_data.consumibles = obj_player.inventory;
        }
        // NUEVO: Asegurarnos de que el equipo activo se registre globalmente
        if (variable_instance_exists(obj_player, "equipo_arma")) {
            global.inventory_data.equipado_arma = obj_player.equipo_arma;
        }
        if (variable_instance_exists(obj_player, "equipo_armadura")) {
            global.inventory_data.equipado_armadura = obj_player.equipo_armadura;
        }
    }
    
    return global.inventory_data;
}
