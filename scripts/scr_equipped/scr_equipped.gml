function get_jugador_ataque() {
    var _atk = ataque_base;
    if (equipo_arma != -1) {
        var _item_data = global.equip_db[$ equipo_arma];
        if (_item_data != undefined) {
            _atk += _item_data.ataque;
        }
    }
    return _atk;
}

function get_jugador_defensa() {
    var _def = defensa_base;
    if (equipo_armadura != -1) {
        var _item_data = global.equip_db[$ equipo_armadura];
        if (_item_data != undefined) {
            _def += _item_data.defensa;
        }
    }
    return _def;
}