/// =========================================================
/// SCR_HABILIDADES_SYSTEM
/// NUEVO SCRIPT
/// =========================================================
///
/// Habilidades PERMANENTES.
/// Se guardan dentro de global.inventory_data.habilidades.
///
/// La stamina también se guarda dentro de inventory_data.
/// scr_save_system ya serializa esa estructura completa.
///
/// No existe función para quitar habilidades.
/// =========================================================


// =========================================================
// DATOS VISUALES DE HABILIDADES
// =========================================================

function scr_habilidad_data(_id)
{
    _id = string_lower(string(_id));

    switch (_id)
    {
        case "sigilo":
        {
            var _icono = asset_get_index("spr_habilidad_sigilo");

            if (_icono == -1)
                _icono = asset_get_index("spr_maya_sigilo");

            return
            {
                id: "sigilo",
                nombre: scr_loc_src("Sigilo"),
                descripcion:
                    scr_loc_src(
                        "Mantén S para moverte agachada. Maya camina más lento y los enemigos del mapa reducen su rango de visión."
                    ),
                icono: _icono
            };
        }


        case "dash":
            return
            {
                id: "dash",
                nombre: scr_loc_src("Dash"),
                descripcion:
                    scr_loc_src(
                        "Con los Zapatos Rápidos equipados, pulsa Espacio dentro del rango de peligro de un enemigo para hacer un dash."
                    ),
                icono: asset_get_index("spr_habilidad_dash")
            };
    }


    return
    {
        id: _id,
        nombre: _id,
        descripcion: scr_loc_src("Habilidad obtenida."),
        icono: -1
    };
}


function scr_habilidades_orden()
{
    return
    [
        "sigilo",
        "dash"
    ];
}


function scr_habilidades_lista_obtenidas()
{
    scr_habilidades_init();

    var _lista = [];
    var _orden = scr_habilidades_orden();

    // Primero, habilidades conocidas en un orden fijo.
    for (var _i = 0; _i < array_length(_orden); _i++)
    {
        var _id = _orden[_i];

        if (scr_habilidad_tiene(_id))
            array_push(_lista, _id);
    }


    // Después, cualquier habilidad futura guardada.
    var _nombres =
        variable_struct_get_names(
            global.inventory_data.habilidades
        );

    for (var _j = 0; _j < array_length(_nombres); _j++)
    {
        var _extra = _nombres[_j];

        if (!scr_habilidad_tiene(_extra))
            continue;

        var _ya_esta = false;

        for (var _k = 0; _k < array_length(_lista); _k++)
        {
            if (_lista[_k] == _extra)
            {
                _ya_esta = true;
                break;
            }
        }

        if (!_ya_esta)
            array_push(_lista, _extra);
    }

    return _lista;
}


function scr_habilidades_init()
{
    scr_inventarios_data();

    if (
        !variable_struct_exists(global.inventory_data, "habilidades")
        ||
        !is_struct(global.inventory_data.habilidades)
    )
    {
        global.inventory_data.habilidades = {};
    }

    if (!variable_struct_exists(global.inventory_data, "dash_stamina"))
        global.inventory_data.dash_stamina = 100;

    if (!variable_struct_exists(global.inventory_data, "dash_recharge_frames"))
        global.inventory_data.dash_recharge_frames = 0;

    global.inventory_data.dash_stamina =
        clamp(global.inventory_data.dash_stamina, 0, 100);

    global.inventory_data.dash_recharge_frames =
        max(0, round(global.inventory_data.dash_recharge_frames));

    return global.inventory_data.habilidades;
}


function scr_habilidad_tiene(_id)
{
    scr_habilidades_init();

    _id = string_lower(string(_id));

    if (_id == "")
        return false;

    if (!variable_struct_exists(global.inventory_data.habilidades, _id))
        return false;

    return
        variable_struct_get(
            global.inventory_data.habilidades,
            _id
        )
        == true;
}


/// Solo añade. Nunca quita.
function scr_habilidad_otorgar(_id)
{
    scr_habilidades_init();

    _id = string_lower(string(_id));

    if (_id == "")
        return false;

    if (scr_habilidad_tiene(_id))
        return false;

    variable_struct_set(
        global.inventory_data.habilidades,
        _id,
        true
    );

    show_debug_message(
        "[HABILIDAD] Obtenida: " + _id
    );

    return true;
}


/// Helper para cinematicas:
///     cs_habilidad("sigilo")
function cs_habilidad(_id)
{
    var _ability_id = string_lower(string(_id));

    return
        cs_do(
            function()
            {
                scr_habilidad_otorgar(_ability_id);
            }
        );
}


// =========================================================
// PLAYER: INICIALIZAR RUNTIME
// =========================================================

function scr_player_abilities_init(_p)
{
    if (_p == noone || !instance_exists(_p))
        return false;

    scr_habilidades_init();

    if (!variable_instance_exists(_p, "abilities_initialized"))
    {
        _p.abilities_initialized = true;

        // Sigilo.
        _p.sigilo_activo = false;
        _p.sigilo_sprite =
            asset_get_index("spr_maya_sigilo");
        _p.sigilo_velocidad_mult = 0.50;

        _p.ability_prev_x = _p.x;
        _p.ability_prev_y = _p.y;

        // Dash.
        _p.dash_stamina =
            clamp(
                global.inventory_data.dash_stamina,
                0,
                100
            );

        _p.dash_recharge_frames =
            max(
                0,
                global.inventory_data.dash_recharge_frames
            );

        _p.dash_cost = 25;
        _p.dash_distance = 28;

        _p.dash_hud_anim = 0;
        _p.dash_hud_hold = 0;

        _p.dash_zero_lock =
            (_p.dash_stamina <= 0);

        _p.dash_used_this_frame = false;
    }

    return true;
}


// =========================================================
// FACTOR DE VISIÓN
// =========================================================

function scr_sigilo_get_factor_from_struct(_datos, _default = 0.50)
{
    if (
        is_struct(_datos)
        &&
        variable_struct_exists(_datos, "sigilo_factor_vision")
    )
    {
        return
            clamp(
                _datos.sigilo_factor_vision,
                0,
                1
            );
    }

    return clamp(_default, 0, 1);
}


// =========================================================
// SIGILO: ACTUALIZAR RANGOS
// =========================================================

function scr_sigilo_actualizar_rangos(_activo)
{
    // -----------------------------------------------------
    // Enemigos de mapa normales + hijos de ruta.
    // -----------------------------------------------------

    var _n_mapa =
        instance_number(obj_enemigo_mapa_parent);

    for (var _i = 0; _i < _n_mapa; _i++)
    {
        var _e =
            instance_find(obj_enemigo_mapa_parent, _i);

        if (_e == noone || !instance_exists(_e))
            continue;


        // Voladores/disparos.
        if (variable_instance_exists(_e, "rango_ataque"))
        {
            if (!variable_instance_exists(_e, "sigilo_rango_ataque_base"))
            {
                _e.sigilo_rango_ataque_base =
                    _e.rango_ataque;
            }

            var _factor_mapa =
                variable_instance_exists(_e, "datos_mapa")
                ? scr_sigilo_get_factor_from_struct(
                    _e.datos_mapa,
                    0.50
                )
                : 0.50;

            _e.rango_ataque =
                _e.sigilo_rango_ataque_base
                *
                (_activo ? _factor_mapa : 1);
        }


        // Enemigos de ruta/daño.
        if (variable_instance_exists(_e, "rango_peligro"))
        {
            if (!variable_instance_exists(_e, "sigilo_rango_peligro_base"))
            {
                _e.sigilo_rango_peligro_base =
                    _e.rango_peligro;
            }

            var _factor_ruta =
                variable_instance_exists(_e, "datos_ruta")
                ? scr_sigilo_get_factor_from_struct(
                    _e.datos_ruta,
                    0.50
                )
                : 0.50;

            _e.rango_peligro =
                _e.sigilo_rango_peligro_base
                *
                (_activo ? _factor_ruta : 1);
        }
    }


    // -----------------------------------------------------
    // Enemigos que persiguen/inician BBS.
    // -----------------------------------------------------

    var _n_bbs =
        instance_number(obj_enemigo_batalla_mapa_parent);

    for (var _j = 0; _j < _n_bbs; _j++)
    {
        var _e_bbs =
            instance_find(
                obj_enemigo_batalla_mapa_parent,
                _j
            );

        if (
            _e_bbs == noone
            ||
            !instance_exists(_e_bbs)
            ||
            !variable_instance_exists(_e_bbs, "rango_persecucion")
        )
        {
            continue;
        }

        if (!variable_instance_exists(_e_bbs, "sigilo_rango_persecucion_base"))
        {
            _e_bbs.sigilo_rango_persecucion_base =
                _e_bbs.rango_persecucion;
        }

        var _factor_bbs =
            variable_instance_exists(_e_bbs, "datos_enemigo_mapa")
            ? scr_sigilo_get_factor_from_struct(
                _e_bbs.datos_enemigo_mapa,
                0.50
            )
            : 0.50;

        _e_bbs.rango_persecucion =
            _e_bbs.sigilo_rango_persecucion_base
            *
            (_activo ? _factor_bbs : 1);
    }
}


// =========================================================
// DASH: ¿ESTÁ EN RANGO DE PELIGRO?
// =========================================================

function scr_player_dash_danger_active(_p)
{
    // Enemigos normales y de ruta.
    var _n =
        instance_number(obj_enemigo_mapa_parent);

    for (var _i = 0; _i < _n; _i++)
    {
        var _e =
            instance_find(obj_enemigo_mapa_parent, _i);

        if (
            _e != noone
            &&
            instance_exists(_e)
            &&
            variable_instance_exists(_e, "en_alerta")
            &&
            _e.en_alerta
        )
        {
            return true;
        }
    }


    // Perseguidores BBS.
    var _n_bbs =
        instance_number(obj_enemigo_batalla_mapa_parent);

    for (var _j = 0; _j < _n_bbs; _j++)
    {
        var _e_bbs =
            instance_find(
                obj_enemigo_batalla_mapa_parent,
                _j
            );

        if (_e_bbs == noone || !instance_exists(_e_bbs))
            continue;

        if (
            variable_instance_exists(_e_bbs, "alerta_activa")
            &&
            _e_bbs.alerta_activa
        )
        {
            return true;
        }

        if (
            variable_instance_exists(_e_bbs, "rango_persecucion")
            &&
            point_distance(
                _p.x,
                _p.y,
                _e_bbs.x,
                _e_bbs.y
            )
            <=
            _e_bbs.rango_persecucion
        )
        {
            return true;
        }
    }

    return false;
}


// =========================================================
// DASH: ¿ARMADURA EQUIPADA?
// =========================================================

function scr_player_has_dash_armor(_p)
{
    if (_p == noone || !instance_exists(_p))
        return false;

    if (!variable_global_exists("equip_db") || !is_struct(global.equip_db))
        scr_equips_data();

    var _eq = _p.equipo_armadura;
    var _data = undefined;

    if (is_struct(_eq))
    {
        _data = _eq;
    }
    else if (
        _eq != -1
        &&
        _eq != ""
        &&
        variable_struct_exists(global.equip_db, _eq)
    )
    {
        _data =
            variable_struct_get(global.equip_db, _eq);
    }

    return
        is_struct(_data)
        &&
        variable_struct_exists(_data, "permite_dash_mapa")
        &&
        _data.permite_dash_mapa;
}


// =========================================================
// PLAYER BEGIN STEP
// =========================================================

function scr_player_abilities_begin_step(_p)
{
    if (!scr_player_abilities_init(_p))
        return;

    _p.ability_prev_x = _p.x;
    _p.ability_prev_y = _p.y;
    _p.dash_used_this_frame = false;


    // =====================================================
    // EXTENSIONES AUTOMÁTICAS
    // =====================================================

    if (
        instance_exists(obj_menu_manager)
        &&
        !instance_exists(obj_menu_habilidades_ext)
    )
    {
        instance_create_depth(
            0,
            0,
            -2000000,
            obj_menu_habilidades_ext
        );
    }


    if (
        scr_habilidad_tiene("sigilo")
        &&
        !instance_exists(obj_sigilo_fx)
    )
    {
        instance_create_depth(
            0,
            0,
            -1500000,
            obj_sigilo_fx
        );
    }


    var _platformer =
        variable_global_exists("platformer_active")
        &&
        global.platformer_active;


    var _pause_menu_open =
        (
            instance_exists(obj_menu_manager)
            &&
            obj_menu_manager.state != MENU_STATE.CLOSED
        );


    var _world_ok =
        (
            room != bbs
            &&
            room != game_over
            &&
            !_platformer
            &&
            !_pause_menu_open
            &&
            !instance_exists(obj_save_menu)
            &&
            !scr_cutscene_world_locked()
            &&
            !instance_exists(obj_pauser)
        );


    _p.sigilo_activo =
        (
            _world_ok
            &&
            scr_habilidad_tiene("sigilo")
            &&
            keyboard_check(ord("S"))
        );


    // Begin Step ocurre antes del Step de enemigos:
    // sus rangos ya llegan reducidos/restaurados.
    scr_sigilo_actualizar_rangos(_p.sigilo_activo);
}


// =========================================================
// INTENTAR DASH
// =========================================================

function scr_player_try_dash(_p)
{
    if (
        !scr_habilidad_tiene("dash")
        ||
        !scr_player_has_dash_armor(_p)
        ||
        _p.dash_stamina < _p.dash_cost
        ||
        !scr_player_dash_danger_active(_p)
        ||
        !keyboard_check_pressed(vk_space)
    )
    {
        return false;
    }

    if (
        room == bbs
        ||
        room == game_over
        ||
        scr_cutscene_world_locked()
        ||
        instance_exists(obj_pauser)
        ||
        !variable_instance_exists(_p, "puede_moverse")
        ||
        !_p.puede_moverse
    )
    {
        return false;
    }


    var _dx = 0;
    var _dy = 0;

    // Dirección mantenida; si no, facing actual.
    if (keyboard_check(vk_right) && !keyboard_check(vk_left))
        _dx = 1;
    else if (keyboard_check(vk_left) && !keyboard_check(vk_right))
        _dx = -1;
    else if (keyboard_check(vk_up) && !keyboard_check(vk_down))
        _dy = -1;
    else if (keyboard_check(vk_down) && !keyboard_check(vk_up))
        _dy = 1;
    else
    {
        switch (_p.facing_direction)
        {
            case 0: _dx = 1;  break;
            case 1: _dx = -1; break;
            case 2: _dy = 1;  break;
            case 3: _dy = -1; break;
        }
    }

    if (_dx == 0 && _dy == 0)
        return false;


    // Pixel por pixel; nunca atraviesa colision.
    for (var _i = 0; _i < _p.dash_distance; _i++)
    {
        var _nx = _p.x + _dx;
        var _ny = _p.y + _dy;

        if (place_meeting(_nx, _ny, colision))
            break;

        _p.x = _nx;
        _p.y = _ny;
    }

    _p.movimiento = true;

    _p.dash_stamina =
        max(
            0,
            _p.dash_stamina - _p.dash_cost
        );

    _p.dash_recharge_frames = 0;
    _p.dash_hud_hold = 30;
    _p.dash_used_this_frame = true;

    if (_p.dash_stamina <= 0)
        _p.dash_zero_lock = true;

    return true;
}


// =========================================================
// PLAYER END STEP
// =========================================================

function scr_player_abilities_end_step(_p)
{
    if (!scr_player_abilities_init(_p))
        return;

    var _platformer =
        variable_global_exists("platformer_active")
        &&
        global.platformer_active;


    // -----------------------------------------------------
    // SIGILO: reducir distancia que ya resolvió el Step RPG.
    // -----------------------------------------------------

    var _ice_locked =
        variable_instance_exists(_p, "ice_anim_lock")
        &&
        _p.ice_anim_lock;

    var _downslide =
        variable_instance_exists(_p, "downslide_active")
        &&
        _p.downslide_active;

    if (
        _p.sigilo_activo
        &&
        !_platformer
        &&
        !_ice_locked
        &&
        !_downslide
    )
    {
        var _moved_x =
            _p.x - _p.ability_prev_x;

        var _moved_y =
            _p.y - _p.ability_prev_y;

        _p.x =
            _p.ability_prev_x
            +
            round(
                _moved_x
                *
                _p.sigilo_velocidad_mult
            );

        _p.y =
            _p.ability_prev_y
            +
            round(
                _moved_y
                *
                _p.sigilo_velocidad_mult
            );
    }


    // -----------------------------------------------------
    // DASH
    // -----------------------------------------------------

    if (!_platformer)
        scr_player_try_dash(_p);


    // -----------------------------------------------------
    // RECARGA
    // 5 segundos sin dash = +25.
    // Cada otros 5 segundos = +25.
    // -----------------------------------------------------

    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    var _recharge_needed =
        round(5 * _fps);

    if (!_p.dash_used_this_frame)
    {
        if (_p.dash_stamina < 100)
        {
            _p.dash_recharge_frames++;

            if (_p.dash_recharge_frames >= _recharge_needed)
            {
                _p.dash_recharge_frames = 0;

                _p.dash_stamina =
                    min(
                        100,
                        _p.dash_stamina + 25
                    );

                if (
                    _p.dash_zero_lock
                    &&
                    _p.dash_stamina >= 25
                )
                {
                    _p.dash_zero_lock = false;
                    _p.dash_hud_hold = 20;
                }
            }
        }
        else
        {
            _p.dash_recharge_frames = 0;
        }
    }


    // -----------------------------------------------------
    // ANIMACIÓN DEL HUD
    // -----------------------------------------------------

    if (_p.dash_hud_hold > 0)
        _p.dash_hud_hold--;

    var _hud_visible =
        _p.dash_hud_hold > 0
        ||
        _p.dash_zero_lock;

    var _hud_target =
        _hud_visible ? 1 : 0;

    _p.dash_hud_anim =
        lerp(
            _p.dash_hud_anim,
            _hud_target,
            0.22
        );

    if (
        abs(_p.dash_hud_anim - _hud_target) < 0.01
    )
    {
        _p.dash_hud_anim = _hud_target;
    }


    // -----------------------------------------------------
    // SPRITE DE SIGILO
    // -----------------------------------------------------

    if (
        _p.sigilo_activo
        &&
        !_platformer
        &&
        _p.sigilo_sprite != -1
        &&
        sprite_exists(_p.sigilo_sprite)
    )
    {
        if (_p.sprite_index != _p.sigilo_sprite)
        {
            _p.sprite_index = _p.sigilo_sprite;
            _p.image_index = 0;
        }

        _p.image_speed =
            _p.movimiento ? 0.15 : 0;
    }


    // -----------------------------------------------------
    // PERSISTENCIA
    // -----------------------------------------------------

    scr_habilidades_init();

    global.inventory_data.dash_stamina =
        _p.dash_stamina;

    global.inventory_data.dash_recharge_frames =
        _p.dash_recharge_frames;
}


// =========================================================
// DRAW GUI DE STAMINA
// =========================================================

function scr_player_abilities_draw_gui(_p)
{
    if (
        _p == noone
        ||
        !instance_exists(_p)
        ||
        !variable_instance_exists(_p, "dash_hud_anim")
        ||
        _p.dash_hud_anim <= 0.01
    )
    {
        return;
    }

    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    var _anim =
        clamp(_p.dash_hud_anim, 0, 1);

    var _w = 132;
    var _h = 10;

    var _x =
        (_gw - _w) * 0.5;

    var _target_y =
        _gh - 22;

    var _hidden_y =
        _gh + 8;

    var _y =
        lerp(
            _hidden_y,
            _target_y,
            _anim
        );

    var _ratio =
        clamp(
            _p.dash_stamina / 100,
            0,
            1
        );

    draw_set_alpha(_anim);

    // Borde.
    draw_set_color(c_black);
    draw_rectangle(
        _x - 2,
        _y - 2,
        _x + _w + 2,
        _y + _h + 2,
        false
    );


    if (_p.dash_stamina <= 0)
    {
        // A 0% TODA la barra queda roja y no desaparece
        // hasta recuperar por lo menos 25%.
        draw_set_color(c_red);
        draw_rectangle(
            _x,
            _y,
            _x + _w,
            _y + _h,
            false
        );
    }
    else
    {
        // Fondo vacío.
        draw_set_color(
            make_color_rgb(40, 40, 40)
        );

        draw_rectangle(
            _x,
            _y,
            _x + _w,
            _y + _h,
            false
        );

        // Stamina restante.
        draw_set_color(c_yellow);

        draw_rectangle(
            _x,
            _y,
            _x + (_w * _ratio),
            _y + _h,
            false
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);
}
