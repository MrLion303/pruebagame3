// ============================================
// OBJ_GAME_OVER_TEXTO
// ROOM END
// ============================================


// =========================================================
// SI "DESPERTAR" ESTÁ CAMBIANDO DE ROOM
// =========================================================
//
// NO devolver movimiento ni visibilidad aquí.
//
// El objeto es persistente y debe mantener la pantalla
// blanca y al jugador bloqueado hasta completar la carga.
// =========================================================

if (
    carga_iniciada
    &&
    estado == 3
)
{
    exit;
}


// =========================================================
// SALIDA NORMAL
// =========================================================

with (obj_player)
{
    visible = true;

    if (variable_instance_exists(id, "puede_moverse"))
        puede_moverse = true;

    if (variable_instance_exists(id, "can_move"))
        can_move = true;
}
