// Variables iniciales
global.start_room = pasillo_school;
global.start_x = 668;
global.start_y = 194;

global.new_game = false;
global.title_bottons = false;

// Identificadores de Habitaciones (Rooms IDs)
global.rm0 = 0;
global.rm1 = 1;
global.rm2 = 2;
global.rm3 = 3;
global.rm4 = 4;
global.rm5 = 5;

// Variable para controlar el tamaño de los botones
var button_scale = 0.15; 

// Coordenadas para posicionar los botones
// Modifica "menu_x" si necesitas moverlos más a la izquierda (número menor) o derecha (número mayor)
var menu_x = 30; 
var menu_y = 90; 

if (file_exists("prueba.ini")) {
    
    // Existe partida, creamos el menú que incluye CONTINUAR
    with (instance_create_depth(menu_x, menu_y, 100, obj_buttons_continue)) {
        image_xscale = button_scale;
        image_yscale = button_scale;
    }

    // Leemos los datos
    ini_open("prueba.ini");
    global.start_room = ini_read_string("Save1", "room", pasillo_school);
    global.start_x = ini_read_real("Save1", "x", 668);
    global.start_y = ini_read_real("Save1", "y", 194);
    ini_close();

} else {

    // NO hay partida, creamos el menú normal (sin CONTINUAR)
    with (instance_create_depth(menu_x, menu_y, 100, obj_buttons)) {
        image_xscale = button_scale;
        image_yscale = button_scale;
    }

}

// Ajuste del mapa de rooms
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