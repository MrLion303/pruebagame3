/// =========================================================
/// OBJ_CUTSCENE_CONTROLLER
/// DRAW
/// =========================================================
///
/// Dibuja la imagen cinemática sobre el gameplay, pero el
/// obj_textbox queda encima porque su depth se fuerza a
/// -100000.
/// =========================================================

if (
    cutscene_image_sprite != noone
    &&
    sprite_exists(cutscene_image_sprite)
    &&
    cutscene_image_alpha > 0
)
{
    var _cam = view_camera[0];

    if (_cam != -1)
    {
        var _vx = camera_get_view_x(_cam);
        var _vy = camera_get_view_y(_cam);
        var _vw = camera_get_view_width(_cam);
        var _vh = camera_get_view_height(_cam);

        draw_sprite_stretched_ext(
            cutscene_image_sprite,
            0,
            _vx,
            _vy,
            _vw,
            _vh,
            c_white,
            cutscene_image_alpha
        );
    }
}
