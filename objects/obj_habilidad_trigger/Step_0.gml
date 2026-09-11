/// =========================================================
/// OBJ_HABILIDAD_TRIGGER
/// STEP - NUEVO
/// =========================================================

if (
    ocultar_si_obtenida
    &&
    scr_habilidad_tiene(habilidad_id)
)
{
    instance_destroy();
    exit;
}

if (!instance_exists(obj_player))
    exit;

if (place_meeting(x, y, obj_player))
{
    scr_habilidad_otorgar(habilidad_id);

    if (destruir_al_obtener)
        instance_destroy();
}
