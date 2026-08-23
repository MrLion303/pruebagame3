/// scr_level_data
/// Datos persistentes de nivel, XP y estadisticas.
function scr_level_data() {
    if (!variable_global_exists("level_data")) {
        var _nivel = 1;
        var _xp = 0;
        var _sig = 100;
        var _atk = 0;
        var _def = 0;
        var _hp = 80;
        if (instance_exists(obj_player)) {
            if (variable_instance_exists(obj_player, "nivel")) _nivel = obj_player.nivel;
            if (variable_instance_exists(obj_player, "exp_actual")) _xp = obj_player.exp_actual;
            if (variable_instance_exists(obj_player, "exp_siguiente")) _sig = obj_player.exp_siguiente;
            if (variable_instance_exists(obj_player, "ataque_base")) _atk = obj_player.ataque_base;
            if (variable_instance_exists(obj_player, "defensa_base")) _def = obj_player.defensa_base;
            if (variable_instance_exists(obj_player, "hp_max")) _hp = obj_player.hp_max;
        }
        global.level_data = {nivel:_nivel, exp_actual:_xp, exp_siguiente:_sig, ataque_base:_atk, defensa_base:_def, hp_max:_hp, nivel_max:20};
    }
    return global.level_data;
}

function scr_level_ganar_experiencia(_cantidad) {
    if (_cantidad <= 0 || !instance_exists(obj_player)) return 0;
    scr_level_data();
    var _subidas = 0;
    var _p = obj_player;
    if (!variable_instance_exists(_p, "nivel")) _p.nivel = global.level_data.nivel;
    if (!variable_instance_exists(_p, "exp_actual")) _p.exp_actual = global.level_data.exp_actual;
    if (!variable_instance_exists(_p, "exp_siguiente")) _p.exp_siguiente = global.level_data.exp_siguiente;
    if (!variable_instance_exists(_p, "ataque_base")) _p.ataque_base = global.level_data.ataque_base;
    if (!variable_instance_exists(_p, "defensa_base")) _p.defensa_base = global.level_data.defensa_base;
    if (!variable_instance_exists(_p, "hp_max")) _p.hp_max = global.level_data.hp_max;

    _p.exp_actual += _cantidad;
    while (_p.nivel < 20 && _p.exp_actual >= _p.exp_siguiente) {
        _p.exp_actual -= _p.exp_siguiente;
        _p.nivel++;
        _p.ataque_base += 1;
        _p.defensa_base += 1;
        _p.hp_max += 5;
        if (variable_instance_exists(_p, "hp")) _p.hp += 5;
        _p.exp_siguiente += 25;
        _subidas++;
    }
    if (_p.nivel >= 20) {
        _p.nivel = 20;
        _p.exp_siguiente = 0;
    }
    global.level_data.nivel = _p.nivel;
    global.level_data.exp_actual = _p.exp_actual;
    global.level_data.exp_siguiente = _p.exp_siguiente;
    global.level_data.ataque_base = _p.ataque_base;
    global.level_data.defensa_base = _p.defensa_base;
    global.level_data.hp_max = _p.hp_max;
    return _subidas;
}
