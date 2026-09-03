/// @function scr_init_playtime()
/// @description Inicia el contador de tiempo de juego a 0.
function scr_init_playtime() {
    global.playtime_frames = 0;
}

/// @function scr_format_playtime(_frames)
/// @description Convierte los frames totales a formato H:MM:SS
/// @param {real} _frames Cantidad de frames transcurridos
function scr_format_playtime(_frames) {
    // Convertimos frames a segundos (asumiendo 60 FPS)
    var _total_seconds = floor(_frames / 60); 
    
    var _hours = floor(_total_seconds / 3600);
    var _minutes = floor((_total_seconds % 3600) / 60);
    var _seconds = _total_seconds % 60;
    
    // Añadimos el cero a la izquierda si es menor a 10
    var _min_str = string(_minutes);
    if (_minutes < 10) _min_str = "0" + _min_str;
    
    var _sec_str = string(_seconds);
    if (_seconds < 10) _sec_str = "0" + _sec_str;
    
    return string(_hours) + ":" + _min_str + ":" + _sec_str;
}
