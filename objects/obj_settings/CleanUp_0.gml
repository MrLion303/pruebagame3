font_delete(global.font_main);

// Limpiar la referencia de la base de datos de ítems
if (variable_global_exists("item_db")) {
    global.item_db = undefined;
}

// Limpiar la referencia de la base de datos de equipamiento
if (variable_global_exists("equip_db")) {
    global.equip_db = undefined; // <-- ¡Añadido aquí!
}