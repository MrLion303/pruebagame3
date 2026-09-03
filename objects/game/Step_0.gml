
/// =========================================================
/// OBJ_GAME - STEP
/// =========================================================
/// F3 normal ya no abre el debug.
/// Ctrl+F3 / Ctrl+F3+T / F4 los maneja obj_dev_console.
/// =========================================================

if (!instance_exists(obj_dev_console))
{
    instance_create_depth(
        0,
        0,
        -10000000,
        obj_dev_console
    );
}

if (variable_global_exists("playtime_frames"))
{
    global.playtime_frames += 1;
}
