/// =========================================================
/// OBJ_MENU_MANAGER
/// OTHER > ROOM START - NUEVO
/// =========================================================
///
/// Garantía adicional:
/// cada vez que una room tenga obj_menu_manager, se asegura
/// de que exista la extensión STAD / HABIL.
///
/// No reemplaza ningún evento actual.
/// =========================================================

if (!instance_exists(obj_menu_habilidades_ext))
{
    instance_create_depth(
        0,
        0,
        -2000000,
        obj_menu_habilidades_ext
    );
}
