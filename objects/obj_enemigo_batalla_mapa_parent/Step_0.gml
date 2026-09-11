/// =========================================================
/// OBJ_ENEMIGO_BATALLA_MAPA_PARENT
/// STEP
/// =========================================================


// =========================================================
// SEGURIDAD
// =========================================================

if (
    batalla_iniciada
    ||
    room == bbs
    ||
    room == game_over
)
{
    exit;
}


// =========================================================
// PAUSA UNIVERSAL ANTES DE BBS
// =========================================================
//
// IMPORTANTE:
// debe ejecutarse ANTES de scr_cutscene_world_locked().
//
// Nosotros mismos activamos global.cutscene_active.
// Este objeto necesita seguir contando mientras TODO lo demás
// está paralizado.
//
// Se aplica tanto a:
//
//     "contacto"
//     "persecucion"
//
// =========================================================

if (pausa_contacto_activa)
{
    mostrar_sprite_alerta();


    persecucion_hsp =
        0;


    persecucion_vsp =
        0;


    if (alerta_timer > 0)
    {
        alerta_timer--;
    }


    if (alerta_timer > 0)
    {
        exit;
    }


    pausa_contacto_activa =
        false;


    if (
        instance_exists(
            obj_player
        )
    )
    {
        var _p_pausa =
            instance_find(
                obj_player,
                0
            );


        iniciar_batalla_bbs(
            _p_pausa
        );
    }
    else
    {
        global.cutscene_active =
            false;
    }


    exit;
}


// =========================================================
// BLOQUEOS NORMALES
// =========================================================

if (
    scr_cutscene_world_locked()
    ||
    instance_exists(
        obj_pauser
    )
)
{
    exit;
}


if (contacto_cooldown > 0)
{
    contacto_cooldown--;
}


// =========================================================
// PLAYER
// =========================================================

if (
    !instance_exists(
        obj_player
    )
)
{
    exit;
}


var _p =
    instance_find(
        obj_player,
        0
    );


if (
    _p == noone
    ||
    !instance_exists(
        _p
    )
)
{
    exit;
}


// =========================================================
// ALERTA DE PERSECUCIÓN
// =========================================================
//
// Al detectar a Maya:
//
//     - sprite alerta;
//     - enemigo quieto 0.5 s;
//     - después persigue.
//
// Maya NO se paraliza aquí.
// =========================================================

if (
    modo_activacion
    ==
    "persecucion"
    &&
    esperando_persecucion
)
{
    mostrar_sprite_alerta();


    persecucion_hsp =
        0;


    persecucion_vsp =
        0;


    if (alerta_timer > 0)
    {
        alerta_timer--;
    }


    if (alerta_timer > 0)
    {
        exit;
    }


    esperando_persecucion =
        false;


    persiguiendo =
        true;
}


// =========================================================
// DETECTAR A MAYA
// =========================================================

if (
    modo_activacion
    ==
    "persecucion"
    &&
    !alerta_activa
    &&
    !persiguiendo
    &&
    !esperando_persecucion
)
{
    var _distancia_alerta =
        point_distance(
            x,
            y,
            _p.x,
            _p.y
        );


    if (
        _distancia_alerta
        <=
        rango_persecucion
    )
    {
        alerta_activa =
            true;


        esperando_persecucion =
            true;


        alerta_timer =
            alerta_persecucion_frames;


        persecucion_hsp =
            0;


        persecucion_vsp =
            0;


        mostrar_sprite_alerta();


        exit;
    }
}


// =========================================================
// POSICIÓN ANTERIOR
// =========================================================

var _old_x =
    x;


var _old_y =
    y;


// =========================================================
// PERSECUCIÓN SMOOTH
// =========================================================
//
// La velocidad no cambia de dirección instantáneamente.
//
// En cada frame:
//
//     velocidad actual -> lerp -> velocidad hacia Maya
//
// Esto produce un giro/aceleración más suave.
// =========================================================

if (
    modo_activacion
    ==
    "persecucion"
    &&
    persiguiendo
)
{
    var _distancia_player =
        point_distance(
            x,
            y,
            _p.x,
            _p.y
        );


    if (_distancia_player > 0.001)
    {
        var _dir_player =
            point_direction(
                x,
                y,
                _p.x,
                _p.y
            );


        var _target_hsp =
            lengthdir_x(
                persecucion_velocidad,
                _dir_player
            );


        var _target_vsp =
            lengthdir_y(
                persecucion_velocidad,
                _dir_player
            );


        persecucion_hsp =
            lerp(
                persecucion_hsp,
                _target_hsp,
                persecucion_suavizado
            );


        persecucion_vsp =
            lerp(
                persecucion_vsp,
                _target_vsp,
                persecucion_suavizado
            );


        var _vel_actual =
            point_distance(
                0,
                0,
                persecucion_hsp,
                persecucion_vsp
            );


        if (
            _vel_actual > 0
            &&
            _vel_actual > _distancia_player
        )
        {
            var _factor =
                _distancia_player
                /
                _vel_actual;


            x +=
                persecucion_hsp
                *
                _factor;


            y +=
                persecucion_vsp
                *
                _factor;
        }
        else
        {
            x +=
                persecucion_hsp;


            y +=
                persecucion_vsp;
        }
    }
}


// =========================================================
// MOVIMIENTO NORMAL POR PRESET
// =========================================================

else if (
    puede_moverse
    &&
    movimiento_velocidad > 0
)
{
    // -----------------------------------------------------
    // IDA Y VUELTA CON SMOOTHERSTEP
    // -----------------------------------------------------

    if (
        movimiento_preset
        ==
        "izquierda_derecha"
        ||
        movimiento_preset
        ==
        "arriba_abajo"
        ||
        movimiento_preset
        ==
        "diagonal"
    )
    {
        var _distancia_recorrido =
            max(
                1,
                movimiento_distancia
            );


        var _paso_t =
            movimiento_velocidad
            /
            (
                3.75
                *
                _distancia_recorrido
            );


        movimiento_trayecto_t +=
            _paso_t
            *
            movimiento_trayecto_sentido;


        if (
            movimiento_trayecto_t
            >=
            1
        )
        {
            movimiento_trayecto_t =
                1;


            movimiento_trayecto_sentido =
                -1;
        }
        else if (
            movimiento_trayecto_t
            <=
            0
        )
        {
            movimiento_trayecto_t =
                0;


            movimiento_trayecto_sentido =
                1;
        }


        var _t =
            clamp(
                movimiento_trayecto_t,
                0,
                1
            );


        var _ease =
            (
                6
                *
                power(
                    _t,
                    5
                )
            )
            -
            (
                15
                *
                power(
                    _t,
                    4
                )
            )
            +
            (
                10
                *
                power(
                    _t,
                    3
                )
            );


        var _offset =
            lerp(
                -_distancia_recorrido,
                _distancia_recorrido,
                _ease
            );


        if (
            movimiento_preset
            ==
            "izquierda_derecha"
        )
        {
            x =
                movimiento_origen_x
                +
                _offset;


            y =
                movimiento_origen_y;
        }
        else if (
            movimiento_preset
            ==
            "arriba_abajo"
        )
        {
            x =
                movimiento_origen_x;


            y =
                movimiento_origen_y
                +
                _offset;
        }
        else
        {
            x =
                movimiento_origen_x
                +
                lengthdir_x(
                    _offset,
                    movimiento_diagonal_angulo
                );


            y =
                movimiento_origen_y
                +
                lengthdir_y(
                    _offset,
                    movimiento_diagonal_angulo
                );
        }
    }


    // -----------------------------------------------------
    // CÍRCULO
    // -----------------------------------------------------

    else if (
        movimiento_preset
        ==
        "circulo"
    )
    {
        var _radio =
            max(
                1,
                movimiento_radio
            );


        var _paso_angular =
            (
                movimiento_velocidad
                /
                _radio
            )
            *
            (
                180
                /
                pi
            );


        movimiento_angulo_actual +=
            _paso_angular
            *
            movimiento_sentido;


        movimiento_angulo_actual =
            movimiento_angulo_actual
            mod
            360;


        x =
            movimiento_centro_x
            +
            lengthdir_x(
                _radio,
                movimiento_angulo_actual
            );


        y =
            movimiento_centro_y
            +
            lengthdir_y(
                _radio,
                movimiento_angulo_actual
            );
    }


    // -----------------------------------------------------
    // CONTINUO
    // -----------------------------------------------------

    else if (
        movimiento_preset
        ==
        "continuo"
    )
    {
        var _angulo_mov =
            movimiento_angulo;


        switch (
            movimiento_direccion
        )
        {
            case "derecha":
                _angulo_mov =
                    0;
                break;


            case "arriba":
                _angulo_mov =
                    90;
                break;


            case "izquierda":
                _angulo_mov =
                    180;
                break;


            case "abajo":
                _angulo_mov =
                    270;
                break;
        }


        x +=
            lengthdir_x(
                movimiento_velocidad,
                _angulo_mov
            );


        y +=
            lengthdir_y(
                movimiento_velocidad,
                _angulo_mov
            );
    }
}


// =========================================================
// SPRITE
// =========================================================

if (alerta_activa)
{
    mostrar_sprite_alerta();
}
else
{
    mostrar_sprite_normal();
}


// =========================================================
// CONTACTO CON MAYA
// =========================================================

if (contacto_cooldown > 0)
{
    exit;
}


var _distancia_contacto =
    point_distance(
        x,
        y,
        _p.x,
        _p.y
    );


if (
    _distancia_contacto
    >
    radio_contacto
)
{
    exit;
}


// =========================================================
// UNIVERSAL:
// AL TOCAR -> PARALIZAR TODO -> BBS
// =========================================================
//
// Ya NO existe comportamiento distinto entre contacto y
// persecución en este punto.
//
// Ambos hacen la misma pausa universal de 1 segundo.
// =========================================================

comenzar_pausa_batalla(
    _p
);


exit;
