// =========================================================
// OBJ_COFRE_UI
// DESTROY
// =========================================================

scr_inventarios_sync();


if (instance_exists(obj_player))
{
    obj_player.puede_moverse =
        true;
}