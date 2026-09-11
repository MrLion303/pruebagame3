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

    if (
        !variable_instance_exists(
            _enemy,
            "platform_hp_max"
        )
    )
    {
        _enemy.platform_hp_max =
            3;
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
    // SONIDO / SHAKE DE IMPACTO
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


    // -----------------------------------------------------
    // MUERTE
    // -----------------------------------------------------

    if (_enemy.platform_hp <= 0)
    {
        var _death_sound =
            asset_get_index(
                "snd_enemy_killed"
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


        with (_enemy)
        {
            instance_destroy();
        }


        return true;
    }


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
    // HITBOX EN FRENTE
    // =====================================================

    var _body_left =
        x + platform_hit_left;


    var _body_right =
        x + platform_hit_right;


    var _body_top =
        y + platform_hit_top;


    var _body_bottom =
        y + platform_hit_bottom;


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
            scr_platformer_enemy_damage(
                id,
                other.platform_attack_damage,
                other.platform_attack_serial
            );
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


    // El Step RPG debe permanecer desactivado SIEMPRE
    // mientras estemos en este modo.
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
    // BLOQUEOS
    // =====================================================

    var _blocked =
        false;


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


    if (
        instance_exists(obj_menu_manager)
        &&
        obj_menu_manager.state
        !=
        MENU_STATE.CLOSED
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
        keyboard_check(
            vk_left
        );


    var _right =
        keyboard_check(
            vk_right
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
        scr_platformer_collision_at(
            x,
            y + 1,
            platform_hit_left,
            platform_hit_top,
            platform_hit_right,
            platform_hit_bottom
        );


    if (platform_grounded)
    {
        platform_coyote =
            platform_coyote_max;
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
    // SALTO - BUFFER
    // =====================================================

    var _jump_pressed =
    (
        keyboard_check_pressed(
            ord("Z")
        )
        ||
        keyboard_check_pressed(
            vk_enter
        )
    );


    // Si estamos al lado del objeto de salida/entrada,
    // Z se reserva para interactuar con él.
    if (
        _jump_pressed
        &&
        !scr_platformer_jump_blocked_by_warp()
    )
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


        platform_coyote =
            0;


        platform_jump_buffer =
            0;
    }


    // =====================================================
    // SALTO VARIABLE
    // =====================================================
    //
    // Soltar Z/Enter pronto = salto más corto.
    // =====================================================

    var _jump_held =
    (
        keyboard_check(
            ord("Z")
        )
        ||
        keyboard_check(
            vk_enter
        )
    );


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


    // =====================================================
    // GRAVEDAD
    // =====================================================

    platform_vsp =
        min(
            platform_vsp
            +
            platform_gravity,
            platform_max_fall
        );


    // =====================================================
    // ATAQUE
    // =====================================================

    if (
        keyboard_check_pressed(
            ord("X")
        )
        ||
        keyboard_check_pressed(
            vk_shift
        )
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
                // PARED.
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
                // _sy > 0:
                //     suelo.
                //
                // _sy < 0:
                //     techo / golpe de cabeza.
                platform_vsp =
                    0;


                platform_y_rem =
                    0;


                if (_sy > 0)
                {
                    platform_grounded =
                        true;
                }


                break;
            }
        }
    }


    // Actualizar suelo después del movimiento.
    platform_grounded =
        scr_platformer_collision_at(
            x,
            y + 1,
            platform_hit_left,
            platform_hit_top,
            platform_hit_right,
            platform_hit_bottom
        );


    // Facing normal compatible con otras partes del juego.
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
    // AIRE -> SALTO
    // =====================================================

    if (!platform_grounded)
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
        _new_sprite =
            scr_platformer_sprite(
                "spr_maya_platform_idle",
                (
                    platform_facing < 0
                    ?
                    pendejo_izquierda
                    :
                    pendejo_derecha
                )
            );
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
// PREPARAR SILICIO
// =========================================================
//
// Se ejecuta desde obj_silicio.
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


        platformer_silicio_prev_suspended =
            false;


        platform_sil_hsp =
            0;


        platform_sil_vsp =
            0;


        platform_sil_x_rem =
            0;


        platform_sil_y_rem =
            0;


        platform_sil_facing =
            1;


        platform_sil_grounded =
            false;


        platform_sil_run_speed =
            4.6;


        platform_sil_accel =
            0.55;


        platform_sil_air_accel =
            0.38;


        platform_sil_friction =
            0.65;


        platform_sil_gravity =
            0.65;


        platform_sil_max_fall =
            12;


        platform_sil_jump_speed =
            -9.5;


        // Silicio actual:
        //
        //     19 x 38
        //     origin 9,19
        //
        // Hitbox de cuerpo completo.
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


    if (platformer_silicio_applied)
    {
        party_follow_suspended =
            true;

        return;
    }


    platformer_silicio_applied =
        true;


    platformer_silicio_prev_suspended =
        party_follow_suspended;


    platform_sil_saved_image_xscale =
        image_xscale;


    platform_sil_saved_image_yscale =
        image_yscale;


    party_follow_suspended =
        true;


    platform_sil_hsp =
        0;


    platform_sil_vsp =
        0;


    platform_sil_x_rem =
        0;


    platform_sil_y_rem =
        0;
}


// =========================================================
// SALIR - SILICIO
// =========================================================

function scr_platformer_silicio_leave()
{
    scr_platformer_silicio_prepare();


    if (!platformer_silicio_applied)
    {
        return;
    }


    platformer_silicio_applied =
        false;


    party_follow_suspended =
        platformer_silicio_prev_suspended;


    platform_sil_hsp =
        0;


    platform_sil_vsp =
        0;


    platform_sil_x_rem =
        0;


    platform_sil_y_rem =
        0;


    image_xscale =
        platform_sil_saved_image_xscale;


    image_yscale =
        platform_sil_saved_image_yscale;


    // Volver a un sprite normal.
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
}


// =========================================================
// FISICA / FOLLOW DE SILICIO
// =========================================================
//
// Se ejecuta desde obj_silicio -> End Step.
//
// El follow normal está suspendido.
/// =========================================================

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


    if (!instance_exists(obj_player))
    {
        return;
    }


    var _p =
        instance_find(
            obj_player,
            0
        );


    // =====================================================
    // BLOQUEO DURANTE TRANSICION / PAUSA
    // =====================================================

    var _blocked =
        false;


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


    if (
        instance_exists(obj_menu_manager)
        &&
        obj_menu_manager.state
        !=
        MENU_STATE.CLOSED
    )
    {
        _blocked =
            true;
    }


    if (_blocked)
    {
        platform_sil_hsp =
            0;


        scr_platformer_silicio_apply_sprite();

        return;
    }


    // =====================================================
    // FAILSAFE
    // =====================================================
    //
    // Si queda demasiado lejos después de un salto, cambio
    // de room o caída rara, reaparece cerca de Maya.
    // =====================================================

    if (
        point_distance(
            x,
            y,
            _p.x,
            _p.y
        )
        >
        220

        ||

        abs(
            y - _p.y
        )
        >
        150
    )
    {
        x =
            _p.x
            -
            (
                _p.platform_facing
                *
                28
            );


        y =
            _p.y;


        // Sacarlo hacia arriba si cayó dentro de suelo.
        for (
            var _fix = 0;
            _fix < 64;
            _fix++
        )
        {
            if (
                !scr_platformer_collision_at(
                    x,
                    y,
                    platform_sil_hit_left,
                    platform_sil_hit_top,
                    platform_sil_hit_right,
                    platform_sil_hit_bottom
                )
            )
            {
                break;
            }


            y -=
                1;
        }


        platform_sil_hsp =
            0;


        platform_sil_vsp =
            0;


        platform_sil_x_rem =
            0;


        platform_sil_y_rem =
            0;
    }


    // =====================================================
    // OBJETIVO: QUEDARSE DETRAS DE MAYA
    // =====================================================

    var _target_x =
        _p.x
        -
        (
            _p.platform_facing
            *
            30
        );


    var _dx =
        _target_x - x;


    var _input =
        0;


    if (abs(_dx) > 8)
    {
        _input =
            sign(
                _dx
            );
    }


    if (_input != 0)
    {
        platform_sil_facing =
            _input;
    }


    // =====================================================
    // SUELO
    // =====================================================

    platform_sil_grounded =
        scr_platformer_collision_at(
            x,
            y + 1,
            platform_sil_hit_left,
            platform_sil_hit_top,
            platform_sil_hit_right,
            platform_sil_hit_bottom
        );


    // =====================================================
    // HORIZONTAL
    // =====================================================

    if (_input != 0)
    {
        var _accel =
            (
                platform_sil_grounded
                ?
                platform_sil_accel
                :
                platform_sil_air_accel
            );


        platform_sil_hsp =
            scr_platformer_approach(
                platform_sil_hsp,
                _input * platform_sil_run_speed,
                _accel
            );
    }
    else
    {
        platform_sil_hsp =
            scr_platformer_approach(
                platform_sil_hsp,
                0,
                platform_sil_friction
            );
    }


    // =====================================================
    // SALTO AUTOMATICO
    // =====================================================
    //
    // Salta si:
    //
    // - Maya está claramente más arriba;
    // - encuentra una pared mientras intenta seguirla.
    // =====================================================

    if (platform_sil_grounded)
    {
        var _wall_ahead =
            false;


        if (_input != 0)
        {
            _wall_ahead =
                scr_platformer_collision_at(
                    x + _input,
                    y,
                    platform_sil_hit_left,
                    platform_sil_hit_top,
                    platform_sil_hit_right,
                    platform_sil_hit_bottom
                );
        }


        if (
            _p.y < y - 18

            ||

            _wall_ahead
        )
        {
            platform_sil_vsp =
                platform_sil_jump_speed;


            platform_sil_grounded =
                false;
        }
    }


    // =====================================================
    // GRAVEDAD
    // =====================================================

    platform_sil_vsp =
        min(
            platform_sil_vsp
            +
            platform_sil_gravity,
            platform_sil_max_fall
        );


    // =====================================================
    // MOVER X
    // =====================================================

    platform_sil_x_rem +=
        platform_sil_hsp;


    var _move_x =
        round(
            platform_sil_x_rem
        );


    platform_sil_x_rem -=
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
                    platform_sil_hit_left,
                    platform_sil_hit_top,
                    platform_sil_hit_right,
                    platform_sil_hit_bottom
                )
            )
            {
                x +=
                    _sx;
            }
            else
            {
                platform_sil_hsp =
                    0;


                platform_sil_x_rem =
                    0;


                break;
            }
        }
    }


    // =====================================================
    // MOVER Y
    // =====================================================

    platform_sil_y_rem +=
        platform_sil_vsp;


    var _move_y =
        round(
            platform_sil_y_rem
        );


    platform_sil_y_rem -=
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
            if (
                !scr_platformer_collision_at(
                    x,
                    y + _sy,
                    platform_sil_hit_left,
                    platform_sil_hit_top,
                    platform_sil_hit_right,
                    platform_sil_hit_bottom
                )
            )
            {
                y +=
                    _sy;
            }
            else
            {
                platform_sil_vsp =
                    0;


                platform_sil_y_rem =
                    0;


                if (_sy > 0)
                {
                    platform_sil_grounded =
                        true;
                }


                break;
            }
        }
    }


    platform_sil_grounded =
        scr_platformer_collision_at(
            x,
            y + 1,
            platform_sil_hit_left,
            platform_sil_hit_top,
            platform_sil_hit_right,
            platform_sil_hit_bottom
        );


    scr_platformer_silicio_apply_sprite();
}


// =========================================================
// SPRITE SILICIO
// =========================================================

function scr_platformer_silicio_apply_sprite()
{
    var _new_sprite =
        -1;


    if (!platform_sil_grounded)
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
    else if (abs(platform_sil_hsp) > 0.20)
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
    else
    {
        _new_sprite =
            scr_platformer_sprite(
                "spr_silicio_platform_idle",
                (
                    platform_sil_facing < 0
                    ?
                    spr_silicio_izquierda
                    :
                    spr_silicio_derecha
                )
            );
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
