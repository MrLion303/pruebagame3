/// =========================================================
/// OBJ_WARP
/// CREATE COMPLETO
/// =========================================================

// Destino.
target_x = 0;
target_y = 0;
target_rm = 0;
target_face = 0;
target_music = -1;
keep_music = false;


// =========================================================
// CINEMÁTICA AL ENTRAR AL DESTINO
// =========================================================
//
// Estos valores llegan desde obj_warp_block.
//
// Vacío:
//     no inicia ninguna cinemática.
//
// Ejemplo:
//     target_cutscene = "entrada_gerson";
//
// true:
//     solo una vez por partida.
//
// false:
//     se ejecuta cada vez que se use ese warp.
//
target_cutscene = "";
target_cutscene_once = true;


// =========================================================
// TRANSICIÓN NORMAL UNIVERSAL
// =========================================================
//
// Este mismo obj_warp se usa para TODAS las habitaciones,
// incluyendo tiendas.
//
// Debe sobrevivir al room_goto para poder reproducir la
// MISMA animación hacia atrás en la habitación de destino.
// =========================================================

persistent = true;

warp_room_changed = false;

// Respetar la velocidad configurada en el objeto/sprite.
warp_anim_speed = abs(image_speed);

if (warp_anim_speed <= 0)
{
    warp_anim_speed = 1;
}

image_speed = warp_anim_speed;
image_index = 0;


// =========================================================
// FINALIZAR TRANSICIÓN
// =========================================================

warp_finish = function()
{
    // =====================================================
    // ¿HAY UNA CINEMÁTICA PENDIENTE PARA ESTA ROOM?
    // =====================================================
    //
    // Si la hay, NO devolveremos el movimiento todavía.
    //
    // obj_settings iniciará la cinemática inmediatamente
    // después de desaparecer obj_warp.
    // =====================================================

    var _hold_for_cutscene =
        false;


    if (
        variable_global_exists("warp_cutscene_pending")
        &&
        global.warp_cutscene_pending
        &&
        variable_global_exists("warp_cutscene_pending_room")
        &&
        global.warp_cutscene_pending_room == room
    )
    {
        _hold_for_cutscene =
            true;
    }


    if (instance_exists(obj_player))
    {
        var _p = instance_find(obj_player, 0);


        if (!_hold_for_cutscene)
        {
            if (variable_instance_exists(_p, "puede_moverse"))
            {
                _p.puede_moverse = true;
            }

            if (variable_instance_exists(_p, "can_move"))
            {
                _p.can_move = true;
            }
        }
        else
        {
            // Mantener completamente bloqueado hasta que
            // comience la cinemática.
            if (variable_instance_exists(_p, "puede_moverse"))
            {
                _p.puede_moverse = false;
            }

            if (variable_instance_exists(_p, "can_move"))
            {
                _p.can_move = false;
            }
        }


        if (variable_instance_exists(_p, "cutscene_motion_active"))
        {
            _p.cutscene_motion_active = false;
        }
    }


    persistent = false;
    instance_destroy();
};
