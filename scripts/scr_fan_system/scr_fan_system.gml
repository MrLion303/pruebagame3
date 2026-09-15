/// =========================================================
/// SCR_FAN_SYSTEM - COMPLETO
/// =========================================================
///
/// Sistema universal de abanicos / ventiladores.
///
/// OBJETOS ACTUALES:
///
///     obj_abanico_izquierda
///     obj_abanico_derecha
///     obj_abanico_arriba
///     obj_abanico_abajo
///
/// Cada objeto ya llama:
///
///     Create:
///         scr_fan_prepare(id, dir_x, dir_y);
///
///     Step:
///         scr_fan_update(id);
///
/// Para visualizar el aire, cada uno tendrá además:
///
///     Draw:
///         scr_fan_draw(id);
///
/// =========================================================
/// CREATION CODE DE CADA ABANICO
/// =========================================================
///
/// Distancia EXACTA del aire en píxeles:
///
///     fan_distance = 160;
///
/// Fuerza del aire:
///
///     fan_force = 3.5;
///
/// Encender / apagar:
///
///     fan_enabled = true;
///
/// Mostrar / ocultar la zona blanca:
///
///     fan_air_visible = true;
///
/// Opacidad de la zona:
///
///     fan_air_alpha = 0.5;
///
/// Sprite personalizado, como antes:
///
///     fan_sprite = spr_mi_abanico;
///
/// COMPATIBILIDAD:
///
///     fan_range_base
///
/// sigue funcionando como alias antiguo de fan_distance.
///
/// IMPORTANTE:
///
/// El viento:
///
///     - mueve físicamente a Maya;
///     - NO cambia sprite_index;
///     - NO cambia platform_facing;
///     - NO cambia face;
///     - NO cambia direccion;
///     - NO fuerza movimiento = true;
///     - NO modifica platform_hsp/platform_vsp.
///
/// Por eso ser empujado por el aire NO cambia la animación.
/// Maya conserva la animación que le corresponda por sus
/// propios controles y estado.
///
/// =========================================================


// =========================================================
// PREPARAR ABANICO
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


    // -----------------------------------------------------
    // SPRITE
    // -----------------------------------------------------

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


    // -----------------------------------------------------
    // FUERZA
    // -----------------------------------------------------
    //
    // Maya:
    //
    //     plataformero = 5 px/frame a velocidad máxima
    //     overworld normal = 4 px/frame caminando
    //
    // 3.5 deja:
    //
    //     plataformero: ~1.5 px/frame contra el viento
    //     overworld:    ~0.5 px/frame contra el viento
    //
    // Es una resistencia fuerte, pero vencible.
    // -----------------------------------------------------

    if (
        !variable_instance_exists(
            _fan,
            "fan_force"
        )
    )
    {
        _fan.fan_force =
            3.5;
    }


    // -----------------------------------------------------
    // DISTANCIA DEL AIRE
    // -----------------------------------------------------
    //
    // Es una distancia ABSOLUTA en píxeles.
    // NO se multiplica por image_xscale/image_yscale.
    //
    // Así:
    //
    //     fan_distance = 200;
    //
    // significa exactamente 200 px desde la cara del abanico.
    // -----------------------------------------------------

    if (
        !variable_instance_exists(
            _fan,
            "fan_distance"
        )
    )
    {
        _fan.fan_distance =
            120;
    }


    // Valor base para detectar configuraciones antiguas.
    _fan.fan_distance_default =
        120;


    // Alias antiguo.
    //
    // Si un abanico ya tenía:
    //
    //     fan_range_base = 160;
    //
    // seguirá funcionando.
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


    // -----------------------------------------------------
    // ESTADO
    // -----------------------------------------------------

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


    // -----------------------------------------------------
    // VISUAL DEL AIRE
    // -----------------------------------------------------

    if (
        !variable_instance_exists(
            _fan,
            "fan_air_visible"
        )
    )
    {
        _fan.fan_air_visible =
            true;
    }


    if (
        !variable_instance_exists(
            _fan,
            "fan_air_alpha"
        )
    )
    {
        _fan.fan_air_alpha =
            0.5;
    }


    if (
        !variable_instance_exists(
            _fan,
            "fan_air_color"
        )
    )
    {
        _fan.fan_air_color =
            c_white;
    }


    // -----------------------------------------------------
    // DIRECCIÓN
    // -----------------------------------------------------

    _fan.fan_direction_x =
        sign(_dir_x);


    _fan.fan_direction_y =
        sign(_dir_y);


    // -----------------------------------------------------
    // ACUMULADOR SUBPÍXEL DEL EMPUJE
    // -----------------------------------------------------
    //
    // Permite fuerzas decimales como 3.5:
    //
    //     frame 1 -> 3 px
    //     frame 2 -> 4 px
    //     frame 3 -> 3 px
    //     frame 4 -> 4 px
    //
    // promedio = 3.5 px/frame.
    // -----------------------------------------------------

    _fan.fan_push_accum =
        0;


    // -----------------------------------------------------
    // ÚLTIMA ZONA CALCULADA
    // -----------------------------------------------------

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
// DISTANCIA REAL CONFIGURADA
// =========================================================

function scr_fan_get_distance(_fan)
{
    if (
        _fan == noone
        ||
        !instance_exists(_fan)
    )
    {
        return 0;
    }


    var _distance =
        max(
            0,
            _fan.fan_distance
        );


    // -----------------------------------------------------
    // COMPATIBILIDAD CON fan_range_base
    // -----------------------------------------------------
    //
    // Si fan_distance sigue en su valor por defecto, pero
    // Creation Code cambió fan_range_base, respetamos el valor
    // antiguo.
    //
    // Si fan_distance fue personalizado, tiene prioridad.
    // -----------------------------------------------------

    if (
        variable_instance_exists(
            _fan,
            "fan_range_base"
        )
        &&
        _fan.fan_distance
        ==
        _fan.fan_distance_default
        &&
        _fan.fan_range_base
        !=
        _fan.fan_distance_default
    )
    {
        _distance =
            max(
                0,
                _fan.fan_range_base
            );
    }


    return _distance;
}


// =========================================================
// OBTENER RECTÁNGULO FÍSICO DEL ABANICO
// =========================================================

function scr_fan_get_source_rect(_fan)
{
    var _left =
        _fan.x - 16;

    var _top =
        _fan.y - 16;

    var _right =
        _fan.x + 16;

    var _bottom =
        _fan.y + 16;


    if (
        _fan.sprite_index != -1
        &&
        sprite_exists(
            _fan.sprite_index
        )
    )
    {
        _left =
            _fan.bbox_left;

        _top =
            _fan.bbox_top;

        _right =
            _fan.bbox_right;

        _bottom =
            _fan.bbox_bottom;
    }


    return {
        left: _left,
        top: _top,
        right: _right,
        bottom: _bottom
    };
}


// =========================================================
// CALCULAR ZONA DEL VIENTO
// =========================================================
//
// El rectángulo comienza exactamente en la CARA del abanico
// hacia la que apunta.
//
// IZQUIERDA:
//
//     [ aire <--------- ][ABANICO]
//
// DERECHA:
//
//     [ABANICO][---------> aire ]
//
// ARRIBA:
//
//              aire
//               ^
//               |
//            [ABANICO]
//
// ABAJO:
//
//            [ABANICO]
//               |
//               v
//              aire
//
// El ancho perpendicular coincide con el tamaño físico del
// abanico.
//
// =========================================================

function scr_fan_update_zone(_fan)
{
    if (
        _fan == noone
        ||
        !instance_exists(_fan)
    )
    {
        return false;
    }


    var _src =
        scr_fan_get_source_rect(
            _fan
        );


    var _distance =
        scr_fan_get_distance(
            _fan
        );


    var _left =
        _src.left;

    var _top =
        _src.top;

    var _right =
        _src.right;

    var _bottom =
        _src.bottom;


    var _dir_x =
        _fan.fan_direction_x;

    var _dir_y =
        _fan.fan_direction_y;


    // -----------------------------------------------------
    // DERECHA
    // -----------------------------------------------------

    if (_dir_x > 0)
    {
        _left =
            _src.right;

        _right =
            _src.right
            +
            _distance;
    }

    // -----------------------------------------------------
    // IZQUIERDA
    // -----------------------------------------------------

    else if (_dir_x < 0)
    {
        _right =
            _src.left;

        _left =
            _src.left
            -
            _distance;
    }

    // -----------------------------------------------------
    // ABAJO
    // -----------------------------------------------------

    else if (_dir_y > 0)
    {
        _top =
            _src.bottom;

        _bottom =
            _src.bottom
            +
            _distance;
    }

    // -----------------------------------------------------
    // ARRIBA
    // -----------------------------------------------------

    else if (_dir_y < 0)
    {
        _bottom =
            _src.top;

        _top =
            _src.top
            -
            _distance;
    }


    _fan.fan_wind_left =
        min(
            _left,
            _right
        );


    _fan.fan_wind_top =
        min(
            _top,
            _bottom
        );


    _fan.fan_wind_right =
        max(
            _left,
            _right
        );


    _fan.fan_wind_bottom =
        max(
            _top,
            _bottom
        );


    return true;
}


// =========================================================
// HITBOX REAL DEL PLAYER
// =========================================================

function scr_fan_get_player_rect(_p)
{
    var _left =
        _p.bbox_left;

    var _top =
        _p.bbox_top;

    var _right =
        _p.bbox_right;

    var _bottom =
        _p.bbox_bottom;


    // En modo plataformero NO usamos bbox del sprite.
    //
    // Usamos exactamente la hitbox física de cuerpo completo.
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
        &&
        variable_instance_exists(
            _p,
            "platform_hit_top"
        )
        &&
        variable_instance_exists(
            _p,
            "platform_hit_right"
        )
        &&
        variable_instance_exists(
            _p,
            "platform_hit_bottom"
        )
    )
    {
        _left =
            _p.x
            +
            _p.platform_hit_left;


        _top =
            _p.y
            +
            _p.platform_hit_top;


        _right =
            _p.x
            +
            _p.platform_hit_right;


        _bottom =
            _p.y
            +
            _p.platform_hit_bottom;
    }


    return {
        left: _left,
        top: _top,
        right: _right,
        bottom: _bottom
    };
}


// =========================================================
// ¿MAYA ESTÁ DENTRO DEL AIRE?
// =========================================================

function scr_fan_player_in_wind(
    _fan,
    _p
)
{
    var _rect =
        scr_fan_get_player_rect(
            _p
        );


    return
    (
        _rect.right
        >=
        _fan.fan_wind_left

        &&

        _rect.left
        <=
        _fan.fan_wind_right

        &&

        _rect.bottom
        >=
        _fan.fan_wind_top

        &&

        _rect.top
        <=
        _fan.fan_wind_bottom
    );
}


// =========================================================
// ¿EL PLAYER CHOCA SI EL VIENTO LO MUEVE?
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
        &&
        variable_instance_exists(
            _p,
            "platform_hit_top"
        )
        &&
        variable_instance_exists(
            _p,
            "platform_hit_right"
        )
        &&
        variable_instance_exists(
            _p,
            "platform_hit_bottom"
        )
    )
    {
        // -------------------------------------------------
        // ABAJO
        // -------------------------------------------------
        //
        // Al empujar hacia abajo respetamos:
        //
        //     - colision normal;
        //     - plataformas traspasables;
        //     - trampolines.
        // -------------------------------------------------

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


        // -------------------------------------------------
        // IZQUIERDA / DERECHA / ARRIBA
        // -------------------------------------------------

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
            _next_x
            +
            _left_offset,
            _next_y
            +
            _top_offset,
            _next_x
            +
            _right_offset,
            _next_y
            +
            _bottom_offset,
            colision,
            false,
            true
        )
        !=
        noone;
}


// =========================================================
// ¿EL MUNDO PERMITE QUE EL AIRE MUEVA A MAYA?
// =========================================================

function scr_fan_world_free()
{
    if (
        room == bbs
        ||
        room == game_over
    )
    {
        return false;
    }


    if (
        variable_global_exists(
            "gameover_death_freeze_active"
        )
        &&
        global.gameover_death_freeze_active
    )
    {
        return false;
    }


    if (
        variable_global_exists(
            "cutscene_active"
        )
        &&
        global.cutscene_active
    )
    {
        return false;
    }


    if (
        instance_exists(
            obj_pauser
        )
        ||
        instance_exists(
            obj_save_menu
        )
        ||
        instance_exists(
            obj_textbox
        )
        ||
        instance_exists(
            obj_transicion_bbs
        )
    )
    {
        return false;
    }


    if (
        instance_exists(
            obj_menu_manager
        )
        &&
        obj_menu_manager.state
        !=
        MENU_STATE.CLOSED
    )
    {
        return false;
    }


    return true;
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


    // =====================================================
    // SPRITE PERSONALIZADO
    // =====================================================
    //
    // Creation Code se ejecuta después del Create.
    // Por eso el sprite se aplica aquí.
    // =====================================================

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


    // La zona se calcula SIEMPRE para que el Draw tenga datos
    // correctos incluso aunque Maya no esté dentro.
    scr_fan_update_zone(
        _fan
    );


    if (!_fan.fan_enabled)
    {
        _fan.fan_push_accum =
            0;

        return false;
    }


    if (!scr_fan_world_free())
    {
        _fan.fan_push_accum =
            0;

        return false;
    }


    if (!instance_exists(obj_player))
    {
        _fan.fan_push_accum =
            0;

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
        _fan.fan_push_accum =
            0;

        return false;
    }


    // =====================================================
    // ¿MAYA ESTÁ EN LA ZONA?
    // =====================================================

    if (
        !scr_fan_player_in_wind(
            _fan,
            _p
        )
    )
    {
        _fan.fan_push_accum =
            0;

        return false;
    }


    // =====================================================
    // FUERZA SUBPÍXEL
    // =====================================================

    var _force =
        max(
            0,
            abs(
                _fan.fan_force
            )
        );


    if (_force <= 0)
    {
        _fan.fan_push_accum =
            0;

        return false;
    }


    _fan.fan_push_accum +=
        _force;


    var _steps =
        floor(
            _fan.fan_push_accum
        );


    _fan.fan_push_accum -=
        _steps;


    if (_steps <= 0)
    {
        return false;
    }


    var _dir_x =
        _fan.fan_direction_x;


    var _dir_y =
        _fan.fan_direction_y;


    var _moved =
        false;


    // =====================================================
    // EMPUJE PÍXEL A PÍXEL
    // =====================================================
    //
    // SOLO cambiamos x / y.
    //
    // NO tocamos:
    //
    //     movimiento
    //     direccion
    //     face
    //     facing_direction
    //     sprite_index
    //     image_index
    //     image_speed
    //     platform_hsp
    //     platform_vsp
    //     platform_facing
    //
    // En modo plataformero la física de Maya ocurre en
    // BEGIN STEP y los abanicos ejecutan su Step normal.
    //
    // Resultado:
    //
    //     1. Maya se mueve por sus propios controles.
    //     2. Después el viento añade desplazamiento externo.
    //
    // Esto hace posible caminar contra el aire sin que el
    // ventilador se apropie de la animación.
    // =====================================================

    for (
        var _i = 0;
        _i < _steps;
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
            // No acumular fuerza detrás de una pared.
            _fan.fan_push_accum =
                0;

            break;
        }


        _p.x =
            _next_x;


        _p.y =
            _next_y;


        _moved =
            true;
    }


    return _moved;
}


// =========================================================
// DRAW
// =========================================================
//
// Dibuja:
//
//     1. zona de aire blanca semitransparente;
//     2. sprite normal del abanico encima.
//
// La zona dibujada es EXACTAMENTE la misma que usa la física.
//
// =========================================================

function scr_fan_draw(_fan)
{
    if (
        _fan == noone
        ||
        !instance_exists(_fan)
    )
    {
        return false;
    }


    // Por seguridad, recalcular aquí también.
    //
    // Así cambiar fan_distance desde Creation Code/runtime se
    // refleja inmediatamente en el dibujo.
    scr_fan_update_zone(
        _fan
    );


    if (
        _fan.fan_enabled
        &&
        _fan.fan_air_visible
        &&
        scr_fan_get_distance(
            _fan
        )
        >
        0
    )
    {
        var _old_alpha =
            draw_get_alpha();


        var _old_color =
            draw_get_color();


        draw_set_alpha(
            clamp(
                _fan.fan_air_alpha,
                0,
                1
            )
        );


        draw_set_color(
            _fan.fan_air_color
        );


        draw_rectangle(
            _fan.fan_wind_left,
            _fan.fan_wind_top,
            _fan.fan_wind_right,
            _fan.fan_wind_bottom,
            false
        );


        draw_set_alpha(
            _old_alpha
        );


        draw_set_color(
            _old_color
        );
    }


    // Mantener el sprite/animación normal del abanico.
    with (_fan)
    {
        draw_self();
    }


    return true;
}
