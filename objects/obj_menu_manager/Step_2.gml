/// =========================================================
/// OBJ_MENU_MANAGER
/// END STEP COMPLETO
/// =========================================================
///
/// 1) STAD / HABIL integrado DIRECTAMENTE en este objeto.
/// 2) Conserva todos los ajustes del modo plataformero.
/// =========================================================


// =========================================================
// STAD / HABIL - INICIALIZACIÓN
// =========================================================

if (
    !variable_instance_exists(
        id,
        "stad_tabs_ready"
    )
)
{
    stad_tabs_ready =
        true;

    // 0 = STAD
    // 1 = HABIL
    stad_tab =
        0;

    stad_tab_slide =
        0;

    stad_tab_slide_speed =
        1 / 12;

    habil_index =
        0;

    habil_scroll =
        0;

    habil_visible_rows =
        5;

    habil_info_open =
        false;

    habil_info_id =
        "";

    stad_was_active =
        false;
}


// =========================================================
// SI STEP NORMAL INTENTÓ SALIR CON X MIENTRAS HABÍA INFO
// =========================================================
//
// Step_0 procesa X antes que End Step.
//
// Si había un cuadro de información de habilidad abierto,
// reinterpretamos ese X como "cerrar cuadro", no "salir de
// STAD".
// =========================================================

if (
    habil_info_open
    &&
    state == MENU_STATE.MAIN
    &&
    (
        keyboard_check_pressed(
            ord("X")
        )
        ||
        keyboard_check_pressed(
            vk_shift
        )
    )
)
{
    state =
        MENU_STATE.INFO_MENU;

    habil_info_open =
        false;

    habil_info_id =
        "";

    keyboard_clear(
        ord("X")
    );

    keyboard_clear(
        vk_shift
    );

    audio_play_sound(
        snd_menumove,
        10,
        false
    );
}


// =========================================================
// ESTADO STAD
// =========================================================

var _stad_active =
    (
        state
        ==
        MENU_STATE.INFO_MENU
    );


if (_stad_active)
{
    // ---------------------------------------------
    // ACABAMOS DE ENTRAR
    // ---------------------------------------------

    if (!stad_was_active)
    {
        stad_tab =
            0;

        stad_tab_slide =
            0;

        habil_index =
            0;

        habil_scroll =
            0;

        habil_info_open =
            false;

        habil_info_id =
            "";
    }


    stad_was_active =
        true;


    // ---------------------------------------------
    // ANIMACIÓN DE LA CAJA DE PESTAÑAS
    // ---------------------------------------------

    stad_tab_slide =
        min(
            1,
            stad_tab_slide
            +
            stad_tab_slide_speed
        );


    var _habilidades =
        scr_habilidades_lista_obtenidas();


    var _habil_total =
        array_length(
            _habilidades
        );


    if (_habil_total <= 0)
    {
        habil_index =
            0;

        habil_scroll =
            0;
    }
    else
    {
        habil_index =
            clamp(
                habil_index,
                0,
                _habil_total - 1
            );
    }


    // ---------------------------------------------
    // INFO ABIERTA
    // ---------------------------------------------

    if (habil_info_open)
    {
        if (
            keyboard_check_pressed(
                ord("Z")
            )
            ||
            keyboard_check_pressed(
                vk_enter
            )
        )
        {
            habil_info_open =
                false;

            habil_info_id =
                "";

            keyboard_clear(
                ord("Z")
            );

            keyboard_clear(
                vk_enter
            );

            audio_play_sound(
                snd_menumove,
                10,
                false
            );
        }
    }

    // ---------------------------------------------
    // NAVEGACIÓN NORMAL
    // ---------------------------------------------

    else
    {
        var _tab_changed =
            false;


        if (
            keyboard_check_pressed(
                vk_right
            )
        )
        {
            stad_tab =
                (stad_tab + 1)
                mod
                2;

            _tab_changed =
                true;
        }


        if (
            keyboard_check_pressed(
                vk_left
            )
        )
        {
            stad_tab =
                (stad_tab - 1 + 2)
                mod
                2;

            _tab_changed =
                true;
        }


        if (_tab_changed)
        {
            habil_index =
                0;

            habil_scroll =
                0;

            audio_play_sound(
                snd_menumove,
                10,
                false
            );
        }


        // -----------------------------------------
        // HABIL
        // -----------------------------------------

        if (stad_tab == 1)
        {
            var _habil_moved =
                false;


            if (
                _habil_total > 0
                &&
                keyboard_check_pressed(
                    vk_down
                )
            )
            {
                habil_index =
                    min(
                        _habil_total - 1,
                        habil_index + 1
                    );

                _habil_moved =
                    true;
            }


            if (
                _habil_total > 0
                &&
                keyboard_check_pressed(
                    vk_up
                )
            )
            {
                habil_index =
                    max(
                        0,
                        habil_index - 1
                    );

                _habil_moved =
                    true;
            }


            if (_habil_moved)
            {
                if (
                    habil_index
                    <
                    habil_scroll
                )
                {
                    habil_scroll =
                        habil_index;
                }


                if (
                    habil_index
                    >=
                    habil_scroll
                    +
                    habil_visible_rows
                )
                {
                    habil_scroll =
                        habil_index
                        -
                        habil_visible_rows
                        +
                        1;
                }


                audio_play_sound(
                    snd_menumove,
                    10,
                    false
                );
            }


            if (
                _habil_total > 0
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
                habil_info_id =
                    _habilidades[
                        habil_index
                    ];

                habil_info_open =
                    true;

                keyboard_clear(
                    ord("Z")
                );

                keyboard_clear(
                    vk_enter
                );

                audio_play_sound(
                    snd_menumove,
                    10,
                    false
                );
            }
        }
    }
}
else
{
    stad_was_active =
        false;

    stad_tab_slide =
        0;

    habil_info_open =
        false;

    habil_info_id =
        "";
}


// =========================================================
// PLATAFORMERO - CÓDIGO ACTUAL CONSERVADO
// =========================================================

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


    main_index =
        min(
            platform_main_index,
            4
        );
}
