/// =========================================================
/// OBJ_BUTTONS
/// DRAW GUI
/// =========================================================

if (newgame_transition_active)
{
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


    // =====================================================
    // SPR_TRANSITION ANIMADO
    // =====================================================

    if (_frames > 1)
    {
        _frame =
            floor(
                newgame_transition_progress
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


    // =====================================================
    // SPRITE DE UN SOLO FRAME
    // =====================================================

    else
    {
        _frame =
            0;


        _alpha_transition =
            newgame_transition_progress;
    }


    // =====================================================
    // TRANSICIÓN
    // =====================================================

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


    draw_set_alpha(
        1
    );


    draw_set_color(
        c_white
    );
}