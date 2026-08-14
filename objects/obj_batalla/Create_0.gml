// Identificador único basado en la room y las coordenadas exactas de este objeto en el mapa
var _id_unico = string(room) + "_" + string(x) + "_" + string(y);

// Si ya fue destruido en esta sesión de la room (y no hemos cambiado de mapa real), nos borramos al nacer
if (variable_global_exists("enemigos_destruidos") && struct_exists(global.enemigos_destruidos, _id_unico)) {
    instance_destroy();
    exit;
}

// El enemigo empieza listo para la batalla
esta_activo = true;