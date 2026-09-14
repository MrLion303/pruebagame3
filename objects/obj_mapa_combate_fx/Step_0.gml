/// =========================================================
/// OBJ_MAPA_COMBATE_FX
/// STEP COMPLETO
/// =========================================================


// =========================================================
// GAME OVER - CONGELACIÓN DE 1 SEGUNDO
// =========================================================

if (
    variable_global_exists(
        "gameover_death_freeze_active"
    )
    &&
    global.gameover_death_freeze_active
)
{
    if (death_timer > 0)
    {
        death_timer--;


        if (death_timer <= 0)
        {
            room_goto(
                game_over
            );
        }
    }


    exit;
}


// =========================================================
// ENCONTRAR SI HAY ALGÚN ENEMIGO EN ALERTA
// =========================================================

danger_active =
    false;


oscuridad_actual =
    0;


with (obj_enemigo_mapa_parent)
{
    if (
        variable_instance_exists(
            id,
            "en_alerta"
        )
        &&
        en_alerta
    )
    {
        other.danger_active =
            true;


        if (
            variable_instance_exists(
                id,
                "oscuridad"
            )
        )
        {
            other.oscuridad_actual =
                max(
                    other.oscuridad_actual,
                    oscuridad
                );
        }
    }
}


var _platformer_mode =
(
    variable_global_exists(
        "platformer_active"
    )
    &&
    global.platformer_active
);


var _platformer_menu_open =
(
    _platformer_mode
    &&
    instance_exists(obj_menu_manager)
    &&
    obj_menu_manager.state != MENU_STATE.CLOSED
);


// =========================================================
// BLOQUEAR MENÚ DE PAUSA DURANTE PELIGRO
// =========================================================
//
// En RPG se conserva el bloqueo antiguo.
// En plataformero el cierre real lo gestiona obj_menu_manager
// End Step según el rango de ataque, para poder cerrarlo incluso
// si el enemigo entra al rango DESPUÉS de abrir el menú.
// =========================================================

if (
    danger_active
    &&
    !_platformer_mode
)
{
    keyboard_clear(
        ord("C")
    );


    keyboard_clear(
        vk_control
    );


    if (instance_exists(obj_menu_manager))
    {
        var _menu =
            instance_find(
                obj_menu_manager,
                0
            );


        if (_menu != noone)
        {
            _menu.state =
                MENU_STATE.CLOSED;


            if (
                variable_instance_exists(
                    _menu,
                    "inventory_tab_focus"
                )
            )
            {
                _menu.inventory_tab_focus =
                    false;
            }
        }
    }
}


// =========================================================
// FADE DEL EFECTO DE PELIGRO
// =========================================================
//
// CORRECCIÓN DEL PARPADEO/DESFASE EN PLATAFORMERO:
//
// Si un enemigo entra al rango mientras el inventario está
// abierto, obj_menu_manager lo cierra en End Step. Antes, este
// objeto ya había avanzado fx_anim durante Step y Draw GUI podía
// mostrar durante ese único frame una copia roja desfasada.
//
// Mientras el menú plataforma siga abierto EN STEP, mantenemos
// el FX visual en 0. El enemigo y toda su lógica siguen activos.
// Cuando el menú ya está cerrado, el fade comienza limpio desde
// el frame siguiente.
// =========================================================

if (_platformer_menu_open)
{
    fx_anim =
        0;


    oscuridad_base =
        0;
}
else if (danger_active)
{
    oscuridad_base =
        oscuridad_actual;


    fx_anim =
        min(
            1,
            fx_anim
            +
            fx_anim_speed
        );
}
else
{
    fx_anim =
        max(
            0,
            fx_anim
            -
            fx_anim_speed
        );


    if (fx_anim <= 0)
    {
        oscuridad_base =
            0;
    }
}


// =========================================================
// ANIMACIÓN DEL HUD
// =========================================================

if (_platformer_menu_open)
{
    hud_anim =
        0;


    hud_hp_anterior =
        -1;


    hud_timer_dolor =
        0;
}
else if (danger_active)
{
    hud_anim =
        min(
            1,
            hud_anim
            +
            hud_anim_speed
        );
}
else
{
    hud_anim =
        max(
            0,
            hud_anim
            -
            hud_anim_speed
        );


    if (hud_anim <= 0)
    {
        hud_hp_anterior =
            -1;


        hud_timer_dolor =
            0;
    }
}


// =========================================================
// PLAYER
// =========================================================

if (
    !instance_exists(
        obj_player
    )
)
{
    exit;
}


var _p =
    instance_find(
        obj_player,
        0
    );


// I-frames.
if (
    !variable_instance_exists(
        _p,
        "map_battle_iframes"
    )
)
{
    _p.map_battle_iframes =
        0;
}


if (_p.map_battle_iframes > 0)
{
    _p.map_battle_iframes--;
}


// =========================================================
// MUERTE
// =========================================================

if (_p.hp <= 0)
{
    _p.hp =
        0;


    global.player_hp_current =
        0;


    global.gameover_death_freeze_active =
        true;


    // 30 frames = 1 segundo.
    death_timer =
        30;


    if (
        variable_instance_exists(
            _p,
            "puede_moverse"
        )
    )
    {
        _p.puede_moverse =
            false;
    }


    if (
        variable_instance_exists(
            _p,
            "can_move"
        )
    )
    {
        _p.can_move =
            false;
    }


    _p.hspeed =
        0;


    _p.vspeed =
        0;


    _p.speed =
        0;
}
