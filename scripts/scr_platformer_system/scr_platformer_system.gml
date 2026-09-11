/// =========================================================
/// SCR_PLATFORMER_SYSTEM
/// =========================================================
///
/// Modo plataformero para DESVELO.
///
/// CONTROLES:
///
///     Izquierda / Derecha
///         movimiento
///
///     Z / Enter
///         salto
///
///     X / Shift
///         ataque melee
///
/// El sistema usa "colision" como:
///
///     suelo
///     paredes
///     techo
///
/// IMPORTANTE:
///
/// La fisica NO depende de la mascara del sprite de Maya.
/// Usa un rectangulo propio, asi cambiar de sprite no rompe
/// suelo / paredes / techo.
/// =========================================================


// =========================================================
// UTILIDADES
// =========================================================

function scr_platformer_approach(
    _value,
    _target,
    _amount
)
{
    if (_value < _target)
    {
        return min(
            _value + _amount,
            _target
        );
    }


    if (_value > _target)
    {
        return max(
            _value - _amount,
            _target
        );
    }


    return _target;
}


// =========================================================
// BUSCAR SPRITE OPCIONAL
// =========================================================
//
// Permite instalar el codigo ANTES de crear el arte.
//
// Si el sprite no existe, se usa el fallback.
// =========================================================

function scr_platformer_sprite(
    _name,
    _fallback
)
{
    var _asset =
        asset_get_index(
            _name
        );


    if (
        _asset != -1
        &&
        sprite_exists(_asset)
    )
    {
        return _asset;
    }


    return _fallback;
}


// =========================================================
// COLISION RECTANGULAR UNIVERSAL
// =========================================================
//
// _x / _y:
//     posicion de la instancia.
//
// offsets:
//     caja respecto a esa posicion.
//
// De esta forma NO dependemos de bbox/mask del sprite actual.
// =========================================================

function scr_platformer_collision_at(
    _x,
    _y,
    _left,
    _top,
    _right,
    _bottom
)
{
    return
        collision_rectangle(
            _x + _left,
            _y + _top,
            _x + _right,
            _y + _bottom,
            colision,
            false,
            true
        )
        !=
        noone;
}


// =========================================================
// GLOBAL
// =========================================================

function scr_platformer_init()
{
    if (
        !variable_global_exists(
            "platformer_active"
        )
    )
    {
        global.platformer_active =
            false;
    }


    // =====================================================
    // CONTROLES EXCLUSIVOS DEL PLATAFORMERO
    // =====================================================
    //
    // false:
    //     saltar = Z / Enter
    //     atacar = X / Shift
    //
    // true:
    //     saltar = X / Shift
    //     atacar = Z / Enter
    //
    // Esto NO toca el remapeo global del juego.
    // El menu de pausa sigue usando Z para confirmar y X
    // para volver.
    // =====================================================

    if (
        !variable_global_exists(
            "platformer_controls_swapped"
        )
    )
    {
        global.platformer_controls_swapped =
            false;
    }


    // =====================================================
    // CAMBIO DE MODO PENDIENTE ENTRE ROOMS
    // =====================================================
    //
    // El trigger NO cambia el modo en la room de origen.
    //
    // Solo deja pendiente el cambio y obj_player lo aplica
    // cuando YA estamos dentro de la room destino.
    // =====================================================

    if (
        !variable_global_exists(
            "platformer_mode_pending"
        )
    )
    {
        global.platformer_mode_pending =
            false;
    }


    if (
        !variable_global_exists(
            "platformer_mode_pending_enable"
        )
    )
    {
        global.platformer_mode_pending_enable =
            false;
    }


    if (
        !variable_global_exists(
            "platformer_mode_pending_room"
        )
    )
    {
        global.platformer_mode_pending_room =
            -1;
    }


    if (
        !variable_global_exists(
            "platformer_mode_pending_facing"
        )
    )
    {
        global.platformer_mode_pending_facing =
            1;
    }
}

// =========================================================
// INPUT EXCLUSIVO DEL PLATAFORMERO
// =========================================================

function scr_platformer_jump_pressed()
{
    scr_platformer_init();


    if (global.platformer_controls_swapped)
    {
        return
        (
            keyboard_check_pressed(
                ord("X")
            )
            ||
            keyboard_check_pressed(
                vk_shift
            )
        );
    }


    return
    (
        keyboard_check_pressed(
            ord("Z")
        )
        ||
        keyboard_check_pressed(
            vk_enter
        )
    );
}


function scr_platformer_jump_held()
{
    scr_platformer_init();


    if (global.platformer_controls_swapped)
    {
        return
        (
            keyboard_check(
                ord("X")
            )
            ||
            keyboard_check(
                vk_shift
            )
        );
    }


    return
    (
        keyboard_check(
            ord("Z")
        )
        ||
        keyboard_check(
            vk_enter
        )
    );
}


function scr_platformer_attack_pressed()
{
    scr_platformer_init();


    if (global.platformer_controls_swapped)
    {
        return
        (
            keyboard_check_pressed(
                ord("Z")
            )
            ||
            keyboard_check_pressed(
                vk_enter
            )
        );
    }


    return
    (
        keyboard_check_pressed(
            ord("X")
        )
        ||
        keyboard_check_pressed(
            vk_shift
        )
    );
}


function scr_platformer_toggle_controls()
{
    scr_platformer_init();


    global.platformer_controls_swapped =
        !global.platformer_controls_swapped;


    return
        global.platformer_controls_swapped;
}


// =========================================================
// CAMBIO DE MODO DESPUES DEL ROOM_GOTO
// =========================================================

function scr_platformer_queue_mode_change(
    _enabled,
    _target_room,
    _start_facing = 1
)
{
    scr_platformer_init();


    global.platformer_mode_pending =
        true;


    global.platformer_mode_pending_enable =
        _enabled;


    global.platformer_mode_pending_room =
        _target_room;


    global.platformer_mode_pending_facing =
        (
            _start_facing < 0
            ?
            -1
            :
            1
        );


    return true;
}


function scr_platformer_apply_pending_mode()
{
    scr_platformer_init();


    if (!global.platformer_mode_pending)
    {
        return false;
    }


    if (
        room
        !=
        global.platformer_mode_pending_room
    )
    {
        return false;
    }


    var _enable =
        global.platformer_mode_pending_enable;


    var _facing =
        global.platformer_mode_pending_facing;


    // Limpiar ANTES de aplicar para que jamás se repita
    // accidentalmente si algún código cambia de room.
    global.platformer_mode_pending =
        false;


    global.platformer_mode_pending_room =
        -1;


    scr_platformer_set_mode(
        _enable
    );


    if (
        _enable
        &&
        instance_exists(obj_player)
    )
    {
        var _p =
            instance_find(
                obj_player,
                0
            );


        if (
            variable_instance_exists(
                _p,
                "platform_facing"
            )
        )
        {
            _p.platform_facing =
                _facing;
        }
    }


    return true;
}


// =========================================================
// ACTIVAR UN WARP DEL PLATAFORMERO
// =========================================================

function scr_platformer_warp_activate(
    _warp
)
{
    if (
        _warp == noone
        ||
        !instance_exists(_warp)
    )
    {
        return false;
    }


    if (
        !variable_instance_exists(
            _warp,
            "active"
        )
        ||
        !_warp.active
    )
    {
        return false;
    }


    if (
        variable_instance_exists(
            _warp,
            "interaction_locked"
        )
        &&
        _warp.interaction_locked
    )
    {
        return false;
    }


    if (
        !variable_instance_exists(
            _warp,
            "target_room"
        )
        ||
        _warp.target_room == noone
        ||
        _warp.target_room == -1
    )
    {
        return false;
    }


    if (instance_exists(obj_warp))
    {
        return false;
    }


    _warp.interaction_locked =
        true;


    var _enable =
        (
            variable_instance_exists(
                _warp,
                "platformer_enable"
            )
            ?
            _warp.platformer_enable
            :
            true
        );


    var _start_facing =
        (
            variable_instance_exists(
                _warp,
                "platformer_start_facing"
            )
            ?
            _warp.platformer_start_facing
            :
            1
        );


    // IMPORTANTE:
    //
    // Todavía NO tocamos global.platformer_active.
    //
    // El sprite y la física cambiarán únicamente cuando
    // obj_player detecte que YA estamos en target_room.
    scr_platformer_queue_mode_change(
        _enable,
        _warp.target_room,
        _start_facing
    );


    var _transition =
        instance_create_depth(
            0,
            0,
            -9999,
            obj_warp
        );


    _transition.target_x =
        _warp.target_x;


    _transition.target_y =
        _warp.target_y;


    _transition.target_rm =
        _warp.target_room;


    _transition.target_face =
        _warp.target_face;


    _transition.target_music =
        _warp.target_music;


    _transition.keep_music =
        _warp.keep_music;


    _transition.target_cutscene =
        "";


    _transition.target_cutscene_once =
        true;


    return true;
}


// =========================================================
// TRAMPOLINES
// =========================================================
//
// Devuelve el trampolín cuya SUPERFICIE superior está
// tocando la hitbox indicada.
//
// Es one-way:
// solo funciona como suelo desde arriba.
// =========================================================

function scr_platformer_trampoline_at(
    _x,
    _y,
    _left,
    _top,
    _right,
    _bottom
)
{
    var _trampoline_obj =
        asset_get_index(
            "obj_platformer_trampolin"
        );


    if (_trampoline_obj == -1)
    {
        return noone;
    }


    var _player_left =
        _x + _left;


    var _player_top =
        _y + _top;


    var _player_right =
        _x + _right;


    var _player_bottom =
        _y + _bottom;


    var _count =
        instance_number(
            _trampoline_obj
        );


    for (
        var _i = 0;
        _i < _count;
        _i++
    )
    {
        var _tr =
            instance_find(
                _trampoline_obj,
                _i
            );


        if (
            _tr == noone
            ||
            !instance_exists(_tr)
        )
        {
            continue;
        }


        if (
            variable_instance_exists(
                _tr,
                "active"
            )
            &&
            !_tr.active
        )
        {
            continue;
        }


        var _left_tr;
        var _right_tr;
        var _top_tr;
        var _bottom_tr;


        if (
            _tr.sprite_index != -1
            &&
            sprite_exists(
                _tr.sprite_index
            )
        )
        {
            _left_tr =
                _tr.bbox_left;


            _right_tr =
                _tr.bbox_right;


            _top_tr =
                _tr.bbox_top;


            _bottom_tr =
                _tr.bbox_bottom;
        }
        else
        {
            var _half_w =
                16;


            var _height =
                8;


            if (
                variable_instance_exists(
                    _tr,
                    "trampoline_half_width"
                )
            )
            {
                _half_w =
                    max(
                        1,
                        _tr.trampoline_half_width
                    );
            }


            if (
                variable_instance_exists(
                    _tr,
                    "trampoline_height"
                )
            )
            {
                _height =
                    max(
                        1,
                        _tr.trampoline_height
                    );
            }


            _left_tr =
                _tr.x - _half_w;


            _right_tr =
                _tr.x + _half_w;


            _top_tr =
                _tr.y;


            _bottom_tr =
                _tr.y + _height;
        }


        var _surface_margin =
            2;


        if (
            variable_instance_exists(
                _tr,
                "surface_margin"
            )
        )
        {
            _surface_margin =
                max(
                    1,
                    _tr.surface_margin
                );
        }


        var _horizontal_overlap =
        (
            _player_right
            >=
            _left_tr

            &&

            _player_left
            <=
            _right_tr
        );


        var _touching_surface =
        (
            _player_top
            <
            _top_tr

            &&

            _player_bottom
            >=
            _top_tr

            &&

            _player_bottom
            <=
            _top_tr
            +
            _surface_margin
        );


        if (
            _horizontal_overlap
            &&
            _touching_surface
        )
        {
            return _tr;
        }
    }


    return noone;
}


// =========================================================
// PLATAFORMA TRASPASABLE DESDE ABAJO
// =========================================================
//
// Objeto:
//
//     obj_colision_platformer_traspasar
//
// Comportamiento:
//
//     subir:
//         se atraviesa.
//
//     bajar:
//         funciona como suelo.
//
//     lados:
//         nunca bloquea.
//
// Sirve tanto para Maya como para Silicio.
// =========================================================

function scr_platformer_oneway_at(
    _x,
    _y,
    _left,
    _top,
    _right,
    _bottom
)
{
    var _platform_obj =
        asset_get_index(
            "obj_colision_platformer_traspasar"
        );


    if (_platform_obj == -1)
    {
        return noone;
    }


    var _player_left =
        _x + _left;


    var _player_top =
        _y + _top;


    var _player_right =
        _x + _right;


    var _player_bottom =
        _y + _bottom;


    var _count =
        instance_number(
            _platform_obj
        );


    for (
        var _i = 0;
        _i < _count;
        _i++
    )
    {
        var _pl =
            instance_find(
                _platform_obj,
                _i
            );


        if (
            _pl == noone
            ||
            !instance_exists(_pl)
        )
        {
            continue;
        }


        if (
            variable_instance_exists(
                _pl,
                "active"
            )
            &&
            !_pl.active
        )
        {
            continue;
        }


        var _left_pl;
        var _right_pl;
        var _top_pl;
        var _bottom_pl;


        // Si tiene sprite/máscara, usamos el bbox real.
        // Esto respeta image_xscale / image_yscale.
        if (
            _pl.sprite_index != -1
            &&
            sprite_exists(
                _pl.sprite_index
            )
        )
        {
            _left_pl =
                _pl.bbox_left;


            _right_pl =
                _pl.bbox_right;


            _top_pl =
                _pl.bbox_top;


            _bottom_pl =
                _pl.bbox_bottom;
        }
        else
        {
            // Fallback para poder probarla incluso sin sprite.
            var _width =
                32;


            var _height =
                8;


            if (
                variable_instance_exists(
                    _pl,
                    "platform_width"
                )
            )
            {
                _width =
                    max(
                        1,
                        _pl.platform_width
                    );
            }


            if (
                variable_instance_exists(
                    _pl,
                    "platform_height"
                )
            )
            {
                _height =
                    max(
                        1,
                        _pl.platform_height
                    );
            }


            _left_pl =
                _pl.x
                -
                (_width * 0.5);


            _right_pl =
                _pl.x
                +
                (_width * 0.5);


            // En el fallback "y" representa la superficie.
            _top_pl =
                _pl.y;


            _bottom_pl =
                _pl.y + _height;
        }


        var _surface_margin =
            2;


        if (
            variable_instance_exists(
                _pl,
                "surface_margin"
            )
        )
        {
            _surface_margin =
                max(
                    1,
                    _pl.surface_margin
                );
        }


        var _horizontal_overlap =
        (
            _player_right
            >=
            _left_pl

            &&

            _player_left
            <=
            _right_pl
        );


        // Solo cuenta cuando los PIES están entrando en la
        // cara superior desde arriba.
        //
        // Si el cuerpo está atravesando desde abajo,
        // _player_bottom queda demasiado por debajo del
        // margen y no bloquea.
        var _touching_surface =
        (
            _player_top
            <
            _top_pl

            &&

            _player_bottom
            >=
            _top_pl

            &&

            _player_bottom
            <=
            _top_pl
            +
            _surface_margin
        );


        if (
            _horizontal_overlap
            &&
            _touching_surface
        )
        {
            return _pl;
        }
    }


    return noone;
}


function scr_platformer_floor_at(
    _x,
    _y,
    _left,
    _top,
    _right,
    _bottom
)
{
    if (
        scr_platformer_collision_at(
            _x,
            _y,
            _left,
            _top,
            _right,
            _bottom
        )
    )
    {
        return true;
    }


    if (
        scr_platformer_trampoline_at(
            _x,
            _y,
            _left,
            _top,
            _right,
            _bottom
        )
        !=
        noone
    )
    {
        return true;
    }


    return
        scr_platformer_oneway_at(
            _x,
            _y,
            _left,
            _top,
            _right,
            _bottom
        )
        !=
        noone;
}



// =========================================================
// PREPARAR MAYA
// =========================================================
//
// Se ejecuta desde obj_player.
// =========================================================

function scr_platformer_player_prepare()
{
    if (
        !variable_instance_exists(
            id,
            "platformer_ready"
        )
    )
    {
        platformer_ready =
            true;


        platformer_mode_applied =
            false;


        platformer_prev_puede_moverse =
            true;


        // ---------------------------------------------
        // FISICA
        // ---------------------------------------------

        platform_hsp =
            0;


        platform_vsp =
            0;


        platform_x_rem =
            0;


        platform_y_rem =
            0;


        platform_facing =
            1;


        platform_grounded =
            false;


        platform_coyote =
            0;


        platform_jump_buffer =
            0;


        // 30 FPS.
        platform_run_speed =
            5.0;


        platform_ground_accel =
            0.85;


        platform_air_accel =
            0.48;


        platform_friction =
            0.80;


        platform_gravity =
            0.65;


        platform_max_fall =
            12;


        platform_jump_speed =
            -10.5;


        platform_jump_cut_speed =
            -4.5;


        platform_coyote_max =
            3;


        platform_jump_buffer_max =
            3;


        // ---------------------------------------------
        // SENTON
        // ---------------------------------------------
        //
        // En el aire:
        //
        //     ABAJO + botón de SALTO
        //
        // acelera la caída.
        //
        // Si golpea un obj_platformer_trampolin:
        // rebota con mucha más fuerza.
        // ---------------------------------------------

        platform_stomp_active =
            false;


        platform_stomp_available =
            false;


        platform_stomp_start_speed =
            12;


        platform_stomp_gravity =
            1.65;


        platform_stomp_max_fall =
            18;


        // ---------------------------------------------
        // HITBOX FISICA
        // ---------------------------------------------
        //
        // Maya actual:
        //
        //     23 x 47
        //     origin 0,0
        //
        // La mascara RPG actual solo cubre los pies.
        //
        // Para un plataformero necesitamos CUERPO COMPLETO
        // para poder golpearnos la cabeza con el techo.
        // ---------------------------------------------

        platform_hit_left =
            3;


        platform_hit_top =
            2;


        platform_hit_right =
            19;


        platform_hit_bottom =
            45;


        // ---------------------------------------------
        // ATAQUE
        // ---------------------------------------------

        platform_attack_damage =
            1;


        platform_attack_range =
            34;


        platform_attack_vertical_margin =
            3;


        platform_attack_cooldown =
            0;


        platform_attack_cooldown_max =
            8;


        platform_attack_timer =
            0;


        platform_attack_timer_max =
            5;


        platform_attack_serial =
            0;


        platform_attack_left =
            0;


        platform_attack_top =
            0;


        platform_attack_right =
            0;


        platform_attack_bottom =
            0;


        platform_attack_direction =
            "horizontal";


        // ---------------------------------------------
        // POGO / REBOTE SOBRE ENEMIGO FLOTANTE
        // ---------------------------------------------

        platform_pogo_bounce_speed =
            -18.0;


        // ---------------------------------------------
        // SPRITES / ESCALA
        // ---------------------------------------------

        platform_saved_image_xscale =
            image_xscale;


        platform_saved_image_yscale =
            image_yscale;
    }
}


// =========================================================
// ENTRAR EN MODO PLATAFORMERO - MAYA
// =========================================================
//
// Se ejecuta desde obj_player.
// =========================================================

function scr_platformer_player_enter()
{
    scr_platformer_player_prepare();


    if (platformer_mode_applied)
    {
        puede_moverse =
            false;

        return;
    }


    platformer_mode_applied =
        true;


    platformer_prev_puede_moverse =
        puede_moverse;


    platform_saved_image_xscale =
        image_xscale;


    platform_saved_image_yscale =
        image_yscale;


    // El Step RPG normal NO debe mover a Maya.
    puede_moverse =
        false;


    movimiento =
        false;


    hsp =
        0;


    vsp =
        0;


    hspeed =
        0;


    vspeed =
        0;


    speed =
        0;


    platform_hsp =
        0;


    platform_vsp =
        0;


    platform_x_rem =
        0;


    platform_y_rem =
        0;


    platform_coyote =
        0;


    platform_jump_buffer =
        0;


    platform_attack_cooldown =
        0;


    platform_attack_timer =
        0;


    platform_stomp_active =
        false;


    platform_stomp_available =
        false;


    // Empezar mirando según la última dirección normal.
    if (
        variable_instance_exists(
            id,
            "facing_direction"
        )
    )
    {
        if (facing_direction == 1)
        {
            platform_facing =
                -1;
        }
        else if (facing_direction == 0)
        {
            platform_facing =
                1;
        }
    }
}


// =========================================================
// SALIR DEL MODO PLATAFORMERO - MAYA
// =========================================================

function scr_platformer_player_leave()
{
    scr_platformer_player_prepare();


    if (!platformer_mode_applied)
    {
        return;
    }


    platformer_mode_applied =
        false;


    puede_moverse =
        platformer_prev_puede_moverse;


    platform_hsp =
        0;


    platform_vsp =
        0;


    platform_x_rem =
        0;


    platform_y_rem =
        0;


    platform_attack_timer =
        0;


    platform_attack_cooldown =
        0;


    platform_stomp_active =
        false;


    platform_stomp_available =
        false;


    image_xscale =
        platform_saved_image_xscale;


    image_yscale =
        platform_saved_image_yscale;


    // Volver inmediatamente a un sprite normal lateral.
    if (platform_facing < 0)
    {
        direccion =
            "izquierda";


        face =
            LEFT;


        facing_direction =
            1;


        sprite_index =
            pendejo_izquierda;
    }
    else
    {
        direccion =
            "derecha";


        face =
            RIGHT;


        facing_direction =
            0;


        sprite_index =
            pendejo_derecha;
    }


    image_index =
        0;


    image_speed =
        0;
}


// =========================================================
// ACTIVAR / DESACTIVAR GLOBALMENTE
// =========================================================

function scr_platformer_set_mode(
    _enabled
)
{
    scr_platformer_init();


    global.platformer_active =
        _enabled;


    if (instance_exists(obj_player))
    {
        var _p =
            instance_find(
                obj_player,
                0
            );


        if (_enabled)
        {
            with (_p)
            {
                scr_platformer_player_enter();
            }
        }
        else
        {
            with (_p)
            {
                scr_platformer_player_leave();
            }
        }
    }


    // Silicio se prepara/restaura desde su End Step.
    // Esto permite que también funcione si aparece después
    // de haber cambiado de room.


    return global.platformer_active;
}


// =========================================================
// ¿ESTAMOS TOCANDO UN WARP DE PLATAFORMERO?
// =========================================================
//
// Evita que Z haga un salto justo al mismo tiempo que se usa
// para salir del modo.
/// =========================================================

function scr_platformer_jump_blocked_by_warp()
{
    var _warp_obj =
        asset_get_index(
            "obj_platformer_warp"
        );


    if (_warp_obj == -1)
    {
        return false;
    }


    var _count =
        instance_number(
            _warp_obj
        );


    for (
        var _i = 0;
        _i < _count;
        _i++
    )
    {
        var _w =
            instance_find(
                _warp_obj,
                _i
            );


        if (
            _w == noone
            ||
            !instance_exists(_w)
        )
        {
            continue;
        }


        var _range =
            48;


        if (
            variable_instance_exists(
                _w,
                "interaction_distance"
            )
        )
        {
            _range =
                _w.interaction_distance;
        }


        var _cx =
            x
            +
            (
                platform_hit_left
                +
                platform_hit_right
            )
            *
            0.5;


        var _cy =
            y
            +
            (
                platform_hit_top
                +
                platform_hit_bottom
            )
            *
            0.5;


        if (
            point_distance(
                _cx,
                _cy,
                _w.x,
                _w.y
            )
            <=
            _range
        )
        {
            return true;
        }
    }


    return false;
}


// =========================================================
// ¿EL ENEMIGO ESTÁ FLOTANDO?
// =========================================================
//
// Por defecto se considera flotante si NO tiene suelo sólido
// ni plataforma one-way inmediatamente debajo.
//
// Puedes forzarlo en una instancia:
//
//     platform_floating = true;
//
// o:
//
//     platform_floating = false;
// =========================================================

function scr_platformer_enemy_is_floating(
    _enemy
)
{
    if (
        _enemy == noone
        ||
        !instance_exists(_enemy)
    )
    {
        return false;
    }


    if (
        variable_instance_exists(
            _enemy,
            "platform_floating"
        )
    )
    {
        return _enemy.platform_floating;
    }


    var _probe_top =
        _enemy.bbox_bottom + 1;


    var _probe_bottom =
        _enemy.bbox_bottom + 4;


    // Suelo sólido normal.
    if (
        collision_rectangle(
            _enemy.bbox_left,
            _probe_top,
            _enemy.bbox_right,
            _probe_bottom,
            colision,
            false,
            true
        )
        !=
        noone
    )
    {
        return false;
    }


    // Plataforma one-way.
    var _oneway_obj =
        asset_get_index(
            "obj_colision_platformer_traspasar"
        );


    if (_oneway_obj != -1)
    {
        if (
            collision_rectangle(
                _enemy.bbox_left,
                _probe_top,
                _enemy.bbox_right,
                _probe_bottom,
                _oneway_obj,
                false,
                true
            )
            !=
            noone
        )
        {
            return false;
        }
    }


    return true;
}


// =========================================================
// MUERTE ENEMIGO PLATAFORMERO
// =========================================================
//
// Ya NO se destruye de golpe.
//
// Durante 15 frames:
//     - deja de atacar;
//     - deja de moverse;
//     - destruye sus proyectiles;
//     - se desvanece;
//
// y al terminar desaparece.
// =========================================================

function scr_platformer_enemy_begin_death(
    _enemy
)
{
    if (
        _enemy == noone
        ||
        !instance_exists(_enemy)
    )
    {
        return false;
    }


    if (
        variable_instance_exists(
            _enemy,
            "platform_dying"
        )
        &&
        _enemy.platform_dying
    )
    {
        return false;
    }


    _enemy.platform_dying =
        true;


    _enemy.platform_can_be_attacked =
        false;


    _enemy.platform_hp =
        0;


    _enemy.platform_death_duration =
        15;


    _enemy.platform_death_timer =
        _enemy.platform_death_duration;


    _enemy.platform_death_alpha_start =
        _enemy.image_alpha;


    // Detener la IA normal sin tocar su Step completo.
    if (
        variable_instance_exists(
            _enemy,
            "en_alerta"
        )
    )
    {
        _enemy.en_alerta =
            false;
    }


    if (
        variable_instance_exists(
            _enemy,
            "puede_moverse"
        )
    )
    {
        _enemy.puede_moverse =
            false;
    }


    if (
        variable_instance_exists(
            _enemy,
            "rango_ataque"
        )
    )
    {
        _enemy.rango_ataque =
            -1;
    }


    if (
        variable_instance_exists(
            _enemy,
            "timer_ataque"
        )
    )
    {
        _enemy.timer_ataque =
            999999;
    }


    _enemy.speed =
        0;


    _enemy.hspeed =
        0;


    _enemy.vspeed =
        0;


    _enemy.image_speed =
        0;


    // Borrar proyectiles que pertenecían al enemigo.
    var _owner_dead =
        _enemy;


    with (obj_proyectil_mapa)
    {
        if (
            owner_enemy
            ==
            _owner_dead
        )
        {
            instance_destroy();
        }
    }


    // Sonido específico solicitado.
    var _death_sound =
        asset_get_index(
            "snd_enemy_defeat_quick"
        );


    if (
        _death_sound != -1
        &&
        audio_exists(_death_sound)
    )
    {
        audio_play_sound(
            _death_sound,
            10,
            false
        );
    }


    return true;
}


// =========================================================
// DAÑO A ENEMIGO DE MAPA
// =========================================================

function scr_platformer_enemy_damage(
    _enemy,
    _damage,
    _attack_serial
)
{
    if (
        _enemy == noone
        ||
        !instance_exists(_enemy)
    )
    {
        return false;
    }


    // -----------------------------------------------------
    // ASEGURAR VIDA
    // -----------------------------------------------------
    //
    // V4:
    //     12 HP por defecto.
    //
    // Sigue pudiendo sobrescribirse por instancia.
    // -----------------------------------------------------

    if (
        !variable_instance_exists(
            _enemy,
            "platform_hp_max"
        )
    )
    {
        _enemy.platform_hp_max =
            12;
    }


    if (
        !variable_instance_exists(
            _enemy,
            "platform_hp"
        )
    )
    {
        _enemy.platform_hp =
            _enemy.platform_hp_max;
    }


    if (
        !variable_instance_exists(
            _enemy,
            "platform_can_be_attacked"
        )
    )
    {
        _enemy.platform_can_be_attacked =
            true;
    }


    if (
        !variable_instance_exists(
            _enemy,
            "platform_last_attack_serial"
        )
    )
    {
        _enemy.platform_last_attack_serial =
            -1;
    }


    if (
        variable_instance_exists(
            _enemy,
            "platform_dying"
        )
        &&
        _enemy.platform_dying
    )
    {
        return false;
    }


    if (!_enemy.platform_can_be_attacked)
    {
        return false;
    }


    // El mismo swing no golpea dos veces al mismo enemigo.
    if (
        _enemy.platform_last_attack_serial
        ==
        _attack_serial
    )
    {
        return false;
    }


    _enemy.platform_last_attack_serial =
        _attack_serial;


    _enemy.platform_hp -=
        max(
            1,
            round(_damage)
        );


    // -----------------------------------------------------
    // MUERTE
    // -----------------------------------------------------

    if (_enemy.platform_hp <= 0)
    {
        scr_screen_shake_start(
            3,
            6
        );


        scr_platformer_enemy_begin_death(
            _enemy
        );


        return true;
    }


    // -----------------------------------------------------
    // IMPACTO NORMAL
    // -----------------------------------------------------

    var _hit_sound =
        asset_get_index(
            "snd_atacado"
        );


    if (
        _hit_sound != -1
        &&
        audio_exists(_hit_sound)
    )
    {
        audio_play_sound(
            _hit_sound,
            10,
            false
        );
    }


    scr_screen_shake_start(
        2,
        4
    );


    return true;
}


// =========================================================
// ATAQUE MELEE DE MAYA
// =========================================================
//
// Se ejecuta desde obj_player.
// =========================================================

function scr_platformer_player_attack()
{
    if (platform_attack_cooldown > 0)
    {
        return;
    }


    platform_attack_cooldown =
        platform_attack_cooldown_max;


    platform_attack_timer =
        platform_attack_timer_max;


    platform_attack_serial++;


    // =====================================================
    // SONIDO DE ATAQUE
    // =====================================================

    var _swing_sound =
        asset_get_index(
            "snd_smallswing"
        );


    if (
        _swing_sound != -1
        &&
        audio_exists(_swing_sound)
    )
    {
        audio_play_sound(
            _swing_sound,
            10,
            false
        );
    }


    // =====================================================
    // DAÑO = AT REAL DE MAYA
    // =====================================================
    //
    // Usa exactamente:
    //
    //     ataque_base + arma equipada
    //
    // mediante get_jugador_ataque().
    // =====================================================

    platform_attack_damage =
        max(
            1,
            round(
                get_jugador_ataque()
            )
        );


    // =====================================================
    // DIRECCIÓN DEL GOLPE
    // =====================================================
    //
    // ARRIBA + ataque:
    //     golpe vertical hacia arriba.
    //
    // ABAJO + ataque:
    //     golpe vertical hacia abajo.
    //
    // Sin dirección vertical:
    //     golpe horizontal según platform_facing.
    // =====================================================

    var _up =
        keyboard_check(
            vk_up
        );


    var _down =
        keyboard_check(
            vk_down
        );


    platform_attack_direction =
        "horizontal";


    if (
        _up
        &&
        !_down
    )
    {
        platform_attack_direction =
            "up";
    }
    else if (
        _down
        &&
        !_up
    )
    {
        platform_attack_direction =
            "down";
    }


    // =====================================================
    // CUERPO DE MAYA
    // =====================================================

    var _body_left =
        x + platform_hit_left;


    var _body_right =
        x + platform_hit_right;


    var _body_top =
        y + platform_hit_top;


    var _body_bottom =
        y + platform_hit_bottom;


    // =====================================================
    // HITBOX HORIZONTAL
    // =====================================================

    if (platform_attack_direction == "horizontal")
    {
        if (platform_facing >= 0)
        {
            platform_attack_left =
                _body_right;


            platform_attack_right =
                _body_right
                +
                platform_attack_range;
        }
        else
        {
            platform_attack_left =
                _body_left
                -
                platform_attack_range;


            platform_attack_right =
                _body_left;
        }


        platform_attack_top =
            _body_top
            -
            platform_attack_vertical_margin;


        platform_attack_bottom =
            _body_bottom
            +
            platform_attack_vertical_margin;
    }

    // =====================================================
    // HITBOX ARRIBA
    // =====================================================

    else if (platform_attack_direction == "up")
    {
        platform_attack_left =
            _body_left
            -
            platform_attack_vertical_margin;


        platform_attack_right =
            _body_right
            +
            platform_attack_vertical_margin;


        platform_attack_top =
            _body_top
            -
            platform_attack_range;


        platform_attack_bottom =
            _body_top;
    }

    // =====================================================
    // HITBOX ABAJO
    // =====================================================

    else
    {
        platform_attack_left =
            _body_left
            -
            platform_attack_vertical_margin;


        platform_attack_right =
            _body_right
            +
            platform_attack_vertical_margin;


        platform_attack_top =
            _body_bottom;


        platform_attack_bottom =
            _body_bottom
            +
            platform_attack_range;
    }


    // =====================================================
    // GOLPEAR ENEMIGOS DE MAPA
    // =====================================================

    with (obj_enemigo_mapa_parent)
    {
        var _overlap =
        (
            bbox_right
            >=
            other.platform_attack_left

            &&

            bbox_left
            <=
            other.platform_attack_right

            &&

            bbox_bottom
            >=
            other.platform_attack_top

            &&

            bbox_top
            <=
            other.platform_attack_bottom
        );


        if (_overlap)
        {
            var _enemy_was_floating =
                scr_platformer_enemy_is_floating(
                    id
                );


            var _did_hit =
                scr_platformer_enemy_damage(
                    id,
                    other.platform_attack_damage,
                    other.platform_attack_serial
                );


            // =================================================
            // POGO / REBOTE DE GOLPE HACIA ABAJO
            // =================================================
            //
            // Maya debe:
            //
            //     - estar en el aire;
            //     - golpear hacia abajo;
            //     - acertar a un enemigo flotante.
            //
            // El resultado es otro salto.
            // =================================================

            if (
                _did_hit
                &&
                _enemy_was_floating
                &&
                other.platform_attack_direction
                ==
                "down"
                &&
                !other.platform_grounded
            )
            {
                other.platform_vsp =
                    other.platform_pogo_bounce_speed;


                other.platform_y_rem =
                    0;


                other.platform_grounded =
                    false;


                other.platform_stomp_active =
                    false;


                // Después del pogo puede volver a hacer sentón.
                other.platform_stomp_available =
                    true;


                other.platform_coyote =
                    0;


                other.platform_jump_buffer =
                    0;
            }
        }
    }


    // =====================================================
    // GOLPEAR TRIGGER DE SALIDA
    // =====================================================
    //
    // Funciona desde cualquiera de las 4 direcciones.
    // =====================================================

    var _warp_obj =
        asset_get_index(
            "obj_platformer_warp"
        );


    if (_warp_obj != -1)
    {
        var _warp_count =
            instance_number(
                _warp_obj
            );


        for (
            var _wi = 0;
            _wi < _warp_count;
            _wi++
        )
        {
            var _w =
                instance_find(
                    _warp_obj,
                    _wi
                );


            if (
                _w == noone
                ||
                !instance_exists(_w)
            )
            {
                continue;
            }


            if (
                !variable_instance_exists(
                    _w,
                    "platformer_enable"
                )
                ||
                _w.platformer_enable
            )
            {
                continue;
            }


            if (
                variable_instance_exists(
                    _w,
                    "active"
                )
                &&
                !_w.active
            )
            {
                continue;
            }


            if (
                variable_instance_exists(
                    _w,
                    "interaction_locked"
                )
                &&
                _w.interaction_locked
            )
            {
                continue;
            }


            var _wl;
            var _wr;
            var _wt;
            var _wb;


            if (
                _w.sprite_index != -1
                &&
                sprite_exists(
                    _w.sprite_index
                )
            )
            {
                _wl =
                    _w.bbox_left;


                _wr =
                    _w.bbox_right;


                _wt =
                    _w.bbox_top;


                _wb =
                    _w.bbox_bottom;
            }
            else
            {
                var _half_w =
                    16;


                var _half_h =
                    24;


                if (
                    variable_instance_exists(
                        _w,
                        "attack_hitbox_half_width"
                    )
                )
                {
                    _half_w =
                        max(
                            1,
                            _w.attack_hitbox_half_width
                        );
                }


                if (
                    variable_instance_exists(
                        _w,
                        "attack_hitbox_half_height"
                    )
                )
                {
                    _half_h =
                        max(
                            1,
                            _w.attack_hitbox_half_height
                        );
                }


                _wl =
                    _w.x - _half_w;


                _wr =
                    _w.x + _half_w;


                _wt =
                    _w.y - _half_h;


                _wb =
                    _w.y + _half_h;
            }


            var _warp_overlap =
            (
                _wr
                >=
                platform_attack_left

                &&

                _wl
                <=
                platform_attack_right

                &&

                _wb
                >=
                platform_attack_top

                &&

                _wt
                <=
                platform_attack_bottom
            );


            if (_warp_overlap)
            {
                scr_platformer_warp_activate(
                    _w
                );


                break;
            }
        }
    }


    // =====================================================
    // EFECTO VISUAL
    // =====================================================

    var _fx_obj =
        asset_get_index(
            "obj_platformer_attack_fx"
        );


    if (_fx_obj != -1)
    {
        var _fx =
            instance_create_depth(
                x,
                y,
                depth - 1,
                _fx_obj
            );


        _fx.owner =
            id;


        _fx.facing =
            platform_facing;


        _fx.attack_direction =
            platform_attack_direction;


        _fx.life =
            platform_attack_timer_max;
    }
}


// =========================================================
// FISICA DE MAYA
// =========================================================
//
// Se ejecuta desde obj_player -> Begin Step.
// =========================================================

function scr_platformer_player_update()
{
    scr_platformer_player_prepare();


    puede_moverse =
        false;


    movimiento =
        false;


    hsp =
        0;


    vsp =
        0;


    hspeed =
        0;


    vspeed =
        0;


    speed =
        0;


    // =====================================================
    // BLOQUEOS DEL MUNDO / MENÚ NO PAUSABLE
    // =====================================================
    //
    // El menú de pausa NO congela el plataformero.
    //
    // Mientras está abierto:
    //     - gravedad sigue;
    //     - velocidad sigue;
    //     - colisiones siguen;
    //     - enemigos/proyectiles siguen;
    //
    // Solo anulamos el INPUT de Maya para que las flechas
    // usadas por el menú no la muevan también.
    // =====================================================

    var _blocked =
        false;


    var _menu_open =
    (
        instance_exists(obj_menu_manager)
        &&
        obj_menu_manager.state
        !=
        MENU_STATE.CLOSED
    );


    if (
        variable_global_exists(
            "gameover_death_freeze_active"
        )
        &&
        global.gameover_death_freeze_active
    )
    {
        _blocked =
            true;
    }


    if (
        variable_global_exists(
            "cutscene_active"
        )
        &&
        global.cutscene_active
    )
    {
        _blocked =
            true;
    }


    if (
        instance_exists(obj_pauser)
        ||
        instance_exists(obj_textbox)
        ||
        instance_exists(obj_save_menu)
    )
    {
        _blocked =
            true;
    }


    if (_blocked)
    {
        platform_hsp =
            0;


        return;
    }


    var _controls_enabled =
        !_menu_open;


    // =====================================================
    // TIMERS
    // =====================================================

    if (platform_attack_cooldown > 0)
    {
        platform_attack_cooldown--;
    }


    if (platform_attack_timer > 0)
    {
        platform_attack_timer--;
    }


    // =====================================================
    // INPUT HORIZONTAL
    // =====================================================

    var _left =
        (
            _controls_enabled
            &&
            keyboard_check(
                vk_left
            )
        );


    var _right =
        (
            _controls_enabled
            &&
            keyboard_check(
                vk_right
            )
        );


    if (_left && _right)
    {
        _left =
            false;


        _right =
            false;
    }


    var _input =
        0;


    if (_left)
    {
        _input =
            -1;
    }


    if (_right)
    {
        _input =
            1;
    }


    if (_input != 0)
    {
        platform_facing =
            _input;
    }


    // =====================================================
    // SUELO / COYOTE TIME
    // =====================================================

    platform_grounded =
        (
            platform_vsp >= 0
            &&
            scr_platformer_floor_at(
                x,
                y + 1,
                platform_hit_left,
                platform_hit_top,
                platform_hit_right,
                platform_hit_bottom
            )
        );


    if (platform_grounded)
    {
        platform_coyote =
            platform_coyote_max;


        platform_stomp_active =
            false;


        platform_stomp_available =
            false;
    }
    else if (platform_coyote > 0)
    {
        platform_coyote--;
    }


    // =====================================================
    // ACELERACION
    // =====================================================

    if (_input != 0)
    {
        var _accel =
            (
                platform_grounded
                ?
                platform_ground_accel
                :
                platform_air_accel
            );


        platform_hsp =
            scr_platformer_approach(
                platform_hsp,
                _input * platform_run_speed,
                _accel
            );
    }
    else
    {
        var _friction =
            (
                platform_grounded
                ?
                platform_friction
                :
                platform_air_accel * 0.35
            );


        platform_hsp =
            scr_platformer_approach(
                platform_hsp,
                0,
                _friction
            );
    }


    // =====================================================
    // INPUT DE SALTO
    // =====================================================

    var _jump_pressed =
        (
            _controls_enabled
            ?
            scr_platformer_jump_pressed()
            :
            false
        );


    var _jump_held =
        (
            _controls_enabled
            ?
            scr_platformer_jump_held()
            :
            false
        );


    // =====================================================
    // SENTON
    // =====================================================

    if (
        !platform_grounded
        &&
        !platform_stomp_active
        &&
        platform_stomp_available
        &&
        keyboard_check(vk_down)
        &&
        _jump_pressed
    )
    {
        platform_stomp_active =
            true;


        platform_stomp_available =
            false;


        platform_jump_buffer =
            0;


        platform_coyote =
            0;


        platform_vsp =
            max(
                platform_vsp,
                platform_stomp_start_speed
            );


        platform_y_rem =
            0;
    }


    // =====================================================
    // SALTO - BUFFER
    // =====================================================

    if (!platform_stomp_active)
    {
        if (_jump_pressed)
        {
            platform_jump_buffer =
                platform_jump_buffer_max;
        }
        else if (platform_jump_buffer > 0)
        {
            platform_jump_buffer--;
        }


        if (
            platform_jump_buffer > 0
            &&
            platform_coyote > 0
        )
        {
            platform_vsp =
                platform_jump_speed;


            platform_grounded =
                false;


            platform_stomp_available =
                true;


            // Sonido específico del salto plataformero.
            var _jump_sound =
                asset_get_index(
                    "snd_jump_platformer"
                );


            if (
                _jump_sound != -1
                &&
                audio_exists(_jump_sound)
            )
            {
                audio_play_sound(
                    _jump_sound,
                    10,
                    false
                );
            }


            platform_coyote =
                0;


            platform_jump_buffer =
                0;
        }


        // =================================================
        // SALTO VARIABLE
        // =================================================

        if (
            !_jump_held
            &&
            platform_vsp
            <
            platform_jump_cut_speed
        )
        {
            platform_vsp =
                platform_jump_cut_speed;
        }
    }


    // =====================================================
    // GRAVEDAD
    // =====================================================

    if (platform_stomp_active)
    {
        platform_vsp =
            min(
                platform_vsp
                +
                platform_stomp_gravity,
                platform_stomp_max_fall
            );
    }
    else
    {
        platform_vsp =
            min(
                platform_vsp
                +
                platform_gravity,
                platform_max_fall
            );
    }


    // =====================================================
    // ATAQUE
    // =====================================================

    if (
        _controls_enabled
        &&
        !platform_stomp_active
        &&
        scr_platformer_attack_pressed()
    )
    {
        scr_platformer_player_attack();
    }


    // =====================================================
    // MOVIMIENTO X CON SUBPIXEL
    // =====================================================

    platform_x_rem +=
        platform_hsp;


    var _move_x =
        round(
            platform_x_rem
        );


    platform_x_rem -=
        _move_x;


    if (_move_x != 0)
    {
        var _sx =
            sign(
                _move_x
            );


        for (
            var _ix = 0;
            _ix < abs(_move_x);
            _ix++
        )
        {
            if (
                !scr_platformer_collision_at(
                    x + _sx,
                    y,
                    platform_hit_left,
                    platform_hit_top,
                    platform_hit_right,
                    platform_hit_bottom
                )
            )
            {
                x +=
                    _sx;
            }
            else
            {
                platform_hsp =
                    0;


                platform_x_rem =
                    0;


                break;
            }
        }
    }


    // =====================================================
    // MOVIMIENTO Y CON SUBPIXEL
    // =====================================================

    platform_y_rem +=
        platform_vsp;


    var _move_y =
        round(
            platform_y_rem
        );


    platform_y_rem -=
        _move_y;


    if (_move_y != 0)
    {
        var _sy =
            sign(
                _move_y
            );


        for (
            var _iy = 0;
            _iy < abs(_move_y);
            _iy++
        )
        {
            var _trampoline =
                noone;


            var _oneway =
                noone;


            if (_sy > 0)
            {
                _trampoline =
                    scr_platformer_trampoline_at(
                        x,
                        y + _sy,
                        platform_hit_left,
                        platform_hit_top,
                        platform_hit_right,
                        platform_hit_bottom
                    );


                _oneway =
                    scr_platformer_oneway_at(
                        x,
                        y + _sy,
                        platform_hit_left,
                        platform_hit_top,
                        platform_hit_right,
                        platform_hit_bottom
                    );
            }


            if (_trampoline != noone)
            {
                platform_y_rem =
                    0;


                if (platform_stomp_active)
                {
                    var _bounce =
                        -15.5;


                    if (
                        variable_instance_exists(
                            _trampoline,
                            "bounce_speed"
                        )
                    )
                    {
                        _bounce =
                            _trampoline.bounce_speed;
                    }


                    platform_vsp =
                        min(
                            -1,
                            _bounce
                        );


                    platform_stomp_active =
                        false;


                    // El rebote vuelve a contar como estar
                    // lanzado por un salto, así se puede
                    // encadenar otro sentón si se desea.
                    platform_stomp_available =
                        true;


                    platform_grounded =
                        false;


                    scr_screen_shake_start(
                        3,
                        6
                    );


                    if (
                        variable_instance_exists(
                            _trampoline,
                            "bounce_sound"
                        )
                        &&
                        _trampoline.bounce_sound != -1
                        &&
                        audio_exists(
                            _trampoline.bounce_sound
                        )
                    )
                    {
                        audio_play_sound(
                            _trampoline.bounce_sound,
                            10,
                            false
                        );
                    }
                }
                else
                {
                    platform_vsp =
                        0;


                    platform_grounded =
                        true;
                }


                break;
            }


            // Plataforma traspasable:
            // solo bloquea cuando estamos bajando y tocamos
            // su superficie superior.
            if (_oneway != noone)
            {
                platform_vsp =
                    0;


                platform_y_rem =
                    0;


                platform_grounded =
                    true;


                if (platform_stomp_active)
                {
                    platform_stomp_active =
                        false;


                    scr_screen_shake_start(
                        2,
                        4
                    );
                }


                break;
            }


            if (
                !scr_platformer_collision_at(
                    x,
                    y + _sy,
                    platform_hit_left,
                    platform_hit_top,
                    platform_hit_right,
                    platform_hit_bottom
                )
            )
            {
                y +=
                    _sy;
            }
            else
            {
                platform_vsp =
                    0;


                platform_y_rem =
                    0;


                if (_sy > 0)
                {
                    platform_grounded =
                        true;


                    if (platform_stomp_active)
                    {
                        platform_stomp_active =
                            false;


                        scr_screen_shake_start(
                            2,
                            4
                        );
                    }
                }


                break;
            }
        }
    }


    // =====================================================
    // ACTUALIZAR SUELO DESPUES DEL MOVIMIENTO
    // =====================================================

    platform_grounded =
        (
            platform_vsp >= 0
            &&
            scr_platformer_floor_at(
                x,
                y + 1,
                platform_hit_left,
                platform_hit_top,
                platform_hit_right,
                platform_hit_bottom
            )
        );


    if (platform_facing < 0)
    {
        facing_direction =
            1;


        direccion =
            "izquierda";
    }
    else
    {
        facing_direction =
            0;


        direccion =
            "derecha";
    }
}


// =========================================================
// SPRITE DE MAYA
// =========================================================
//
// Se llama en obj_player -> End Step.
//
// El Step RPG ya habrá intentado poner sus sprites normales.
// Este evento ocurre después y aplica el sprite final del
// plataformero justo antes del Draw.
// =========================================================

function scr_platformer_player_apply_sprite()
{
    scr_platformer_player_prepare();


    var _new_sprite =
        -1;


    // =====================================================
    // SENTON
    // =====================================================
    //
    // Sprite opcional:
    //
    //     spr_maya_platform_senton
    //
    // Si no existe usa el mismo sprite de salto.
    // =====================================================

    if (platform_stomp_active)
    {
        var _jump_fallback =
            scr_platformer_sprite(
                "spr_maya_platform_salto",
                (
                    platform_facing < 0
                    ?
                    pendejo_izquierda
                    :
                    pendejo_derecha
                )
            );


        _new_sprite =
            scr_platformer_sprite(
                "spr_maya_platform_senton",
                _jump_fallback
            );
    }

    // =====================================================
    // AIRE -> SALTO
    // =====================================================

    else if (!platform_grounded)
    {
        _new_sprite =
            scr_platformer_sprite(
                "spr_maya_platform_salto",
                (
                    platform_facing < 0
                    ?
                    pendejo_izquierda
                    :
                    pendejo_derecha
                )
            );
    }

    // =====================================================
    // CORRIENDO
    // =====================================================

    else if (abs(platform_hsp) > 0.20)
    {
        if (platform_facing < 0)
        {
            _new_sprite =
                scr_platformer_sprite(
                    "spr_maya_platform_run_izquierda",
                    pendejo_izquierda
                );
        }
        else
        {
            _new_sprite =
                scr_platformer_sprite(
                    "spr_maya_platform_run_derecha",
                    pendejo_derecha
                );
        }
    }

    // =====================================================
    // IDLE
    // =====================================================

    else
    {
        if (platform_facing < 0)
        {
            _new_sprite =
                scr_platformer_sprite(
                    "spr_maya_platform_idle_izquierda",
                    pendejo_izquierda
                );
        }
        else
        {
            _new_sprite =
                scr_platformer_sprite(
                    "spr_maya_platform_idle_derecha",
                    pendejo_derecha
                );
        }
    }


    if (
        _new_sprite != -1
        &&
        sprite_index != _new_sprite
    )
    {
        sprite_index =
            _new_sprite;


        image_index =
            0;
    }


    // Animaciones del asset respetan su velocidad propia.
    image_speed =
        1;


    // Nunca invertimos el sprite automáticamente.
    // Run izquierda/derecha son sprites separados.
    image_xscale =
        abs(
            platform_saved_image_xscale
        );


    image_yscale =
        platform_saved_image_yscale;
}


// =========================================================
// SILICIO - PLATAFORMERO V4
// =========================================================
//
// IMPORTANTE:
//
// Silicio YA NO tiene una segunda física independiente.
//
// El sistema de party original del juego:
//
//     scr_party_update()
//
// reproduce la ruta histórica de Maya. Esa ruta ya contiene:
//
//     - caminar;
//     - saltos;
//     - caídas;
//     - rebotes;
//     - plataformas.
//
// Por eso en plataformero dejamos que el sistema original
// mueva físicamente a Silicio y aquí SOLO:
//
//     - mantenemos follow habilitado;
//     - detectamos su movimiento final;
//     - aplicamos sprites de plataforma.
//
// Esto elimina la pelea entre dos sistemas de movimiento.
// =========================================================


// =========================================================
// PREPARAR SILICIO
// =========================================================

function scr_platformer_silicio_prepare()
{
    if (
        !variable_instance_exists(
            id,
            "platformer_silicio_ready"
        )
    )
    {
        platformer_silicio_ready =
            true;


        platformer_silicio_applied =
            false;


        platform_sil_facing =
            (
                variable_instance_exists(
                    id,
                    "facing_direction"
                )
                &&
                facing_direction == 1
                ?
                -1
                :
                1
            );


        platform_sil_prev_x =
            x;


        platform_sil_prev_y =
            y;


        platform_sil_move_x =
            0;


        platform_sil_move_y =
            0;


        platform_sil_grounded =
            true;


        // Silicio actual:
        //     19 x 38
        //     origin 9,19
        platform_sil_hit_left =
            -8;


        platform_sil_hit_top =
            -18;


        platform_sil_hit_right =
            8;


        platform_sil_hit_bottom =
            18;


        platform_sil_saved_image_xscale =
            image_xscale;


        platform_sil_saved_image_yscale =
            image_yscale;
    }
}


// =========================================================
// ENTRAR - SILICIO
// =========================================================

function scr_platformer_silicio_enter()
{
    scr_platformer_silicio_prepare();


    if (!platformer_silicio_applied)
    {
        platformer_silicio_applied =
            true;


        platform_sil_saved_image_xscale =
            image_xscale;


        platform_sil_saved_image_yscale =
            image_yscale;


        platform_sil_prev_x =
            x;


        platform_sil_prev_y =
            y;
    }


    // CLAVE DEL FIX:
    // jamás suspender el follow durante el plataformero.
    party_follow_suspended =
        false;
}


// =========================================================
// SALIR - SILICIO
// =========================================================

function scr_platformer_silicio_leave()
{
    scr_platformer_silicio_prepare();


    if (!platformer_silicio_applied)
    {
        party_follow_suspended =
            false;

        return;
    }


    platformer_silicio_applied =
        false;


    party_follow_suspended =
        false;


    image_xscale =
        platform_sil_saved_image_xscale;


    image_yscale =
        platform_sil_saved_image_yscale;


    if (platform_sil_facing < 0)
    {
        sprite_index =
            spr_silicio_izquierda;


        facing_direction =
            1;


        direccion =
            "izquierda";
    }
    else
    {
        sprite_index =
            spr_silicio_derecha;


        facing_direction =
            0;


        direccion =
            "derecha";
    }


    image_index =
        0;


    image_speed =
        0;


    platform_sil_prev_x =
        x;


    platform_sil_prev_y =
        y;
}


// =========================================================
// UPDATE DESDE OBJ_SILICIO -> END STEP
// =========================================================
//
// Aquí NO movemos x/y.
//
// Solo nos aseguramos de que el party system siga activo.
// La aplicación visual final ocurre DESPUÉS de:
//
//     scr_party_update()
//
// desde obj_settings -> End Step.
// =========================================================

function scr_platformer_silicio_update()
{
    scr_platformer_silicio_prepare();


    if (
        !scr_party_has(
            "silicio"
        )
    )
    {
        if (platformer_silicio_applied)
        {
            scr_platformer_silicio_leave();
        }


        return;
    }


    if (
        !variable_global_exists(
            "platformer_active"
        )
        ||
        !global.platformer_active
    )
    {
        if (platformer_silicio_applied)
        {
            scr_platformer_silicio_leave();
        }


        return;
    }


    scr_platformer_silicio_enter();


    // NO tocar posición.
    // NO tocar gravedad.
    // NO calcular path.
    // El sistema original de party hace todo eso mediante
    // la ruta real que recorrió Maya.
}


// =========================================================
// VISUAL DE PARTY DESPUÉS DE SCR_PARTY_UPDATE()
// =========================================================
//
// Debe llamarse desde obj_settings -> End Step justo después
// de scr_party_update().
// =========================================================

function scr_platformer_party_visual_update()
{
    scr_platformer_init();


    if (!global.platformer_active)
    {
        return;
    }


    if (!scr_party_has("silicio"))
    {
        return;
    }


    var _sil =
        scr_party_get_instance(
            "silicio"
        );


    if (
        _sil == noone
        ||
        !instance_exists(_sil)
    )
    {
        return;
    }


    with (_sil)
    {
        scr_platformer_silicio_enter();


        // Movimiento REAL que acaba de hacer el party system.
        platform_sil_move_x =
            x - platform_sil_prev_x;


        platform_sil_move_y =
            y - platform_sil_prev_y;


        if (abs(platform_sil_move_x) > 0.05)
        {
            platform_sil_facing =
                sign(
                    platform_sil_move_x
                );
        }


        platform_sil_grounded =
            (
                abs(platform_sil_move_y) <= 0.05
                &&
                scr_platformer_floor_at(
                    x,
                    y + 1,
                    platform_sil_hit_left,
                    platform_sil_hit_top,
                    platform_sil_hit_right,
                    platform_sil_hit_bottom
                )
            );


        scr_platformer_silicio_apply_sprite();


        platform_sil_prev_x =
            x;


        platform_sil_prev_y =
            y;
    }
}


// =========================================================
// SPRITE SILICIO
// =========================================================

function scr_platformer_silicio_apply_sprite()
{
    var _new_sprite =
        -1;


    // =====================================================
    // AIRE / MOVIMIENTO VERTICAL
    // =====================================================

    if (
        abs(platform_sil_move_y) > 0.05
        ||
        !platform_sil_grounded
    )
    {
        _new_sprite =
            scr_platformer_sprite(
                "spr_silicio_platform_salto",
                (
                    platform_sil_facing < 0
                    ?
                    spr_silicio_izquierda
                    :
                    spr_silicio_derecha
                )
            );
    }

    // =====================================================
    // CORRIENDO
    // =====================================================

    else if (abs(platform_sil_move_x) > 0.05)
    {
        if (platform_sil_facing < 0)
        {
            _new_sprite =
                scr_platformer_sprite(
                    "spr_silicio_platform_run_izquierda",
                    spr_silicio_izquierda
                );
        }
        else
        {
            _new_sprite =
                scr_platformer_sprite(
                    "spr_silicio_platform_run_derecha",
                    spr_silicio_derecha
                );
        }
    }

    // =====================================================
    // IDLE IZQUIERDA / DERECHA
    // =====================================================

    else
    {
        if (platform_sil_facing < 0)
        {
            _new_sprite =
                scr_platformer_sprite(
                    "spr_silicio_platform_idle_izquierda",
                    spr_silicio_izquierda
                );
        }
        else
        {
            _new_sprite =
                scr_platformer_sprite(
                    "spr_silicio_platform_idle_derecha",
                    spr_silicio_derecha
                );
        }
    }


    if (
        _new_sprite != -1
        &&
        sprite_index != _new_sprite
    )
    {
        sprite_index =
            _new_sprite;


        image_index =
            0;
    }


    image_speed =
        1;


    image_xscale =
        abs(
            platform_sil_saved_image_xscale
        );


    image_yscale =
        platform_sil_saved_image_yscale;


    if (platform_sil_facing < 0)
    {
        facing_direction =
            1;


        direccion =
            "izquierda";
    }
    else
    {
        facing_direction =
            0;


        direccion =
            "derecha";
    }
}


// =========================================================
// PLATAFORMERO V5 - FORZAR VUELTA AL MODO NORMAL
// =========================================================
//
// Se usa al entrar a game_over.
//
// Limpia:
//
//     - modo plataformero actual;
//     - cambios de modo pendientes;
//     - físicas residuales;
//     - estado especial de Silicio;
//     - HUD temporal de curación.
//
// De esta forma game_over SIEMPRE es una room normal.
// =========================================================

function scr_platformer_force_normal_mode()
{
    scr_platformer_init();


    global.platformer_mode_pending =
        false;


    global.platformer_mode_pending_enable =
        false;


    global.platformer_mode_pending_room =
        -1;


    global.platformer_mode_pending_facing =
        1;


    global.platformer_active =
        false;


    if (
        variable_global_exists(
            "platformer_heal_hud_timer"
        )
    )
    {
        global.platformer_heal_hud_timer =
            0;
    }


    if (
        variable_global_exists(
            "platformer_heal_amount"
        )
    )
    {
        global.platformer_heal_amount =
            0;
    }


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


        with (_p)
        {
            if (
                variable_instance_exists(
                    id,
                    "platformer_mode_applied"
                )
                &&
                platformer_mode_applied
            )
            {
                scr_platformer_player_leave();
            }


            if (
                variable_instance_exists(
                    id,
                    "platform_hsp"
                )
            )
            {
                platform_hsp =
                    0;
            }


            if (
                variable_instance_exists(
                    id,
                    "platform_vsp"
                )
            )
            {
                platform_vsp =
                    0;
            }


            if (
                variable_instance_exists(
                    id,
                    "platform_x_rem"
                )
            )
            {
                platform_x_rem =
                    0;
            }


            if (
                variable_instance_exists(
                    id,
                    "platform_y_rem"
                )
            )
            {
                platform_y_rem =
                    0;
            }


            if (
                variable_instance_exists(
                    id,
                    "platform_stomp_active"
                )
            )
            {
                platform_stomp_active =
                    false;
            }
        }
    }


    // =====================================================
    // SILICIO
    // =====================================================

    if (instance_exists(obj_silicio))
    {
        with (obj_silicio)
        {
            party_follow_suspended =
                false;


            if (
                variable_instance_exists(
                    id,
                    "platformer_silicio_applied"
                )
                &&
                platformer_silicio_applied
            )
            {
                scr_platformer_silicio_leave();
            }
        }
    }


    return true;
}


// =========================================================
// PLATAFORMERO V5 - DIBUJAR HUD DE VIDA
// =========================================================
//
// Dibuja la misma caja/proporción del HUD de enemigos.
//
// _x / _y:
//     posición GUI.
//
// _heal_amount:
//     si es > 0 dibuja temporalmente:
//
//         +N
//
// para mostrar cuánto recuperó el consumible.
//
// _alpha:
//     opacidad de todo el HUD. Se usa para replicar el
//     mismo fade-out del HUD de enemigos al deslizarse.
// =========================================================

function scr_platformer_draw_player_hp_hud(
    _x,
    _y,
    _heal_amount = 0,
    _alpha = 1
)
{
    _alpha =
        clamp(
            _alpha,
            0,
            1
        );
    if (!instance_exists(obj_player))
    {
        return false;
    }


    var _p =
        instance_find(
            obj_player,
            0
        );


    var _gui_w =
        display_get_gui_width();


    var _gui_h =
        display_get_gui_height();


    var _s =
        min(
            _gui_w / 320,
            _gui_h / 240
        )
        *
        0.78;


    // =====================================================
    // CAJA
    // =====================================================

    draw_sprite_ext(
        spr_bbs_textbox,
        0,
        _x,
        _y,
        2.27451 * _s,
        1.0 * _s,
        0,
        c_white,
        _alpha
    );


    // =====================================================
    // CABEZA
    // =====================================================

    var _head_frame =
        0;


    if (
        variable_instance_exists(
            _p,
            "map_battle_iframes"
        )
        &&
        _p.map_battle_iframes > 0
    )
    {
        _head_frame =
            1;
    }


    _head_frame =
        clamp(
            _head_frame,
            0,
            max(
                0,
                sprite_get_number(
                    spr_bbs_prota_head
                )
                -
                1
            )
        );


    draw_sprite_ext(
        spr_bbs_prota_head,
        _head_frame,
        _x + (8 * _s),
        _y + (12 * _s),
        1.0 * _s,
        1.0 * _s,
        0,
        c_white,
        _alpha
    );


    // Textos y rectángulos respetan el mismo fade.
    draw_set_alpha(
        _alpha
    );


    if (variable_global_exists("font_main"))
    {
        draw_set_font(
            global.font_main
        );
    }


    var _info_x =
        _x
        +
        (49 * _s);


    var _info_y =
        _y
        +
        (6 * _s);


    draw_set_halign(
        fa_left
    );


    draw_set_valign(
        fa_top
    );


    draw_set_color(
        c_white
    );


    draw_text_transformed(
        _info_x,
        _info_y,
        scr_loc("Maya"),
        0.84,
        0.84,
        0
    );


    // =====================================================
    // HP
    // =====================================================

    var _hp_now =
        max(
            0,
            round(
                _p.hp
            )
        );


    var _hp_max_now =
        max(
            1,
            round(
                _p.hp_max
            )
        );


    var _hp_label_y =
        _info_y
        +
        (16 * _s);


    var _hp_scale =
        0.7
        *
        0.78;


    draw_text_transformed(
        _info_x,
        _hp_label_y,
        "HP",
        _hp_scale,
        _hp_scale,
        0
    );


    var _hp_text =
        string(_hp_now)
        +
        " / "
        +
        string(_hp_max_now);


    var _hp_ref =
        "80 / 80";


    var _hp_text_x_base =
        _info_x
        +
        (24 * _s);


    var _hp_ref_w =
        string_width(
            _hp_ref
        )
        *
        _hp_scale;


    var _hp_actual_w =
        string_width(
            _hp_text
        )
        *
        _hp_scale;


    var _hp_right =
        _hp_text_x_base
        +
        _hp_ref_w;


    var _hp_text_x =
        _hp_right
        -
        _hp_actual_w;


    draw_text_transformed(
        _hp_text_x,
        _hp_label_y,
        _hp_text,
        _hp_scale,
        _hp_scale,
        0
    );


    // =====================================================
    // CUÁNTO SE CURÓ
    // =====================================================

    if (_heal_amount > 0)
    {
        draw_set_color(
            c_lime
        );


        draw_text_transformed(
            _hp_right
            +
            (20 * _s),
            _hp_label_y,
            "+"
            +
            string(
                round(
                    _heal_amount
                )
            ),
            _hp_scale,
            _hp_scale,
            0
        );


        draw_set_color(
            c_white
        );
    }


    // =====================================================
    // BARRA
    // =====================================================

    var _bar_left =
        _info_x;


    var _bar_right =
        _hp_right;


    var _bar_y1 =
        _hp_label_y
        +
        (10 * _s);


    var _bar_y2 =
        _bar_y1
        +
        (6 * _s);


    draw_rectangle_color(
        _bar_left,
        _bar_y1,
        _bar_right,
        _bar_y2,
        $202020,
        $202020,
        $202020,
        $202020,
        false
    );


    var _ratio =
        clamp(
            _hp_now
            /
            _hp_max_now,
            0,
            1
        );


    draw_rectangle_color(
        _bar_left,
        _bar_y1,
        _bar_left
        +
        (
            (_bar_right - _bar_left)
            *
            _ratio
        ),
        _bar_y2,
        c_yellow,
        c_yellow,
        c_yellow,
        c_yellow,
        false
    );


    draw_set_halign(
        fa_left
    );


    draw_set_valign(
        fa_top
    );


    draw_set_color(
        c_white
    );


    draw_set_alpha(
        1
    );


    return true;
}
