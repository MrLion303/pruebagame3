/// =========================================================
/// OBJ_ENEMIGO_BATALLA_MAPA_PARENT
/// CREATE
/// =========================================================
///
/// Parent universal para enemigos del mapa que pueden
/// iniciar una batalla BBS.
///
/// MODOS:
///
///     "contacto"
///         Hace su movimiento normal.
///         Al tocar a Maya:
///             alerta
///             -> congela TODO 1 segundo
///             -> batalla.
///
///     "persecucion"
///         Hace su movimiento normal.
///         Cuando detecta a Maya:
///             alerta
///             -> enemigo quieto 0.5 s
///             -> persigue a Maya.
///         Al tocar a Maya:
///             congela TODO 1 segundo
///             -> batalla.
///
/// REGLAS UNIVERSALES:
///
///     - Los tiempos anteriores NO se personalizan.
///     - El sprite NORMAL viene directamente del OBJETO.
///     - Solo sprite_alerta se configura en los datos.
///     - Los enemigos de persecución desaparecen al volver
///       de la batalla que ellos iniciaron.
///     - Si sales de la habitación y vuelves a entrar,
///       reaparecen normalmente.
///
/// =========================================================


// =========================================================
// ID DE CONFIGURACIÓN
// =========================================================

if (
    !variable_instance_exists(
        id,
        "enemigo_batalla_mapa_id"
    )
)
{
    enemigo_batalla_mapa_id =
        "caminante_01";
}


// =========================================================
// PUNTO ORIGINAL DE LA INSTANCIA
// =========================================================
//
// Se guarda ANTES de mover al enemigo.
//
// Sirve para:
//
//     - origen de presets;
//     - identificar exactamente qué instancia debe
//       desaparecer al regresar de BBS.
//
// =========================================================

spawn_room =
    room;


spawn_x =
    x;


spawn_y =
    y;


movimiento_origen_x =
    x;


movimiento_origen_y =
    y;


// =========================================================
// SPRITE NORMAL
// =========================================================
//
// YA NO se configura en el script.
//
// El sprite normal es el que tenga asignado el OBJETO.
// =========================================================

sprite_normal =
    sprite_index;


image_speed_normal =
    image_speed;


// =========================================================
// CARGAR CONFIGURACIÓN
// =========================================================

datos_enemigo_mapa =
    scr_enemigos_batalla_mapa_data(
        enemigo_batalla_mapa_id
    );


batalla_id =
    datos_enemigo_mapa.batalla_id;


modo_activacion =
    string_lower(
        datos_enemigo_mapa.modo_activacion
    );


rango_persecucion =
    max(
        0,
        datos_enemigo_mapa.rango_persecucion
    );


radio_contacto =
    max(
        1,
        datos_enemigo_mapa.radio_contacto
    );


sprite_alerta =
    datos_enemigo_mapa.sprite_alerta;


// =========================================================
// GLOBALES SEGURAS DE RETORNO
// =========================================================
//
// IMPORTANTE:
//
// NO usamos variable_global_del().
//
// Esa llamada era la causa del crash porque no existe como
// función válida aquí.
//
// En su lugar mantenemos globals normales y usamos booleanos
// para saber cuándo tienen datos activos.
// =========================================================

if (
    !variable_global_exists(
        "map_enemy_defeated_return_pending"
    )
)
{
    global.map_enemy_defeated_return_pending =
        false;
}


if (
    !variable_global_exists(
        "map_enemy_defeated_room"
    )
)
{
    global.map_enemy_defeated_room =
        -1;
}


if (
    !variable_global_exists(
        "map_enemy_defeated_id"
    )
)
{
    global.map_enemy_defeated_id =
        "";
}


if (
    !variable_global_exists(
        "map_enemy_defeated_spawn_x"
    )
)
{
    global.map_enemy_defeated_spawn_x =
        0;
}


if (
    !variable_global_exists(
        "map_enemy_defeated_spawn_y"
    )
)
{
    global.map_enemy_defeated_spawn_y =
        0;
}


if (
    !variable_global_exists(
        "map_enemy_contact_grace_pending"
    )
)
{
    global.map_enemy_contact_grace_pending =
        false;
}


if (
    !variable_global_exists(
        "map_enemy_contact_grace_room"
    )
)
{
    global.map_enemy_contact_grace_room =
        -1;
}


if (
    !variable_global_exists(
        "map_enemy_contact_grace_id"
    )
)
{
    global.map_enemy_contact_grace_id =
        "";
}


if (
    !variable_global_exists(
        "map_enemy_contact_grace_spawn_x"
    )
)
{
    global.map_enemy_contact_grace_spawn_x =
        0;
}


if (
    !variable_global_exists(
        "map_enemy_contact_grace_spawn_y"
    )
)
{
    global.map_enemy_contact_grace_spawn_y =
        0;
}


// =========================================================
// PERSEGUIDOR DERROTADO: DESAPARECER AL VOLVER DE BBS
// =========================================================
//
// El marcador guarda:
//
//     room
//     ID de datos
//     coordenada ORIGINAL de la instancia
//
// Así, si hay varios perseguidores iguales en la room,
// desaparece únicamente el que inició la batalla.
//
// En cuanto esta instancia se destruye, consumimos el
// marcador.
//
// Por eso:
//
//     vuelve de BBS -> NO aparece;
//     sale de room -> entra otra vez -> aparece normalmente.
//
// =========================================================

if (
    modo_activacion
    ==
    "persecucion"
    &&
    global.map_enemy_defeated_return_pending
    &&
    global.map_enemy_defeated_room
    ==
    room
    &&
    global.map_enemy_defeated_id
    ==
    enemigo_batalla_mapa_id
    &&
    abs(
        global.map_enemy_defeated_spawn_x
        -
        spawn_x
    )
    <=
    0.1
    &&
    abs(
        global.map_enemy_defeated_spawn_y
        -
        spawn_y
    )
    <=
    0.1
)
{
    global.map_enemy_defeated_return_pending =
        false;


    instance_destroy();


    exit;
}


// =========================================================
// TIEMPOS UNIVERSALES
// =========================================================

var _fps_actual =
    max(
        1,
        game_get_speed(
            gamespeed_fps
        )
    );


// Persecución:
// quieto después de detectar a Maya.
alerta_persecucion_frames =
    max(
        1,
        round(
            0.5
            *
            _fps_actual
        )
    );


// TODOS:
// congelación al tocar antes de BBS.
pausa_antes_batalla_frames =
    max(
        1,
        round(
            1.0
            *
            _fps_actual
        )
    );


// =========================================================
// MOVIMIENTO NORMAL - PRESETS
// =========================================================
//
// Igual que los enemigos de mapa a distancia.
//
// PRESETS:
//
//     "ninguno"
//     "izquierda_derecha"
//     "arriba_abajo"
//     "diagonal"
//     "circulo"
//     "continuo"
//
// Para izquierda/derecha, arriba/abajo y diagonal se usa
// smootherstep, frenando y acelerando suavemente.
//
// =========================================================

puede_moverse =
    datos_enemigo_mapa.puede_moverse;


movimiento_preset =
    string_lower(
        datos_enemigo_mapa.movimiento_preset
    );


movimiento_velocidad =
    max(
        0,
        datos_enemigo_mapa.movimiento_velocidad
    );


movimiento_distancia =
    max(
        0,
        datos_enemigo_mapa.movimiento_distancia
    );


movimiento_radio =
    max(
        1,
        datos_enemigo_mapa.movimiento_radio
    );


movimiento_direccion =
    string_lower(
        datos_enemigo_mapa.movimiento_direccion
    );


movimiento_angulo =
    datos_enemigo_mapa.movimiento_angulo;


movimiento_sentido =
    (
        datos_enemigo_mapa.movimiento_sentido
        <
        0
    )
    ?
    -1
    :
    1;


movimiento_diagonal_angulo =
    datos_enemigo_mapa.movimiento_diagonal_angulo;


// Punto medio del smootherstep.
movimiento_trayecto_t =
    0.5;


movimiento_trayecto_sentido =
    1;


// El punto colocado en la room es la parte superior inicial
// del círculo, igual que el sistema existente.
movimiento_centro_x =
    movimiento_origen_x;


movimiento_centro_y =
    movimiento_origen_y
    +
    movimiento_radio;


movimiento_angulo_actual =
    270;


// =========================================================
// PERSECUCIÓN
// =========================================================

persecucion_velocidad =
    max(
        0,
        datos_enemigo_mapa.persecucion_velocidad
    );


persiguiendo =
    false;


alerta_activa =
    false;


esperando_persecucion =
    false;


// Velocidad suavizada durante persecución.
persecucion_hsp =
    0;


persecucion_vsp =
    0;


// Universal.
// Más alto = gira/acelera más rápido.
persecucion_suavizado =
    0.22;


// =========================================================
// PAUSA / BATALLA
// =========================================================

alerta_timer =
    0;


pausa_contacto_activa =
    false;


batalla_iniciada =
    false;


// =========================================================
// COOLDOWN PARA ENEMIGOS DE CONTACTO
// =========================================================
//
// Los de persecución desaparecen al regresar.
//
// Los de contacto permanecen, así que solo reciben un margen
// breve para no reactivar BBS instantáneamente.
// =========================================================

contacto_cooldown =
    0;


if (
    modo_activacion
    ==
    "contacto"
    &&
    global.map_enemy_contact_grace_pending
    &&
    global.map_enemy_contact_grace_room
    ==
    room
    &&
    global.map_enemy_contact_grace_id
    ==
    enemigo_batalla_mapa_id
    &&
    abs(
        global.map_enemy_contact_grace_spawn_x
        -
        spawn_x
    )
    <=
    0.1
    &&
    abs(
        global.map_enemy_contact_grace_spawn_y
        -
        spawn_y
    )
    <=
    0.1
)
{
    contacto_cooldown =
        30;


    global.map_enemy_contact_grace_pending =
        false;
}


// =========================================================
// SPRITE NORMAL
// =========================================================

mostrar_sprite_normal =
function()
{
    if (
        sprite_normal != -1
        &&
        sprite_exists(
            sprite_normal
        )
    )
    {
        if (
            sprite_index
            !=
            sprite_normal
        )
        {
            sprite_index =
                sprite_normal;


            image_index =
                0;
        }


        image_speed =
            image_speed_normal;
    }
};


// =========================================================
// SPRITE DE ALERTA
// =========================================================

mostrar_sprite_alerta =
function()
{
    if (
        sprite_alerta != -1
        &&
        sprite_exists(
            sprite_alerta
        )
    )
    {
        if (
            sprite_index
            !=
            sprite_alerta
        )
        {
            sprite_index =
                sprite_alerta;


            image_index =
                0;
        }


        image_speed =
            image_speed_normal;
    }
};


// =========================================================
// COMENZAR PAUSA UNIVERSAL ANTES DE BBS
// =========================================================

comenzar_pausa_batalla =
function(_p)
{
    if (
        pausa_contacto_activa
        ||
        batalla_iniciada
        ||
        _p == noone
        ||
        !instance_exists(
            _p
        )
    )
    {
        return;
    }


    alerta_activa =
        true;


    pausa_contacto_activa =
        true;


    alerta_timer =
        pausa_antes_batalla_frames;


    persecucion_hsp =
        0;


    persecucion_vsp =
        0;


    mostrar_sprite_alerta();


    // Congelar sistemas que respetan el bloqueo de mundo.
    global.cutscene_active =
        true;


    if (
        variable_instance_exists(
            _p,
            "puede_moverse"
        )
    )
    {
        _p.puede_moverse =
            false;
    }


    if (
        variable_instance_exists(
            _p,
            "can_move"
        )
    )
    {
        _p.can_move =
            false;
    }


    if (
        variable_instance_exists(
            _p,
            "cutscene_motion_active"
        )
    )
    {
        _p.cutscene_motion_active =
            false;
    }


    _p.image_index =
        0;
};


// =========================================================
// INICIAR BATALLA BBS
// =========================================================

iniciar_batalla_bbs =
function(_p)
{
    if (
        batalla_iniciada
        ||
        _p == noone
        ||
        !instance_exists(
            _p
        )
    )
    {
        return;
    }


    batalla_iniciada =
        true;


    // -----------------------------------------------------
    // POSICIÓN DE REGRESO
    // -----------------------------------------------------

    global.return_x =
        _p.x;


    global.return_y =
        _p.y;


    global.return_room =
        room;


    // -----------------------------------------------------
    // HP
    // -----------------------------------------------------

    if (
        variable_instance_exists(
            _p,
            "hp"
        )
    )
    {
        global.player_hp_current =
            _p.hp;
    }


    // -----------------------------------------------------
    // BATALLA
    // -----------------------------------------------------

    global.enemigo_actual_id =
        batalla_id;


    global.battle_enemy_id =
        batalla_id;


    // -----------------------------------------------------
    // QUÉ HACER CUANDO BBS REGRESE A LA ROOM
    // -----------------------------------------------------

    if (
        modo_activacion
        ==
        "persecucion"
    )
    {
        // Este perseguidor debe desaparecer al volver.
        global.map_enemy_defeated_return_pending =
            true;


        global.map_enemy_defeated_room =
            room;


        global.map_enemy_defeated_id =
            enemigo_batalla_mapa_id;


        global.map_enemy_defeated_spawn_x =
            spawn_x;


        global.map_enemy_defeated_spawn_y =
            spawn_y;
    }
    else
    {
        // Los de contacto se mantienen, pero reciben margen.
        global.map_enemy_contact_grace_pending =
            true;


        global.map_enemy_contact_grace_room =
            room;


        global.map_enemy_contact_grace_id =
            enemigo_batalla_mapa_id;


        global.map_enemy_contact_grace_spawn_x =
            spawn_x;


        global.map_enemy_contact_grace_spawn_y =
            spawn_y;
    }


    // -----------------------------------------------------
    // NO ES UNA CINEMÁTICA
    // -----------------------------------------------------

    scr_cutscene_clear_resume();


    // Termina nuestro congelamiento.
    // La transición BBS toma el control a partir de aquí.
    global.cutscene_active =
        false;


    // -----------------------------------------------------
    // BLOQUEAR MAYA EN LA TRANSICIÓN
    // -----------------------------------------------------

    if (
        variable_instance_exists(
            _p,
            "puede_moverse"
        )
    )
    {
        _p.puede_moverse =
            false;
    }


    if (
        variable_instance_exists(
            _p,
            "can_move"
        )
    )
    {
        _p.can_move =
            false;
    }


    if (
        variable_instance_exists(
            _p,
            "cutscene_motion_active"
        )
    )
    {
        _p.cutscene_motion_active =
            false;
    }


    _p.image_index =
        0;


    // -----------------------------------------------------
    // TRANSICIÓN
    // -----------------------------------------------------

    if (
        !instance_exists(
            obj_transicion_bbs
        )
    )
    {
        instance_create_depth(
            0,
            0,
            -1000000,
            obj_transicion_bbs
        );
    }
};


// =========================================================
// DEBUG
// =========================================================

if (
    sprite_normal == -1
    ||
    !sprite_exists(
        sprite_normal
    )
)
{
    show_debug_message(
        "[ENEMIGO BATALLA MAPA] "
        +
        object_get_name(
            object_index
        )
        +
        " no tiene sprite normal asignado."
    );
}


if (
    sprite_alerta == -1
)
{
    show_debug_message(
        "[ENEMIGO BATALLA MAPA] "
        +
        enemigo_batalla_mapa_id
        +
        " no tiene sprite_alerta. Se conservará el normal."
    );
}


// =========================================================
// Y-SORT
// =========================================================

scr_depth_sort_register(
    id
);
