/// =========================================================
/// OBJ_SHOP_CONTROLLER
/// DESTROY COMPLETO
/// =========================================================
//
// Si la tienda desaparece por un room_goto ejecutado por
// obj_warp, NO liberamos aquí al player: obj_warp lo mantiene
// bloqueado hasta terminar de abrir spr_warp_transition.
// =========================================================

if (instance_exists(obj_player))
{
    if (!instance_exists(obj_warp))
    {
        if (variable_instance_exists(obj_player, "puede_moverse"))
        {
            obj_player.puede_moverse = true;
        }

        if (variable_instance_exists(obj_player, "can_move"))
        {
            obj_player.can_move = true;
        }
    }
}
