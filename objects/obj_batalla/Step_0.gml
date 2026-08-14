if (esta_activo) {
    var _p = instance_place(x, y, obj_player);

    if (_p != noone) {
        // Verificar que no exista ya una transicion corriendo
        if (!instance_exists(obj_transicion_bbs)) {
            
            // --- CONGELAR AL JUGADOR ---
            if (variable_instance_exists(_p, "can_move")) {
                _p.can_move = false;
            }
            if (variable_instance_exists(_p, "hsp")) _p.hsp = 0;
            if (variable_instance_exists(_p, "vsp")) _p.vsp = 0;
            
            // --- GUARDAMOS LA POSICIÓN DE RETORNO UNIVERSAL ---
            global.return_room = room;
            global.return_x = _p.x;
            global.return_y = _p.y;
            
            // Guardamos el enemigo configurado (el "toby" o el que tenga asignado)
            global.enemigo_actual_id = enemigo_id;
            
            // Aseguramos que exista la estructura global de control de enemigos destruidos
            if (!variable_global_exists("enemigos_destruidos")) {
                global.enemigos_destruidos = {};
            }
            
            // Marcamos este enemigo específico como destruido dentro del struct usando sus coordenadas
            var _id_unico = string(room) + "_" + string(x) + "_" + string(y);
            global.enemigos_destruidos[$ _id_unico] = true;
            
            // Registramos que el viaje actual es hacia la batalla (para proteger la memoria de los enemigos)
            global.viajando_a_batalla = true;
            
            // Disparamos el sonido al iniciar la transicion
            audio_play_sound(snd_bbs_start, 10, false);
            
            // Creamos la transicion
            instance_create_layer(0, 0, layer, obj_transicion_bbs);
            
            // Destruimos esta instancia específica del mapa para que desaparezca LITERALMENTE
            instance_destroy(); 
        }
    }
}