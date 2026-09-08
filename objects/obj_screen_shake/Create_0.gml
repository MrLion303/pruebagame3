/// =========================================================
/// OBJ_SCREEN_SHAKE
/// CREATE
/// =========================================================

persistent =
    true;


scr_screen_shake_init();


bound_camera =
    -1;


// Matriz usada únicamente para BBS Draw GUI.
gui_shake_active =
    false;


gui_matrix_previous =
    matrix_build_identity();
