/// =========================================================
/// OBJ_MENU_HABILIDADES_EXT
/// BEGIN STEP COMPLETO
/// =========================================================

if (
    !instance_exists(
        obj_menu_manager
    )
)
{
    last_info_active =
        false;

    stad_tab_slide =
        0;

    habil_info_open =
        false;

    habil_info_id =
        "";

    exit;
}


var _menu =
    instance_find(
        obj_menu_manager,
        0
    );


if (_menu == noone)
{
    exit;
}


var _info_active =
    (
        _menu.state
        ==
        MENU_STATE.INFO_MENU
    );


// =========================================================
// FUERA DE STAD
// =========================================================

if (!_info_active)
{
    last_info_active =
        false;

    stad_tab_slide =
        0;

    habil_info_open =
        false;

    habil_info_id =
        "";

    exit;
}


// =========================================================
// ACABA DE ENTRAR A STAD
// =========================================================

if (!last_info_active)
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


last_info_active =
    true;


// =========================================================
// ANIMACIÓN DE LA BARRA
// =========================================================

stad_tab_slide =
    min(
        1,
        stad_tab_slide
        +
        stad_tab_slide_speed
    );


// =========================================================
// HABILIDADES OBTENIDAS
// =========================================================

var _lista =
    scr_habilidades_lista_obtenidas();


var _total =
    array_length(
        _lista
    );


if (_total <= 0)
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
            _total - 1
        );
}


// =========================================================
// MODAL DE INFORMACIÓN
// =========================================================
//
// Si está abierto, consumimos las teclas ANTES del Step
// normal del menú para que X no cierre también STAD.
// =========================================================

if (habil_info_open)
{
    var _close_info =
        keyboard_check_pressed(
            ord("Z")
        )
        ||
        keyboard_check_pressed(
            vk_enter
        )
        ||
        keyboard_check_pressed(
            ord("X")
        )
        ||
        keyboard_check_pressed(
            vk_shift
        );


    if (_close_info)
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


    exit;
}


// =========================================================
// STAD <-> HABIL
// =========================================================

var _tab_moved =
    false;


if (
    keyboard_check_pressed(
        vk_right
    )
)
{
    stad_tab =
        (stad_tab + 1)
        %
        2;

    _tab_moved =
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
        %
        2;

    _tab_moved =
        true;
}


if (_tab_moved)
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


// =========================================================
// HABIL - NAVEGACIÓN
// =========================================================

if (stad_tab == 1)
{
    var _moved =
        false;


    if (
        _total > 0
        &&
        keyboard_check_pressed(
            vk_down
        )
    )
    {
        habil_index =
            min(
                _total - 1,
                habil_index + 1
            );

        _moved =
            true;
    }


    if (
        _total > 0
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

        _moved =
            true;
    }


    if (_moved)
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
        _total > 0
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
            _lista[
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


// X / Shift sin modal queda libre.
// obj_menu_manager lo utiliza normalmente para regresar a MAIN.
