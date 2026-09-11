/// =========================================================
/// OBJ_ENEMIGO_BATALLA_MAPA_PARENT
/// CREATE
/// =========================================================
///
/// Parent universal de enemigos de mapa que pueden iniciar
/// una batalla BBS al tocar a Maya.
///
/// TIPOS:
///
///     "contacto"
///         Patrulla normalmente.
///         Al tocar a Maya:
///             1. cambia al sprite de alerta;
///             2. bloquea el mundo durante el tiempo indicado;
///             3. después inicia la batalla.
///
///     "persecucion"
///         Patrulla normalmente.
///         Cuando Maya entra en su rango:
///             1. cambia al sprite de alerta;
///             2. se queda quieto un momento;
///             3. después empieza a perseguirla;
///             4. al tocarla inicia batalla inmediatamente.
///
/// La configuración se encuentra en:
///
///     scr_enemigos_batalla_mapa_data
///
/// =========================================================


// =========================================================
// ID DE DATOS
// =========================================================
//
// Los objetos hijos deben asignar primero:
//
//     enemigo_batalla_mapa_id = "mi_enemigo";
//
// y después:
//
//     event_inherited();
//
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


// =========================================================
// TIEMPOS DE ALERTA
// =========================================================
//
// Se configuran en SEGUNDOS en el script de datos.
// Aquí se convierten automáticamente a frames usando los FPS
// reales configurados en GameMaker.
//
// Ejemplo a 30 FPS:
//
//     1.0 s = 30 frames
//     0.5 s = 15 frames
//
// =========================================================

var _fps_actual =
    max(
        1,
        game_get_speed(
            gamespeed_fps
        )
    );


alerta_contacto_frames =
    max(
        0,
        round(
            datos_enemigo_mapa.alerta_contacto_segundos
            *
            _fps_actual
        )
    );


alerta_persecucion_frames =
    max(
        0,
        round(
            datos_enemigo_mapa.alerta_persecucion_segundos
            *
            _fps_actual
        )
    );


// =========================================================
// PATRULLA
// =========================================================

patrulla_x1 =
    datos_enemigo_mapa.patrulla_x1;

patrulla_y1 =
    datos_enemigo_mapa.patrulla_y1;

patrulla_x2 =
    datos_enemigo_mapa.patrulla_x2;

patrulla_y2 =
    datos_enemigo_mapa.patrulla_y2;


patrulla_velocidad =
    max(
        0,
        datos_enemigo_mapa.patrulla_velocidad
    );


patrulla_iniciar_en_a =
    datos_enemigo_mapa.patrulla_iniciar_en_a;


patrulla_objetivo =
    patrulla_iniciar_en_a
    ?
    1
    :
    0;


if (patrulla_iniciar_en_a)
{
    x =
        patrulla_x1;

    y =
        patrulla_y1;
}
else
{
    x =
        patrulla_x2;

    y =
        patrulla_y2;
}


// =========================================================
// PERSECUCIÓN / ALERTA
// =========================================================

persecucion_velocidad =
    max(
        0,
        datos_enemigo_mapa.persecucion_velocidad
    );


persiguiendo =
    false;


// true desde que un enemigo de persecución detecta a Maya.
// Permanece true durante la espera y durante toda la
// persecución hasta abandonar la room.
alerta_activa =
    false;


// Espera de 0.5 s (o el tiempo configurado) antes de empezar
// a perseguir.
esperando_persecucion =
    false;


// Cuenta regresiva usada tanto por la alerta de persecución
// como por la pausa previa a una batalla de contacto.
alerta_timer =
    0;


// En modo contacto, durante esta pausa el parent seguirá
// ejecutando su Step para contar el tiempo, pero el resto del
// mundo queda bloqueado usando el sistema de cutscenes.
pausa_contacto_activa =
    false;


// =========================================================
// ESTADO DE BATALLA
// =========================================================

batalla_iniciada =
    false;


// Al volver de una batalla evitamos que el mismo contacto
// vuelva a dispararla instantáneamente.
contacto_cooldown =
    0;


if (
    variable_global_exists(
        "map_enemy_return_grace_room"
    )
    &&
    global.map_enemy_return_grace_room
    ==
    room
)
{
    contacto_cooldown =
        30;

    variable_global_del(
        "map_enemy_return_grace_room"
    );
}


// =========================================================
// SPRITES
// =========================================================

sprite_default =
    datos_enemigo_mapa.sprite_default;

sprite_arriba =
    datos_enemigo_mapa.sprite_arriba;

sprite_abajo =
    datos_enemigo_mapa.sprite_abajo;

sprite_izquierda =
    datos_enemigo_mapa.sprite_izquierda;

sprite_derecha =
    datos_enemigo_mapa.sprite_derecha;


// Sprite que se muestra al detectar a Maya o al producirse el
// contacto previo a batalla.
sprite_alerta =
    datos_enemigo_mapa.sprite_alerta;


image_speed_caminando =
    max(
        0,
        datos_enemigo_mapa.image_speed_caminando
    );


image_speed_alerta =
    max(
        0,
        datos_enemigo_mapa.image_speed_alerta
    );


if (
    sprite_default != -1
    &&
    sprite_exists(sprite_default)
)
{
    sprite_index =
        sprite_default;
}


image_speed =
    image_speed_caminando;


// =========================================================
// FUNCIÓN INTERNA: CAMBIAR A SPRITE DE ALERTA
// =========================================================
//
// Si sprite_alerta vale -1, simplemente conserva el sprite
// que ya estaba usando.
// =========================================================

mostrar_sprite_alerta =
function()
{
    if (
        sprite_alerta != -1
        &&
        sprite_exists(sprite_alerta)
    )
    {
        if (sprite_index != sprite_alerta)
        {
            sprite_index =
                sprite_alerta;

            image_index =
                0;
        }


        image_speed =
            image_speed_alerta;
    }
};


// =========================================================
// FUNCIÓN INTERNA: INICIAR BATALLA BBS
// =========================================================
//
// Centraliza el flujo para que contacto y persecución usen
// exactamente la misma entrada a batalla.
// =========================================================

iniciar_batalla_bbs =
function(_p)
{
    if (
        batalla_iniciada
        ||
        _p == noone
        ||
        !instance_exists(_p)
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
    // HP ACTUAL
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


    // Al regresar se da un pequeño margen para evitar que el
    // mismo contacto reactive instantáneamente la batalla.
    global.map_enemy_return_grace_room =
        room;


    // Este encuentro no pertenece a una cinemática.
    scr_cutscene_clear_resume();

    global.cutscene_active =
        false;


    // -----------------------------------------------------
    // BLOQUEAR A MAYA DURANTE LA TRANSICIÓN
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
    // TRANSICIÓN BBS
    // -----------------------------------------------------

    if (!instance_exists(obj_transicion_bbs))
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
// Y-SORT
// =========================================================

scr_depth_sort_register(
    id
);
