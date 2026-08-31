/// =========================================================
/// OBJ_BATALLA_UI
/// DRAW
/// =========================================================
//
// FONDO PERSONALIZADO DE BATALLA
//
// fondo_batalla = noone:
//     no dibuja nada y queda el background normal del room bbs.
//
// fondo_batalla = spr_algo:
//     el sprite cubre toda la vista de batalla.
// =========================================================

if (
    variable_instance_exists(id, "fondo_batalla")
    &&
    fondo_batalla != noone
    &&
    sprite_exists(fondo_batalla)
)
{
    var _cam =
        view_camera[0];

    if (_cam != -1)
    {
        var _vx =
            camera_get_view_x(_cam);

        var _vy =
            camera_get_view_y(_cam);

        var _vw =
            camera_get_view_width(_cam);

        var _vh =
            camera_get_view_height(_cam);

        draw_sprite_stretched_ext(
            fondo_batalla,
            0,
            _vx,
            _vy,
            _vw,
            _vh,
            c_white,
            1
        );
    }
}

// Si alguna vez le asignas un sprite normal a obj_batalla_ui,
// conservar su dibujo.
if (sprite_index != -1)
{
    draw_self();
}
