/// =========================================================
/// SCR_ICE_SYSTEM
/// =========================================================
///
/// Se llama desde obj_player -> Step.
///
/// OBJETOS:
///
///     obj_hielo
///         hielo normal con inercia.
///
///     obj_hielo_azul
///         deslizamiento continuo estilo Undertale.
///
/// El movimiento conserva la colisión con:
///
///     colision
///
/// por lo que también respeta obj_caja_puzzle si ese objeto
/// tiene como Parent a "colision".
/// =========================================================


// =========================================================
// ACERCAR UN VALOR A OTRO
// =========================================================

function scr_ice_approach(
    _value,
    _target,
    _amount
)
{
    if (_value < _target)
    {
        return min(
            _value + _amount,
            _target
        );
    }


    if (_value > _target)
    {
        return max(
            _value - _amount,
            _target
        );
    }


    return _target;
}


// =========================================================
// ACTUALIZAR DIRECCIÓN VISUAL
// =========================================================

function scr_ice_set_face(
    _dx,
    _dy
)
{
    if (_dx > 0)
    {
        face =
            RIGHT;

        direccion =
            "derecha";
    }
    else if (_dx < 0)
    {
        face =
            LEFT;

        direccion =
            "izquierda";
    }
    else if (_dy > 0)
    {
        face =
            DOWN;

        direccion =
            "abajo";
    }
    else if (_dy < 0)
    {
        face =
            UP;

        direccion =
            "arriba";
    }
}


// =========================================================
// MOVER HORIZONTALMENTE CON COLISIÓN PÍXEL A PÍXEL
// =========================================================

function scr_ice_move_x(_pixels)
{
    var _dir =
        sign(_pixels);

    var _amount =
        abs(_pixels);

    var _moved =
        false;


    for (
        var _i = 0;
        _i < _amount;
        _i++
    )
    {
        if (
            !place_meeting(
                x + _dir,
                y,
                colision
            )
        )
        {
            x +=
                _dir;

            _moved =
                true;
        }
        else
        {
            // Golpeamos una pared.
            ice_vx =
                0;

            ice_accum_x =
                0;

            return {
                moved:
                    _moved,

                blocked:
                    true
            };
        }
    }


    return {
        moved:
            _moved,

        blocked:
            false
    };
}


// =========================================================
// MOVER VERTICALMENTE CON COLISIÓN PÍXEL A PÍXEL
// =========================================================

function scr_ice_move_y(_pixels)
{
    var _dir =
        sign(_pixels);

    var _amount =
        abs(_pixels);

    var _moved =
        false;


    for (
        var _i = 0;
        _i < _amount;
        _i++
    )
    {
        if (
            !place_meeting(
                x,
                y + _dir,
                colision
            )
        )
        {
            y +=
                _dir;

            _moved =
                true;
        }
        else
        {
            ice_vy =
                0;

            ice_accum_y =
                0;

            return {
                moved:
                    _moved,

                blocked:
                    true
            };
        }
    }


    return {
        moved:
            _moved,

        blocked:
            false
    };
}


// =========================================================
// HIELO NORMAL
// =========================================================

function scr_ice_normal_update(
    _vel,
    _right,
    _left,
    _up,
    _down
)
{
    // -----------------------------------------------------
    // OBJETIVO DE VELOCIDAD
    // -----------------------------------------------------

    var _target_x =
        0;

    var _target_y =
        0;


    if (_right)
    {
        _target_x =
            _vel;
    }

    if (_left)
    {
        _target_x =
            -_vel;
    }

    if (_down)
    {
        _target_y =
            _vel;
    }

    if (_up)
    {
        _target_y =
            -_vel;
    }


    // -----------------------------------------------------
    // INERCIA HORIZONTAL
    // -----------------------------------------------------

    if (_target_x != 0)
    {
        ice_vx =
            scr_ice_approach(
                ice_vx,
                _target_x,
                ice_acceleration
            );
    }
    else
    {
        ice_vx =
            scr_ice_approach(
                ice_vx,
                0,
                ice_friction
            );
    }


    // -----------------------------------------------------
    // INERCIA VERTICAL
    // -----------------------------------------------------

    if (_target_y != 0)
    {
        ice_vy =
            scr_ice_approach(
                ice_vy,
                _target_y,
                ice_acceleration
            );
    }
    else
    {
        ice_vy =
            scr_ice_approach(
                ice_vy,
                0,
                ice_friction
            );
    }


    // -----------------------------------------------------
    // DIRECCIÓN VISUAL
    // -----------------------------------------------------

    // Igual que el movimiento normal:
    // vertical tiene prioridad si se pulsa al mismo tiempo.
    if (_right)
    {
        scr_ice_set_face(
            1,
            0
        );
    }

    if (_left)
    {
        scr_ice_set_face(
            -1,
            0
        );
    }

    if (_up)
    {
        scr_ice_set_face(
            0,
            -1
        );
    }

    if (_down)
    {
        scr_ice_set_face(
            0,
            1
        );
    }


    // -----------------------------------------------------
    // ACUMULAR SUBPÍXELES
    // -----------------------------------------------------

    ice_accum_x +=
        ice_vx;

    ice_accum_y +=
        ice_vy;


    var _move_x =
        (
            ice_accum_x >= 0
        )
        ?
        floor(ice_accum_x)
        :
        ceil(ice_accum_x);


    var _move_y =
        (
            ice_accum_y >= 0
        )
        ?
        floor(ice_accum_y)
        :
        ceil(ice_accum_y);


    ice_accum_x -=
        _move_x;

    ice_accum_y -=
        _move_y;


    // -----------------------------------------------------
    // MOVER
    // -----------------------------------------------------

    if (_move_x != 0)
    {
        var _result_x =
            scr_ice_move_x(
                _move_x
            );


        if (_result_x.moved)
        {
            movimiento =
                true;
        }
    }


    if (_move_y != 0)
    {
        var _result_y =
            scr_ice_move_y(
                _move_y
            );


        if (_result_y.moved)
        {
            movimiento =
                true;
        }
    }


    return true;
}


// =========================================================
// ELEGIR DIRECCIÓN DEL HIELO AZUL
// =========================================================

function scr_blue_ice_choose_direction(
    _right,
    _left,
    _up,
    _down,
    _allow_facing_fallback
)
{
    var _dx =
        0;

    var _dy =
        0;


    // Una tecla pulsada manda.
    if (_right)
    {
        _dx =
            1;
    }
    else if (_left)
    {
        _dx =
            -1;
    }
    else if (_up)
    {
        _dy =
            -1;
    }
    else if (_down)
    {
        _dy =
            1;
    }
    else if (_allow_facing_fallback)
    {
        // Al entrar por primera vez al hielo azul,
        // continuar en la dirección en que Maya ya miraba.
        switch (face)
        {
            case RIGHT:
                _dx = 1;
                break;

            case LEFT:
                _dx = -1;
                break;

            case UP:
                _dy = -1;
                break;

            case DOWN:
                _dy = 1;
                break;
        }
    }


    if (
        _dx != 0
        ||
        _dy != 0
    )
    {
        blue_ice_dx =
            _dx;

        blue_ice_dy =
            _dy;

        blue_ice_sliding =
            true;

        blue_ice_waiting_input =
            false;


        scr_ice_set_face(
            _dx,
            _dy
        );


        return true;
    }


    return false;
}


// =========================================================
// HIELO AZUL
// =========================================================

function scr_ice_blue_update(
    _right,
    _left,
    _up,
    _down
)
{
    // El hielo azul no utiliza la inercia del hielo normal.
    ice_vx =
        0;

    ice_vy =
        0;

    ice_accum_x =
        0;

    ice_accum_y =
        0;


    // -----------------------------------------------------
    // INICIAR / REINICIAR DESLIZAMIENTO
    // -----------------------------------------------------

    if (!blue_ice_sliding)
    {
        // Si chocamos previamente con una pared,
        // exigimos una nueva tecla.
        //
        // Si acabamos de entrar al hielo azul,
        // usamos la dirección a la que Maya ya miraba.
        scr_blue_ice_choose_direction(
            _right,
            _left,
            _up,
            _down,
            !blue_ice_waiting_input
        );
    }


    if (!blue_ice_sliding)
    {
        return true;
    }


    // -----------------------------------------------------
    // DIRECCIÓN
    // -----------------------------------------------------

    scr_ice_set_face(
        blue_ice_dx,
        blue_ice_dy
    );


    // -----------------------------------------------------
    // DESLIZAR CONTINUAMENTE
    // -----------------------------------------------------

    var _speed =
        max(
            1,
            round(
                blue_ice_speed
            )
        );


    for (
        var _i = 0;
        _i < _speed;
        _i++
    )
    {
        var _next_x =
            x
            +
            blue_ice_dx;

        var _next_y =
            y
            +
            blue_ice_dy;


        // =============================================
        // COLISIÓN
        // =============================================

        if (
            place_meeting(
                _next_x,
                _next_y,
                colision
            )
        )
        {
            blue_ice_sliding =
                false;

            blue_ice_waiting_input =
                true;

            break;
        }


        x =
            _next_x;

        y =
            _next_y;

        movimiento =
            true;


        // =============================================
        // SALIMOS DEL HIELO AZUL
        // =============================================
        //
        // En cuanto Maya deja de tocar el objeto,
        // termina el deslizamiento.
        // =============================================

        if (
            !place_meeting(
                x,
                y,
                obj_hielo_azul
            )
        )
        {
            blue_ice_sliding =
                false;

            blue_ice_waiting_input =
                false;

            break;
        }
    }


    return true;
}


// =========================================================
// FUNCIÓN PRINCIPAL
// =========================================================
//
// Devuelve:
//
//     true
//         el hielo controló el movimiento este frame.
//
//     false
//         utilizar movimiento normal del player.
//
// =========================================================

function scr_player_ice_update(
    _vel,
    _right,
    _left,
    _up,
    _down
)
{
    var _on_blue =
        place_meeting(
            x,
            y,
            obj_hielo_azul
        );


    var _on_normal =
        place_meeting(
            x,
            y,
            obj_hielo
        );



    // Guardar exactamente qué tipo de hielo está tocando.
    //
    // El hielo azul tiene prioridad si por accidente ambas
    // superficies se solapan.
    ice_on_blue =
        _on_blue;

    ice_on_normal =
        (
            _on_normal
            &&
            !_on_blue
        );


    // Se mantiene para bloquear los sonidos de pasos.
    ice_anim_lock =
        (
            ice_on_blue
            ||
            ice_on_normal
        );


    // =====================================================
    // HIELO AZUL TIENE PRIORIDAD
    // =====================================================

    if (_on_blue)
    {
        return scr_ice_blue_update(
            _right,
            _left,
            _up,
            _down
        );
    }


    // =====================================================
    // HIELO NORMAL
    // =====================================================

    if (_on_normal)
    {
        blue_ice_sliding =
            false;

        blue_ice_waiting_input =
            false;


        return scr_ice_normal_update(
            _vel,
            _right,
            _left,
            _up,
            _down
        );
    }


    // =====================================================
    // SUELO NORMAL
    // =====================================================

    ice_anim_lock =
        false;

    ice_on_normal =
        false;

    ice_on_blue =
        false;


    ice_vx =
        0;

    ice_vy =
        0;

    ice_accum_x =
        0;

    ice_accum_y =
        0;

    blue_ice_sliding =
        false;

    blue_ice_waiting_input =
        false;


    return false;
}
