/// scr_config_data
/// Configuracion persistente del juego.
function scr_config_data() {
    if (!variable_global_exists("config_data")) {
        global.config_data = {
            master_volume: 1.0,
            fullscreen_enabled: window_get_fullscreen(),
            autocorrer_enabled: false
        };
    }
    global.autocorrer_enabled = global.config_data.autocorrer_enabled;
    return global.config_data;
}

function scr_config_sync() {
    scr_config_data();
    // CORRECCIÓN: Se añadió "global." a las variables después del signo de interrogación
    global.config_data.master_volume = variable_global_exists("master_volume") ? global.master_volume : global.config_data.master_volume;
    global.config_data.fullscreen_enabled = variable_global_exists("fullscreen_enabled") ? global.fullscreen_enabled : global.config_data.fullscreen_enabled;
    global.config_data.autocorrer_enabled = variable_global_exists("autocorrer_enabled") ? global.autocorrer_enabled : global.config_data.autocorrer_enabled;
}