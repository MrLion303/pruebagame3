/// =========================================================
/// OBJ_WARP_SIGILO
/// STEP - NUEVO
/// =========================================================
///
/// **PARENT OBLIGATORIO: obj_warp_block**
///
/// NO necesita Create.
/// Hereda exactamente los mismos campos del warp normal.
/// Creation Code = igual a obj_warp_block.
///
/// Solo ejecuta el warp mientras Maya tiene Sigilo y mantiene S.
/// =========================================================

if (!instance_exists(obj_player))
    exit;

var _p =
    instance_find(obj_player, 0);

if (
    !scr_habilidad_tiene("sigilo")
    ||
    !variable_instance_exists(_p, "sigilo_activo")
    ||
    !_p.sigilo_activo
)
{
    exit;
}


// Reutilizar TODO el Step actual de obj_warp_block:
// transición, música, tiendas y cinemática.
event_inherited();
