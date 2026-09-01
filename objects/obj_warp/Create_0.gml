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
    if (instance_exists(obj_player))
    {
        var _p = instance_find(obj_player, 0);

        if (variable_instance_exists(_p, "puede_moverse"))
        {
            _p.puede_moverse = true;
        }

        if (variable_instance_exists(_p, "can_move"))
        {
            _p.can_move = true;
        }

        if (variable_instance_exists(_p, "cutscene_motion_active"))
        {
            _p.cutscene_motion_active = false;
        }
    }

    persistent = false;
    instance_destroy();
};
