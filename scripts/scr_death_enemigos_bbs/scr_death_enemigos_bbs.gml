// Script dedicado para el control de enemigos derrotados en batalla
function scr_inicializar_muertes_enemigos(_array_enemigos) {
    var _mapa = ds_map_create();
    for (var i = 0; i < array_length(_array_enemigos); i++) {
        _mapa[? string(i)] = false; // Ninguno empieza muerto
    }
    return _mapa;
}

function scr_marcar_enemigo_muerto(_mapa_muertes, _index) {
    if (_mapa_muertes != undefined && ds_exists(_mapa_muertes, ds_type_map)) {
        _mapa_muertes[? string(_index)] = true;
    }
}

function scr_esta_enemigo_muerto(_mapa_muertes, _index) {
    if (_mapa_muertes != undefined && ds_exists(_mapa_muertes, ds_type_map)) {
        var _val = _mapa_muertes[? string(_index)];
        if (_val != undefined) return _val;
    }
    return false;
}