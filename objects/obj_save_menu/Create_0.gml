
// =========================================================
// OBJ_SAVE_MENU
// CREATE
// =========================================================

state = 0;
// 0 = Menú izquierdo
// 1 = Menú derecho

action_options = [
    scr_loc_src("Salvar"),
    scr_loc_src("Cargar"),
    scr_loc_src("Borrar")
];

slot_index = 0;


// =========================================================
// CONFIRMACIÓN DE GUARDADO
// =========================================================

guardado_confirmado = false;
guardado_slot = -1;


// =========================================================
// TRANSICIÓN DE CARGA
// =========================================================

transicion_activa = false;

// 0 = ninguna
// 1 = fade hacia negro
// 2 = esperando cambio de room
// 3 = fade desde negro
transicion_fase = 0;

// Progreso de 0 a 1.
transicion_progreso = 0;

// Velocidad.
//
// 0.04 = aproximadamente 25 frames.
// Puedes bajar a 0.03 si la quieres más lenta.
transicion_velocidad = 0.04;

// Slot que cargaremos cuando la pantalla esté cubierta.
transicion_seccion = "";

// Destino.
transicion_room = room;
transicion_x = 0;
transicion_y = 0;

// Durante el fade-out en la nueva room
// ya no dibujaremos la interfaz de guardado.
mostrar_interfaz = true;


// =========================================================
// DETECTAR SI VENIMOS DEL TÍTULO
// =========================================================

from_title = (
    instance_exists(obj_buttons_continue)
    ||
    instance_exists(obj_buttons)
);

// Título = empezar en Cargar.
// Juego = empezar en Salvar.
action_index = from_title ? 1 : 0;


// =========================================================
// NOMBRES DE ROOMS
// =========================================================
//
// Ahora se administran desde:
//
//     scr_save_room_names
//
// usando:
//
//     scr_save_room_name(room_asset)
//
// =========================================================


// =========================================================
// INFORMACIÓN DE LOS SLOTS
// =========================================================

slots_data = array_create(3);

ini_open("save.ini");

for (var i = 0; i < 3; i++)
{
    var _seccion = "Save" + string(i + 1);

    if (ini_key_exists(_seccion, "room"))
    {
        var _rm_guardada = ini_read_real(
            _seccion,
            "room",
            1
        );

        var _frames_guardados = ini_read_real(
            _seccion,
            "playtime",
            0
        );

        slots_data[i] =
        {
            nombre: scr_locf(
                "Archivo {n}",
                {
                    n: string(i + 1)
                }
            ),

            tiempo: scr_format_playtime(
                _frames_guardados
            ),

            lugar: scr_save_room_name(
                _rm_guardada
            )
        };
    }
    else
    {
        slots_data[i] =
        {
            nombre: scr_locf(
                "Archivo {n}",
                {
                    n: string(i + 1)
                }
            ),

            tiempo: "--:--:--",

            lugar: scr_loc_src(
                "Datos vacios"
            )
        };
    }
}

ini_close();
