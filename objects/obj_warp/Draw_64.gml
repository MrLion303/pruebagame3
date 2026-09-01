/// =========================================================
/// OBJ_WARP
/// DRAW GUI
/// =========================================================
//
// La animación SIGUE siendo la misma transición normal de
// obj_warp. Este evento solamente repite visualmente el frame
// actual sobre el GUI para que una interfaz Draw GUI, como la
// tienda, no pueda taparla.
//
// NO hay fade de la interfaz.
// =========================================================

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _sx = 1;
var _sy = 1;

if (view_enabled && view_camera[0] != -1)
{
    var _vw = camera_get_view_width(view_camera[0]);
    var _vh = camera_get_view_height(view_camera[0]);

    if (_vw > 0) _sx = _gw / _vw;
    if (_vh > 0) _sy = _gh / _vh;
}

draw_set_color(c_white);
draw_set_alpha(1);

draw_sprite_tiled_ext(
    sprite_index,
    image_index,
    0,
    0,
    _sx,
    _sy,
    c_white,
    1
);

draw_set_alpha(1);
draw_set_color(c_white);
