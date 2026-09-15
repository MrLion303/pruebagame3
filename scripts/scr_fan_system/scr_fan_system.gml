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
///     - mueve físicamente a Maya y a Silicio;
///     - NO cambia sprite_index;
///     - NO cambia platform_facing;
///     - NO cambia face;
///     - NO cambia direccion;
///     - NO fuerza movimiento = true;
///     - NO modifica platform_hsp/platform_vsp.
///
/// Por eso ser empujado por el aire NO cambia la animación.
/// Maya y Silicio conservan la animación que les corresponda
/// por sus propios controles, seguimiento y estado.
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
    // EXPULSIÓN EXTRA DE SILICIO
    // -----------------------------------------------------
    //
    // Cuando Silicio termina de abandonar la corriente recibe
    // este impulso adicional para quedar claramente FUERA del
    // rectángulo blanco.
    //
    // Creation Code opcional:
    //
    //     fan_silicio_eject_extra = 32;
    //
    // -----------------------------------------------------

    if (
        !variable_instance_exists(
            _fan,
            "fan_silicio_eject_extra"
        )
    )
    {
        _fan.fan_silicio_eject_extra =
            24;
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

    // Acumuladores separados.
    //
    // Maya y Silicio pueden entrar/salir de la corriente en
    // momentos distintos, así que NO deben compartir residuo
    // subpíxel.
    _fan.fan_push_accum =
        0;


    _fan.fan_push_accum_maya =
        0;


    _fan.fan_push_accum_silicio =
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
// HITBOX REAL DE UN ACTOR
// =========================================================
//
// Soporta:
//
//     Maya:
//         platform_hit_*
//
//     Silicio:
//         platform_sil_hit_*
//
// Fuera del plataformero usa bbox normal.
// =========================================================

function scr_fan_get_actor_rect(_actor)
{
    var _left =
        _actor.bbox_left;

    var _top =
        _actor.bbox_top;

    var _right =
        _actor.bbox_right;

    var _bottom =
        _actor.bbox_bottom;


    var _platformer =
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active;


    // =====================================================
    // MAYA
    // =====================================================

    if (
        _platformer
        &&
        variable_instance_exists(
            _actor,
            "platform_hit_left"
        )
        &&
        variable_instance_exists(
            _actor,
            "platform_hit_top"
        )
        &&
        variable_instance_exists(
            _actor,
            "platform_hit_right"
        )
        &&
        variable_instance_exists(
            _actor,
            "platform_hit_bottom"
        )
    )
    {
        _left =
            _actor.x
            +
            _actor.platform_hit_left;

        _top =
            _actor.y
            +
            _actor.platform_hit_top;

        _right =
            _actor.x
            +
            _actor.platform_hit_right;

        _bottom =
            _actor.y
            +
            _actor.platform_hit_bottom;
    }

    // =====================================================
    // SILICIO
    // =====================================================

    else if (
        _platformer
        &&
        variable_instance_exists(
            _actor,
            "platform_sil_hit_left"
        )
        &&
        variable_instance_exists(
            _actor,
            "platform_sil_hit_top"
        )
        &&
        variable_instance_exists(
            _actor,
            "platform_sil_hit_right"
        )
        &&
        variable_instance_exists(
            _actor,
            "platform_sil_hit_bottom"
        )
    )
    {
        _left =
            _actor.x
            +
            _actor.platform_sil_hit_left;

        _top =
            _actor.y
            +
            _actor.platform_sil_hit_top;

        _right =
            _actor.x
            +
            _actor.platform_sil_hit_right;

        _bottom =
            _actor.y
            +
            _actor.platform_sil_hit_bottom;
    }


    return {
        left: _left,
        top: _top,
        right: _right,
        bottom: _bottom
    };
}


// Compatibilidad con el nombre usado por la versión anterior.
function scr_fan_get_player_rect(_p)
{
    return
        scr_fan_get_actor_rect(
            _p
        );
}


// =========================================================
// ¿UN ACTOR ESTÁ DENTRO DEL AIRE?
// =========================================================

function scr_fan_actor_in_wind(
    _fan,
    _actor
)
{
    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return false;
    }


    var _rect =
        scr_fan_get_actor_rect(
            _actor
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


// Compatibilidad.
function scr_fan_player_in_wind(
    _fan,
    _p
)
{
    return
        scr_fan_actor_in_wind(
            _fan,
            _p
        );
}


// =========================================================
// OBTENER HITBOX PLATAFORMERA DE UN ACTOR
// =========================================================

function scr_fan_get_platform_hitbox(_actor)
{
    // MAYA
    if (
        variable_instance_exists(
            _actor,
            "platform_hit_left"
        )
        &&
        variable_instance_exists(
            _actor,
            "platform_hit_top"
        )
        &&
        variable_instance_exists(
            _actor,
            "platform_hit_right"
        )
        &&
        variable_instance_exists(
            _actor,
            "platform_hit_bottom"
        )
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


    // SILICIO
    if (
        variable_instance_exists(
            _actor,
            "platform_sil_hit_left"
        )
        &&
        variable_instance_exists(
            _actor,
            "platform_sil_hit_top"
        )
        &&
        variable_instance_exists(
            _actor,
            "platform_sil_hit_right"
        )
        &&
        variable_instance_exists(
            _actor,
            "platform_sil_hit_bottom"
        )
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
// ¿UN ACTOR CHOCA SI EL VIENTO LO MUEVE?
// =========================================================

function scr_fan_actor_blocked(
    _actor,
    _next_x,
    _next_y,
    _dir_x,
    _dir_y
)
{
    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return true;
    }


    var _platformer =
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active;


    if (_platformer)
    {
        var _hit =
            scr_fan_get_platform_hitbox(
                _actor
            );


        if (_hit.valid)
        {
            // Hacia abajo respetamos también plataformas
            // one-way y trampolines.
            if (_dir_y > 0)
            {
                return
                    scr_platformer_floor_at(
                        _next_x,
                        _next_y,
                        _hit.left,
                        _hit.top,
                        _hit.right,
                        _hit.bottom
                    );
            }


            return
                scr_platformer_collision_at(
                    _next_x,
                    _next_y,
                    _hit.left,
                    _hit.top,
                    _hit.right,
                    _hit.bottom
                );
        }
    }


    // =====================================================
    // OVERWORLD NORMAL
    // =====================================================

    var _left_offset =
        _actor.bbox_left
        -
        _actor.x;

    var _top_offset =
        _actor.bbox_top
        -
        _actor.y;

    var _right_offset =
        _actor.bbox_right
        -
        _actor.x;

    var _bottom_offset =
        _actor.bbox_bottom
        -
        _actor.y;


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


// Compatibilidad.
function scr_fan_player_blocked(
    _p,
    _next_x,
    _next_y,
    _dir_x,
    _dir_y
)
{
    return
        scr_fan_actor_blocked(
            _p,
            _next_x,
            _next_y,
            _dir_x,
            _dir_y
        );
}


// =========================================================
// EMPUJAR UN ACTOR
// =========================================================
//
// _accum_name:
//     acumulador subpíxel propio del actor para este abanico.
//
// _is_maya:
//     si es Maya, compensamos el historial de la party para
//     que Silicio NO reproduzca ocho frames después el viento
//     que ya le corresponde recibir físicamente por sí mismo.
// =========================================================

function scr_fan_push_actor(
    _fan,
    _actor,
    _accum_name,
    _is_maya
)
{
    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        variable_instance_set(
            _fan,
            _accum_name,
            0
        );

        return false;
    }


    if (
        !scr_fan_actor_in_wind(
            _fan,
            _actor
        )
    )
    {
        variable_instance_set(
            _fan,
            _accum_name,
            0
        );

        return false;
    }


    // =====================================================
    // SILICIO: DESPRENDER DEL FOLLOWER AL TOCAR EL VIENTO
    // =====================================================
    //
    // El problema anterior era que el abanico sí desplazaba
    // a Silicio, pero después el sistema de party volvía a
    // moverlo en End Step.
    //
    // Desde el PRIMER frame dentro de la corriente:
    //
    //     1. Silicio queda temporalmente desprendido.
    //     2. El follower deja de controlar su posición.
    //     3. Solo el viento puede moverlo hasta expulsarlo.
    //     4. Ya fuera, espera a que Maya se detenga y vuelva
    //        a caminar para empezar a reincorporarse.
    // =====================================================

    var _actor_is_silicio_party =
        (
            !_is_maya
            &&
            variable_instance_exists(
                _actor,
                "party_id"
            )
            &&
            _actor.party_id
            ==
            "silicio"
            &&
            variable_instance_exists(
                _actor,
                "party_member"
            )
            &&
            _actor.party_member
        );


    if (_actor_is_silicio_party)
    {
        _actor.fan_detached =
            true;

        _actor.fan_detached_room =
            room;

        _actor.fan_rejoin_active =
            false;

        _actor.fan_rejoin_walk_armed =
            false;

        _actor.fan_outside_frames =
            0;


        // Última dirección real que lo está expulsando.
        //
        // Se usa también para el impulso final fuera de la zona
        // blanca, evitando que Silicio quede pegado exactamente
        // al borde del rango del abanico.
        _actor.fan_detach_dir_x =
            _fan.fan_direction_x;

        _actor.fan_detach_dir_y =
            _fan.fan_direction_y;


        // El viento NO cuenta como movimiento de caminar.
        if (
            variable_instance_exists(
                _actor,
                "platform_sil_move_x"
            )
        )
        {
            _actor.platform_sil_move_x =
                0;
        }

        if (
            variable_instance_exists(
                _actor,
                "platform_sil_move_y"
            )
        )
        {
            _actor.platform_sil_move_y =
                0;
        }

        _actor.movimiento =
            false;

        _actor.image_speed =
            0;
    }


    var _force =
        max(
            0,
            abs(
                _fan.fan_force
            )
        );


    if (_force <= 0)
    {
        variable_instance_set(
            _fan,
            _accum_name,
            0
        );

        return false;
    }


    var _accum =
        variable_instance_get(
            _fan,
            _accum_name
        );


    _accum +=
        _force;


    var _steps =
        floor(
            _accum
        );


    _accum -=
        _steps;


    variable_instance_set(
        _fan,
        _accum_name,
        _accum
    );


    if (_steps <= 0)
    {
        return false;
    }


    var _dir_x =
        _fan.fan_direction_x;

    var _dir_y =
        _fan.fan_direction_y;


    var _start_x =
        _actor.x;

    var _start_y =
        _actor.y;


    var _moved =
        false;


    // SOLO modificamos x/y.
    //
    // NO tocamos ninguna variable visual ni de input.
    for (
        var _i = 0;
        _i < _steps;
        _i++
    )
    {
        var _next_x =
            _actor.x
            +
            _dir_x;

        var _next_y =
            _actor.y
            +
            _dir_y;


        if (
            scr_fan_actor_blocked(
                _actor,
                _next_x,
                _next_y,
                _dir_x,
                _dir_y
            )
        )
        {
            variable_instance_set(
                _fan,
                _accum_name,
                0
            );

            break;
        }


        _actor.x =
            _next_x;

        _actor.y =
            _next_y;


        _moved =
            true;
    }


    // =====================================================
    // SILICIO: EXPULSIÓN REAL FUERA DEL ÁREA BLANCA
    // =====================================================
    //
    // Antes, en cuanto su hitbox dejaba de solaparse con la
    // corriente, el empuje terminaba. Eso hacía que visualmente
    // quedara "pegado" justo a la orilla del rango.
    //
    // Ahora, en el MISMO frame en que sale de la corriente,
    // recibe un pequeño impulso residual adicional.
    //
    // Así:
    //
    //     corriente -> borde -> SALE DESPEDIDO -> queda fuera
    //
    // y no:
    //
    //     corriente -> borde -> se queda pegado
    //
    // Este impulso sigue respetando colisiones del escenario.
    // =====================================================

    if (
        _actor_is_silicio_party
        &&
        _moved
        &&
        !scr_fan_actor_in_wind(
            _fan,
            _actor
        )
    )
    {
        var _eject_extra =
            24;


        // Permitir personalizarlo desde Creation Code del abanico:
        //
        //     fan_silicio_eject_extra = 32;
        //
        // Si no se define, usa 24 px.
        if (
            variable_instance_exists(
                _fan,
                "fan_silicio_eject_extra"
            )
        )
        {
            _eject_extra =
                max(
                    0,
                    round(
                        _fan.fan_silicio_eject_extra
                    )
                );
        }


        for (
            var _ej = 0;
            _ej < _eject_extra;
            _ej++
        )
        {
            var _eject_next_x =
                _actor.x
                +
                _dir_x;

            var _eject_next_y =
                _actor.y
                +
                _dir_y;


            if (
                scr_fan_actor_blocked(
                    _actor,
                    _eject_next_x,
                    _eject_next_y,
                    _dir_x,
                    _dir_y
                )
            )
            {
                break;
            }


            _actor.x =
                _eject_next_x;

            _actor.y =
                _eject_next_y;


            _moved =
                true;
        }
    }


    // =====================================================
    // MAYA: NO COPIAR EL VIENTO AL BUFFER DE SILICIO
    // =====================================================
    //
    // obj_settings registra en End Step cuánto se movió Maya.
    // Los abanicos empujan en Step.
    //
    // Ajustando el punto de referencia por el MISMO desplazamiento
    // externo, el historial conserva solo el movimiento propio de
    // Maya. Así Silicio no recibe después un "eco" del viento.
    // =====================================================

    if (
        _moved
        &&
        _is_maya
        &&
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active
    )
    {
        var _external_dx =
            _actor.x
            -
            _start_x;

        var _external_dy =
            _actor.y
            -
            _start_y;


        if (
            variable_global_exists(
                "platform_party_last_player_feet_x"
            )
        )
        {
            global.platform_party_last_player_feet_x +=
                _external_dx;
        }


        if (
            variable_global_exists(
                "platform_party_last_player_feet_y"
            )
        )
        {
            global.platform_party_last_player_feet_y +=
                _external_dy;
        }
    }


    return _moved;
}


// =========================================================
// SILICIO - ¿ESTÁ DENTRO DE ALGUNA CORRIENTE?
// =========================================================
//
// Se consulta desde End Step.
//
// Esto es independiente de qué abanico lo empujó. Si hay varios
// ventiladores solapados, Silicio seguirá desprendido hasta salir
// de TODOS ellos.
// =========================================================

function scr_fan_silicio_find_wind(_sil)
{
    if (
        _sil == noone
        ||
        !instance_exists(_sil)
    )
    {
        return noone;
    }


    var _fan_objects =
    [
        obj_abanico_izquierda,
        obj_abanico_derecha,
        obj_abanico_arriba,
        obj_abanico_abajo
    ];


    for (
        var _oi = 0;
        _oi < array_length(_fan_objects);
        _oi++
    )
    {
        var _fan_obj =
            _fan_objects[_oi];


        var _count =
            instance_number(
                _fan_obj
            );


        for (
            var _fi = 0;
            _fi < _count;
            _fi++
        )
        {
            var _fan =
                instance_find(
                    _fan_obj,
                    _fi
                );


            if (
                _fan == noone
                ||
                !instance_exists(_fan)
            )
            {
                continue;
            }


            if (
                variable_instance_exists(
                    _fan,
                    "fan_enabled"
                )
                &&
                !_fan.fan_enabled
            )
            {
                continue;
            }


            scr_fan_update_zone(
                _fan
            );


            if (
                scr_fan_actor_in_wind(
                    _fan,
                    _sil
                )
            )
            {
                return _fan;
            }
        }
    }


    return noone;
}


function scr_fan_silicio_in_any_wind(_sil)
{
    return
        scr_fan_silicio_find_wind(
            _sil
        )
        !=
        noone;
}


// =========================================================
// SILICIO - PREPARAR ESTADO DE EXPULSIÓN / REINGRESO
// =========================================================

function scr_fan_silicio_detach_prepare(_sil)
{
    if (
        _sil == noone
        ||
        !instance_exists(_sil)
    )
    {
        return false;
    }


    if (
        !variable_instance_exists(
            _sil,
            "fan_detached"
        )
    )
    {
        _sil.fan_detached =
            false;
    }


    if (
        !variable_instance_exists(
            _sil,
            "fan_detached_room"
        )
    )
    {
        _sil.fan_detached_room =
            -1;
    }


    if (
        !variable_instance_exists(
            _sil,
            "fan_rejoin_active"
        )
    )
    {
        _sil.fan_rejoin_active =
            false;
    }


    if (
        !variable_instance_exists(
            _sil,
            "fan_rejoin_walk_armed"
        )
    )
    {
        _sil.fan_rejoin_walk_armed =
            false;
    }


    if (
        !variable_instance_exists(
            _sil,
            "fan_outside_frames"
        )
    )
    {
        _sil.fan_outside_frames =
            0;
    }


    // Acumulador de fuerza DEL PROPIO SILICIO.
    //
    // Ya no depende del Step del abanico.
    if (
        !variable_instance_exists(
            _sil,
            "fan_detach_push_accum"
        )
    )
    {
        _sil.fan_detach_push_accum =
            0;
    }


    if (
        !variable_instance_exists(
            _sil,
            "fan_detach_dir_x"
        )
    )
    {
        _sil.fan_detach_dir_x =
            0;
    }


    if (
        !variable_instance_exists(
            _sil,
            "fan_detach_dir_y"
        )
    )
    {
        _sil.fan_detach_dir_y =
            0;
    }


    if (
        !variable_instance_exists(
            _sil,
            "fan_detach_last_fan"
        )
    )
    {
        _sil.fan_detach_last_fan =
            noone;
    }


    // Más rápido que Maya (5 px/frame) para poder alcanzarla.
    if (
        !variable_instance_exists(
            _sil,
            "fan_rejoin_speed"
        )
    )
    {
        _sil.fan_rejoin_speed =
            9;
    }


    // Separación objetivo aproximada del follower nativo:
    //
    //     8 frames * 5 px ~= 40 px.
    if (
        !variable_instance_exists(
            _sil,
            "fan_rejoin_follow_distance"
        )
    )
    {
        _sil.fan_rejoin_follow_distance =
            40;
    }


    return true;
}


// =========================================================
// SILICIO - RESETEAR HISTORIAL AL REINCORPORARSE
// =========================================================
//
// El follower plataformero reproduce DELTAS antiguos de Maya.
//
// Después de una expulsión NO debemos conservar esos comandos,
// porque podrían volver a arrastrar a Silicio hacia la corriente.
// Sembramos un historial limpio exactamente igual al sistema
// normal.
// =========================================================

function scr_fan_silicio_reset_platform_history(_p)
{
    if (
        _p == noone
        ||
        !instance_exists(_p)
    )
    {
        return false;
    }


    scr_platformer_party_ext_init();


    var _snap =
        scr_platformer_party_snapshot(
            _p
        );


    global.platform_party_history =
        [];


    global.platform_party_room =
        room;


    global.platform_party_was_active =
        true;


    global.platform_party_last_player_feet_x =
        _snap.x;


    global.platform_party_last_player_feet_y =
        _snap.y;


    for (
        var _i = 0;
        _i < global.platform_party_delay_frames;
        _i++
    )
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


    return true;
}


// =========================================================
// SILICIO - MOVER UN PASO DE REINCORPORACIÓN
// =========================================================

function scr_fan_silicio_rejoin_axis_x(
    _sil,
    _target_x,
    _steps
)
{
    var _moved =
        0;


    if (
        _steps <= 0
        ||
        abs(
            _target_x
            -
            _sil.x
        )
        <
        0.5
    )
    {
        return 0;
    }


    var _dir =
        sign(
            _target_x
            -
            _sil.x
        );


    for (
        var _i = 0;
        _i < _steps;
        _i++
    )
    {
        if (
            abs(
                _target_x
                -
                _sil.x
            )
            <
            0.5
        )
        {
            break;
        }


        var _next_x =
            _sil.x
            +
            _dir;


        if (
            scr_platformer_collision_at(
                _next_x,
                _sil.y,
                _sil.platform_sil_hit_left,
                _sil.platform_sil_hit_top,
                _sil.platform_sil_hit_right,
                _sil.platform_sil_hit_bottom
            )
        )
        {
            break;
        }


        _sil.x =
            _next_x;


        _moved +=
            _dir;
    }


    return _moved;
}


function scr_fan_silicio_rejoin_axis_y(
    _sil,
    _target_y,
    _steps
)
{
    var _moved =
        0;


    if (
        _steps <= 0
        ||
        abs(
            _target_y
            -
            _sil.y
        )
        <
        0.5
    )
    {
        return 0;
    }


    var _dir =
        sign(
            _target_y
            -
            _sil.y
        );


    for (
        var _i = 0;
        _i < _steps;
        _i++
    )
    {
        if (
            abs(
                _target_y
                -
                _sil.y
            )
            <
            0.5
        )
        {
            break;
        }


        var _next_y =
            _sil.y
            +
            _dir;


        var _blocked =
            false;


        if (_dir > 0)
        {
            _blocked =
                scr_platformer_floor_at(
                    _sil.x,
                    _next_y,
                    _sil.platform_sil_hit_left,
                    _sil.platform_sil_hit_top,
                    _sil.platform_sil_hit_right,
                    _sil.platform_sil_hit_bottom
                );
        }
        else
        {
            _blocked =
                scr_platformer_collision_at(
                    _sil.x,
                    _next_y,
                    _sil.platform_sil_hit_left,
                    _sil.platform_sil_hit_top,
                    _sil.platform_sil_hit_right,
                    _sil.platform_sil_hit_bottom
                );
        }


        if (_blocked)
        {
            break;
        }


        _sil.y =
            _next_y;


        _moved +=
            _dir;
    }


    return _moved;
}


// =========================================================
// SILICIO - CONTROLADOR DE EXPULSIÓN Y REINCORPORACIÓN
// =========================================================
//
// Devuelve TRUE cuando este sistema consume el follower normal.
//
// FLUJO:
//
//     entra en viento
//         -> follower OFF
//         -> solo el abanico lo empuja
//
//     sale COMPLETAMENTE del rectángulo blanco
//         -> se queda donde cayó
//
//     Maya queda quieta
//         -> se arma el reingreso
//
//     Maya vuelve a caminar
//         -> Silicio corre para alcanzar su formación
//
//     llega detrás de Maya
//         -> historial limpio
//         -> follower normal ON otra vez
// =========================================================

function scr_fan_silicio_detach_update(
    _sil,
    _p
)
{
    if (
        _sil == noone
        ||
        !instance_exists(_sil)
        ||
        _p == noone
        ||
        !instance_exists(_p)
    )
    {
        return false;
    }


    scr_fan_silicio_detach_prepare(
        _sil
    );


    // SOLO preparar hitbox/variables.
    //
    // NO llamar scr_platformer_silicio_enter() aquí porque esa
    // función fuerza party_follow_suspended = false.
    with (_sil)
    {
        scr_platformer_silicio_prepare();
    }


    // =====================================================
    // CAMBIO DE ROOM
    // =====================================================

    if (
        _sil.fan_detached
        &&
        _sil.fan_detached_room
        !=
        room
    )
    {
        _sil.fan_detached =
            false;

        _sil.fan_rejoin_active =
            false;

        _sil.fan_rejoin_walk_armed =
            false;

        _sil.fan_outside_frames =
            0;

        _sil.fan_detach_push_accum =
            0;

        _sil.party_follow_suspended =
            false;


        return false;
    }


    // =====================================================
    // DETECTAR CORRIENTE ACTUAL
    // =====================================================

    var _wind =
        scr_fan_silicio_find_wind(
            _sil
        );


    // =====================================================
    // DENTRO DE UNA CORRIENTE
    // =====================================================

    if (
        _wind != noone
        &&
        instance_exists(_wind)
    )
    {
        _sil.fan_detached =
            true;

        _sil.fan_detached_room =
            room;

        _sil.fan_rejoin_active =
            false;

        _sil.fan_rejoin_walk_armed =
            false;

        _sil.fan_outside_frames =
            0;

        _sil.party_follow_suspended =
            true;


        _sil.fan_detach_last_fan =
            _wind;

        _sil.fan_detach_dir_x =
            _wind.fan_direction_x;

        _sil.fan_detach_dir_y =
            _wind.fan_direction_y;


        // =================================================
        // FUERZA
        // =================================================

        var _force =
            max(
                0,
                abs(
                    _wind.fan_force
                )
            );


        _sil.fan_detach_push_accum +=
            _force;


        var _steps =
            floor(
                _sil.fan_detach_push_accum
            );


        _sil.fan_detach_push_accum -=
            _steps;


        var _dir_x =
            _sil.fan_detach_dir_x;

        var _dir_y =
            _sil.fan_detach_dir_y;


        // =================================================
        // EMPUJE PÍXEL A PÍXEL
        // =================================================

        for (
            var _i = 0;
            _i < _steps;
            _i++
        )
        {
            var _next_x =
                _sil.x
                +
                _dir_x;

            var _next_y =
                _sil.y
                +
                _dir_y;


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
                _sil.fan_detach_push_accum =
                    0;

                break;
            }


            _sil.x =
                _next_x;

            _sil.y =
                _next_y;
        }


        // =================================================
        // ¿ACABA DE SALIR?
        // =================================================
        //
        // En el MISMO End Step en que su hitbox deja de tocar
        // el rectángulo, lo lanzamos unos píxeles extra.
        //
        // Esto garantiza que NO se quede pegado a la frontera.
        // =================================================

        if (
            !scr_fan_actor_in_wind(
                _wind,
                _sil
            )
        )
        {
            var _extra =
                (
                    variable_instance_exists(
                        _wind,
                        "fan_silicio_eject_extra"
                    )
                    ?
                    max(
                        0,
                        round(
                            _wind.fan_silicio_eject_extra
                        )
                    )
                    :
                    24
                );


            for (
                var _ej = 0;
                _ej < _extra;
                _ej++
            )
            {
                var _extra_x =
                    _sil.x
                    +
                    _dir_x;

                var _extra_y =
                    _sil.y
                    +
                    _dir_y;


                if (
                    scr_fan_actor_blocked(
                        _sil,
                        _extra_x,
                        _extra_y,
                        _dir_x,
                        _dir_y
                    )
                )
                {
                    break;
                }


                _sil.x =
                    _extra_x;

                _sil.y =
                    _extra_y;
            }


            _sil.fan_detach_push_accum =
                0;
        }


        // =================================================
        // EL VIENTO NO ES "CAMINAR"
        // =================================================

        _sil.platform_sil_move_x =
            0;

        _sil.platform_sil_move_y =
            0;

        _sil.platform_sil_vsp =
            0;

        _sil.movimiento =
            false;


        _sil.platform_sil_grounded =
            scr_platformer_floor_at(
                _sil.x,
                _sil.y + 1,
                _sil.platform_sil_hit_left,
                _sil.platform_sil_hit_top,
                _sil.platform_sil_hit_right,
                _sil.platform_sil_hit_bottom
            );


        var _wind_face =
            (
                variable_instance_exists(
                    _sil,
                    "platform_sil_facing"
                )
                ?
                _sil.platform_sil_facing
                :
                1
            );


        scr_platformer_silicio_apply_extended_sprite(
            _sil,
            (
                _sil.platform_sil_grounded
                ?
                "idle"
                :
                "jump"
            ),
            _wind_face
        );


        // SIEMPRE quieto durante la corriente.
        _sil.image_index =
            0;

        _sil.image_speed =
            0;


        return true;
    }


    // =====================================================
    // NO ESTÁ EN VIENTO
    // =====================================================

    if (!_sil.fan_detached)
    {
        _sil.party_follow_suspended =
            false;

        return false;
    }


    // Sigue separado del follower hasta reincorporarse.
    _sil.party_follow_suspended =
        true;


    _sil.fan_outside_frames++;


    _sil.platform_sil_move_x =
        0;

    _sil.platform_sil_move_y =
        0;

    _sil.platform_sil_vsp =
        0;

    _sil.movimiento =
        false;


    _sil.platform_sil_grounded =
        scr_platformer_floor_at(
            _sil.x,
            _sil.y + 1,
            _sil.platform_sil_hit_left,
            _sil.platform_sil_hit_top,
            _sil.platform_sil_hit_right,
            _sil.platform_sil_hit_bottom
        );


    // =====================================================
    // ESPERAR A QUE MAYA SE DETENGA Y VUELVA A CAMINAR
    // =====================================================

    var _maya_walking =
        (
            variable_instance_exists(
                _p,
                "platform_hsp"
            )
            &&
            abs(
                _p.platform_hsp
            )
            >
            0.20
            &&
            variable_instance_exists(
                _p,
                "platform_grounded"
            )
            &&
            _p.platform_grounded
        );


    if (!_sil.fan_rejoin_active)
    {
        if (
            _sil.fan_outside_frames >= 1
            &&
            !_maya_walking
        )
        {
            _sil.fan_rejoin_walk_armed =
                true;
        }


        if (
            !_sil.fan_rejoin_walk_armed
            ||
            !_maya_walking
        )
        {
            var _waiting_face =
                (
                    variable_instance_exists(
                        _sil,
                        "platform_sil_facing"
                    )
                    ?
                    _sil.platform_sil_facing
                    :
                    1
                );


            scr_platformer_silicio_apply_extended_sprite(
                _sil,
                (
                    _sil.platform_sil_grounded
                    ?
                    "idle"
                    :
                    "jump"
                ),
                _waiting_face
            );


            _sil.image_index =
                0;

            _sil.image_speed =
                0;


            return true;
        }


        _sil.fan_rejoin_active =
            true;
    }


    // =====================================================
    // REINCORPORACIÓN
    // =====================================================

    var _p_facing =
        (
            variable_instance_exists(
                _p,
                "platform_facing"
            )
            &&
            _p.platform_facing < 0
            ?
            -1
            :
            1
        );


    var _player_feet_x =
        _p.x
        +
        (
            (
                _p.platform_hit_left
                +
                _p.platform_hit_right
            )
            *
            0.5
        );


    var _player_feet_y =
        _p.y
        +
        _p.platform_hit_bottom;


    var _target_x =
        _player_feet_x
        -
        (
            _p_facing
            *
            _sil.fan_rejoin_follow_distance
        );


    var _target_y =
        _player_feet_y
        -
        _sil.platform_sil_hit_bottom;


    var _speed =
        max(
            1,
            round(
                _sil.fan_rejoin_speed
            )
        );


    var _old_x =
        _sil.x;

    var _old_y =
        _sil.y;


    scr_fan_silicio_rejoin_axis_x(
        _sil,
        _target_x,
        _speed
    );


    scr_fan_silicio_rejoin_axis_y(
        _sil,
        _target_y,
        _speed
    );


    var _move_x =
        _sil.x
        -
        _old_x;

    var _move_y =
        _sil.y
        -
        _old_y;


    _sil.platform_sil_move_x =
        _move_x;

    _sil.platform_sil_move_y =
        _move_y;

    _sil.platform_sil_vsp =
        _move_y;

    _sil.movimiento =
        (
            abs(_move_x) > 0.001
            ||
            abs(_move_y) > 0.001
        );


    _sil.platform_sil_grounded =
        scr_platformer_floor_at(
            _sil.x,
            _sil.y + 1,
            _sil.platform_sil_hit_left,
            _sil.platform_sil_hit_top,
            _sil.platform_sil_hit_right,
            _sil.platform_sil_hit_bottom
        );


    var _visual_state =
        (
            _sil.platform_sil_grounded
            ?
            (
                abs(_move_x) > 0.20
                ?
                "run"
                :
                "idle"
            )
            :
            "jump"
        );


    var _visual_facing =
        (
            abs(_move_x) > 0.20
            ?
            sign(_move_x)
            :
            _p_facing
        );


    scr_platformer_silicio_apply_extended_sprite(
        _sil,
        _visual_state,
        _visual_facing
    );


    // Si la reincorporación ocurre en el aire, frame fijo.
    if (!_sil.platform_sil_grounded)
    {
        _sil.image_index =
            0;

        _sil.image_speed =
            0;
    }


    _sil.depth =
        _p.depth
        +
        1;


    _sil.platform_sil_prev_x =
        _sil.x;

    _sil.platform_sil_prev_y =
        _sil.y;


    // =====================================================
    // FIN DE REINCORPORACIÓN
    // =====================================================

    if (
        point_distance(
            _sil.x,
            _sil.y,
            _target_x,
            _target_y
        )
        <=
        4
    )
    {
        _sil.fan_detached =
            false;

        _sil.fan_rejoin_active =
            false;

        _sil.fan_rejoin_walk_armed =
            false;

        _sil.fan_outside_frames =
            0;

        _sil.fan_detach_push_accum =
            0;

        _sil.party_follow_suspended =
            false;


        scr_fan_silicio_reset_platform_history(
            _p
        );
    }


    return true;
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


    // La misma zona sirve para dibujo y física.
    scr_fan_update_zone(
        _fan
    );


    if (!_fan.fan_enabled)
    {
        _fan.fan_push_accum =
            0;

        _fan.fan_push_accum_maya =
            0;

        _fan.fan_push_accum_silicio =
            0;

        return false;
    }


    if (!scr_fan_world_free())
    {
        _fan.fan_push_accum =
            0;

        _fan.fan_push_accum_maya =
            0;

        _fan.fan_push_accum_silicio =
            0;

        return false;
    }


    var _moved_maya =
        false;

    var _moved_silicio =
        false;


    // =====================================================
    // MAYA
    // =====================================================

    if (instance_exists(obj_player))
    {
        var _p =
            instance_find(
                obj_player,
                0
            );


        _moved_maya =
            scr_fan_push_actor(
                _fan,
                _p,
                "fan_push_accum_maya",
                true
            );
    }
    else
    {
        _fan.fan_push_accum_maya =
            0;
    }


    // Mantener el acumulador antiguo sincronizado con Maya por
    // compatibilidad con cualquier código/debug previo.
    _fan.fan_push_accum =
        _fan.fan_push_accum_maya;


    // =====================================================
    // SILICIO
    // =====================================================
    //
    // IMPORTANTE:
    //
    // YA NO se mueve a Silicio desde el Step del abanico.
    //
    // Su corriente se procesa en:
    //
    //     obj_settings -> End Step
    //         scr_fan_silicio_detach_update()
    //
    // Esto hace que:
    //
    //     detectar corriente
    //     cancelar follower
    //     empujar
    //     congelar sprite
    //     expulsar
    //
    // ocurra TODO en el mismo controlador y en el mismo momento
    // del frame.
    // =====================================================

    _fan.fan_push_accum_silicio =
        0;


    var _moved_silicio =
        false;


    return
        _moved_maya
        ||
        _moved_silicio;
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
