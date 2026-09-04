/// =========================================================
/// OBJETO "game"
/// END STEP
///
/// GAME OVER UNIVERSAL
/// =========================================================
//
// Detecta HP <= 0 independientemente de si el daño vino de:
//
//     obj_damage_test
//     batalla
//     una cinemática
//     cualquier otro sistema futuro
//
// A 30 FPS:
//
//     30 frames = 1 segundo exacto.
//
// =========================================================


// =========================================================
// ASEGURAR FLAG
// =========================================================

if (
    !variable_global_exists(
        "gameover_death_freeze_active"
    )
)
{
    global.gameover_death_freeze_active =
        false;
}


// =========================================================
// YA ESTAMOS EN GAME OVER
// =========================================================
//
// Seguridad adicional.
//
// obj_game_over_texto también limpia este flag en Create,
// pero así no dependemos de su orden de creación.
// =========================================================

if (room == game_over)
{
    if (global.gameover_death_freeze_active)
    {
        global.gameover_death_freeze_active =
            false;

        death_freeze_timer =
            0;

        scr_cutscene_world_unlock();
    }

    exit;
}


// =========================================================
// SEGUNDO DE CONGELACIÓN
// =========================================================

if (global.gameover_death_freeze_active)
{
    // =====================================================
    // SILENCIO ABSOLUTO DURANTE TODO EL SEGUNDO DE MUERTE
    // =====================================================
    //
    // Esto se ejecuta CADA FRAME del congelamiento.
    // Si cualquier objeto alcanzara a iniciar un sonido,
    // se corta inmediatamente en este mismo End Step.
    // =====================================================

    audio_stop_all();


    // Mantener inputs principales consumidos.
    keyboard_clear(ord("C"));
    keyboard_clear(vk_control);

    keyboard_clear(ord("Z"));
    keyboard_clear(vk_enter);

    keyboard_clear(ord("X"));
    keyboard_clear(vk_shift);

    keyboard_clear(vk_left);
    keyboard_clear(vk_right);
    keyboard_clear(vk_up);
    keyboard_clear(vk_down);


    // -----------------------------------------------------
    // MANTENER PLAYER TOTALMENTE QUIETO
    // -----------------------------------------------------

    if (instance_exists(obj_player))
    {
        var _p =
            instance_find(
                obj_player,
                0
            );


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


        if (
            variable_instance_exists(
                _p,
                "movimiento"
            )
        )
        {
            _p.movimiento =
                false;
        }


        _p.hspeed =
            0;

        _p.vspeed =
            0;

        _p.speed =
            0;

        _p.image_speed =
            0;
    }


    // -----------------------------------------------------
    // CONTAR 30 FRAMES
    // -----------------------------------------------------

    death_freeze_timer++;


    if (death_freeze_timer >= 30)
    {
        death_freeze_timer =
            30;


        // La música anterior estaba pausada.
        // La eliminamos antes de entrar a Game Over.
        audio_stop_all();


        // NO quitamos todavía el flag aquí.
        //
        // game_over / obj_game_over_texto lo limpiarán
        // al entrar, evitando que haya un frame intermedio
        // donde el juego vuelva a actuar.
        room_goto(
            game_over
        );


        exit;
    }


    exit;
}


// =========================================================
// DETECTAR MUERTE
// =========================================================

if (instance_exists(obj_player))
{
    var _p =
        instance_find(
            obj_player,
            0
        );


    if (
        variable_instance_exists(
            _p,
            "hp"
        )
        &&
        _p.hp <= 0
    )
    {
        // Asegurar que nunca sea negativo.
        _p.hp =
            0;


        if (
            variable_global_exists(
                "player_hp_current"
            )
        )
        {
            global.player_hp_current =
                0;
        }


        // ================================================
        // INICIAR CONGELACIÓN
        // ================================================

        global.gameover_death_freeze_active =
            true;


        death_freeze_timer =
            0;


        // Congela los objetos de mundo que ya utilizan
        // el sistema de bloqueo de cinemáticas:
        //
        // obj_batalla
        // obj_damage_test
        // obj_music_trigger
        // obj_warp_block
        scr_cutscene_world_lock();


        // ================================================
        // CERRAR MENÚ DE PAUSA
        // ================================================

        if (instance_exists(obj_menu_manager))
        {
            obj_menu_manager.state =
                MENU_STATE.CLOSED;
        }


        // ================================================
        // BLOQUEAR PLAYER
        // ================================================

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


        if (
            variable_instance_exists(
                _p,
                "movimiento"
            )
        )
        {
            _p.movimiento =
                false;
        }


        _p.hspeed =
            0;

        _p.vspeed =
            0;

        _p.speed =
            0;


        // ================================================
        // CONGELAR ANIMACIONES AUTOMÁTICAS DE LA ROOM
        // ================================================
        //
        // No necesitamos restaurarlas:
        // después de 30 frames abandonamos esta room.
        // ================================================

        with (all)
        {
            image_speed =
                0;
        }


        // ================================================
        // CALLAR TODO EL AUDIO DURANTE EL SEGUNDO
        // ================================================
        //
        // Se DETIENE por completo en vez de pausarse.
        // Así no queda ningún snd_, voz, música o efecto
        // sonando durante el segundo de muerte.
        // ================================================

        audio_stop_all();


        // ================================================
        // CONSUMIR INPUT
        // ================================================

        keyboard_clear(ord("C"));
        keyboard_clear(vk_control);

        keyboard_clear(ord("Z"));
        keyboard_clear(vk_enter);

        keyboard_clear(ord("X"));
        keyboard_clear(vk_shift);

        keyboard_clear(vk_left);
        keyboard_clear(vk_right);
        keyboard_clear(vk_up);
        keyboard_clear(vk_down);


        exit;
    }
}
