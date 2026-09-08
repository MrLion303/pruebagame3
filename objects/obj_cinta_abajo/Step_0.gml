/// =========================================================
/// OBJ_CINTA_ABAJO
/// STEP
/// =========================================================
///
/// Cinta transportadora fija:
///     ABAJO
///
/// NO usa image_angle.
///
/// La detección de superficie copia el mismo patrón que:
///
///     scr_downslide_get_zone()
///
/// Es decir, la comprobación se ejecuta DESDE obj_player
/// usando su bbox completo contra ESTA instancia.
/// =========================================================


// =========================================================
// BLOQUEOS GENERALES
// =========================================================

if (!conveyor_enabled)
{
    exit;
}


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


if (scr_cutscene_world_locked())
{
    exit;
}


if (
    instance_exists(obj_pauser)
    ||
    instance_exists(obj_textbox)
    ||
    instance_exists(obj_save_menu)
)
{
    exit;
}


if (
    instance_exists(obj_menu_manager)
    &&
    obj_menu_manager.state
    !=
    MENU_STATE.CLOSED
)
{
    exit;
}


if (!instance_exists(obj_player))
{
    exit;
}


var _p =
    instance_find(
        obj_player,
        0
    );


if (
    variable_instance_exists(
        _p,
        "puede_moverse"
    )
    &&
    !_p.puede_moverse
)
{
    exit;
}


// =========================================================
// DETECCIÓN DE CINTA - TAMAÑO VISUAL ESCALADO
// =========================================================
//
// IMPORTANTE:
//
// NO usamos:
//     collision_rectangle contra la cinta
//     bbox_left/right de la cinta
//     máscara de colisión de la cinta
//
// Porque en tu proyecto esa máscara sigue comportándose
// como si el sprite midiera su tamaño base de 20x20.
//
// En cambio calculamos directamente los límites VISUALES:
//
//     sprite_width  * image_xscale
//     sprite_height * image_yscale
//
// Es el mismo principio que ya usa:
//     scr_downslide_zone_visual_bounds()
//
// Como estas 4 cintas NO se rotan, el cálculo es exacto.
// =========================================================

if (
    sprite_index == -1
    ||
    !sprite_exists(
        sprite_index
    )
)
{
    exit;
}


// =========================================================
// TAMAÑO ORIGINAL DEL SPRITE
// =========================================================

var _spr_w =
    sprite_get_width(
        sprite_index
    );


var _spr_h =
    sprite_get_height(
        sprite_index
    );


var _xoffset =
    sprite_get_xoffset(
        sprite_index
    );


var _yoffset =
    sprite_get_yoffset(
        sprite_index
    );


// =========================================================
// ESCALA REAL DE ESTA INSTANCIA
// =========================================================

var _sx =
    image_xscale;


var _sy =
    image_yscale;


if (
    abs(_sx) < 0.0001
    ||
    abs(_sy) < 0.0001
)
{
    exit;
}


// =========================================================
// BORDES VISUALES EN COORDENADAS DE LA ROOM
// =========================================================
//
// Igual que el sistema de deslizamiento:
//
//     posición
//     +
//     (coordenada sprite - origin)
//     *
//     escala
//
// Funciona también si alguna escala fuera negativa.
// =========================================================

var _edge_x1 =
    x
    +
    (
        0
        -
        _xoffset
    )
    *
    _sx;


var _edge_x2 =
    x
    +
    (
        _spr_w
        -
        _xoffset
    )
    *
    _sx;


var _edge_y1 =
    y
    +
    (
        0
        -
        _yoffset
    )
    *
    _sy;


var _edge_y2 =
    y
    +
    (
        _spr_h
        -
        _yoffset
    )
    *
    _sy;


var _belt_left =
    min(
        _edge_x1,
        _edge_x2
    );


var _belt_right =
    max(
        _edge_x1,
        _edge_x2
    );


var _belt_top =
    min(
        _edge_y1,
        _edge_y2
    );


var _belt_bottom =
    max(
        _edge_y1,
        _edge_y2
    );


// =========================================================
// HITBOX COMPLETA DE MAYA VS ÁREA VISUAL COMPLETA
// =========================================================
//
// Si la cinta mide visualmente 5 bloques:
//     los 5 bloques completos son zona activa.
//
// Si la estiras 10 veces:
//     toda esa longitud funciona.
//
// La máscara base 20x20 ya no participa.
// =========================================================

var _belt_hit =
(
    _p.bbox_right
    >=
    _belt_left

    &&
    _p.bbox_left
    <=
    _belt_right

    &&
    _p.bbox_bottom
    >=
    _belt_top

    &&
    _p.bbox_top
    <=
    _belt_bottom
);


if (!_belt_hit)
{
    exit;
}


// =========================================================
// MOVIMIENTO DESDE EL CONTEXTO DE MAYA
// =========================================================
//
// ESTE ERA EL FALLO REAL.
//
// Antes hacíamos:
//
//     place_meeting(
//         _p.x + desplazamiento,
//         _p.y,
//         colision
//     );
//
// PERO ese código se ejecutaba desde el Step de la CINTA.
//
// En GameMaker, place_meeting() usa la máscara de la
// INSTANCIA QUE EJECUTA EL CÓDIGO.
//
// Por tanto, estaba comprobando:
//
//     hitbox de la CINTA
//
// desplazada a las coordenadas de Maya.
//
// No estaba comprobando la hitbox de Maya.
//
// Eso hacía que el resultado dependiera del tamaño y
// orientación de cada cinta.
//
// Ahora todo este bloque se ejecuta:
//
//     with (_p)
//
// por lo que:
//
//     place_meeting()
//
// usa realmente la máscara de obj_player, exactamente como
// ocurre en el sistema de deslizamiento.
// =========================================================

with (_p)
{
    var _move_x =
        0;


    var _move_y =
        other.conveyor_speed;


    // =====================================================
    // MOVER EN PASOS PEQUEÑOS
    // =====================================================

    var _steps =
        max(
            1,
            ceil(
                max(
                    abs(_move_x),
                    abs(_move_y)
                )
            )
        );


    var _step_x =
        _move_x
        /
        _steps;


    var _step_y =
        _move_y
        /
        _steps;


    for (
        var _i = 0;
        _i < _steps;
        _i++
    )
    {
        // -------------------------------------------------
        // X
        // -------------------------------------------------

        if (abs(_step_x) > 0.0001)
        {
            var _can_x =
                true;


            if (other.conveyor_respect_collisions)
            {
                _can_x =
                    !place_meeting(
                        x
                        +
                        _step_x,
                        y,
                        colision
                    );
            }


            if (_can_x)
            {
                x +=
                    _step_x;
            }
        }


        // -------------------------------------------------
        // Y
        // -------------------------------------------------

        if (abs(_step_y) > 0.0001)
        {
            var _can_y =
                true;


            if (other.conveyor_respect_collisions)
            {
                _can_y =
                    !place_meeting(
                        x,
                        y
                        +
                        _step_y,
                        colision
                    );
            }


            if (_can_y)
            {
                y +=
                    _step_y;
            }
        }
    }
}


// =========================================================
// SILICIO
// =========================================================
//
// No necesita movimiento manual aquí.
//
// scr_party_update() se ejecuta después, en End Step,
// y registra la posición FINAL de Maya.
//
// Por eso Silicio reproduce también el recorrido generado
// por la cinta.
// =========================================================
