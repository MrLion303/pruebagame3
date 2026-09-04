/// =========================================================
/// OBJ_CAJA_PUZZLE
/// STEP
/// =========================================================


// =========================================================
// MOVIMIENTO ANIMADO
// =========================================================
//
// Se inicializa aquí para no obligarte a modificar Create.
//
if (!variable_instance_exists(id, "push_moving"))
{
    push_moving =
        false;
}


if (!variable_instance_exists(id, "push_target_x"))
{
    push_target_x =
        x;
}


if (!variable_instance_exists(id, "push_target_y"))
{
    push_target_y =
        y;
}


if (!variable_instance_exists(id, "push_target_node"))
{
    push_target_node =
        noone;
}


// Velocidad visual del arrastre.
// A 30 FPS, 4 px/frame se siente rápido pero visible.
if (!variable_instance_exists(id, "push_move_speed"))
{
    push_move_speed =
        4;
}


// =========================================================
// SI LA CAJA YA SE ESTÁ MOVIENDO
// =========================================================
//
// Mientras viaja hacia la siguiente celda:
//     - no acepta otro Z / Enter;
//     - avanza suavemente;
//     - su colisión proxy la acompaña;
//     - al llegar al botón reproduce snd_impact.
//
if (push_moving)
{
    var _dx_move =
        push_target_x
        -
        x;


    var _dy_move =
        push_target_y
        -
        y;


    // -----------------------------------------------------
    // YA CASI LLEGÓ
    // -----------------------------------------------------

    if (
        abs(_dx_move) <= push_move_speed
        &&
        abs(_dy_move) <= push_move_speed
    )
    {
        x =
            push_target_x;

        y =
            push_target_y;


        push_moving =
            false;


        scr_puzzle_collision_proxy_sync(
            id,
            collision_proxy
        );


        // =============================================
        // LLEGADA AL BOTÓN
        // =============================================

        if (
            push_target_node != noone
            &&
            instance_exists(
                push_target_node
            )
            &&
            push_target_node.object_index
            ==
            obj_boton_caja
        )
        {
            locked =
                true;


            if (
                sprite_get_number(
                    sprite_index
                )
                >
                1
            )
            {
                image_index =
                    1;
            }


            push_target_node.pressed =
                true;


            push_target_node.box_on_button =
                id;


            scr_puzzle_box_complete(
                puzzle_state_id,
                push_target_node
            );


            // Sonido de impacto al encajar sobre el botón.
            audio_stop_sound(
                snd_impact
            );

            audio_play_sound(
                snd_impact,
                10,
                false
            );
        }


        push_target_node =
            noone;


        exit;
    }


    // -----------------------------------------------------
    // AVANZAR SUAVEMENTE
    // -----------------------------------------------------

    if (_dx_move != 0)
    {
        x +=
            sign(_dx_move)
            *
            min(
                push_move_speed,
                abs(_dx_move)
            );
    }


    if (_dy_move != 0)
    {
        y +=
            sign(_dy_move)
            *
            min(
                push_move_speed,
                abs(_dy_move)
            );
    }


    scr_puzzle_collision_proxy_sync(
        id,
        collision_proxy
    );


    exit;
}



// =========================================================
// SINCRONIZAR COLISIÓN
// =========================================================

if (
    collision_proxy == noone
    ||
    !instance_exists(
        collision_proxy
    )
)
{
    collision_proxy =
        scr_puzzle_collision_proxy_create(
            id
        );
}


scr_puzzle_collision_proxy_sync(
    id,
    collision_proxy
);


// =========================================================
// INICIALIZAR PERSISTENCIA
// =========================================================

if (!puzzle_initialized)
{
    puzzle_initialized =
        true;


    if (
        !is_string(
            puzzle_state_id
        )
        ||
        puzzle_state_id
        ==
        ""
    )
    {
        puzzle_state_id =
            scr_puzzle_box_auto_id(
                room,
                puzzle_start_x,
                puzzle_start_y
            );
    }


    // =====================================================
    // ESTE PUZZLE YA ESTABA COMPLETADO
    // =====================================================

    if (
        scr_puzzle_box_is_completed(
            puzzle_state_id
        )
    )
    {
        var _saved_target =
            scr_puzzle_box_target_key(
                puzzle_state_id
            );


        var _button_count =
            instance_number(
                obj_boton_caja
            );


        var _restored_button =
            noone;


        for (
            var _i = 0;
            _i < _button_count;
            _i++
        )
        {
            var _button =
                instance_find(
                    obj_boton_caja,
                    _i
                );


            if (
                _button != noone
                &&
                scr_puzzle_button_key(
                    _button
                )
                ==
                _saved_target
            )
            {
                _restored_button =
                    _button;

                break;
            }
        }


        if (
            _restored_button != noone
            &&
            instance_exists(
                _restored_button
            )
        )
        {
            // NO cargamos una posición guardada.
            //
            // Simplemente sabemos que el puzzle ya estaba
            // completado y colocamos la caja sobre su botón
            // actual en esta room.
            x =
                _restored_button.x;

            y =
                _restored_button.y;


            locked =
                true;

            image_index =
                1;


            _restored_button.pressed =
                true;

            _restored_button.box_on_button =
                id;


            scr_puzzle_collision_proxy_sync(
                id,
                collision_proxy
            );
        }
    }
}


// =========================================================
// CAJA YA RESUELTA
// =========================================================

if (locked)
{
    image_speed =
        0;


    if (
        sprite_get_number(
            sprite_index
        )
        >
        1
    )
    {
        image_index =
            1;
    }


    scr_puzzle_collision_proxy_sync(
        id,
        collision_proxy
    );


    exit;
}


// Caja movible = frame 0.
image_speed =
    0;

image_index =
    0;


// =========================================================
// BLOQUEOS DE GAMEPLAY
// =========================================================

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


if (
    variable_global_exists(
        "cutscene_active"
    )
    &&
    global.cutscene_active
)
{
    exit;
}


if (instance_exists(obj_textbox))
{
    exit;
}


if (instance_exists(obj_save_menu))
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


// =========================================================
// Z / ENTER
// =========================================================

var _confirm =
    keyboard_check_pressed(
        ord("Z")
    )
    ||
    keyboard_check_pressed(
        vk_enter
    );


if (!_confirm)
{
    exit;
}


// =========================================================
// PLAYER
// =========================================================

var _p =
    instance_find(
        obj_player,
        0
    );


if (_p == noone)
{
    exit;
}


// =========================================================
// DIRECCIÓN REAL DEL EMPUJE
// =========================================================
//
// IMPORTANTE:
//
// Usamos "face", que es la variable que tu movimiento
// principal actualiza directamente:
//
//     DOWN  = 0
//     LEFT  = 1
//     RIGHT = 2
//     UP    = 3
//
// Así evitamos depender de facing_direction.
//
// =========================================================

var _push_dx =
    0;

var _push_dy =
    0;


switch (_p.face)
{
    case RIGHT:

        _push_dx =
            1;

        break;


    case LEFT:

        _push_dx =
            -1;

        break;


    case DOWN:

        _push_dy =
            1;

        break;


    case UP:

        _push_dy =
            -1;

        break;
}


// =========================================================
// COMPROBAR QUE MAYA ESTÁ DEL LADO CORRECTO
// =========================================================
//
// Maya debe:
//
//     - estar cerca de la caja;
//     - estar alineada con ella;
//     - mirar hacia la caja.
//
// =========================================================

var _looking =
    false;


var _vertical_overlap =
    (
        _p.bbox_bottom
        >=
        bbox_top
        -
        interaction_alignment_tolerance
    )
    &&
    (
        _p.bbox_top
        <=
        bbox_bottom
        +
        interaction_alignment_tolerance
    );


var _horizontal_overlap =
    (
        _p.bbox_right
        >=
        bbox_left
        -
        interaction_alignment_tolerance
    )
    &&
    (
        _p.bbox_left
        <=
        bbox_right
        +
        interaction_alignment_tolerance
    );


// ---------------------------------------------------------
// MIRANDO DERECHA
// ---------------------------------------------------------

if (_push_dx > 0)
{
    var _gap =
        bbox_left
        -
        _p.bbox_right;


    _looking =
        (
            _gap >= -2
            &&
            _gap <= interaction_gap
            &&
            _vertical_overlap
        );
}


// ---------------------------------------------------------
// MIRANDO IZQUIERDA
// ---------------------------------------------------------

else if (_push_dx < 0)
{
    var _gap =
        _p.bbox_left
        -
        bbox_right;


    _looking =
        (
            _gap >= -2
            &&
            _gap <= interaction_gap
            &&
            _vertical_overlap
        );
}


// ---------------------------------------------------------
// MIRANDO ABAJO
// ---------------------------------------------------------

else if (_push_dy > 0)
{
    var _gap =
        bbox_top
        -
        _p.bbox_bottom;


    _looking =
        (
            _gap >= -2
            &&
            _gap <= interaction_gap
            &&
            _horizontal_overlap
        );
}


// ---------------------------------------------------------
// MIRANDO ARRIBA
// ---------------------------------------------------------

else if (_push_dy < 0)
{
    var _gap =
        _p.bbox_top
        -
        bbox_bottom;


    _looking =
        (
            _gap >= -2
            &&
            _gap <= interaction_gap
            &&
            _horizontal_overlap
        );
}


if (!_looking)
{
    exit;
}


// =========================================================
// TAMAÑO DE UNA CELDA
// =========================================================
//
// UNA pulsación:
//
//     horizontal = ancho de la caja
//     vertical   = alto de la caja
//
// No hay interpolación ni deslizamiento.
//
// =========================================================

var _cell_w =
    max(
        1,
        round(
            sprite_get_width(
                sprite_index
            )
            *
            abs(
                image_xscale
            )
        )
    );


var _cell_h =
    max(
        1,
        round(
            sprite_get_height(
                sprite_index
            )
            *
            abs(
                image_yscale
            )
        )
    );


var _target_x =
    x
    +
    (
        _push_dx
        *
        _cell_w
    );


var _target_y =
    y
    +
    (
        _push_dy
        *
        _cell_h
    );


// =========================================================
// COMPROBAR RUTA
// =========================================================
//
// YA NO exigimos:
//
//     nodo.x == target_x
//     nodo.y == target_y
//
// En su lugar comprobamos si la CAJA, colocada
// hipotéticamente en la siguiente celda, toca:
//
//     obj_boton_caja
//
// o:
//
//     obj_caja_camino
//
// Esto hace que funcione aunque los sprites tengan orígenes
// distintos o el marcador no esté perfectamente centrado.
//
// =========================================================

var _target_button =
    instance_place(
        _target_x,
        _target_y,
        obj_boton_caja
    );


var _target_path =
    instance_place(
        _target_x,
        _target_y,
        obj_caja_camino
    );


var _target_node =
    noone;


// El botón tiene prioridad sobre el marcador normal.
if (_target_button != noone)
{
    _target_node =
        _target_button;
}
else if (_target_path != noone)
{
    _target_node =
        _target_path;
}


// No existe una celda válida en esa dirección.
if (_target_node == noone)
{
    exit;
}


// =========================================================
// COMPROBAR COLISIÓN REAL DEL DESTINO
// =========================================================
//
// Apartamos temporalmente NUESTRA propia colisión proxy.
//
// Así la comprobación detecta:
//
//     paredes
//     barreras
//     otras cajas
//
// pero no la colisión de esta misma caja.
//
// =========================================================

var _proxy_valid =
    (
        collision_proxy != noone
        &&
        instance_exists(
            collision_proxy
        )
    );


var _proxy_x =
    0;

var _proxy_y =
    0;


if (_proxy_valid)
{
    _proxy_x =
        collision_proxy.x;

    _proxy_y =
        collision_proxy.y;


    collision_proxy.x =
        -1000000;

    collision_proxy.y =
        -1000000;
}


// =========================================================
// DESTINO BLOQUEADO
// =========================================================

var _blocked =
    place_meeting(
        _target_x,
        _target_y,
        colision
    );


// Devolver inmediatamente el proxy.
if (_proxy_valid)
{
    collision_proxy.x =
        _proxy_x;

    collision_proxy.y =
        _proxy_y;
}


if (_blocked)
{
    exit;
}


// =========================================================
// EMPEZAR EMPUJE ANIMADO
// =========================================================
//
// La distancia sigue siendo EXACTAMENTE una celda.
//
// Lo único que cambia es que ya no salta instantáneamente:
// ahora avanza hasta esa posición durante varios frames.
//
// =========================================================

push_target_x =
    _target_x;

push_target_y =
    _target_y;

push_target_node =
    _target_node;

push_moving =
    true;


// Sonido al comenzar a arrastrar/mover la caja.
audio_stop_sound(
    snd_smallswing
);

audio_play_sound(
    snd_smallswing,
    10,
    false
);


// =========================================================
// CONSUMIR INPUT
// =========================================================

keyboard_clear(
    ord("Z")
);

keyboard_clear(
    vk_enter
);
