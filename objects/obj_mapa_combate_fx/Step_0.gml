/// =========================================================
/// OBJ_MAPA_COMBATE_FX
/// STEP
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


// =========================================================
// FADE DEL EFECTO DE PELIGRO
// =========================================================
//
// La oscuridad y el rojo de Maya usan la misma transición.
// Si sales y vuelves a entrar durante el fade, se invierte
// desde el punto exacto en el que se encontraba.
// =========================================================

if (danger_active)
{
    oscuridad_base =
        max(
            oscuridad_base,
            oscuridad_actual
        );


    // Si aparece un enemigo con una oscuridad distinta
    // mientras ya estamos dentro del peligro, actualizar
    // también hacia su valor actual.
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

if (danger_active)
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
