/// =========================================================
/// SCR_FAN_SYSTEM
/// =========================================================
///
/// Sistema universal de abanicos / ventiladores.
///
/// Cada objeto de dirección llama:
///
///     scr_fan_prepare(id, dir_x, dir_y)
///     scr_fan_update(id)
///
/// Creation Code disponible:
///
///     fan_sprite = spr_mi_abanico;
///     fan_force = 6;
///     fan_range_base = 160;
///     fan_enabled = true;
///
/// Si escalas la instancia:
///
///     image_xscale
///     image_yscale
///
/// el rango del viento aumenta proporcionalmente.
///
/// =========================================================


// =========================================================
// PREPARAR
// =========================================================

function scr_fan_prepare(
    _fan,
    _dir_x,
    _dir_y
)
{
    if (
        _fan == noone
        ||
        !instance_exists(_fan)
    )
    {
        return false;
    }


    if (
        !variable_instance_exists(
            _fan,
            "fan_sprite"
        )
    )
    {
        _fan.fan_sprite =
            -1;
    }


    if (
        !variable_instance_exists(
            _fan,
            "fan_force"
        )
    )
    {
        _fan.fan_force =
            5;
    }


    if (
        !variable_instance_exists(
            _fan,
            "fan_range_base"
        )
    )
    {
        _fan.fan_range_base =
            120;
    }


    if (
        !variable_instance_exists(
            _fan,
            "fan_enabled"
        )
    )
    {
        _fan.fan_enabled =
            true;
    }


    _fan.fan_direction_x =
        sign(_dir_x);


    _fan.fan_direction_y =
        sign(_dir_y);


    // Último rectángulo de viento.
    //
    // Es útil si después quieres dibujarlo en debug.
    _fan.fan_wind_left =
        _fan.x;


    _fan.fan_wind_top =
        _fan.y;


    _fan.fan_wind_right =
        _fan.x;


    _fan.fan_wind_bottom =
        _fan.y;


    return true;
}


// =========================================================
// ¿EL JUGADOR CHOCA SI LO MOVEMOS A X/Y?
// =========================================================

function scr_fan_player_blocked(
    _p,
    _next_x,
    _next_y,
    _dir_x,
    _dir_y
)
{
    if (
        _p == noone
        ||
        !instance_exists(_p)
    )
    {
        return true;
    }


    // =====================================================
    // FÍSICA PLATAFORMERA
    // =====================================================

    if (
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active
        &&
        variable_instance_exists(
            _p,
            "platform_hit_left"
        )
    )
    {
        // Al empujar hacia ABAJO respetamos también plataformas
        // atravesables y trampolines.
        if (_dir_y > 0)
        {
            return
                scr_platformer_floor_at(
                    _next_x,
                    _next_y,
                    _p.platform_hit_left,
                    _p.platform_hit_top,
                    _p.platform_hit_right,
                    _p.platform_hit_bottom
                );
        }


        return
            scr_platformer_collision_at(
                _next_x,
                _next_y,
                _p.platform_hit_left,
                _p.platform_hit_top,
                _p.platform_hit_right,
                _p.platform_hit_bottom
            );
    }


    // =====================================================
    // OVERWORLD NORMAL
    // =====================================================

    var _left_offset =
        _p.bbox_left
        -
        _p.x;


    var _top_offset =
        _p.bbox_top
        -
        _p.y;


    var _right_offset =
        _p.bbox_right
        -
        _p.x;


    var _bottom_offset =
        _p.bbox_bottom
        -
        _p.y;


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


// =========================================================
// UPDATE
// =========================================================

function scr_fan_update(_fan)
{
    if (
        _fan == noone
        ||
        !instance_exists(_fan)
    )
    {
        return false;
    }


    // Creation Code corre después del Create.
    //
    // Por eso el sprite personalizado se aplica aquí.
    if (
        _fan.fan_sprite != -1
        &&
        sprite_exists(
            _fan.fan_sprite
        )
        &&
        _fan.sprite_index
        !=
        _fan.fan_sprite
    )
    {
        _fan.sprite_index =
            _fan.fan_sprite;


        _fan.image_index =
            0;
    }


    if (!_fan.fan_enabled)
    {
        return false;
    }


    if (!instance_exists(obj_player))
    {
        return false;
    }


    var _p =
        instance_find(
            obj_player,
            0
        );


    if (
        _p == noone
        ||
        !instance_exists(_p)
    )
    {
        return false;
    }


    var _dir_x =
        _fan.fan_direction_x;


    var _dir_y =
        _fan.fan_direction_y;


    // =====================================================
    // RANGO PROPORCIONAL A LA ESCALA DEL OBJETO
    // =====================================================

    var _axis_scale =
        (
            _dir_x != 0
            ?
            abs(
                _fan.image_xscale
            )
            :
            abs(
                _fan.image_yscale
            )
        );


    var _range =
        max(
            0,
            _fan.fan_range_base
            *
            _axis_scale
        );


    // =====================================================
    // RECTÁNGULO DE VIENTO
    // =====================================================

    var _wl =
        _fan.bbox_left;


    var _wt =
        _fan.bbox_top;


    var _wr =
        _fan.bbox_right;


    var _wb =
        _fan.bbox_bottom;


    if (_dir_x > 0)
    {
        _wl =
            _fan.bbox_right;


        _wr =
            _fan.bbox_right
            +
            _range;
    }
    else if (_dir_x < 0)
    {
        _wr =
            _fan.bbox_left;


        _wl =
            _fan.bbox_left
            -
            _range;
    }
    else if (_dir_y > 0)
    {
        _wt =
            _fan.bbox_bottom;


        _wb =
            _fan.bbox_bottom
            +
            _range;
    }
    else if (_dir_y < 0)
    {
        _wb =
            _fan.bbox_top;


        _wt =
            _fan.bbox_top
            -
            _range;
    }


    // Ordenar por seguridad.
    var _left =
        min(
            _wl,
            _wr
        );


    var _right =
        max(
            _wl,
            _wr
        );


    var _top =
        min(
            _wt,
            _wb
        );


    var _bottom =
        max(
            _wt,
            _wb
        );


    _fan.fan_wind_left =
        _left;


    _fan.fan_wind_top =
        _top;


    _fan.fan_wind_right =
        _right;


    _fan.fan_wind_bottom =
        _bottom;


    // =====================================================
    // ¿MAYA ESTÁ DENTRO DEL VIENTO?
    // =====================================================

    var _overlap =
        (
            _p.bbox_right
            >=
            _left
            &&
            _p.bbox_left
            <=
            _right
            &&
            _p.bbox_bottom
            >=
            _top
            &&
            _p.bbox_top
            <=
            _bottom
        );


    if (!_overlap)
    {
        return false;
    }


    var _force =
        max(
            1,
            round(
                abs(
                    _fan.fan_force
                )
            )
        );


    var _moved =
        false;


    // =====================================================
    // EMPUJE PÍXEL A PÍXEL
    // =====================================================

    for (
        var _i = 0;
        _i < _force;
        _i++
    )
    {
        var _next_x =
            _p.x
            +
            _dir_x;


        var _next_y =
            _p.y
            +
            _dir_y;


        if (
            scr_fan_player_blocked(
                _p,
                _next_x,
                _next_y,
                _dir_x,
                _dir_y
            )
        )
        {
            break;
        }


        _p.x =
            _next_x;


        _p.y =
            _next_y;


        _moved =
            true;
    }


    if (_moved)
    {
        _p.movimiento =
            true;
    }


    return _moved;
}
