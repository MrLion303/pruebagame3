
/// =========================================================
/// OBJ_SHOP_CONTROLLER
/// CREATE COMPLETO
/// =========================================================

visible =
    true;


// =========================================================
// ASEGURAR SISTEMAS
// =========================================================

scr_shop_init();


// =========================================================
// IDENTIFICAR TIENDA POR ROOM
// =========================================================

shop_id =
    room_get_name(room);

shop_data =
    scr_shop_data(
        shop_id
    );


// =========================================================
// ESTADOS
// =========================================================
//
// 0 = menú superior
// 1 = comprar
// 2 = vender
// 3 = hablar - lista de temas
// 4 = hablar - diálogo dentro de caja TALK
// 5 = despedida de SALIR en caja izquierda
// =========================================================

SHOP_TOP =
    0;

SHOP_BUY =
    1;

SHOP_SELL =
    2;

SHOP_TALK =
    3;

SHOP_TALK_DIALOG =
    4;

SHOP_EXIT_DIALOG =
    5;

// Selector previo de categoría para VENDER.
SHOP_SELL_TYPE =
    6;


state =
    SHOP_TOP;


// =========================================================
// MENÚ SUPERIOR
// =========================================================

top_options =
[
    scr_loc_src("COMPRAR"),
    scr_loc_src("VENDER"),
    scr_loc_src("HABLAR"),
    scr_loc_src("SALIR")
];

top_index =
    0;


// Contenido que se previsualiza.
// SALIR NO altera este índice.
top_preview_index =
    0;


// =========================================================
// COMPRAR
// =========================================================

buy_index =
    0;

buy_scroll =
    0;


// =========================================================
// VENDER
// =========================================================
//
// Antes de mostrar el inventario, se elige categoría.
// =========================================================

sell_type_options =
[
    scr_loc_src("* ITEM"),
    scr_loc_src("* JUGUETE"),
    scr_loc_src("* ARMA"),
    scr_loc_src("* ARMADURA")
];

sell_type_keys =
[
    "item",
    "toy",
    "arma",
    "armadura"
];

sell_type_index =
    0;

sell_category =
    "item";

sell_list =
    [];

sell_index =
    0;

sell_scroll =
    0;


// =========================================================
// TALK
// =========================================================

talk_index =
    0;

talk_dialogues =
    [];

talk_line_index =
    0;

talk_char =
    0;

talk_sound_timer =
    0;

talk_sound_delay =
    2;

// Mantener C completa instantáneamente la línea actual.
talk_fast_skip_key =
    ord("C");


// =========================================================
// DESPEDIDA / SALIR
// =========================================================

exit_dialogues =
    [];

exit_line_index =
    0;

exit_char =
    0;

exit_sound_timer =
    0;


// =========================================================
// MENSAJE TEMPORAL
// =========================================================

shop_message =
    "";

shop_message_timer =
    0;


// =========================================================
// CONFIG UI
// =========================================================

visible_rows =
    5;


// =========================================================
// TRANSICIÓN
// =========================================================
//
// La tienda usa EXACTAMENTE el mismo obj_warp que cualquier
// cambio de habitación normal. No hay transición especial
// ni sprite alternativo para shops.
// =========================================================

// =========================================================
// BLOQUEAR PLAYER
// =========================================================

if (instance_exists(obj_player))
{
    if (
        variable_instance_exists(
            obj_player,
            "puede_moverse"
        )
    )
    {
        obj_player.puede_moverse =
            false;
    }


    if (
        variable_instance_exists(
            obj_player,
            "can_move"
        )
    )
    {
        obj_player.can_move =
            false;
    }
}


// =========================================================
// CERRAR MENÚ DE PAUSA
// =========================================================

if (instance_exists(obj_menu_manager))
{
    if (
        variable_instance_exists(
            obj_menu_manager,
            "state"
        )
    )
    {
        obj_menu_manager.state =
            0;
    }
}

// =========================================================
// RETORNO UNIVERSAL DE LA TIENDA
// =========================================================
//
// La posición de entrada se guarda ANTES de entrar a una
// habitación cuyo nombre empiece por "shop_".
//
// Devuelve true si había un retorno válido.
// =========================================================

shop_return_to_entry = function()
{
    if (
        !variable_global_exists("shop_return_valid")
        ||
        !global.shop_return_valid
        ||
        !variable_global_exists("shop_return_room")
        ||
        global.shop_return_room == noone
    )
    {
        return false;
    }


    var _return_room =
        global.shop_return_room;

    var _return_x =
        global.shop_return_x;

    var _return_y =
        global.shop_return_y;

    var _return_face =
        global.shop_return_face;

    var _return_music_name =
        "";


    if (variable_global_exists("shop_return_music_name"))
    {
        _return_music_name =
            global.shop_return_music_name;
    }


    // Convertir el nombre guardado de la música al asset
    // que obj_warp reproducirá justo al cambiar de room.
    var _return_music_asset =
        -1;


    if (
        is_string(_return_music_name)
        &&
        _return_music_name != ""
    )
    {
        _return_music_asset =
            asset_get_index(
                _return_music_name
            );


        if (
            _return_music_asset == -1
            ||
            !audio_exists(_return_music_asset)
        )
        {
            _return_music_asset =
                -1;
        }
    }


    // Consumimos este retorno para que no pueda reutilizarse
    // accidentalmente una segunda vez.
    global.shop_return_valid =
        false;


    // Al volver EXACTAMENTE a la coordenada de entrada,
    // probablemente seguiremos tocando el mismo obj_warp_block.
    // Este bloqueo evita que nos mande de nuevo a la tienda.
    global.shop_return_lock =
        true;

    global.shop_return_lock_room =
        _return_room;


    if (
        variable_global_exists("shop_entry_warp_x")
        &&
        variable_global_exists("shop_entry_warp_y")
    )
    {
        global.shop_return_lock_warp_x =
            global.shop_entry_warp_x;

        global.shop_return_lock_warp_y =
            global.shop_entry_warp_y;
    }


    global.shop_return_music_name =
        "";


    // =====================================================
    // TRANSICIÓN NORMAL DE SALIDA
    // =====================================================
    //
    // Exactamente igual que cualquier obj_warp_block normal:
    // se crea obj_warp, se pasan destino/música y el propio
    // objeto ejecuta su animación normal de cerrar -> cambiar
    // room -> abrir.
    // =====================================================

    if (instance_exists(obj_warp))
    {
        return true;
    }


    var _warp =
        instance_create_depth(
            0,
            0,
            -9999,
            obj_warp
        );


    _warp.target_x =
        _return_x;

    _warp.target_y =
        _return_y;

    _warp.target_rm =
        _return_room;

    _warp.target_face =
        _return_face;

    _warp.target_music =
        _return_music_asset;

    // Detener la música de la tienda y restaurar la que
    // estaba sonando antes de entrar.
    _warp.keep_music =
        false;


    return true;
};
