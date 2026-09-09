/// =========================================================
/// OBJ_CONTROLS_MANAGER
/// STEP
/// =========================================================


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
// NECESITAMOS EL MENU PRINCIPAL
// =========================================================

if (!instance_exists(obj_menu_manager))
{
    if (controls_listening)
    {
        controls_listening =
            false;

        controls_wait_release =
            false;

        scr_controls_apply();
    }


    controls_last_state =
        -1;

    exit;
}


var _menu =
    instance_find(
        obj_menu_manager,
        0
    );


// =========================================================
// ¿ESTAMOS EN CONFIG -> CONTROLES?
// =========================================================

var _controls_visible =
(
    _menu.config_tab == 1
    &&
    (
        _menu.state
        ==
        MENU_STATE.CONFIG_MENU

        ||

        _menu.state
        ==
        MENU_STATE.CONFIG_ACTION
    )
);


if (!_controls_visible)
{
    if (controls_listening)
    {
        controls_listening =
            false;

        controls_wait_release =
            false;

        scr_controls_apply();
    }


    controls_last_state =
        _menu.state;

    exit;
}


// =========================================================
// ACABAMOS DE ENTRAR A LA LISTA
// =========================================================

if (
    _menu.state
    ==
    MENU_STATE.CONFIG_ACTION

    &&

    controls_last_state
    !=
    MENU_STATE.CONFIG_ACTION
)
{
    control_index =
        0;

    control_scroll =
        0;
}


controls_last_state =
    _menu.state;


// =========================================================
// CAPTURANDO UNA TECLA
// =========================================================

if (controls_listening)
{
    // -----------------------------------------------------
    // ESCAPE CANCELA
    // -----------------------------------------------------

    if (keyboard_check_pressed(vk_escape))
    {
        controls_listening =
            false;

        controls_wait_release =
            false;


        scr_controls_apply();


        controls_message =
            "Cambio cancelado";

        controls_message_timer =
            30;


        keyboard_clear(
            vk_escape
        );


        exit;
    }


    // -----------------------------------------------------
    // ESPERAR A QUE SE SUELTE LA TECLA QUE ABRIO LA CAPTURA
    // -----------------------------------------------------
    //
    // Si Confirmar actualmente fuese A, la pulsacion A que
    // abrio este modo no debe convertirse inmediatamente en
    // la nueva asignacion.
    // -----------------------------------------------------

    if (controls_wait_release)
    {
        if (!keyboard_check(vk_anykey))
        {
            controls_wait_release =
                false;
        }


        // Impedir que el menu normal reaccione mientras
        // estamos esperando.
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


    // -----------------------------------------------------
    // NUEVA TECLA
    // -----------------------------------------------------

    if (keyboard_check_pressed(vk_anykey))
    {
        var _new_key =
            keyboard_lastkey;


        if (scr_controls_key_valid(_new_key))
        {
            if (
                scr_controls_set_key(
                    control_index,
                    _new_key
                )
            )
            {
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


        // -------------------------------------------------
        // EVITAR QUE LA MISMA PULSACION AFECTE AL MENU
        // -------------------------------------------------

        keyboard_clear(
            _new_key
        );


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
    }


    exit;
}


// =========================================================
// EN LA PESTAÑA, PERO AUN NO EN LA LISTA
// =========================================================

if (
    _menu.state
    !=
    MENU_STATE.CONFIG_ACTION
)
{
    exit;
}


// =========================================================
// NAVEGACION DE LA LISTA
// =========================================================

var _total_rows =
    8;


var _moved =
    false;


// ---------------------------------------------------------
// ABAJO
// ---------------------------------------------------------

if (
    keyboard_check_pressed(vk_down)
    ||
    mouse_wheel_down()
)
{
    control_index =
        min(
            control_index + 1,
            _total_rows - 1
        );

    _moved =
        true;
}


// ---------------------------------------------------------
// ARRIBA
// ---------------------------------------------------------

if (
    keyboard_check_pressed(vk_up)
    ||
    mouse_wheel_up()
)
{
    control_index =
        max(
            control_index - 1,
            0
        );

    _moved =
        true;
}


// El propio obj_menu_manager ya reproduce snd_menumove
// cuando usamos Arriba/Abajo dentro de CONFIG_ACTION.
//
// Solo reproducimos sonido aqui si el movimiento vino
// exclusivamente de la rueda del mouse.
if (_moved)
{
    var _mouse_only =
    (
        !keyboard_check_pressed(vk_down)
        &&
        !keyboard_check_pressed(vk_up)
    );


    if (_mouse_only)
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
        _total_rows
        -
        controls_visible_rows
    );


if (
    control_index
    <
    control_scroll
)
{
    control_scroll =
        control_index;
}


if (
    control_index
    >=
    control_scroll
    +
    controls_visible_rows
)
{
    control_scroll =
        control_index
        -
        controls_visible_rows
        +
        1;
}


control_scroll =
    clamp(
        control_scroll,
        0,
        _max_scroll
    );


// =========================================================
// CONFIRMAR
// =========================================================

if (
    keyboard_check_pressed(ord("Z"))
    ||
    keyboard_check_pressed(vk_enter)
)
{
    // -----------------------------------------------------
    // CAMBIAR UNA TECLA
    // -----------------------------------------------------

    if (control_index < 7)
    {
        controls_listening =
            true;

        controls_wait_release =
            true;


        controls_message =
            "";

        controls_message_timer =
            0;


        // MUY IMPORTANTE:
        //
        // Mientras capturamos necesitamos leer la tecla
        // FISICA real, no la tecla ya remapeada.
        keyboard_unset_map();


        // Evitar que el Z/Enter que entro aqui se reutilice
        // en el menu normal durante este frame.
        keyboard_clear(
            ord("Z")
        );

        keyboard_clear(
            vk_enter
        );
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


        audio_play_sound(
            snd_menumove,
            10,
            false
        );


        keyboard_clear(
            ord("Z")
        );

        keyboard_clear(
            vk_enter
        );
    }
}
