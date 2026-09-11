/// =========================================================
/// OBJ_MENU_MANAGER
/// END STEP
/// =========================================================
///
/// AJUSTES EXCLUSIVOS DEL MODO PLATAFORMERO:
///
/// - añade una sexta opción debajo de CERRAR;
/// - permite intercambiar salto/ataque;
/// - bloquea TOYS;
/// - bloquea entrar a EQUIP para cambiar equipo.
///
/// Se hace en End Step para conservar intacta toda la lógica
/// existente del menú.
/// =========================================================

scr_platformer_init();


if (
    !variable_instance_exists(
        id,
        "platform_main_ready"
    )
)
{
    platform_main_ready =
        true;


    platform_main_index =
        clamp(
            main_index,
            0,
            4
        );


    platform_main_was_active =
        false;
}


var _platform_mode =
    global.platformer_active;


// =========================================================
// FUERA DEL PLATAFORMERO
// =========================================================

if (!_platform_mode)
{
    platform_main_was_active =
        false;


    platform_main_index =
        clamp(
            main_index,
            0,
            4
        );


    exit;
}


// =========================================================
// ACABAMOS DE ENTRAR AL MODO
// =========================================================

if (!platform_main_was_active)
{
    platform_main_index =
        clamp(
            main_index,
            0,
            4
        );
}


platform_main_was_active =
    true;


// =========================================================
// SEXTA OPCIÓN: INTERCAMBIAR SALTO / ATAQUE
// =========================================================
//
// Durante Step, la sexta opción usa main_index = 4 como
// sustituto. Por eso el Step normal intentará abrir CERRAR.
//
// Aquí reconocemos ese caso y lo convertimos en el cambio
// de controles solicitado.
// =========================================================

if (
    state == MENU_STATE.GAME_CLOSE_CONFIRM
    &&
    platform_main_index == 5
    &&
    (
        keyboard_check_pressed(
            ord("Z")
        )
        ||
        keyboard_check_pressed(
            vk_enter
        )
    )
)
{
    state =
        MENU_STATE.MAIN;


    scr_platformer_toggle_controls();


    main_index =
        4;


    keyboard_clear(
        ord("Z")
    );


    keyboard_clear(
        vk_enter
    );


    exit;
}


// =========================================================
// BLOQUEO DE TOYS
// =========================================================
//
// El Step normal pudo intentar entrar a TOYS este mismo frame.
//
// Lo devolvemos inmediatamente a MAIN antes de dibujar.
// =========================================================

if (
    state >= MENU_STATE.TOY_MENU
    &&
    state <= MENU_STATE.TOY_DROP_CONFIRM
)
{
    state =
        MENU_STATE.MAIN;


    platform_main_index =
        1;


    main_index =
        1;


    if (audio_is_playing(snd_menumove))
    {
        audio_stop_sound(
            snd_menumove
        );
    }


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


    keyboard_clear(
        ord("Z")
    );


    keyboard_clear(
        vk_enter
    );


    exit;
}


// =========================================================
// BLOQUEO DE EQUIPAMIENTO
// =========================================================
//
// EQUIP puede seguir viéndose como pestaña.
//
// Pero al confirmar la pestaña no se puede entrar a sus slots,
// así que no existe ninguna ruta para equipar/cambiar equipo.
// =========================================================

if (
    state == MENU_STATE.EQUIP_MENU
    &&
    !inventory_tab_focus
    &&
    (
        keyboard_check_pressed(
            ord("Z")
        )
        ||
        keyboard_check_pressed(
            vk_enter
        )
    )
)
{
    inventory_tab_focus =
        true;


    equip_x =
        0;


    equip_y =
        0;


    equip_scroll =
        0;


    if (audio_is_playing(snd_menumove))
    {
        audio_stop_sound(
            snd_menumove
        );
    }


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


    keyboard_clear(
        ord("Z")
    );


    keyboard_clear(
        vk_enter
    );


    exit;
}


// Failsafe por si otro código dejó abierto un submenú EQUIP.
if (
    state == MENU_STATE.EQUIP_ACTION
    ||
    state == MENU_STATE.EQUIP_INFO
    ||
    state == MENU_STATE.EQUIP_DROP_CONFIRM
)
{
    state =
        MENU_STATE.EQUIP_MENU;


    inventory_tab =
        1;


    inventory_tab_focus =
        true;


    equip_x =
        0;


    equip_y =
        0;


    equip_scroll =
        0;


    exit;
}


// =========================================================
// MENÚ PRINCIPAL CON 6 OPCIONES
// =========================================================
//
// 0 INV
// 1 TOYS          bloqueado
// 2 STAD
// 3 CONFIG
// 4 CERRAR
// 5 CAMBIAR Z/X
//
// El Step normal sigue creyendo que existen 5 opciones.
//
// Para la sexta usamos main_index = 4 como índice sustituto
// durante Step y corregimos aquí el estado final.
// =========================================================

if (state == MENU_STATE.MAIN)
{
    var _up =
        keyboard_check_pressed(
            vk_up
        );


    var _down =
        keyboard_check_pressed(
            vk_down
        );


    if (_down)
    {
        platform_main_index =
            (
                platform_main_index
                +
                1
            )
            mod
            6;
    }


    if (_up)
    {
        platform_main_index =
            (
                platform_main_index
                -
                1
                +
                6
            )
            mod
            6;
    }


    var _confirm =
    (
        keyboard_check_pressed(
            ord("Z")
        )
        ||
        keyboard_check_pressed(
            vk_enter
        )
    );


    if (_confirm)
    {
        // ---------------------------------------------
        // TOYS BLOQUEADO
        // ---------------------------------------------

        if (platform_main_index == 1)
        {
            state =
                MENU_STATE.MAIN;


            if (audio_is_playing(snd_menumove))
            {
                audio_stop_sound(
                    snd_menumove
                );
            }


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


            keyboard_clear(
                ord("Z")
            );


            keyboard_clear(
                vk_enter
            );
        }

        // ---------------------------------------------
        // INTERCAMBIAR SALTO / ATAQUE
        // ---------------------------------------------

        else if (platform_main_index == 5)
        {
            // El Step normal habrá interpretado temporalmente
            // main_index=4 como CERRAR. Cancelamos ese estado.
            state =
                MENU_STATE.MAIN;


            scr_platformer_toggle_controls();


            keyboard_clear(
                ord("Z")
            );


            keyboard_clear(
                vk_enter
            );
        }
    }


    // La sexta opción necesita un índice sustituto para que
    // el Step normal no salga del rango de main_options.
    main_index =
        min(
            platform_main_index,
            4
        );
}
