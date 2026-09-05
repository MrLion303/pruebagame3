/// =========================================================
/// SCR_DOWNSLIDE_SYSTEM
/// =========================================================
///
/// Terreno de deslizamiento hacia abajo.
///
/// OBJETO:
///
///     obj_deslizamiento_abajo
///
/// REGLAS:
///
/// - Solo se activa al entrar DESDE ARRIBA.
/// - Arrastra automáticamente hacia abajo.
/// - Permite moverse a izquierda/derecha.
/// - Izquierda/derecha NO cambia dirección ni sprite.
/// - No permite escapar por los lados del terreno.
/// - Al llegar al final, sale unos píxeles extra por abajo.
/// - Mientras está activo usa exclusivamente:
///
///       pendejo_abajo -> frame 4
///
///   (quinto fotograma).
/// =========================================================


// =========================================================
// ¿EL PLAYER TOCA ALGÚN OBJETO DE DESLIZAMIENTO?
// =========================================================

function scr_downslide_get_zone()
{
    return collision_rectangle(
        bbox_left,
        bbox_top,
        bbox_right,
        bbox_bottom,
        obj_deslizamiento_abajo,
        false,
        true
    );
}


// =========================================================
// LÍMITES VISUALES DEL SPRITE DEL DESLIZAMIENTO
// =========================================================
//
// IMPORTANTE:
//
// No usamos bbox_left/bbox_right del objeto para los lados,
// porque esos valores dependen de la máscara de colisión.
//
// Aquí usamos el TAMAÑO VISUAL REAL DEL SPRITE, incluyendo
// image_xscale.
//
// Así, si haces más ancho el objeto desde el Room Editor,
// los límites laterales crecen exactamente con el sprite.
//
// =========================================================

function scr_downslide_zone_visual_bounds(_zone)
{
    if (
        _zone == noone
        ||
        !instance_exists(_zone)
        ||
        _zone.sprite_index == -1
        ||
        !sprite_exists(_zone.sprite_index)
    )
    {
        return {
            left: 0,
            right: 0
        };
    }


    var _spr =
        _zone.sprite_index;


    var _width =
        sprite_get_width(
            _spr
        );


    var _xoffset =
        sprite_get_xoffset(
            _spr
        );


    var _sx =
        _zone.image_xscale;


    // Coordenadas mundiales de ambos extremos del sprite.
    // Funciona también si image_xscale fuera negativo.
    var _edge_a =
        _zone.x
        +
        (
            0
            -
            _xoffset
        )
        *
        _sx;


    var _edge_b =
        _zone.x
        +
        (
            _width
            -
            _xoffset
        )
        *
        _sx;


    return {
        left:
            min(
                _edge_a,
                _edge_b
            ),

        right:
            max(
                _edge_a,
                _edge_b
            )
    };
}


// =========================================================
// MOVIMIENTO HORIZONTAL DURANTE EL DESLIZAMIENTO
// =========================================================

function scr_downslide_move_side(_dir, _speed)
{
    if (_dir == 0)
        return false;


    var _moved =
        false;


    for (
        var _i = 0;
        _i < _speed;
        _i++
    )
    {
        var _next_x =
            x + _dir;


        // Pared / caja / barrera.
        if (
            place_meeting(
                _next_x,
                y,
                colision
            )
        )
        {
            break;
        }


        // =================================================
        // LÍMITES LATERALES DEL SPRITE
        // =================================================
        //
        // Mientras todavía estamos siendo arrastrados por
        // el objeto, TODO el bbox del jugador debe quedar
        // dentro de los bordes visuales del sprite.
        //
        // Si escalas el objeto en el Room Editor, estos
        // límites se escalan junto con él.
        // =================================================

        if (!downslide_exiting)
        {
            var _zone =
                scr_downslide_get_zone();


            if (_zone == noone)
            {
                break;
            }


            var _bounds =
                scr_downslide_zone_visual_bounds(
                    _zone
                );


            var _next_left =
                bbox_left
                +
                _dir;


            var _next_right =
                bbox_right
                +
                _dir;


            if (
                _next_left
                <
                _bounds.left
                ||
                _next_right
                >
                _bounds.right
            )
            {
                break;
            }
        }


        x =
            _next_x;

        _moved =
            true;
    }


    return _moved;
}


// =========================================================
// CORREGIR ENTRADA / ESQUINA LATERAL
// =========================================================
//
// NO cambia el tamaño del trigger.
//
// Solo mueve al Player unos píxeles hacia el INTERIOR cuando:
//
//     - entró parcialmente por una esquina;
//     - o una colisión situada justo junto al lateral impide
//       seguir bajando.
//
// Esto evita quedar atrapado en una esquina del objeto.
//
// =========================================================

function scr_downslide_fit_inside_zone(_zone)
{
    if (
        _zone == noone
        ||
        !instance_exists(_zone)
    )
    {
        return false;
    }


    var _bounds =
        scr_downslide_zone_visual_bounds(
            _zone
        );


    // Un píxel hacia dentro evita rozar una colisión exterior
    // situada exactamente junto al borde visual.
    var _safe_left =
        _bounds.left
        +
        1;


    var _safe_right =
        _bounds.right
        -
        1;


    var _correction =
        0;


    if (bbox_left < _safe_left)
    {
        _correction =
            ceil(
                _safe_left
                -
                bbox_left
            );
    }
    else if (bbox_right > _safe_right)
    {
        _correction =
            -ceil(
                bbox_right
                -
                _safe_right
            );
    }


    if (_correction == 0)
    {
        return true;
    }


    var _dir =
        sign(
            _correction
        );


    var _amount =
        abs(
            _correction
        );


    for (
        var _i = 0;
        _i < _amount;
        _i++
    )
    {
        var _next_x =
            x
            +
            _dir;


        if (
            place_meeting(
                _next_x,
                y,
                colision
            )
        )
        {
            break;
        }


        x =
            _next_x;

        movimiento =
            true;
    }


    return true;
}


// =========================================================
// ESCAPE DE ESQUINA
// =========================================================
//
// Si debajo hay colisión mientras seguimos dentro del
// deslizamiento, intentamos desplazarnos unos píxeles hacia
// el centro de la zona.
//
// En cuanto encontramos una X donde y+1 esté libre,
// continuamos cayendo normalmente.
//
// NO se ejecuta cuando la bajada está libre.
//
// =========================================================

function scr_downslide_rescue_corner(_zone)
{
    if (
        _zone == noone
        ||
        !instance_exists(_zone)
    )
    {
        return false;
    }


    if (
        !place_meeting(
            x,
            y + 1,
            colision
        )
    )
    {
        return true;
    }


    var _bounds =
        scr_downslide_zone_visual_bounds(
            _zone
        );


    var _zone_center_x =
        (
            _bounds.left
            +
            _bounds.right
        )
        *
        0.5;


    var _player_center_x =
        (
            bbox_left
            +
            bbox_right
        )
        *
        0.5;


    var _dir =
        sign(
            _zone_center_x
            -
            _player_center_x
        );


    if (_dir == 0)
    {
        return false;
    }


    // Debe superar ligeramente el desplazamiento lateral
    // normal para que mantener una flecha contra el borde
    // no pueda dejar al Player atrapado.
    var _max_rescue =
        max(
            2,
            round(
                downslide_side_speed
            )
            +
            2
        );


    for (
        var _i = 0;
        _i < _max_rescue;
        _i++
    )
    {
        var _next_x =
            x
            +
            _dir;


        var _next_left =
            bbox_left
            +
            _dir;


        var _next_right =
            bbox_right
            +
            _dir;


        if (
            _next_left
            <
            _bounds.left
            +
            1
            ||
            _next_right
            >
            _bounds.right
            -
            1
        )
        {
            break;
        }


        if (
            place_meeting(
                _next_x,
                y,
                colision
            )
        )
        {
            break;
        }


        x =
            _next_x;

        movimiento =
            true;


        // Ya encontramos una columna libre para seguir bajando.
        if (
            !place_meeting(
                x,
                y + 1,
                colision
            )
        )
        {
            return true;
        }
    }


    return
        !place_meeting(
            x,
            y + 1,
            colision
        );
}


// =========================================================
// FUNCIÓN PRINCIPAL
// =========================================================
//
// Devuelve true si este terreno controla el movimiento en
// este frame.
// =========================================================

function scr_player_downslide_update(
    _run_speed,
    _key_right,
    _key_left
)
{
    var _zone =
        scr_downslide_get_zone();


    // =====================================================
    // INICIAR SOLO DESDE ARRIBA
    // =====================================================

    if (!downslide_active)
    {
        if (_zone != noone)
        {
            var _entered_from_top =
                (
                    downslide_prev_bottom
                    <=
                    _zone.bbox_top
                    +
                    downslide_entry_tolerance
                );


            if (_entered_from_top)
            {
                downslide_active =
                    true;

                downslide_exiting =
                    false;

                downslide_exit_remaining =
                    downslide_exit_extra;


                // Si entramos rozando una esquina, colocar el
                // bbox completamente dentro del ancho visual
                // antes de comenzar el arrastre.
                scr_downslide_fit_inside_zone(
                    _zone
                );
            }
        }
    }


    // =====================================================
    // NO ESTAMOS DESLIZANDO
    // =====================================================

    if (!downslide_active)
    {
        downslide_prev_bottom =
            bbox_bottom;

        return false;
    }


    // =====================================================
    // ESTADO VISUAL / DIRECCIÓN
    // =====================================================
    //
    // Aunque Maya se mueva lateralmente, sigue mirando abajo.
    // =====================================================

    face =
        DOWN;

    facing_direction =
        2;

    direccion =
        "abajo";


    // El terreno de bajada tiene prioridad sobre el hielo.
    ice_on_normal =
        false;

    ice_on_blue =
        false;

    ice_anim_lock =
        false;

    blue_ice_sliding =
        false;

    blue_ice_waiting_input =
        false;

    ice_vx =
        0;

    ice_vy =
        0;

    ice_accum_x =
        0;

    ice_accum_y =
        0;


    // =====================================================
    // MOVIMIENTO LATERAL
    // =====================================================

    if (_key_right && !_key_left)
    {
        if (
            scr_downslide_move_side(
                1,
                downslide_side_speed
            )
        )
        {
            movimiento =
                true;
        }
    }
    else if (_key_left && !_key_right)
    {
        if (
            scr_downslide_move_side(
                -1,
                downslide_side_speed
            )
        )
        {
            movimiento =
                true;
        }
    }


    // =====================================================
    // ARRASTRE HACIA ABAJO
    // =====================================================

    // La bajada usa exactamente la velocidad de correr
    // que recibe desde obj_player.
    var _speed_down =
        max(
            1,
            round(
                _run_speed
            )
        );


    for (
        var _i = 0;
        _i < _speed_down;
        _i++
    )
    {
        // =================================================
        // COLISIÓN DEBAJO
        // =================================================
        //
        // Si estamos pegados a una esquina lateral, intentar
        // corregir X hacia el interior antes de cancelar la
        // bajada.
        // =================================================

        if (
            place_meeting(
                x,
                y + 1,
                colision
            )
        )
        {
            var _rescue_zone =
                scr_downslide_get_zone();


            var _rescued =
                scr_downslide_rescue_corner(
                    _rescue_zone
                );


            // Sigue realmente bloqueado: es una pared/suelo
            // legítimo, no un atasco de esquina.
            if (
                !_rescued
                ||
                place_meeting(
                    x,
                    y + 1,
                    colision
                )
            )
            {
                break;
            }
        }


        y +=
            1;

        movimiento =
            true;


        var _still_inside =
            (
                scr_downslide_get_zone()
                !=
                noone
            );


        // ---------------------------------------------
        // ACABAMOS DE SALIR POR ABAJO
        // ---------------------------------------------

        if (
            !_still_inside
            &&
            !downslide_exiting
        )
        {
            downslide_exiting =
                true;

            downslide_exit_remaining =
                downslide_exit_extra;
        }


        // ---------------------------------------------
        // UNOS PÍXELES EXTRA FUERA DEL OBJETO
        // ---------------------------------------------

        if (downslide_exiting)
        {
            downslide_exit_remaining--;


            if (
                downslide_exit_remaining
                <=
                0
            )
            {
                downslide_active =
                    false;

                downslide_exiting =
                    false;

                break;
            }
        }
    }


    downslide_prev_bottom =
        bbox_bottom;


    // Aunque acabe de terminar este mismo frame, el sistema
    // controló el movimiento y no debemos ejecutar además el
    // movimiento normal / hielo.
    return true;
}
