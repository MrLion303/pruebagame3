/// =========================================================
/// OBJ_ENEMIGO_RUTA_DANO_PARENT
/// STEP
/// =========================================================
///
/// Sobrescribe por completo el Step de obj_enemigo_mapa_parent.
/// NO uses event_inherited() aquí.
///
/// =========================================================


// =========================================================
// SEGURIDAD
// =========================================================

if (
    room == bbs
    ||
    room == game_over
)
{
    exit;
}


if (
    variable_global_exists(
        "gameover_death_freeze_active"
    )
    &&
    global.gameover_death_freeze_active
)
{
    exit;
}


// =========================================================
// BLOQUEOS DEL MUNDO
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


// =========================================================
// RUTA POR COORDENADAS EN BUCLE
// =========================================================
//
// Cada tramo usa smootherstep.
//
// ruta_indice:
//     punto actual.
//
// siguiente:
//     (ruta_indice + 1) mod cantidad.
//
// Cuando llega al siguiente:
//
//     ese punto pasa a ser el actual
//     y empieza el próximo tramo.
//
// El último vuelve automáticamente al primero.
// =========================================================

if (
    ruta_total >= 2
    &&
    ruta_velocidad > 0
)
{
    var _indice_desde =
        ruta_indice;


    var _indice_hasta =
        (
            ruta_indice
            +
            1
        )
        mod
        ruta_total;


    var _ax =
        ruta_puntos[
            _indice_desde
        ].x;


    var _ay =
        ruta_puntos[
            _indice_desde
        ].y;


    var _bx =
        ruta_puntos[
            _indice_hasta
        ].x;


    var _by =
        ruta_puntos[
            _indice_hasta
        ].y;


    var _longitud_tramo =
        point_distance(
            _ax,
            _ay,
            _bx,
            _by
        );


    // -----------------------------------------------------
    // PUNTOS DUPLICADOS
    // -----------------------------------------------------

    if (_longitud_tramo <= 0.001)
    {
        x =
            _bx;


        y =
            _by;


        ruta_indice =
            _indice_hasta;


        ruta_t =
            0;
    }
    else
    {
        // -------------------------------------------------
        // VELOCIDAD -> PROGRESO
        // -------------------------------------------------
        //
        // La derivada máxima de smootherstep es 1.875.
        //
        // Esto hace que ruta_velocidad sea aproximadamente
        // la velocidad máxima en píxeles/frame.
        // -------------------------------------------------

        var _paso_t =
            ruta_velocidad
            /
            (
                1.875
                *
                _longitud_tramo
            );


        ruta_t =
            min(
                1,
                ruta_t
                +
                _paso_t
            );


        var _t =
            clamp(
                ruta_t,
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


        x =
            lerp(
                _ax,
                _bx,
                _ease
            );


        y =
            lerp(
                _ay,
                _by,
                _ease
            );


        // ---------------------------------------------
        // TERMINÓ EL TRAMO
        // ---------------------------------------------

        if (ruta_t >= 1)
        {
            x =
                _bx;


            y =
                _by;


            ruta_indice =
                _indice_hasta;


            ruta_t =
                0;
        }
    }
}


// =========================================================
// PLAYER / PELIGRO
// =========================================================

if (
    !instance_exists(
        obj_player
    )
)
{
    en_alerta =
        false;


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
    en_alerta =
        false;


    exit;
}


// =========================================================
// MISMO RANGO DE PELIGRO QUE LOS ENEMIGOS DE MAPA
// =========================================================
//
// Al entrar:
//
//     obj_mapa_combate_fx detecta en_alerta = true
//     -> fade oscuro
//     -> Maya roja
//     -> HUD de HP
//     -> este enemigo queda iluminado.
//
// Al salir:
//
//     exactamente el mismo fade-out existente.
//
// =========================================================

var _distancia_peligro =
    point_distance(
        x,
        y,
        _p.x,
        _p.y
    );


en_alerta =
(
    _distancia_peligro
    <=
    rango_peligro
);


// =========================================================
// CONTACTO
// =========================================================
//
// Para el golpe usamos:
//
//     - bbox del enemigo;
//     - rectángulo visual COMPLETO de Maya.
//
// Es la misma idea usada por obj_proyectil_mapa.
// =========================================================

if (
    sprite_index == -1
    ||
    _p.sprite_index == -1
)
{
    exit;
}


// ---------------------------------------------------------
// RECTÁNGULO VISUAL DE MAYA
// ---------------------------------------------------------

var _p_sprite_w =
    sprite_get_width(
        _p.sprite_index
    );


var _p_sprite_h =
    sprite_get_height(
        _p.sprite_index
    );


var _p_origin_x =
    sprite_get_xoffset(
        _p.sprite_index
    );


var _p_origin_y =
    sprite_get_yoffset(
        _p.sprite_index
    );


var _p_x1 =
    _p.x
    -
    (
        _p_origin_x
        *
        _p.image_xscale
    );


var _p_y1 =
    _p.y
    -
    (
        _p_origin_y
        *
        _p.image_yscale
    );


var _p_x2 =
    _p_x1
    +
    (
        _p_sprite_w
        *
        _p.image_xscale
    );


var _p_y2 =
    _p_y1
    +
    (
        _p_sprite_h
        *
        _p.image_yscale
    );


var _p_left =
    min(
        _p_x1,
        _p_x2
    );


var _p_right =
    max(
        _p_x1,
        _p_x2
    );


var _p_top =
    min(
        _p_y1,
        _p_y2
    );


var _p_bottom =
    max(
        _p_y1,
        _p_y2
    );


// ---------------------------------------------------------
// BBOX DEL ENEMIGO CONTRA MAYA
// ---------------------------------------------------------

var _impacta_player =
(
    bbox_right
    >=
    _p_left

    &&
    bbox_left
    <=
    _p_right

    &&
    bbox_bottom
    >=
    _p_top

    &&
    bbox_top
    <=
    _p_bottom
);


if (!_impacta_player)
{
    exit;
}


// =========================================================
// I-FRAMES
// =========================================================

if (
    !variable_instance_exists(
        _p,
        "map_battle_iframes"
    )
)
{
    _p.map_battle_iframes =
        0;
}


if (_p.map_battle_iframes > 0)
{
    exit;
}


// =========================================================
// DAÑO - MISMA FÓRMULA DE LOS PROYECTILES DE MAPA
// =========================================================

var _defensa_actual =
    0;


with (_p)
{
    _defensa_actual =
        get_jugador_defensa();
}


var _porcentaje_reduccion =
    min(
        _defensa_actual
        *
        1.6,
        50
    );


var _dano_final =
    round(
        dano_contacto
        *
        (
            1
            -
            (
                _porcentaje_reduccion
                /
                100
            )
        )
    );


_dano_final =
    max(
        1,
        _dano_final
    );


_p.hp =
    max(
        0,
        _p.hp
        -
        _dano_final
    );


_p.map_battle_iframes =
    invulnerabilidad_frames;


global.player_hp_current =
    _p.hp;


// =========================================================
// SHAKE
// =========================================================

scr_screen_shake_start(
    3,
    8
);


// =========================================================
// SONIDO
// =========================================================

if (
    audio_exists(
        snd_atacado
    )
)
{
    if (
        audio_is_playing(
            snd_atacado
        )
    )
    {
        audio_stop_sound(
            snd_atacado
        );
    }


    audio_play_sound(
        snd_atacado,
        10,
        false
    );
}


// =========================================================
// DEBUG
// =========================================================

show_debug_message(
    "[ENEMIGO RUTA DAÑO] Daño: "
    +
    string(
        _dano_final
    )
    +
    " | HP: "
    +
    string(
        _p.hp
    )
);
