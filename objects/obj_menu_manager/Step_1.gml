/// =========================================================
/// OBJ_MENU_MANAGER
/// BEGIN STEP
/// =========================================================
///
/// Sistema funcional de:
///
///     PAUSA -> CONFIG -> CONTROLES
///
/// Cambios V3:
///
/// - Navegacion con repeticion al mantener Arriba / Abajo.
/// - Animacion de pestañas General / Controles.
/// - Animacion de ventana inferior de mensajes.
/// - Conserva el remapeo global ya funcional.
/// =========================================================


// =========================================================
// INICIALIZACION UNA SOLA VEZ
// =========================================================

if (
    !variable_instance_exists(
        id,
        "controls_system_ready"
    )
)
{
    controls_system_ready =
        true;


    controls_index =
        0;


    controls_scroll =
        0;


    controls_visible_rows =
        6;


    controls_listening =
        false;


    controls_wait_release =
        false;


    controls_message =
        "";


    controls_message_timer =
        0;


    controls_was_action =
        false;


    // -----------------------------------------------------
    // REPETICION AL MANTENER ARRIBA / ABAJO
    // -----------------------------------------------------

    controls_repeat_dir =
        0;


    controls_repeat_timer =
        0;


    controls_repeat_delay =
        10;


    controls_repeat_rate =
        3;


    // -----------------------------------------------------
    // ANIMACION DE PESTAÑAS CONFIG
    // -----------------------------------------------------

    controls_tab_slide =
        0;


    controls_tab_slide_speed =
        1 / 12;


    // -----------------------------------------------------
    // ANIMACION DE VENTANA INFERIOR
    // -----------------------------------------------------

    controls_notice_slide =
        0;


    controls_notice_slide_speed =
        1 / 12;


    // Texto que permanece guardado durante la animacion OUT.
    controls_notice_cached_text =
        "";


    controls_notice_cached_yellow =
        false;


    scr_config_data();

    scr_controls_apply();
}


// =========================================================
// ESTADOS GENERALES DE CONFIG
// =========================================================

var _config_visible =
(
    state == MENU_STATE.CONFIG_MENU

    ||

    state == MENU_STATE.CONFIG_ACTION
);


var _controls_tab_visible =
(
    config_tab == 1

    &&

    _config_visible
);


var _controls_action =
(
    config_tab == 1

    &&

    state == MENU_STATE.CONFIG_ACTION
);


// =========================================================
// ANIMACION DE PESTAÑAS GENERAL / CONTROLES
// =========================================================
//
// Exactamente la misma duracion que las pestañas:
//
//     INV / EQUIP / CLAVE
//
// 12 frames con ease-out cubico en Draw GUI End.
// =========================================================

if (_config_visible)
{
    controls_tab_slide =
        min(
            1,
            controls_tab_slide
            +
            controls_tab_slide_speed
        );
}
else
{
    controls_tab_slide =
        0;
}


// =========================================================
// MENSAJE TEMPORAL
// =========================================================

if (controls_message_timer > 0)
{
    controls_message_timer--;


    if (controls_message_timer <= 0)
    {
        controls_message =
            "";
    }
}


// =========================================================
// ANIMACION DE VENTANA INFERIOR
// =========================================================
//
// Activa cuando:
//
// - estamos esperando una tecla;
// - hay un mensaje temporal.
//
// ENTRADA:
//
//     0 -> 1
//
// SALIDA:
//
//     1 -> 0
//
// Se usa exactamente la misma variable y la misma velocidad,
// por lo que la salida es la animacion de entrada reproducida
// en reversa.
//
// Muy importante:
//
// mientras hace OUT conservamos el ultimo texto mostrado,
// aunque controls_message ya haya terminado.
/// =========================================================

var _notice_active =
(
    _controls_tab_visible

    &&

    (
        controls_listening

        ||

        (
            controls_message_timer > 0
            &&
            controls_message != ""
        )
    )
);


// =========================================================
// ACTUALIZAR TEXTO CACHEADO
// =========================================================

if (_notice_active)
{
    if (controls_listening)
    {
        controls_notice_cached_text =
            "Pulsa una tecla... ESC cancela";


        controls_notice_cached_yellow =
            true;
    }
    else
    {
        controls_notice_cached_text =
            controls_message;


        controls_notice_cached_yellow =
            false;
    }
}


// =========================================================
// ENTRADA / SALIDA
// =========================================================

if (_notice_active)
{
    controls_notice_slide =
        min(
            1,
            controls_notice_slide
            +
            controls_notice_slide_speed
        );
}
else
{
    controls_notice_slide =
        max(
            0,
            controls_notice_slide
            -
            controls_notice_slide_speed
        );
}


// =========================================================
// SI SALIMOS DE CONTROLES MIENTRAS CAPTURABAMOS
// =========================================================

if (!_controls_tab_visible)
{
    if (controls_listening)
    {
        controls_listening =
            false;


        controls_wait_release =
            false;


        scr_controls_apply();
    }


    controls_was_action =
        false;


    controls_repeat_dir =
        0;


    controls_repeat_timer =
        0;


    exit;
}


// =========================================================
// ACABAMOS DE ENTRAR A LA LISTA
// =========================================================

if (
    _controls_action
    &&
    !controls_was_action
)
{
    controls_index =
        0;


    controls_scroll =
        0;


    controls_repeat_dir =
        0;


    controls_repeat_timer =
        0;
}


controls_was_action =
    _controls_action;


// =========================================================
// CAPTURA DE TECLA
// =========================================================
//
// Mientras capturamos:
//
//     keyboard_unset_map()
//
// permanece activo para leer la tecla FISICA real.
// =========================================================

if (controls_listening)
{
    controls_repeat_dir =
        0;


    controls_repeat_timer =
        0;


    // -----------------------------------------------------
    // ESCAPE = CANCELAR
    // -----------------------------------------------------

    if (keyboard_check_pressed(vk_escape))
    {
        keyboard_clear(
            vk_escape
        );


        controls_listening =
            false;


        controls_wait_release =
            false;


        scr_controls_apply();


        controls_message =
            "Cambio cancelado";


        controls_message_timer =
            30;
    }

    // -----------------------------------------------------
    // ESPERAR A SOLTAR LA TECLA QUE ABRIO LA CAPTURA
    // -----------------------------------------------------

    else if (controls_wait_release)
    {
        if (!keyboard_check(vk_anykey))
        {
            controls_wait_release =
                false;
        }
    }

    // -----------------------------------------------------
    // LEER NUEVA TECLA
    // -----------------------------------------------------

    else if (keyboard_check_pressed(vk_anykey))
    {
        var _new_key =
            keyboard_lastkey;


        // Consumirla mientras el mapa aun esta desactivado.
        keyboard_clear(
            _new_key
        );


        if (scr_controls_key_valid(_new_key))
        {
            scr_controls_set_key(
                controls_index,
                _new_key
            );


            controls_listening =
                false;


            controls_wait_release =
                false;


            controls_message =
                "Control actualizado";


            controls_message_timer =
                30;


            audio_play_sound(
                snd_menumove,
                10,
                false
            );
        }
        else
        {
            controls_message =
                "Tecla no disponible";


            controls_message_timer =
                45;


            if (audio_is_playing(snd_error))
            {
                audio_stop_sound(
                    snd_error
                );
            }


            audio_play_sound(
                snd_error,
                10,
                false
            );
        }
    }


    // -----------------------------------------------------
    // BLOQUEAR EL STEP NORMAL DEL MENU
    // -----------------------------------------------------

    keyboard_clear(vk_up);
    keyboard_clear(vk_down);
    keyboard_clear(vk_left);
    keyboard_clear(vk_right);

    keyboard_clear(ord("Z"));
    keyboard_clear(ord("X"));
    keyboard_clear(ord("C"));

    keyboard_clear(vk_enter);
    keyboard_clear(vk_shift);
    keyboard_clear(vk_control);


    exit;
}


// =========================================================
// AUN ESTAMOS EN LAS PESTAÑAS GENERAL / CONTROLES
// =========================================================
//
// CONFIG_MENU sigue siendo controlado por el Step normal:
//
//     Izquierda / Derecha
//         cambia de pestaña.
//
//     Z / Enter
//         entra a la pestaña.
//
// =========================================================

if (!_controls_action)
{
    controls_repeat_dir =
        0;


    controls_repeat_timer =
        0;


    exit;
}


// =========================================================
// LISTA
// =========================================================
//
// 0 Abajo
// 1 Derecha
// 2 Arriba
// 3 Izquierda
// 4 Confirmar
// 5 Cancelar/Correr
// 6 Menu
// 7 Restaurar predeterminado
// =========================================================

var _total =
    8;


// =========================================================
// REPETICION AL MANTENER ARRIBA / ABAJO
// =========================================================
//
// Comportamiento:
//
// 1. Al pulsar:
//      mueve inmediatamente.
//
// 2. Si se mantiene:
//      espera controls_repeat_delay frames.
//
// 3. Despues:
//      repite cada controls_repeat_rate frames.
//
// A 30 FPS:
//
//     delay = 10
//         ~0.33 s
//
//     rate = 3
//         ~10 movimientos por segundo
// =========================================================

var _held_dir =
    0;


if (
    keyboard_check(vk_down)
    &&
    !keyboard_check(vk_up)
)
{
    _held_dir =
        1;
}
else if (
    keyboard_check(vk_up)
    &&
    !keyboard_check(vk_down)
)
{
    _held_dir =
        -1;
}


var _should_move =
    false;


var _first_press =
    false;


if (_held_dir == 0)
{
    controls_repeat_dir =
        0;


    controls_repeat_timer =
        0;
}
else if (_held_dir != controls_repeat_dir)
{
    controls_repeat_dir =
        _held_dir;


    controls_repeat_timer =
        0;


    _should_move =
        true;


    _first_press =
        true;
}
else
{
    controls_repeat_timer++;


    if (
        controls_repeat_timer
        >=
        controls_repeat_delay
    )
    {
        if (
            (
                controls_repeat_timer
                -
                controls_repeat_delay
            )
            mod
            controls_repeat_rate
            ==
            0
        )
        {
            _should_move =
                true;
        }
    }
}


// =========================================================
// RUEDA DEL MOUSE
// =========================================================

var _wheel_move =
    0;


if (mouse_wheel_down())
{
    _wheel_move =
        1;
}


if (mouse_wheel_up())
{
    _wheel_move =
        -1;
}


// =========================================================
// APLICAR MOVIMIENTO
// =========================================================

var _old_index =
    controls_index;


if (_should_move)
{
    controls_index =
        clamp(
            controls_index
            +
            _held_dir,
            0,
            _total - 1
        );
}


if (_wheel_move != 0)
{
    controls_index =
        clamp(
            controls_index
            +
            _wheel_move,
            0,
            _total - 1
        );
}


// Reproducir sonido.
//
// La primera pulsacion de flecha tambien llega al Step
// normal de CONFIG_ACTION, que ya reproduce snd_menumove.
// Evitamos duplicarlo.
//
// Las repeticiones y la rueda SI necesitan sonido aqui.
if (controls_index != _old_index)
{
    if (
        !_first_press
        ||
        _wheel_move != 0
    )
    {
        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }
}


// =========================================================
// SCROLL AUTOMATICO
// =========================================================

var _max_scroll =
    max(
        0,
        _total
        -
        controls_visible_rows
    );


if (
    controls_index
    <
    controls_scroll
)
{
    controls_scroll =
        controls_index;
}


if (
    controls_index
    >=
    controls_scroll
    +
    controls_visible_rows
)
{
    controls_scroll =
        controls_index
        -
        controls_visible_rows
        +
        1;
}


controls_scroll =
    clamp(
        controls_scroll,
        0,
        _max_scroll
    );


// =========================================================
// CONFIRMAR FILA
// =========================================================

if (
    keyboard_check_pressed(ord("Z"))
    ||
    keyboard_check_pressed(vk_enter)
)
{
    // Consumirla para que el Step normal no la reutilice.
    keyboard_clear(
        ord("Z")
    );


    keyboard_clear(
        vk_enter
    );


    // -----------------------------------------------------
    // REMAPEAR UNA ACCION
    // -----------------------------------------------------

    if (controls_index < 7)
    {
        controls_listening =
            true;


        controls_wait_release =
            true;


        controls_message =
            "";


        controls_message_timer =
            0;


        controls_notice_slide =
            0;


        // La siguiente tecla debe leerse fisicamente.
        keyboard_unset_map();
    }

    // -----------------------------------------------------
    // RESTAURAR PREDETERMINADOS
    // -----------------------------------------------------

    else
    {
        scr_controls_reset();


        controls_message =
            "Predeterminados restaurados";


        controls_message_timer =
            45;


        controls_notice_slide =
            0;


        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }
}
