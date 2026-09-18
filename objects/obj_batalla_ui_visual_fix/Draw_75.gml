/// =========================================================
/// OBJ_BATALLA_UI_VISUAL_FIX
/// DRAW GUI END - COMPLETO
/// =========================================================
///
/// OBJETO NUEVO.
///
/// Su única función es restaurar el origen original del
/// retrato de batalla DESPUÉS de que obj_batalla_ui termine
/// de dibujarlo.
///
/// De esta manera el centrado del retrato NO modifica los
/// retratos usados por obj_textbox fuera de batalla.
/// =========================================================


// =========================================================
// RESTAURAR SPRITE
// =========================================================

if (
    variable_instance_exists(
        id,
        "restore_pending"
    )
    &&
    restore_pending
)
{
    if (
        variable_instance_exists(
            id,
            "restore_sprite"
        )
        &&
        restore_sprite != -1
        &&
        sprite_exists(
            restore_sprite
        )
    )
    {
        sprite_set_offset(
            restore_sprite,
            restore_xoffset,
            restore_yoffset
        );
    }


    restore_pending =
        false;
}


// =========================================================
// AUTODESTRUIR FUERA DE LA BATALLA
// =========================================================

if (
    room != bbs
    ||
    !instance_exists(
        obj_batalla_ui
    )
)
{
    instance_destroy();
}
