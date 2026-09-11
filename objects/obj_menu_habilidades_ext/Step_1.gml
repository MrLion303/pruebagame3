/// =========================================================
/// OBJ_MENU_HABILIDADES_EXT
/// BEGIN STEP - NUEVO
/// =========================================================

if (!instance_exists(obj_menu_manager))
{
    instance_destroy();
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


// =========================================================
// ENTRAR / SALIR DE STAD
// =========================================================

if (_menu.state != MENU_STATE.INFO_MENU)
{
    habil_info_open = false;
    habil_info_id = "";
    last_menu_state = _menu.state;
    exit;
}


if (last_menu_state != MENU_STATE.INFO_MENU)
{
    stad_tab = 0;
    habil_index = 0;
    habil_scroll = 0;
    habil_info_open = false;
    habil_info_id = "";
}


last_menu_state =
    MENU_STATE.INFO_MENU;


var _lista =
    scr_habilidades_lista_obtenidas();


var _total =
    array_length(
        _lista
    );


if (_total <= 0)
{
    habil_index = 0;
    habil_scroll = 0;
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
// CUADRO DE INFO ABIERTO
// =========================================================
//
// X/Shift o Z/Enter cierran SOLO el cuadro.
// Limpiamos esas teclas antes del Step normal del menú para
// que X no cierre también todo STAD.
// =========================================================

if (habil_info_open)
{
    var _cerrar_info =
        keyboard_check_pressed(ord("X"))
        ||
        keyboard_check_pressed(vk_shift)
        ||
        keyboard_check_pressed(ord("Z"))
        ||
        keyboard_check_pressed(vk_enter);


    if (_cerrar_info)
    {
        habil_info_open = false;
        habil_info_id = "";

        keyboard_clear(ord("X"));
        keyboard_clear(vk_shift);
        keyboard_clear(ord("Z"));
        keyboard_clear(vk_enter);

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    exit;
}


// =========================================================
// CAMBIAR STAD / HABIL
// =========================================================

var _tab_moved = false;


if (keyboard_check_pressed(vk_right))
{
    stad_tab =
        (stad_tab + 1) % 2;

    _tab_moved = true;
}


if (keyboard_check_pressed(vk_left))
{
    stad_tab =
        (stad_tab - 1 + 2) % 2;

    _tab_moved = true;
}


if (_tab_moved)
{
    habil_index = 0;
    habil_scroll = 0;

    audio_play_sound(
        snd_menumove,
        10,
        false
    );
}


// =========================================================
// HABIL - LISTA
// =========================================================

if (stad_tab == 1)
{
    var _moved = false;


    if (
        _total > 0
        &&
        keyboard_check_pressed(vk_down)
    )
    {
        habil_index =
            min(
                _total - 1,
                habil_index + 1
            );

        _moved = true;
    }


    if (
        _total > 0
        &&
        keyboard_check_pressed(vk_up)
    )
    {
        habil_index =
            max(
                0,
                habil_index - 1
            );

        _moved = true;
    }


    if (_moved)
    {
        if (habil_index < habil_scroll)
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


    // Z / Enter abre el cuadro de información.
    if (
        _total > 0
        &&
        (
            keyboard_check_pressed(ord("Z"))
            ||
            keyboard_check_pressed(vk_enter)
        )
    )
    {
        habil_info_id =
            _lista[
                habil_index
            ];


        habil_info_open =
            true;


        keyboard_clear(ord("Z"));
        keyboard_clear(vk_enter);


        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }
}
