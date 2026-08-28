// =========================================================
// OBJ_TITLE
// EVENTO: INICIO DEL JUEGO
// =========================================================


// =========================================================
// INICIALIZAR LOCALIZACIÓN
// =========================================================

// Carga el idioma guardado en idioma_config.ini.
// Si no existe configuración, utiliza español.
scr_loc_init();

// =========================================================
// SISTEMA DE SPRITES TRADUCIBLES
// =========================================================

scr_sprites_idioma_init();

if (!instance_exists(obj_sprites_idioma)) {

    instance_create_depth(
        0,
        0,
        -999999,
        obj_sprites_idioma
    );

}


// =========================================================
// VARIABLES INICIALES
// =========================================================

global.start_room = pasillo_school;
global.start_x = 668;
global.start_y = 194;

global.new_game = false;
global.title_bottons = false;


// =========================================================
// IDENTIFICADORES DE HABITACIONES
// =========================================================

global.rm0 = 0;
global.rm1 = 1;
global.rm2 = 2;
global.rm3 = 3;
global.rm4 = 4;
global.rm5 = 5;


// =========================================================
// CONFIGURACIÓN DEL MENÚ DEL TÍTULO
// =========================================================

// Escala de los botones
var button_scale = 0.15;

// Posición del menú
var menu_x = 30;
var menu_y = 90;


// =========================================================
// COMPROBAR SI EXISTE PARTIDA GUARDADA
// =========================================================

if (file_exists("save.ini")) {

    // -----------------------------------------------------
    // EXISTE PARTIDA
    // Crear menú con CONTINUAR
    // -----------------------------------------------------

    var _buttons = instance_create_depth(
        menu_x,
        menu_y,
        100,
        obj_buttons_continue
    );

    // Escala
    _buttons.image_xscale = button_scale;
    _buttons.image_yscale = button_scale;

    // El menú siempre aparece haciendo Fade In.
    _buttons.image_alpha = 0;
    _buttons.image_speed = 0;
    _buttons.image_index = 0;


    // -----------------------------------------------------
    // ELEGIR EL SPRITE CORRECTO DESDE EL PRINCIPIO
    // -----------------------------------------------------

    if (scr_language_is_english()) {

        _buttons.sprite_index = spr_buttons_continue_english;

    }

    // Si estamos en español NO hacemos nada.
    //
    // El objeto conservará automáticamente el sprite
    // español que tiene asignado en GameMaker.


    // -----------------------------------------------------
    // LEER DATOS DE GUARDADO
    // -----------------------------------------------------

    ini_open("save.ini");

    global.start_room = ini_read_string(
        "Save1",
        "room",
        pasillo_school
    );

    global.start_x = ini_read_real(
        "Save1",
        "x",
        668
    );

    global.start_y = ini_read_real(
        "Save1",
        "y",
        194
    );

    ini_close();

}
else {

    // -----------------------------------------------------
    // NO EXISTE PARTIDA
    // Crear menú normal
    // -----------------------------------------------------

    var _buttons = instance_create_depth(
        menu_x,
        menu_y,
        100,
        obj_buttons
    );

    // Escala
    _buttons.image_xscale = button_scale;
    _buttons.image_yscale = button_scale;

    // El menú empieza completamente invisible.
    _buttons.image_alpha = 0;

    // Evitamos que GameMaker anime automáticamente los
    // subframes del sprite.
    _buttons.image_speed = 0;

    // Empezar en NUEVO JUEGO.
    _buttons.image_index = 0;


    // -----------------------------------------------------
    // ELEGIR EL SPRITE CORRECTO DESDE EL PRINCIPIO
    // -----------------------------------------------------

    if (scr_language_is_english()) {

        _buttons.sprite_index = spr_buttons_english;

    }

    // Español:
    // conserva el sprite original asignado a obj_buttons.
}


// =========================================================
// AJUSTAR MAPA DE ROOMS
// =========================================================

if (global.start_room == 0) {

    global.start_room = test;

}

if (global.start_room == 1) {

    global.start_room = pasillo_school;

}

if (global.start_room == 2) {

    global.start_room = toriel_salon;

}

if (global.start_room == 3) {

    global.start_room = huevo;

}