/// =========================================================
/// OBJ_NEW_GAME_TRANSITION
/// DRAW GUI
/// =========================================================


// =========================================================
// PREPARAR
// =========================================================

draw_set_color(
    c_white
);

draw_set_alpha(
    1
);


var _gui_w =
    display_get_gui_width();


var _gui_h =
    display_get_gui_height();


var _frames =
    sprite_get_number(
        spr_transition
    );


var _frame =
    0;


var _alpha_transition =
    1;


// =========================================================
// SPR_TRANSITION CON VARIOS FRAMES
// =========================================================

if (_frames > 1)
{
    _frame =
        floor(
            transicion_progreso
            *
            (_frames - 1)
        );


    _frame =
        clamp(
            _frame,
            0,
            _frames - 1
        );
}


// =========================================================
// SI SPR_TRANSITION TIENE SOLO 1 FRAME
// =========================================================

else
{
    _frame =
        0;


    _alpha_transition =
        transicion_progreso;
}


// =========================================================
// DIBUJAR TRANSICIÓN
// =========================================================

draw_sprite_stretched_ext(
    spr_transition,

    _frame,

    0,
    0,

    _gui_w,
    _gui_h,

    c_white,

    _alpha_transition
);


// =========================================================
// RESTAURAR
// =========================================================

draw_set_alpha(
    1
);

draw_set_color(
    c_white
);