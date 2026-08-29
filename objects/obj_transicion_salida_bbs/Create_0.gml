/// =========================================================
/// OBJ_TRANSICION_SALIDA_BBS
/// CREATE
/// =========================================================

depth =
    -10000;

persistent =
    true;

image_speed =
    0.5;

image_index =
    0;

fase_salida =
    false;

retorno_finalizado =
    false;


// =========================================================
// FUNCIÓN FINAL DEL RETORNO
// =========================================================

f_finalizar_retorno = function()
{
    if (retorno_finalizado)
    {
        return;
    }


    retorno_finalizado =
        true;


    // Si veníamos de una cinemática,
    // esto crea de nuevo el controller
    // exactamente desde la acción posterior a cs_battle().
    var _reanudo =
        scr_cutscene_resume_after_battle();


    // Batalla normal:
    // devolver control como siempre.
    if (!_reanudo)
    {
        if (instance_exists(obj_player))
        {
            if (
                variable_instance_exists(
                    obj_player,
                    "puede_moverse"
                )
            )
            {
                obj_player.puede_moverse =
                    true;
            }


            if (
                variable_instance_exists(
                    obj_player,
                    "can_move"
                )
            )
            {
                obj_player.can_move =
                    true;
            }


            if (
                variable_instance_exists(
                    obj_player,
                    "cutscene_motion_active"
                )
            )
            {
                obj_player.cutscene_motion_active =
                    false;
            }


            if (
                variable_instance_exists(
                    obj_player,
                    "cutscene_sprite_override_active"
                )
            )
            {
                obj_player.cutscene_sprite_override_active =
                    false;
            }
        }


        global.cutscene_active =
            false;
    }


    persistent =
        false;


    instance_destroy();
};

