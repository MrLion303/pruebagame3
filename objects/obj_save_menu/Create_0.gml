state = 0; // 0 = Menú izquierdo (Acciones), 1 = Menú derecho (Archivos)
action_options = ["Salvar", "Cargar", "Borrar"];
slot_index = 0;

// Detectar si el menú fue abierto desde el título (para bloquear "Salvar")
from_title = (instance_exists(obj_buttons_continue) || instance_exists(obj_buttons));

// Si venimos del título, empezamos seleccionando "Cargar" (1), de lo contrario "Salvar" (0)
action_index = from_title ? 1 : 0; 

get_room_name = function(_id) {
    if (_id == 0) return "Test";
    if (_id == 1) return "Pasillo School";
    if (_id == 2) return "Salón de Toriel";
    if (_id == 3) return "El Huevo";
    return "Desconocido"; 
};

slots_data = array_create(3);

ini_open("prueba.ini");

for (var i = 0; i < 3; i++) {
    var _seccion = "Save" + string(i + 1);
    
    if (ini_key_exists(_seccion, "room")) {
        var _rm_guardada = ini_read_real(_seccion, "room", 1); 
        // Leemos el tiempo guardado (si no existe, carga 0)
        var _frames_guardados = ini_read_real(_seccion, "playtime", 0);
        
        slots_data[i] = {
            nombre: "Archivo " + string(i + 1),
            tiempo: scr_format_playtime(_frames_guardados), 
            lugar: get_room_name(_rm_guardada)
        };
    } else {
        slots_data[i] = {
            nombre: "Archivo " + string(i + 1),
            tiempo: "--:--:--",
            lugar: "Datos vacios"
        };
    }
}

ini_close();