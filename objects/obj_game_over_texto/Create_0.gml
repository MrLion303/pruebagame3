// ============================================
// OBJ_GAME_OVER_TEXTO
// CREATE
// ============================================


// ============================================
// DETENER MÚSICA ANTERIOR
// ============================================

audio_stop_all();


// ============================================
// MÚSICA DE GAME OVER
// ============================================

audio_play_sound(
    mus_gameover,
    10,
    true
);


// ============================================
// TERMINÓ EL SEGUNDO DE MUERTE
// ============================================

global.gameover_death_freeze_active =
    false;


// Ya estamos en una room segura.
// Liberamos el bloqueo temporal del mundo.
scr_cutscene_world_unlock();


// Si la muerte ocurrió durante una batalla,
// no conservar el flag temporal del viaje.
if (
    variable_global_exists(
        "viajando_a_batalla"
    )
)
{
    global.viajando_a_batalla =
        false;
}


// No queremos continuar una cinemática/batalla actual
// después de cargar un save anterior.
if (
    variable_global_exists(
        "cutscene_active"
    )
)
{
    global.cutscene_active =
        false;
}


scr_cutscene_clear_resume();


// ============================================
// OCULTAR Y BLOQUEAR JUGADOR
// ============================================

with (obj_player)
{
    visible = false;

    if (variable_instance_exists(id, "puede_moverse"))
        puede_moverse = false;

    if (variable_instance_exists(id, "can_move"))
        can_move = false;

    hspeed = 0;
    vspeed = 0;
}


// ============================================
// TEXTOS
// ============================================

textos = [
    scr_loc_src(
        "Parece que conseguiste\ndormir..."
    ),

    scr_loc_src(
        "¿Esto es realmente\nlo que buscabas?"
    ),

    scr_loc_src(
        "No dejes tus recuerdos\nmorir de nuevo..."
    ),

    scr_loc_src(
        "¿Volverás a despertar?"
    )
];

pagina = 0;


// ============================================
// TYPEWRITER
// ============================================

caracteres = 0;
acumulador_texto = 0;

// Juego a 30 FPS
velocidad_texto = 0.45;


// X / Shift duplican esta velocidad,
// pero nunca saltan el texto.


// ============================================
// ESCALA DE TEXTO
// ============================================

escala_texto = 1.25;


// ============================================
// DECISIÓN
// ============================================

// 0 = Despertar
// 1 = Olvidar
seleccion = 0;


// Textos fuente de las opciones.
// scr_loc_src() hace que el exportador de localización
// pueda detectarlos y añadirlos a los JSON.
texto_opcion_despertar =
    scr_loc_src(
        "Despertar"
    );

texto_opcion_olvidar =
    scr_loc_src(
        "Olvidar"
    );


// ============================================
// FADE IN DE OPCIONES
// ============================================

opciones_alpha = 0;

// 15 frames a 30 FPS = 0.5 segundos
opciones_fade_vel = 1 / 15;


// ============================================
// ESTADOS
// ============================================
//
// 0 = diálogo normal
// 1 = Olvidar
// 2 = fade blanco de Despertar + espera de 1 segundo
// 3 = partida ya cargada / retirar blanco
//

estado = 0;


// ============================================
// OLVIDAR
// ============================================

texto_olvidar =
    scr_loc_src(
        "Y de pronto... sientes\ntodo desvanecerse..."
    );

caracteres_olvidar = 0;
acumulador_olvidar = 0;

timer_cerrar = -1;


// ============================================
// DESPERTAR
// ============================================

fade_blanco = 0;

// 45 frames = 1.5 segundos
// para llegar a blanco completo.
velocidad_fade = 1 / 45;

// Una vez blanco, esperamos 30 frames.
timer_blanco = 0;

// =========================================================
// CARGA DE "DESPERTAR"
// =========================================================
//
// El objeto sobrevivirá temporalmente al room_goto para
// mantener la pantalla blanca mientras se coloca/restaura
// el jugador en la partida guardada.
// =========================================================

carga_iniciada = false;
carga_room_lista = false;

carga_seccion = "";
carga_room = -1;
carga_x = 0;
carga_y = 0;


// =========================================================
// BUSCAR LA ÚLTIMA PARTIDA GUARDADA
// =========================================================
//
// PRIORIDAD:
//
// 1. global.save_actual
// 2. [Meta] last_save de save.ini
// 3. fallback: Save1/Save2/Save3 con mayor playtime.
//
// El punto 2 queda completamente exacto si añades también
// el pequeño cambio incluido para scr_guardar_juego.
// =========================================================

obtener_ultimo_save = function()
{
    if (!file_exists("save.ini"))
    {
        return "";
    }


    ini_open("save.ini");


    // -----------------------------------------------------
    // 1. GLOBAL DE LA SESIÓN ACTUAL
    // -----------------------------------------------------

    if (
        variable_global_exists("save_actual")
        &&
        is_string(global.save_actual)
        &&
        global.save_actual != ""
    )
    {
        var _global_extra =
            ini_read_string(
                global.save_actual,
                "extra_data",
                ""
            );


        if (_global_extra != "")
        {
            var _resultado =
                global.save_actual;

            ini_close();

            return _resultado;
        }
    }


    // -----------------------------------------------------
    // 2. ÚLTIMO SLOT GUARDADO ESCRITO EN EL INI
    // -----------------------------------------------------

    var _meta_save =
        ini_read_string(
            "Meta",
            "last_save",
            ""
        );


    if (_meta_save != "")
    {
        var _meta_extra =
            ini_read_string(
                _meta_save,
                "extra_data",
                ""
            );


        if (_meta_extra != "")
        {
            ini_close();

            return _meta_save;
        }
    }


    // -----------------------------------------------------
    // 3. COMPATIBILIDAD CON SAVES ANTIGUOS
    // -----------------------------------------------------
    //
    // Antes de agregar [Meta] last_save no existe forma
    // perfecta de saber qué slot fue escrito cronológicamente.
    //
    // Como fallback elegimos el válido con mayor playtime.
    // -----------------------------------------------------

    var _mejor_save = "";
    var _mejor_tiempo = -1;


    for (var _i = 1; _i <= 3; _i++)
    {
        var _seccion =
            "Save"
            +
            string(_i);


        var _extra =
            ini_read_string(
                _seccion,
                "extra_data",
                ""
            );


        if (_extra == "")
        {
            continue;
        }


        var _tiempo =
            ini_read_real(
                _seccion,
                "playtime",
                0
            );


        if (_tiempo > _mejor_tiempo)
        {
            _mejor_tiempo =
                _tiempo;

            _mejor_save =
                _seccion;
        }
    }


    ini_close();


    return _mejor_save;
};


// Mientras estamos en la room de Game Over,
// este objeto NO es persistente.
// Solo se vuelve persistente en el instante de cargar.
persistent = false;
