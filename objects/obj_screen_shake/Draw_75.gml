/// =========================================================
/// OBJ_SCREEN_SHAKE
/// DRAW GUI END
/// =========================================================

if (gui_shake_active)
{
    matrix_set(
        matrix_world,
        gui_matrix_previous
    );


    gui_shake_active =
        false;
}
