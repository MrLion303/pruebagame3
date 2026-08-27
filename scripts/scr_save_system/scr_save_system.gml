/// @function scr_guardar_juego(_seccion)
function scr_guardar_juego(_seccion) {
    scr_config_sync();
    scr_inventarios_sync();
    
    var _px = 0;
    var _py = 0;
    var _proom = room;
    var _facing = 2; 
    
    if (instance_exists(obj_player)) {
        _px = obj_player.x;
        _py = obj_player.y;
        _proom = room;
        _facing = obj_player.face; 
        
        global.level_data.nivel = obj_player.nivel;
        global.level_data.exp_actual = obj_player.exp_actual;
        global.level_data.exp_siguiente = obj_player.exp_siguiente;
        global.level_data.ataque_base = obj_player.ataque_base;
        global.level_data.defensa_base = obj_player.defensa_base;
        global.level_data.hp_max = obj_player.hp_max;
        
        global.inventory_data.consumibles = obj_player.inventory;
        global.inventory_data.equipado_arma = obj_player.equipo_arma;
        global.inventory_data.equipado_armadura = obj_player.equipo_armadura;
    }

    var _save_data = {
        config: global.config_data,
        inventarios: global.inventory_data,
        nivel: global.level_data
    };

    var _json_string = json_stringify(_save_data);
    var _base64_string = base64_encode(_json_string);

    ini_open("prueba.ini");
    ini_write_real(_seccion, "room", _proom);
    ini_write_real(_seccion, "x", _px);
    ini_write_real(_seccion, "y", _py);
    ini_write_real(_seccion, "facing", _facing);
    
    // GUARDAMOS EL TIEMPO
    ini_write_real(_seccion, "playtime", global.playtime_frames);
    
    ini_write_string(_seccion, "extra_data", _base64_string);
    ini_close();
    
    show_debug_message("¡Juego guardado en " + _seccion + " con éxito!");
}

/// @function scr_cargar_juego(_seccion)
function scr_cargar_juego(_seccion) {
    if (!file_exists("prueba.ini")) return false;

    ini_open("prueba.ini");
    var _extra = ini_read_string(_seccion, "extra_data", "");
    var _facing = ini_read_real(_seccion, "facing", 2);
    
    // CARGAMOS EL TIEMPO AL ENTRAR AL JUEGO
    global.playtime_frames = ini_read_real(_seccion, "playtime", 0);
    
    ini_close();

    if (_extra != "") {
        var _json_string = base64_decode(_extra);
        var _save_data = json_parse(_json_string);
        
        global.config_data = _save_data.config;
        global.inventory_data = _save_data.inventarios;
        global.level_data = _save_data.nivel;

        global.autocorrer_enabled = global.config_data.autocorrer_enabled;
        global.toy_inventory = global.inventory_data.toys;
        global.equipment_inventory = global.inventory_data.equipamiento;
    }
    
    global.load_facing = _facing;
    return true;
}

/// @function scr_aplicar_datos_cargados(_jugador)
/// @description Pasa los globales al jugador al iniciar la room
function scr_aplicar_datos_cargados(_jugador) {
    _jugador.nivel = global.level_data.nivel;
    _jugador.exp_actual = global.level_data.exp_actual;
    _jugador.exp_siguiente = global.level_data.exp_siguiente;
    _jugador.ataque_base = global.level_data.ataque_base;
    _jugador.defensa_base = global.level_data.defensa_base;
    _jugador.hp_max = global.level_data.hp_max;
    _jugador.hp = global.level_data.hp_max; 
    
    _jugador.inventory = global.inventory_data.consumibles;
    _jugador.equipo_arma = global.inventory_data.equipado_arma;
    _jugador.equipo_armadura = global.inventory_data.equipado_armadura;
    
    if (variable_global_exists("load_facing")) {
        _jugador.facing_direction = global.load_facing;
        switch(global.load_facing) {
            case 0: _jugador.face = RIGHT; _jugador.direccion = "derecha"; break;
            case 1: _jugador.face = LEFT; _jugador.direccion = "izquierda"; break;
            case 2: _jugador.face = DOWN; _jugador.direccion = "abajo"; break;
            case 3: _jugador.face = UP; _jugador.direccion = "arriba"; break;
        }
    }
}