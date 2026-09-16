/// =========================================================
/// SCR_FAN_SYSTEM - COMPLETO
/// =========================================================
///
/// Sistema universal de abanicos / ventiladores.
///
/// Esta versión separa correctamente:
///
///     MAYA
///         -> el Step del abanico aplica el empuje físico.
///
///     SILICIO RPG
///         -> obj_settings lo integra alrededor de scr_party_update().
///         -> usa un ciclo equivalente al de obj_deslizamiento_abajo:
///
///             wind_follow
///             wind_exit
///             wind_wait_gap
///             wind_rejoin
///             none
///
///     SILICIO PLATAFORMERO
///         -> conserva el wrapper del follower plataformero.
///
/// Creation Code opcional del abanico:
///
///     fan_distance = 160;
///     fan_force = 3.5;
///     fan_enabled = true;
///     fan_air_visible = true;
///     fan_air_alpha = 0.5;
///     fan_silicio_eject_extra = 12;
///
/// =========================================================


// =========================================================
// PREPARAR ABANICO
// =========================================================

function scr_fan_prepare(_fan, _dir_x, _dir_y)
{
    if (_fan == noone || !instance_exists(_fan))
        return false;

    if (!variable_instance_exists(_fan, "fan_sprite"))
        _fan.fan_sprite = -1;

    if (!variable_instance_exists(_fan, "fan_force"))
        _fan.fan_force = 3.5;

    if (!variable_instance_exists(_fan, "fan_distance"))
        _fan.fan_distance = 120;

    _fan.fan_distance_default = 120;

    if (!variable_instance_exists(_fan, "fan_range_base"))
        _fan.fan_range_base = 120;

    if (!variable_instance_exists(_fan, "fan_enabled"))
        _fan.fan_enabled = true;

    if (!variable_instance_exists(_fan, "fan_air_visible"))
        _fan.fan_air_visible = true;

    if (!variable_instance_exists(_fan, "fan_air_alpha"))
        _fan.fan_air_alpha = 0.5;

    if (!variable_instance_exists(_fan, "fan_air_color"))
        _fan.fan_air_color = c_white;

    if (!variable_instance_exists(_fan, "fan_silicio_eject_extra"))
        _fan.fan_silicio_eject_extra = 12;

    _fan.fan_direction_x = sign(_dir_x);
    _fan.fan_direction_y = sign(_dir_y);

    _fan.fan_push_accum = 0;
    _fan.fan_push_accum_maya = 0;

    _fan.fan_wind_left = _fan.x;
    _fan.fan_wind_top = _fan.y;
    _fan.fan_wind_right = _fan.x;
    _fan.fan_wind_bottom = _fan.y;

    return true;
}


// =========================================================
// DISTANCIA
// =========================================================

function scr_fan_get_distance(_fan)
{
    if (_fan == noone || !instance_exists(_fan))
        return 0;

    var _distance = max(0, _fan.fan_distance);

    if (
        variable_instance_exists(_fan, "fan_range_base")
        &&
        _fan.fan_distance == _fan.fan_distance_default
        &&
        _fan.fan_range_base != _fan.fan_distance_default
    )
    {
        _distance = max(0, _fan.fan_range_base);
    }

    return _distance;
}


// =========================================================
// RECTÁNGULO DEL ABANICO
// =========================================================

function scr_fan_get_source_rect(_fan)
{
    var _left = _fan.x - 16;
    var _top = _fan.y - 16;
    var _right = _fan.x + 16;
    var _bottom = _fan.y + 16;

    if (_fan.sprite_index != -1 && sprite_exists(_fan.sprite_index))
    {
        _left = _fan.bbox_left;
        _top = _fan.bbox_top;
        _right = _fan.bbox_right;
        _bottom = _fan.bbox_bottom;
    }

    return {
        left: _left,
        top: _top,
        right: _right,
        bottom: _bottom
    };
}


// =========================================================
// ZONA DEL VIENTO
// =========================================================

function scr_fan_update_zone(_fan)
{
    if (_fan == noone || !instance_exists(_fan))
        return false;

    var _src = scr_fan_get_source_rect(_fan);
    var _distance = scr_fan_get_distance(_fan);

    var _left = _src.left;
    var _top = _src.top;
    var _right = _src.right;
    var _bottom = _src.bottom;

    var _dx = _fan.fan_direction_x;
    var _dy = _fan.fan_direction_y;

    if (_dx > 0)
    {
        _left = _src.right;
        _right = _src.right + _distance;
    }
    else if (_dx < 0)
    {
        _right = _src.left;
        _left = _src.left - _distance;
    }
    else if (_dy > 0)
    {
        _top = _src.bottom;
        _bottom = _src.bottom + _distance;
    }
    else if (_dy < 0)
    {
        _bottom = _src.top;
        _top = _src.top - _distance;
    }

    _fan.fan_wind_left = min(_left, _right);
    _fan.fan_wind_top = min(_top, _bottom);
    _fan.fan_wind_right = max(_left, _right);
    _fan.fan_wind_bottom = max(_top, _bottom);

    return true;
}


// =========================================================
// HITBOX REAL DE ACTOR
// =========================================================

function scr_fan_get_actor_rect(_actor)
{
    var _left = _actor.bbox_left;
    var _top = _actor.bbox_top;
    var _right = _actor.bbox_right;
    var _bottom = _actor.bbox_bottom;

    var _platformer =
        variable_global_exists("platformer_active")
        &&
        global.platformer_active;

    if (
        _platformer
        &&
        variable_instance_exists(_actor, "platform_hit_left")
        &&
        variable_instance_exists(_actor, "platform_hit_top")
        &&
        variable_instance_exists(_actor, "platform_hit_right")
        &&
        variable_instance_exists(_actor, "platform_hit_bottom")
    )
    {
        _left = _actor.x + _actor.platform_hit_left;
        _top = _actor.y + _actor.platform_hit_top;
        _right = _actor.x + _actor.platform_hit_right;
        _bottom = _actor.y + _actor.platform_hit_bottom;
    }
    else if (
        _platformer
        &&
        variable_instance_exists(_actor, "platform_sil_hit_left")
        &&
        variable_instance_exists(_actor, "platform_sil_hit_top")
        &&
        variable_instance_exists(_actor, "platform_sil_hit_right")
        &&
        variable_instance_exists(_actor, "platform_sil_hit_bottom")
    )
    {
        _left = _actor.x + _actor.platform_sil_hit_left;
        _top = _actor.y + _actor.platform_sil_hit_top;
        _right = _actor.x + _actor.platform_sil_hit_right;
        _bottom = _actor.y + _actor.platform_sil_hit_bottom;
    }

    return {
        left: _left,
        top: _top,
        right: _right,
        bottom: _bottom
    };
}


function scr_fan_get_player_rect(_p)
{
    return scr_fan_get_actor_rect(_p);
}


// =========================================================
// SOLAPE CON VIENTO
// =========================================================

function scr_fan_actor_in_wind(_fan, _actor)
{
    if (
        _fan == noone
        ||
        !instance_exists(_fan)
        ||
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return false;
    }

    scr_fan_update_zone(_fan);

    var _rect = scr_fan_get_actor_rect(_actor);

    return
        _rect.right >= _fan.fan_wind_left
        &&
        _rect.left <= _fan.fan_wind_right
        &&
        _rect.bottom >= _fan.fan_wind_top
        &&
        _rect.top <= _fan.fan_wind_bottom;
}


function scr_fan_player_in_wind(_fan, _p)
{
    return scr_fan_actor_in_wind(_fan, _p);
}


// =========================================================
// HITBOX PLATAFORMERA
// =========================================================

function scr_fan_get_platform_hitbox(_actor)
{
    if (
        variable_instance_exists(_actor, "platform_hit_left")
        &&
        variable_instance_exists(_actor, "platform_hit_top")
        &&
        variable_instance_exists(_actor, "platform_hit_right")
        &&
        variable_instance_exists(_actor, "platform_hit_bottom")
    )
    {
        return {
            valid: true,
            left: _actor.platform_hit_left,
            top: _actor.platform_hit_top,
            right: _actor.platform_hit_right,
            bottom: _actor.platform_hit_bottom
        };
    }

    if (
        variable_instance_exists(_actor, "platform_sil_hit_left")
        &&
        variable_instance_exists(_actor, "platform_sil_hit_top")
        &&
        variable_instance_exists(_actor, "platform_sil_hit_right")
        &&
        variable_instance_exists(_actor, "platform_sil_hit_bottom")
    )
    {
        return {
            valid: true,
            left: _actor.platform_sil_hit_left,
            top: _actor.platform_sil_hit_top,
            right: _actor.platform_sil_hit_right,
            bottom: _actor.platform_sil_hit_bottom
        };
    }

    return {
        valid: false,
        left: 0,
        top: 0,
        right: 0,
        bottom: 0
    };
}


// =========================================================
// COLISIÓN AL SER EMPUJADO
// =========================================================

function scr_fan_actor_blocked(_actor, _next_x, _next_y, _dir_x, _dir_y)
{
    if (_actor == noone || !instance_exists(_actor))
        return true;

    var _platformer =
        variable_global_exists("platformer_active")
        &&
        global.platformer_active;

    if (_platformer)
    {
        var _hit = scr_fan_get_platform_hitbox(_actor);

        if (_hit.valid)
        {
            if (_dir_y > 0)
            {
                return scr_platformer_floor_at(
                    _next_x,
                    _next_y,
                    _hit.left,
                    _hit.top,
                    _hit.right,
                    _hit.bottom
                );
            }

            return scr_platformer_collision_at(
                _next_x,
                _next_y,
                _hit.left,
                _hit.top,
                _hit.right,
                _hit.bottom
            );
        }
    }

    var _left_offset = _actor.bbox_left - _actor.x;
    var _top_offset = _actor.bbox_top - _actor.y;
    var _right_offset = _actor.bbox_right - _actor.x;
    var _bottom_offset = _actor.bbox_bottom - _actor.y;

    return
        collision_rectangle(
            _next_x + _left_offset,
            _next_y + _top_offset,
            _next_x + _right_offset,
            _next_y + _bottom_offset,
            colision,
            false,
            true
        )
        !=
        noone;
}


function scr_fan_player_blocked(_p, _next_x, _next_y, _dir_x, _dir_y)
{
    return scr_fan_actor_blocked(_p, _next_x, _next_y, _dir_x, _dir_y);
}


// =========================================================
// EMPUJE DE MAYA / ACTOR GENÉRICO
// =========================================================

function scr_fan_push_actor(_fan, _actor, _accum_name, _is_maya)
{
    if (_actor == noone || !instance_exists(_actor))
    {
        variable_instance_set(_fan, _accum_name, 0);
        return false;
    }

    if (!scr_fan_actor_in_wind(_fan, _actor))
    {
        variable_instance_set(_fan, _accum_name, 0);
        return false;
    }

    var _force = max(0, abs(_fan.fan_force));

    if (_force <= 0)
    {
        variable_instance_set(_fan, _accum_name, 0);
        return false;
    }

    var _accum = variable_instance_get(_fan, _accum_name);
    _accum += _force;

    var _steps = floor(_accum);
    _accum -= _steps;

    variable_instance_set(_fan, _accum_name, _accum);

    var _start_x = _actor.x;
    var _start_y = _actor.y;
    var _moved = false;

    for (var _i = 0; _i < _steps; _i++)
    {
        var _next_x = _actor.x + _fan.fan_direction_x;
        var _next_y = _actor.y + _fan.fan_direction_y;

        if (
            scr_fan_actor_blocked(
                _actor,
                _next_x,
                _next_y,
                _fan.fan_direction_x,
                _fan.fan_direction_y
            )
        )
        {
            variable_instance_set(_fan, _accum_name, 0);
            break;
        }

        _actor.x = _next_x;
        _actor.y = _next_y;
        _moved = true;
    }

    // El viento de Maya NO debe reaparecer ocho frames después
    // dentro del historial plataformero de Silicio.
    if (
        _moved
        &&
        _is_maya
        &&
        variable_global_exists("platformer_active")
        &&
        global.platformer_active
    )
    {
        var _external_dx = _actor.x - _start_x;
        var _external_dy = _actor.y - _start_y;

        if (variable_global_exists("platform_party_last_player_feet_x"))
            global.platform_party_last_player_feet_x += _external_dx;

        if (variable_global_exists("platform_party_last_player_feet_y"))
            global.platform_party_last_player_feet_y += _external_dy;
    }

    return _moved;
}


// =========================================================
// BUSCAR CORRIENTE
// =========================================================

function scr_fan_find_wind_for_actor(_actor)
{
    if (_actor == noone || !instance_exists(_actor))
        return noone;

    var _objects = [
        obj_abanico_izquierda,
        obj_abanico_derecha,
        obj_abanico_arriba,
        obj_abanico_abajo
    ];

    for (var _oi = 0; _oi < array_length(_objects); _oi++)
    {
        var _obj = _objects[_oi];
        var _count = instance_number(_obj);

        for (var _i = 0; _i < _count; _i++)
        {
            var _fan = instance_find(_obj, _i);

            if (_fan == noone || !instance_exists(_fan))
                continue;

            if (
                variable_instance_exists(_fan, "fan_enabled")
                &&
                !_fan.fan_enabled
            )
            {
                continue;
            }

            if (scr_fan_actor_in_wind(_fan, _actor))
                return _fan;
        }
    }

    return noone;
}


function scr_fan_silicio_find_wind(_sil)
{
    return scr_fan_find_wind_for_actor(_sil);
}


function scr_fan_silicio_in_any_wind(_sil)
{
    return scr_fan_find_wind_for_actor(_sil) != noone;
}


// =========================================================
// BLOQUEOS DEL MUNDO
// =========================================================

function scr_fan_world_free()
{
    if (room == bbs || room == game_over)
        return false;

    if (
        variable_global_exists("gameover_death_freeze_active")
        &&
        global.gameover_death_freeze_active
    )
    {
        return false;
    }

    if (
        variable_global_exists("cutscene_active")
        &&
        global.cutscene_active
    )
    {
        return false;
    }

    if (
        instance_exists(obj_pauser)
        ||
        instance_exists(obj_save_menu)
        ||
        instance_exists(obj_textbox)
        ||
        instance_exists(obj_transicion_bbs)
    )
    {
        return false;
    }

    if (
        instance_exists(obj_menu_manager)
        &&
        obj_menu_manager.state != MENU_STATE.CLOSED
    )
    {
        return false;
    }

    return true;
}


// =========================================================
// =========================================================
// SILICIO RPG - ESTADO TIPO obj_deslizamiento_abajo
// =========================================================
// =========================================================

function scr_fan_rpg_silicio_prepare(_sil)
{
    if (_sil == noone || !instance_exists(_sil))
        return false;

    if (!variable_instance_exists(_sil, "fan_rpg_mode"))
        _sil.fan_rpg_mode = "none";

    if (!variable_instance_exists(_sil, "fan_rpg_room"))
        _sil.fan_rpg_room = room;

    if (!variable_instance_exists(_sil, "fan_rpg_ref"))
        _sil.fan_rpg_ref = noone;

    if (!variable_instance_exists(_sil, "fan_rpg_dir_x"))
        _sil.fan_rpg_dir_x = 0;

    if (!variable_instance_exists(_sil, "fan_rpg_dir_y"))
        _sil.fan_rpg_dir_y = 0;

    if (!variable_instance_exists(_sil, "fan_rpg_force"))
        _sil.fan_rpg_force = 0;

    if (!variable_instance_exists(_sil, "fan_rpg_accum"))
        _sil.fan_rpg_accum = 0;

    if (!variable_instance_exists(_sil, "fan_rpg_exit_remaining"))
        _sil.fan_rpg_exit_remaining = 0;

    if (!variable_instance_exists(_sil, "fan_rpg_gap_accum"))
        _sil.fan_rpg_gap_accum = 0;

    if (!variable_instance_exists(_sil, "fan_rpg_gap_required"))
        _sil.fan_rpg_gap_required = 20;

    if (!variable_instance_exists(_sil, "fan_rpg_last_player_x"))
        _sil.fan_rpg_last_player_x = 0;

    if (!variable_instance_exists(_sil, "fan_rpg_last_player_y"))
        _sil.fan_rpg_last_player_y = 0;

    if (!variable_instance_exists(_sil, "fan_rpg_rejoin_speed"))
        _sil.fan_rpg_rejoin_speed = 0;

    if (!variable_instance_exists(_sil, "fan_rpg_post_timer"))
        _sil.fan_rpg_post_timer = 0;

    // Offset físico acumulado por el viento respecto a la
    // posición NORMAL que scr_party_update() calcula para Silicio.
    //
    // Mientras wind_follow está activo:
    //
    //     posición final = follower normal + offset del viento
    //
    // Así Silicio puede seguir a Maya Y ser empujado a la vez.
    if (!variable_instance_exists(_sil, "fan_rpg_offset_x"))
        _sil.fan_rpg_offset_x = 0;

    if (!variable_instance_exists(_sil, "fan_rpg_offset_y"))
        _sil.fan_rpg_offset_y = 0;

    if (!variable_instance_exists(_sil, "fan_rpg_base_x"))
        _sil.fan_rpg_base_x = _sil.x;

    if (!variable_instance_exists(_sil, "fan_rpg_base_y"))
        _sil.fan_rpg_base_y = _sil.y;

    if (!variable_instance_exists(_sil, "fan_rpg_base_ready"))
        _sil.fan_rpg_base_ready = false;

    if (!variable_instance_exists(_sil, "fan_rpg_rebase_pending"))
        _sil.fan_rpg_rebase_pending = false;

    if (!variable_instance_exists(_sil, "fan_rpg_hold_x"))
        _sil.fan_rpg_hold_x = _sil.x;

    if (!variable_instance_exists(_sil, "fan_rpg_hold_y"))
        _sil.fan_rpg_hold_y = _sil.y;

    if (!variable_instance_exists(_sil, "fan_detached"))
        _sil.fan_detached = false;

    if (!variable_instance_exists(_sil, "fan_rejoin_active"))
        _sil.fan_rejoin_active = false;

    if (!variable_instance_exists(_sil, "fan_rejoin_walk_armed"))
        _sil.fan_rejoin_walk_armed = false;

    if (_sil.fan_rpg_room != room)
    {
        _sil.fan_rpg_room = room;
        _sil.fan_rpg_mode = "none";
        _sil.fan_rpg_ref = noone;
        _sil.fan_rpg_accum = 0;
        _sil.fan_rpg_exit_remaining = 0;
        _sil.fan_rpg_gap_accum = 0;
        _sil.fan_rpg_rejoin_speed = 0;
        _sil.fan_rpg_post_timer = 0;
        _sil.fan_rpg_offset_x = 0;
        _sil.fan_rpg_offset_y = 0;
        _sil.fan_rpg_base_x = _sil.x;
        _sil.fan_rpg_base_y = _sil.y;
        _sil.fan_rpg_base_ready = false;
        _sil.fan_rpg_rebase_pending = false;
        _sil.fan_rpg_hold_x = _sil.x;
        _sil.fan_rpg_hold_y = _sil.y;
        _sil.fan_detached = false;
        _sil.fan_rejoin_active = false;
        _sil.fan_rejoin_walk_armed = false;
    }

    return true;
}


function scr_fan_rpg_silicio_is_special(_sil)
{
    if (!scr_fan_rpg_silicio_prepare(_sil))
        return false;

    return _sil.fan_rpg_mode != "none";
}


function scr_fan_rpg_silicio_freeze(_sil)
{
    if (_sil == noone || !instance_exists(_sil))
        return;

    // Fuera de WIND_FOLLOW (exit / wait):
    // Silicio sí debe quedar completamente quieto.
    //
    // No cambiamos sprite_index.
    // Solo dejamos el sprite actual en su frame 0.
    _sil.movimiento = false;
    _sil.image_index = 0;
    _sil.image_speed = 0;

    if (variable_instance_exists(_sil, "party_anim_accum"))
        _sil.party_anim_accum = 0;

    if (variable_instance_exists(_sil, "party_anim_hold"))
        _sil.party_anim_hold = 0;

    if (variable_instance_exists(_sil, "party_anim_was_moving"))
        _sil.party_anim_was_moving = false;
}


// =========================================================
// SILICIO RPG - ANIMACIÓN DENTRO DEL AIRE SEGÚN MAYA
// =========================================================
//
// Mientras Silicio SIGUE dentro del rango del ventilador:
//
//     Maya con movimiento
//         -> Silicio conserva su sprite actual
//         -> reproduce su animación normal de caminar.
//
//     Maya quieta
//         -> Silicio conserva su sprite actual
//         -> frame 0
//         -> sin animación.
//
// El VIENTO nunca decide si anima.
// Lo decide únicamente el estado de movimiento de Maya.
// =========================================================

function scr_fan_rpg_silicio_air_animation(_sil, _p)
{
    if (_sil == noone || !instance_exists(_sil))
        return false;


    var _maya_moving =
        (
            _p != noone
            &&
            instance_exists(_p)
            &&
            variable_instance_exists(
                _p,
                "movimiento"
            )
            &&
            _p.movimiento
        );


    if (_maya_moving)
    {
        // No cambiamos sprite_index ni dirección.
        //
        // Usamos exactamente el mismo sistema de animación que
        // ya utiliza el follower RPG normal de Silicio.
        _sil.movimiento =
            true;


        scr_party_apply_walk_animation(
            _sil,
            true
        );


        return true;
    }


    // Maya no tiene movimiento:
    // Silicio queda en frame 0 del sprite que YA tenga.
    _sil.movimiento =
        false;


    scr_party_apply_walk_animation(
        _sil,
        false
    );


    _sil.image_index =
        0;


    _sil.image_speed =
        0;


    if (
        variable_instance_exists(
            _sil,
            "party_anim_accum"
        )
    )
    {
        _sil.party_anim_accum =
            0;
    }


    if (
        variable_instance_exists(
            _sil,
            "party_anim_hold"
        )
    )
    {
        _sil.party_anim_hold =
            0;
    }


    if (
        variable_instance_exists(
            _sil,
            "party_anim_was_moving"
        )
    )
    {
        _sil.party_anim_was_moving =
            false;
    }


    return false;
}


function scr_fan_rpg_release(_sil)
{
    if (_sil == noone || !instance_exists(_sil))
        return;

    _sil.fan_rpg_mode = "none";
    _sil.fan_rpg_ref = noone;
    _sil.fan_rpg_accum = 0;
    _sil.fan_rpg_exit_remaining = 0;
    _sil.fan_rpg_gap_accum = 0;
    _sil.fan_rpg_rejoin_speed = 0;
    _sil.fan_rpg_post_timer = 0;
    _sil.fan_rpg_offset_x = 0;
    _sil.fan_rpg_offset_y = 0;
    _sil.fan_rpg_base_ready = false;
    _sil.fan_rpg_rebase_pending = false;

    _sil.fan_detached = false;
    _sil.fan_rejoin_active = false;
    _sil.fan_rejoin_walk_armed = false;

    _sil.party_follow_suspended = false;
}


function scr_fan_rpg_begin(_sil, _fan, _p)
{
    if (
        !scr_fan_rpg_silicio_prepare(_sil)
        ||
        _fan == noone
        ||
        !instance_exists(_fan)
    )
    {
        return false;
    }

    scr_fan_update_zone(_fan);

    _sil.fan_rpg_mode = "wind_follow";
    _sil.fan_rpg_room = room;
    _sil.fan_rpg_ref = _fan;
    _sil.fan_rpg_dir_x = _fan.fan_direction_x;
    _sil.fan_rpg_dir_y = _fan.fan_direction_y;
    _sil.fan_rpg_force = max(0, abs(_fan.fan_force));
    _sil.fan_rpg_accum = 0;
    _sil.fan_rpg_exit_remaining = 0;
    _sil.fan_rpg_gap_accum = 0;
    _sil.fan_rpg_rejoin_speed = 0;
    _sil.fan_rpg_post_timer = 0;

    // Guardar la posición física exacta donde el viento tomó
    // contacto. En el próximo follower normal calcularemos qué
    // offset corresponde para mantener a Silicio en este punto.
    _sil.fan_rpg_hold_x = _sil.x;
    _sil.fan_rpg_hold_y = _sil.y;
    _sil.fan_rpg_rebase_pending = true;
    _sil.fan_rpg_base_ready = false;

    _sil.fan_detached = true;
    _sil.fan_rejoin_active = false;
    _sil.fan_rejoin_walk_armed = false;

    // CLAVE:
    // dentro del aire Silicio TODAVÍA SIGUE A MAYA.
    // El viento se suma encima de ese movimiento.
    _sil.party_follow_suspended = false;

    // Si estaba en un terreno especial del follower RPG,
    // el viento pasa a ser el efecto físico dominante.
    if (variable_instance_exists(_sil, "party_special_mode"))
    {
        if (
            _sil.party_special_mode == "downslide_follow"
            ||
            _sil.party_special_mode == "downslide_exit"
            ||
            _sil.party_special_mode == "downslide_wait_gap"
            ||
            _sil.party_special_mode == "downslide_rejoin"
            ||
            _sil.party_special_mode == "ice_hold"
            ||
            _sil.party_special_mode == "ice_recover"
        )
        {
            if (
                _sil.party_special_mode == "downslide_follow"
                ||
                _sil.party_special_mode == "downslide_exit"
            )
            {
                scr_party_downslide_sound_stop(_sil);
            }

            _sil.party_special_mode = "none";
        }
    }

    // No cambiamos sprite_index.
    //
    // Si Maya está caminando, Silicio empieza el efecto
    // conservando también su animación de movimiento.
    // Si Maya está quieta, queda inmediatamente en frame 0.
    scr_fan_rpg_silicio_air_animation(
        _sil,
        _p
    );

    return true;
}


function scr_fan_rpg_move(_sil, _dir_x, _dir_y, _steps)
{
    var _moved = 0;
    _steps = max(0, round(_steps));

    for (var _i = 0; _i < _steps; _i++)
    {
        var _next_x = _sil.x + _dir_x;
        var _next_y = _sil.y + _dir_y;

        if (
            scr_fan_actor_blocked(
                _sil,
                _next_x,
                _next_y,
                _dir_x,
                _dir_y
            )
        )
        {
            break;
        }

        _sil.x = _next_x;
        _sil.y = _next_y;
        _moved++;
    }

    return _moved;
}


function scr_fan_rpg_apply_follow_offset(_sil)
{
    if (
        _sil == noone
        ||
        !instance_exists(_sil)
        ||
        !_sil.fan_rpg_base_ready
    )
    {
        return false;
    }

    var _base_x = _sil.fan_rpg_base_x;
    var _base_y = _sil.fan_rpg_base_y;

    // Recolocar primero exactamente en la posición normal del
    // follower que scr_party_update() calculó ESTE frame.
    _sil.x = _base_x;
    _sil.y = _base_y;

    // Después reaplicar el desplazamiento acumulado del viento.
    var _want_x = round(_sil.fan_rpg_offset_x);
    var _want_y = round(_sil.fan_rpg_offset_y);

    if (_want_x != 0)
    {
        scr_fan_rpg_move(
            _sil,
            sign(_want_x),
            0,
            abs(_want_x)
        );
    }

    if (_want_y != 0)
    {
        scr_fan_rpg_move(
            _sil,
            0,
            sign(_want_y),
            abs(_want_y)
        );
    }

    // Si una pared limitó el offset, guardar el desplazamiento
    // físico REAL que sí pudo conservar.
    _sil.fan_rpg_offset_x =
        _sil.x
        -
        _base_x;

    _sil.fan_rpg_offset_y =
        _sil.y
        -
        _base_y;

    return true;
}


function scr_fan_rpg_enter_wait(_sil, _p)
{
    _sil.fan_rpg_mode = "wind_wait_gap";
    _sil.fan_rpg_ref = noone;
    _sil.fan_rpg_accum = 0;
    _sil.fan_rpg_exit_remaining = 0;
    _sil.fan_rpg_gap_accum = 0;
    _sil.fan_rpg_rejoin_speed = 0;
    _sil.fan_rpg_post_timer = 0;

    _sil.fan_rejoin_active = false;
    _sil.fan_rejoin_walk_armed = false;

    var _required = 20;

    if (variable_global_exists("party_follow_delay_walk"))
        _required = max(_required, global.party_follow_delay_walk * 4);

    _required = max(_required, scr_party_history_gap_for_delay(0));

    _sil.fan_rpg_gap_required = _required;

    if (_p != noone && instance_exists(_p))
    {
        _sil.fan_rpg_last_player_x = scr_party_feet_x(_p);
        _sil.fan_rpg_last_player_y = scr_party_feet_y(_p);
    }

    scr_fan_rpg_silicio_freeze(_sil);
}


function scr_fan_rpg_special_update(_sil, _p)
{
    if (!scr_fan_rpg_silicio_prepare(_sil))
        return false;

    if (_sil.fan_rpg_mode == "none")
        return false;

    _sil.fan_detached = true;

    // Dentro de wind_follow el follower sigue ACTIVO.
    // En exit/wait/rejoin sí queda suspendido.
    _sil.party_follow_suspended =
        (_sil.fan_rpg_mode != "wind_follow");

    if (!scr_fan_world_free())
    {
        scr_fan_rpg_silicio_freeze(_sil);
        return true;
    }

    // -----------------------------------------------------
    // WIND_FOLLOW
    // -----------------------------------------------------
    //
    // El follower YA calculó su posición normal este frame.
    // Reaplicamos el offset acumulado del viento encima y luego
    // añadimos la fuerza nueva del ventilador.
    // -----------------------------------------------------

    if (_sil.fan_rpg_mode == "wind_follow")
    {
        _sil.party_follow_suspended = false;

        // Cuando venimos de una captura/reentrada, el primer
        // follower posterior nos da la base respecto a la cual
        // preservar la posición física anterior.
        if (
            _sil.fan_rpg_base_ready
            &&
            _sil.fan_rpg_rebase_pending
        )
        {
            _sil.fan_rpg_offset_x =
                _sil.fan_rpg_hold_x
                -
                _sil.fan_rpg_base_x;

            _sil.fan_rpg_offset_y =
                _sil.fan_rpg_hold_y
                -
                _sil.fan_rpg_base_y;

            _sil.fan_rpg_rebase_pending = false;
        }

        // Si este frame sí pasó por scr_party_update(), restaurar
        // el offset que el viento había acumulado anteriormente.
        if (_sil.fan_rpg_base_ready)
        {
            scr_fan_rpg_apply_follow_offset(_sil);
        }

        var _fan = _sil.fan_rpg_ref;

        var _valid_fan =
            _fan != noone
            &&
            instance_exists(_fan)
            &&
            (!variable_instance_exists(_fan, "fan_enabled") || _fan.fan_enabled);

        if (_valid_fan)
        {
            scr_fan_update_zone(_fan);
        }

        var _inside_saved =
            _valid_fan
            &&
            scr_fan_actor_in_wind(_fan, _sil);

        if (!_inside_saved)
        {
            var _other = scr_fan_find_wind_for_actor(_sil);

            if (_other != noone)
            {
                _fan = _other;
                _sil.fan_rpg_ref = _fan;
                _sil.fan_rpg_dir_x = _fan.fan_direction_x;
                _sil.fan_rpg_dir_y = _fan.fan_direction_y;
                _sil.fan_rpg_force = max(0, abs(_fan.fan_force));
                _sil.fan_rpg_accum = 0;
                _inside_saved = true;
            }
        }

        if (!_inside_saved)
        {
            // Ya salió completamente del aire.
            // Desde AQUÍ deja de seguir a Maya y termina la
            // expulsión exterior.
            if (!_valid_fan)
            {
                scr_fan_rpg_enter_wait(_sil, _p);
                _sil.party_follow_suspended = true;
                _sil.fan_rpg_base_ready = false;
                return true;
            }

            _sil.fan_rpg_mode = "wind_exit";
            _sil.party_follow_suspended = true;
            _sil.fan_rpg_accum = 0;
            _sil.fan_rpg_base_ready = false;
            _sil.fan_rpg_exit_remaining =
                variable_instance_exists(_fan, "fan_silicio_eject_extra")
                ?
                max(0, round(_fan.fan_silicio_eject_extra))
                :
                12;
        }
        else
        {
            // =================================================
            // FUERZA DE VIENTO SIN DUPLICAR
            // =================================================
            //
            // Mientras Maya y Silicio están dentro DEL MISMO
            // ventilador, scr_party_update() ya hace que Silicio
            // reproduzca la ruta física que Maya dejó detrás.
            //
            // Esa ruta YA contiene el empuje del aire aplicado a
            // Maya. Si aquí sumáramos fan_force otra vez, Silicio
            // recibiría aproximadamente:
            //
            //     viento de Maya por follower
            //     +
            //     viento propio
            //
            // y se sentiría más fuerte que en Maya.
            //
            // Por eso:
            //
            //     Maya dentro del mismo fan
            //         -> solo follower (sin viento duplicado)
            //
            //     Maya fuera de ese fan
            //         -> Silicio recibe SU fan_force completo
            //
            // De esta forma Silicio sigue a Maya dentro del aire,
            // pero si Maya ya salió/se detuvo fuera, el ventilador
            // puede terminar de expulsar a Silicio por sí mismo.
            // =================================================

            var _maya_in_same_fan =
                (
                    _p != noone
                    &&
                    instance_exists(_p)
                    &&
                    scr_fan_actor_in_wind(
                        _fan,
                        _p
                    )
                );


            var _silicio_direct_force =
                (
                    _maya_in_same_fan
                    ?
                    0
                    :
                    _sil.fan_rpg_force
                );


            if (_silicio_direct_force > 0)
            {
                _sil.fan_rpg_accum +=
                    _silicio_direct_force;
            }
            else
            {
                // No guardar residuo para que al salir Maya del
                // ventilador Silicio empiece exactamente con la
                // fuerza normal y no con un sobrante anterior.
                _sil.fan_rpg_accum =
                    0;
            }


            var _steps =
                floor(
                    _sil.fan_rpg_accum
                );


            _sil.fan_rpg_accum -=
                _steps;


            for (var _i = 0; _i < _steps; _i++)
            {
                var _moved = scr_fan_rpg_move(
                    _sil,
                    _sil.fan_rpg_dir_x,
                    _sil.fan_rpg_dir_y,
                    1
                );

                if (_moved <= 0)
                {
                    _sil.fan_rpg_accum = 0;
                    break;
                }

                // El offset se mide respecto a la posición normal
                // del follower de ESTE frame.
                if (_sil.fan_rpg_base_ready)
                {
                    _sil.fan_rpg_offset_x =
                        _sil.x
                        -
                        _sil.fan_rpg_base_x;

                    _sil.fan_rpg_offset_y =
                        _sil.y
                        -
                        _sil.fan_rpg_base_y;
                }
                else
                {
                    // Reentrada sin follower en este mismo frame:
                    // conservar la nueva posición para rebasear
                    // correctamente el próximo frame.
                    _sil.fan_rpg_hold_x = _sil.x;
                    _sil.fan_rpg_hold_y = _sil.y;
                    _sil.fan_rpg_rebase_pending = true;
                }

                if (!scr_fan_actor_in_wind(_fan, _sil))
                {
                    _sil.fan_rpg_mode = "wind_exit";
                    _sil.party_follow_suspended = true;
                    _sil.fan_rpg_accum = 0;
                    _sil.fan_rpg_base_ready = false;
                    _sil.fan_rpg_exit_remaining =
                        variable_instance_exists(_fan, "fan_silicio_eject_extra")
                        ?
                        max(0, round(_fan.fan_silicio_eject_extra))
                        :
                        12;
                    break;
                }
            }
        }

        // El follower puede haber elegido sprite/dirección según
        // su movimiento normal.
        //
        // Mientras SIGA dentro del aire:
        //
        //     Maya avanzando -> Silicio anima.
        //     Maya quieta     -> Silicio frame 0.
        //
        // El viento no cambia el sprite actual.
        scr_fan_rpg_silicio_air_animation(
            _sil,
            _p
        );

        // La base solo pertenece al follower de este frame.
        _sil.fan_rpg_base_ready = false;

        if (_sil.fan_rpg_mode == "wind_follow")
            return true;
    }

    // -----------------------------------------------------
    // WIND_EXIT
    // -----------------------------------------------------

    if (_sil.fan_rpg_mode == "wind_exit")
    {
        _sil.party_follow_suspended = true;

        var _new_fan = scr_fan_find_wind_for_actor(_sil);

        if (_new_fan != noone)
        {
            scr_fan_rpg_begin(_sil, _new_fan, _p);

            // Esta reentrada ocurre sin un follower nuevo en este
            // mismo frame. El begin guarda hold_x/hold_y y el
            // próximo frame reconstruirá el offset.
            return scr_fan_rpg_special_update(_sil, _p);
        }

        if (_sil.fan_rpg_exit_remaining > 0)
        {
            var _exit_step = min(6, _sil.fan_rpg_exit_remaining);
            var _exit_moved = scr_fan_rpg_move(
                _sil,
                _sil.fan_rpg_dir_x,
                _sil.fan_rpg_dir_y,
                _exit_step
            );

            _sil.fan_rpg_exit_remaining -= _exit_moved;

            if (_exit_moved < _exit_step)
                _sil.fan_rpg_exit_remaining = 0;
        }

        if (_sil.fan_rpg_exit_remaining <= 0)
        {
            scr_fan_rpg_enter_wait(_sil, _p);
        }

        scr_fan_rpg_silicio_freeze(_sil);
        return true;
    }

    // -----------------------------------------------------
    // WIND_WAIT_GAP
    // -----------------------------------------------------

    if (_sil.fan_rpg_mode == "wind_wait_gap")
    {
        _sil.party_follow_suspended = true;

        var _wait_fan = scr_fan_find_wind_for_actor(_sil);

        if (_wait_fan != noone)
        {
            scr_fan_rpg_begin(_sil, _wait_fan, _p);
            return scr_fan_rpg_special_update(_sil, _p);
        }

        if (_p != noone && instance_exists(_p))
        {
            var _px = scr_party_feet_x(_p);
            var _py = scr_party_feet_y(_p);

            var _step_distance = point_distance(
                _sil.fan_rpg_last_player_x,
                _sil.fan_rpg_last_player_y,
                _px,
                _py
            );

            if (_step_distance <= 24)
                _sil.fan_rpg_gap_accum += max(0, _step_distance);

            _sil.fan_rpg_last_player_x = _px;
            _sil.fan_rpg_last_player_y = _py;
        }

        scr_fan_rpg_silicio_freeze(_sil);

        if (_sil.fan_rpg_gap_accum >= _sil.fan_rpg_gap_required)
        {
            _sil.fan_rpg_mode = "wind_rejoin";
            _sil.fan_rpg_post_timer = 1;
            _sil.fan_rpg_rejoin_speed = 0;
            _sil.fan_rejoin_active = true;
        }

        return true;
    }

    // -----------------------------------------------------
    // WIND_REJOIN
    // -----------------------------------------------------

    if (_sil.fan_rpg_mode == "wind_rejoin")
    {
        _sil.party_follow_suspended = true;
        _sil.fan_rejoin_active = true;

        var _rejoin_fan = scr_fan_find_wind_for_actor(_sil);

        if (_rejoin_fan != noone)
        {
            scr_fan_rpg_begin(_sil, _rejoin_fan, _p);
            return scr_fan_rpg_special_update(_sil, _p);
        }

        if (_sil.fan_rpg_post_timer > 0)
        {
            _sil.fan_rpg_post_timer--;
            scr_fan_rpg_silicio_freeze(_sil);
            return true;
        }

        var _target = scr_party_get_delayed_position(0);
        var _cx = scr_party_feet_x(_sil);
        var _cy = scr_party_feet_y(_sil);
        var _dx = _target.x - _cx;
        var _dy = _target.y - _cy;
        var _distance = point_distance(_cx, _cy, _target.x, _target.y);

        var _start_speed =
            variable_global_exists("party_downslide_rejoin_start_speed")
            ? global.party_downslide_rejoin_start_speed
            : 2.0;

        var _max_speed =
            variable_global_exists("party_downslide_rejoin_speed")
            ? global.party_downslide_rejoin_speed
            : 7.0;

        var _accel =
            variable_global_exists("party_downslide_rejoin_accel")
            ? global.party_downslide_rejoin_accel
            : 0.5;

        if (_sil.fan_rpg_rejoin_speed <= 0)
            _sil.fan_rpg_rejoin_speed = _start_speed;
        else
            _sil.fan_rpg_rejoin_speed = min(
                _max_speed,
                _sil.fan_rpg_rejoin_speed + _accel
            );

        var _face = _target.face;

        if (abs(_dx) > abs(_dy))
        {
            if (_dx > 0) _face = RIGHT;
            else if (_dx < 0) _face = LEFT;
        }
        else
        {
            if (_dy > 0) _face = DOWN;
            else if (_dy < 0) _face = UP;
        }

        if (_distance <= 0.25)
        {
            scr_party_apply_direction(_sil, _face);
            scr_party_apply_walk_animation(_sil, false);
            _sil.movimiento = false;
            scr_fan_rpg_release(_sil);
            return true;
        }

        var _step = min(_sil.fan_rpg_rejoin_speed, _distance);
        var _angle = point_direction(_cx, _cy, _target.x, _target.y);
        var _nx = _cx + lengthdir_x(_step, _angle);
        var _ny = _cy + lengthdir_y(_step, _angle);

        scr_party_apply_direction(_sil, _face);
        scr_party_place_feet(_sil, _nx, _ny);

        _sil.movimiento = true;
        scr_party_apply_walk_animation(_sil, true);

        return true;
    }

    return true;
}


// =========================================================
// RPG - INTERCEPTAR EL PRIMER PÍXEL QUE TOCA LA CORRIENTE
// =========================================================

function scr_fan_rpg_capture_crossing(_sil, _p, _old_x, _old_y, _new_x, _new_y)
{
    if (_sil == noone || !instance_exists(_sil))
        return false;

    var _dx = round(_new_x - _old_x);
    var _dy = round(_new_y - _old_y);

    // Esta es la posición NORMAL que el follower quería alcanzar
    // antes de que el viento se sumara.
    _sil.fan_rpg_base_x = _new_x;
    _sil.fan_rpg_base_y = _new_y;
    _sil.fan_rpg_base_ready = true;

    if (abs(_dx) > 32 || abs(_dy) > 32)
    {
        _sil.x = _new_x;
        _sil.y = _new_y;

        var _direct_big = scr_fan_find_wind_for_actor(_sil);

        if (_direct_big != noone)
        {
            scr_fan_rpg_begin(_sil, _direct_big, _p);

            _sil.fan_rpg_base_x = _new_x;
            _sil.fan_rpg_base_y = _new_y;
            _sil.fan_rpg_base_ready = true;
            _sil.fan_rpg_offset_x = 0;
            _sil.fan_rpg_offset_y = 0;
            _sil.fan_rpg_rebase_pending = false;

            return true;
        }

        _sil.fan_rpg_base_ready = false;
        return false;
    }

    _sil.x = _old_x;
    _sil.y = _old_y;

    var _direct = scr_fan_find_wind_for_actor(_sil);

    if (_direct != noone)
    {
        scr_fan_rpg_begin(_sil, _direct, _p);

        _sil.fan_rpg_base_x = _new_x;
        _sil.fan_rpg_base_y = _new_y;
        _sil.fan_rpg_base_ready = true;
        _sil.fan_rpg_offset_x = _sil.x - _new_x;
        _sil.fan_rpg_offset_y = _sil.y - _new_y;
        _sil.fan_rpg_rebase_pending = false;

        return true;
    }

    if (_dx != 0)
    {
        var _sx = sign(_dx);

        for (var _ix = 0; _ix < abs(_dx); _ix++)
        {
            _sil.x += _sx;

            var _wind_x = scr_fan_find_wind_for_actor(_sil);

            if (_wind_x != noone)
            {
                scr_fan_rpg_begin(_sil, _wind_x, _p);

                _sil.fan_rpg_base_x = _new_x;
                _sil.fan_rpg_base_y = _new_y;
                _sil.fan_rpg_base_ready = true;
                _sil.fan_rpg_offset_x = _sil.x - _new_x;
                _sil.fan_rpg_offset_y = _sil.y - _new_y;
                _sil.fan_rpg_rebase_pending = false;

                return true;
            }
        }
    }

    if (_dy != 0)
    {
        var _sy = sign(_dy);

        for (var _iy = 0; _iy < abs(_dy); _iy++)
        {
            _sil.y += _sy;

            var _wind_y = scr_fan_find_wind_for_actor(_sil);

            if (_wind_y != noone)
            {
                scr_fan_rpg_begin(_sil, _wind_y, _p);

                _sil.fan_rpg_base_x = _new_x;
                _sil.fan_rpg_base_y = _new_y;
                _sil.fan_rpg_base_ready = true;
                _sil.fan_rpg_offset_x = _sil.x - _new_x;
                _sil.fan_rpg_offset_y = _sil.y - _new_y;
                _sil.fan_rpg_rebase_pending = false;

                return true;
            }
        }
    }

    _sil.x = _new_x;
    _sil.y = _new_y;
    _sil.fan_rpg_base_ready = false;

    return false;
}


// =========================================================
// RPG - ANTES / DESPUÉS DE scr_party_update()
// =========================================================

function scr_fan_rpg_before_party_update(_sil)
{
    if (!scr_fan_rpg_silicio_prepare(_sil))
        return false;

    if (_sil.fan_rpg_mode == "wind_follow")
    {
        // Dentro del aire el follower SIGUE funcionando.
        _sil.fan_detached = true;
        _sil.party_follow_suspended = false;
        return false;
    }

    if (_sil.fan_rpg_mode != "none")
    {
        // Ya fuera del aire: exit / wait / rejoin sí tienen
        // control independiente sobre Silicio.
        _sil.fan_detached = true;
        _sil.party_follow_suspended = true;
        return true;
    }

    _sil.party_follow_suspended = false;
    return false;
}


function scr_fan_rpg_after_party_update(_sil, _p, _old_x, _old_y)
{
    if (!scr_fan_rpg_silicio_prepare(_sil))
        return false;

    // WIND_FOLLOW:
    // scr_party_update() acaba de colocar a Silicio en su posición
    // NORMAL de follower. Guardarla como base y sumar encima el
    // offset físico del viento.
    if (_sil.fan_rpg_mode == "wind_follow")
    {
        _sil.fan_rpg_base_x = _sil.x;
        _sil.fan_rpg_base_y = _sil.y;
        _sil.fan_rpg_base_ready = true;

        return scr_fan_rpg_special_update(_sil, _p);
    }

    if (_sil.fan_rpg_mode != "none")
        return scr_fan_rpg_special_update(_sil, _p);

    if (!scr_fan_world_free())
        return false;

    var _new_x = _sil.x;
    var _new_y = _sil.y;

    var _captured = scr_fan_rpg_capture_crossing(
        _sil,
        _p,
        _old_x,
        _old_y,
        _new_x,
        _new_y
    );

    if (_captured)
        return scr_fan_rpg_special_update(_sil, _p);

    return false;
}


// =========================================================
// =========================================================
// SILICIO PLATAFORMERO
// =========================================================
// =========================================================

function scr_fan_platformer_silicio_prepare(_sil)
{
    if (_sil == noone || !instance_exists(_sil))
        return false;

    with (_sil)
    {
        scr_platformer_silicio_prepare();
    }

    if (!variable_instance_exists(_sil, "platform_fan_mode"))
        _sil.platform_fan_mode = "none";

    if (!variable_instance_exists(_sil, "platform_fan_room"))
        _sil.platform_fan_room = room;

    if (!variable_instance_exists(_sil, "platform_fan_ref"))
        _sil.platform_fan_ref = noone;

    if (!variable_instance_exists(_sil, "platform_fan_dir_x"))
        _sil.platform_fan_dir_x = 0;

    if (!variable_instance_exists(_sil, "platform_fan_dir_y"))
        _sil.platform_fan_dir_y = 0;

    if (!variable_instance_exists(_sil, "platform_fan_force"))
        _sil.platform_fan_force = 0;

    if (!variable_instance_exists(_sil, "platform_fan_accum"))
        _sil.platform_fan_accum = 0;

    if (!variable_instance_exists(_sil, "platform_fan_exit_remaining"))
        _sil.platform_fan_exit_remaining = 0;

    if (!variable_instance_exists(_sil, "platform_fan_wait_distance"))
        _sil.platform_fan_wait_distance = 0;

    if (!variable_instance_exists(_sil, "platform_fan_last_player_x"))
        _sil.platform_fan_last_player_x = 0;

    if (!variable_instance_exists(_sil, "platform_fan_last_player_y"))
        _sil.platform_fan_last_player_y = 0;

    if (!variable_instance_exists(_sil, "fan_detached"))
        _sil.fan_detached = false;

    if (!variable_instance_exists(_sil, "fan_rejoin_active"))
        _sil.fan_rejoin_active = false;

    if (_sil.platform_fan_room != room)
    {
        _sil.platform_fan_room = room;
        _sil.platform_fan_mode = "none";
        _sil.platform_fan_ref = noone;
        _sil.platform_fan_accum = 0;
        _sil.platform_fan_exit_remaining = 0;
        _sil.platform_fan_wait_distance = 0;
        _sil.fan_detached = false;
        _sil.fan_rejoin_active = false;
    }

    return true;
}


function scr_fan_platformer_freeze(_sil, _p)
{
    _sil.platform_sil_move_x = 0;
    _sil.platform_sil_move_y = 0;
    _sil.platform_sil_vsp = 0;
    _sil.platform_sil_x_rem = 0;
    _sil.platform_sil_y_rem = 0;
    _sil.movimiento = false;

    _sil.platform_sil_grounded = scr_platformer_floor_at(
        _sil.x,
        _sil.y + 1,
        _sil.platform_sil_hit_left,
        _sil.platform_sil_hit_top,
        _sil.platform_sil_hit_right,
        _sil.platform_sil_hit_bottom
    );

    var _face =
        variable_instance_exists(_sil, "platform_sil_facing")
        ? _sil.platform_sil_facing
        : 1;

    scr_platformer_silicio_apply_extended_sprite(
        _sil,
        _sil.platform_sil_grounded ? "idle" : "jump",
        _face
    );

    // Mantener el sprite que ya corresponda, pero siempre
    // congelado en su primer frame mientras el viento lo controle.
    _sil.image_index = 0;
    _sil.image_speed = 0;

    _sil.platform_sil_prev_x = _sil.x;
    _sil.platform_sil_prev_y = _sil.y;
}


function scr_fan_platformer_seed_wait(_p)
{
    scr_platformer_party_ext_init();

    var _snap = scr_platformer_party_snapshot(_p);

    global.platform_party_history = [];
    global.platform_party_room = room;
    global.platform_party_was_active = true;
    global.platform_party_last_player_feet_x = _snap.x;
    global.platform_party_last_player_feet_y = _snap.y;

    for (var _i = 0; _i < global.platform_party_delay_frames; _i++)
    {
        array_push(
            global.platform_party_history,
            {
                dx: 0,
                dy: 0,
                facing: _snap.facing,
                grounded: true,
                state: "idle"
            }
        );
    }
}


function scr_fan_platformer_sync_player(_p)
{
    scr_platformer_party_ext_init();

    var _snap = scr_platformer_party_snapshot(_p);
    global.platform_party_last_player_feet_x = _snap.x;
    global.platform_party_last_player_feet_y = _snap.y;
}


function scr_fan_platformer_begin(_sil, _fan, _p)
{
    if (!scr_fan_platformer_silicio_prepare(_sil))
        return false;

    _sil.platform_fan_mode = "wind_follow";
    _sil.platform_fan_room = room;
    _sil.platform_fan_ref = _fan;
    _sil.platform_fan_dir_x = _fan.fan_direction_x;
    _sil.platform_fan_dir_y = _fan.fan_direction_y;
    _sil.platform_fan_force = max(0, abs(_fan.fan_force));
    _sil.platform_fan_accum = 0;
    _sil.platform_fan_exit_remaining = 0;
    _sil.platform_fan_wait_distance = 0;

    _sil.fan_detached = true;
    _sil.fan_rejoin_active = false;
    _sil.party_follow_suspended = true;

    scr_fan_platformer_freeze(_sil, _p);
    return true;
}


function scr_fan_platformer_move(_sil, _dx, _dy, _steps)
{
    var _moved = 0;

    for (var _i = 0; _i < max(0, round(_steps)); _i++)
    {
        var _nx = _sil.x + _dx;
        var _ny = _sil.y + _dy;

        if (scr_fan_actor_blocked(_sil, _nx, _ny, _dx, _dy))
            break;

        _sil.x = _nx;
        _sil.y = _ny;
        _moved++;
    }

    return _moved;
}


function scr_fan_platformer_capture(_sil, _p, _old_x, _old_y, _new_x, _new_y)
{
    var _dx = round(_new_x - _old_x);
    var _dy = round(_new_y - _old_y);

    _sil.x = _old_x;
    _sil.y = _old_y;

    var _direct = scr_fan_find_wind_for_actor(_sil);

    if (_direct != noone)
        return scr_fan_platformer_begin(_sil, _direct, _p);

    if (abs(_dx) <= 32 && abs(_dy) <= 32)
    {
        if (_dx != 0)
        {
            var _sx = sign(_dx);

            for (var _ix = 0; _ix < abs(_dx); _ix++)
            {
                _sil.x += _sx;
                var _fx = scr_fan_find_wind_for_actor(_sil);
                if (_fx != noone)
                    return scr_fan_platformer_begin(_sil, _fx, _p);
            }
        }

        if (_dy != 0)
        {
            var _sy = sign(_dy);

            for (var _iy = 0; _iy < abs(_dy); _iy++)
            {
                _sil.y += _sy;
                var _fy = scr_fan_find_wind_for_actor(_sil);
                if (_fy != noone)
                    return scr_fan_platformer_begin(_sil, _fy, _p);
            }
        }
    }

    _sil.x = _new_x;
    _sil.y = _new_y;
    return false;
}


function scr_fan_platformer_special_update(_sil, _p)
{
    if (!scr_fan_platformer_silicio_prepare(_sil))
        return false;

    if (_sil.platform_fan_mode == "none")
        return false;

    _sil.fan_detached = true;
    _sil.party_follow_suspended = true;

    if (!scr_fan_world_free())
    {
        scr_fan_platformer_sync_player(_p);
        scr_fan_platformer_freeze(_sil, _p);
        return true;
    }

    if (_sil.platform_fan_mode == "wind_follow")
    {
        scr_fan_platformer_sync_player(_p);

        var _fan = _sil.platform_fan_ref;
        var _valid =
            _fan != noone
            &&
            instance_exists(_fan)
            &&
            (!variable_instance_exists(_fan, "fan_enabled") || _fan.fan_enabled);

        var _inside = _valid && scr_fan_actor_in_wind(_fan, _sil);

        if (!_inside)
        {
            var _other = scr_fan_find_wind_for_actor(_sil);

            if (_other != noone)
            {
                _fan = _other;
                _sil.platform_fan_ref = _fan;
                _sil.platform_fan_dir_x = _fan.fan_direction_x;
                _sil.platform_fan_dir_y = _fan.fan_direction_y;
                _sil.platform_fan_force = max(0, abs(_fan.fan_force));
                _sil.platform_fan_accum = 0;
                _inside = true;
            }
        }

        if (!_inside)
        {
            if (!_valid)
            {
                _sil.platform_fan_mode = "wind_wait_gap";
                _sil.platform_fan_ref = noone;
                _sil.platform_fan_wait_distance = 0;
                scr_fan_platformer_seed_wait(_p);
            }
            else
            {
                _sil.platform_fan_mode = "wind_exit";
                _sil.platform_fan_exit_remaining =
                    variable_instance_exists(_fan, "fan_silicio_eject_extra")
                    ? max(0, round(_fan.fan_silicio_eject_extra))
                    : 12;
            }
        }
        else
        {
            _sil.platform_fan_accum += _sil.platform_fan_force;
            var _steps = floor(_sil.platform_fan_accum);
            _sil.platform_fan_accum -= _steps;

            for (var _i = 0; _i < _steps; _i++)
            {
                if (
                    scr_fan_platformer_move(
                        _sil,
                        _sil.platform_fan_dir_x,
                        _sil.platform_fan_dir_y,
                        1
                    )
                    <= 0
                )
                {
                    break;
                }

                if (!scr_fan_actor_in_wind(_fan, _sil))
                {
                    _sil.platform_fan_mode = "wind_exit";
                    _sil.platform_fan_exit_remaining =
                        variable_instance_exists(_fan, "fan_silicio_eject_extra")
                        ? max(0, round(_fan.fan_silicio_eject_extra))
                        : 12;
                    break;
                }
            }
        }

        scr_fan_platformer_freeze(_sil, _p);

        if (_sil.platform_fan_mode == "wind_follow")
            return true;
    }

    if (_sil.platform_fan_mode == "wind_exit")
    {
        scr_fan_platformer_sync_player(_p);

        if (_sil.platform_fan_exit_remaining > 0)
        {
            var _step = min(6, _sil.platform_fan_exit_remaining);
            var _moved = scr_fan_platformer_move(
                _sil,
                _sil.platform_fan_dir_x,
                _sil.platform_fan_dir_y,
                _step
            );

            _sil.platform_fan_exit_remaining -= _moved;

            if (_moved < _step)
                _sil.platform_fan_exit_remaining = 0;
        }

        if (_sil.platform_fan_exit_remaining <= 0)
        {
            _sil.platform_fan_mode = "wind_wait_gap";
            _sil.platform_fan_ref = noone;
            _sil.platform_fan_wait_distance = 0;
            scr_fan_platformer_seed_wait(_p);
        }

        scr_fan_platformer_freeze(_sil, _p);
        return true;
    }

    if (_sil.platform_fan_mode == "wind_wait_gap")
    {
        var _wait_fan = scr_fan_find_wind_for_actor(_sil);

        if (_wait_fan != noone)
        {
            scr_fan_platformer_begin(_sil, _wait_fan, _p);
            return scr_fan_platformer_special_update(_sil, _p);
        }

        var _snap = scr_platformer_party_snapshot(_p);
        var _dx = _snap.x - global.platform_party_last_player_feet_x;
        var _dy = _snap.y - global.platform_party_last_player_feet_y;

        if (abs(_dx) <= 32 && abs(_dy) <= 32)
            _sil.platform_fan_wait_distance += point_distance(0, 0, _dx, _dy);

        array_push(
            global.platform_party_history,
            {
                dx: _dx,
                dy: _dy,
                facing: _snap.facing,
                grounded: _snap.grounded,
                state: _snap.state
            }
        );

        global.platform_party_last_player_feet_x = _snap.x;
        global.platform_party_last_player_feet_y = _snap.y;

        scr_fan_platformer_freeze(_sil, _p);

        var _need = max(16, global.platform_party_delay_frames * 4);

        if (_sil.platform_fan_wait_distance >= _need)
        {
            _sil.platform_fan_mode = "none";
            _sil.platform_fan_ref = noone;
            _sil.platform_fan_accum = 0;
            _sil.platform_fan_exit_remaining = 0;
            _sil.fan_detached = false;
            _sil.fan_rejoin_active = false;
            _sil.party_follow_suspended = false;
        }

        return true;
    }

    return true;
}


function scr_fan_platformer_party_follow_update()
{
    scr_platformer_party_ext_init();

    if (
        !variable_global_exists("platformer_active")
        ||
        !global.platformer_active
        ||
        !instance_exists(obj_player)
        ||
        !scr_party_has("silicio")
    )
    {
        return scr_platformer_party_follow_update();
    }

    var _p = instance_find(obj_player, 0);
    var _sil = scr_party_get_instance("silicio");

    if (_sil == noone || !instance_exists(_sil))
        return scr_platformer_party_follow_update();

    scr_fan_platformer_silicio_prepare(_sil);

    if (_sil.platform_fan_mode != "none")
        return scr_fan_platformer_special_update(_sil, _p);

    var _direct = scr_fan_find_wind_for_actor(_sil);

    if (_direct != noone)
    {
        scr_fan_platformer_begin(_sil, _direct, _p);
        return scr_fan_platformer_special_update(_sil, _p);
    }

    var _initializing =
        global.platform_party_room != room
        ||
        !global.platform_party_was_active;

    var _old_x = _sil.x;
    var _old_y = _sil.y;

    var _result = scr_platformer_party_follow_update();

    _sil = scr_party_get_instance("silicio");

    if (_sil == noone || !instance_exists(_sil))
        return _result;

    scr_fan_platformer_silicio_prepare(_sil);

    if (_initializing)
    {
        var _after_init = scr_fan_find_wind_for_actor(_sil);

        if (_after_init != noone)
        {
            scr_fan_platformer_begin(_sil, _after_init, _p);
            return scr_fan_platformer_special_update(_sil, _p);
        }

        return _result;
    }

    var _captured = scr_fan_platformer_capture(
        _sil,
        _p,
        _old_x,
        _old_y,
        _sil.x,
        _sil.y
    );

    if (_captured)
        return scr_fan_platformer_special_update(_sil, _p);

    return _result;
}


// =========================================================
// UPDATE DEL ABANICO
// =========================================================

function scr_fan_update(_fan)
{
    if (_fan == noone || !instance_exists(_fan))
        return false;

    if (
        _fan.fan_sprite != -1
        &&
        sprite_exists(_fan.fan_sprite)
        &&
        _fan.sprite_index != _fan.fan_sprite
    )
    {
        _fan.sprite_index = _fan.fan_sprite;
        _fan.image_index = 0;
    }

    scr_fan_update_zone(_fan);

    if (!_fan.fan_enabled || !scr_fan_world_free())
    {
        _fan.fan_push_accum = 0;
        _fan.fan_push_accum_maya = 0;
        return false;
    }

    var _moved_maya = false;

    if (instance_exists(obj_player))
    {
        var _p = instance_find(obj_player, 0);
        _moved_maya = scr_fan_push_actor(
            _fan,
            _p,
            "fan_push_accum_maya",
            true
        );
    }
    else
    {
        _fan.fan_push_accum_maya = 0;
    }

    _fan.fan_push_accum = _fan.fan_push_accum_maya;

    // Silicio NO se mueve aquí.
    // Se procesa dentro del mismo flujo que su follower en
    // obj_settings, tanto en RPG como en plataformero.

    return _moved_maya;
}


// =========================================================
// DRAW
// =========================================================

function scr_fan_draw(_fan)
{
    if (_fan == noone || !instance_exists(_fan))
        return false;

    scr_fan_update_zone(_fan);

    if (
        _fan.fan_enabled
        &&
        _fan.fan_air_visible
        &&
        scr_fan_get_distance(_fan) > 0
    )
    {
        var _old_alpha = draw_get_alpha();
        var _old_color = draw_get_color();

        draw_set_alpha(clamp(_fan.fan_air_alpha, 0, 1));
        draw_set_color(_fan.fan_air_color);

        draw_rectangle(
            _fan.fan_wind_left,
            _fan.fan_wind_top,
            _fan.fan_wind_right,
            _fan.fan_wind_bottom,
            false
        );

        draw_set_alpha(_old_alpha);
        draw_set_color(_old_color);
    }

    with (_fan)
    {
        draw_self();
    }

    return true;
}
