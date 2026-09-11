/// =========================================================
/// SCR_SAVE_RUNTIME_FIX
/// =========================================================
///
/// Corrige la aplicación de una partida cargada sobre el
/// obj_player persistente.
///
/// scr_cargar_juego() carga correctamente los GLOBALS.
/// Pero al cargar desde obj_save_menu, Maya puede sobrevivir
/// al room_goto y no vuelve a ejecutar Create.
///
/// Esta función vuelve a aplicar al actor REAL:
//
///     - nivel;
///     - HP máximo;
///     - HP completo;
///     - consumibles;
///     - arma equipada;
///     - armadura equipada;
///     - aliases de toys/equip/claves.
///
/// Se llama desde obj_save_menu -> Room Start.
// =========================================================

function scr_save_runtime_apply_loaded_player(
    _player
)
{
    if (
        _player == noone
        ||
        !instance_exists(_player)
    )
    {
        return false;
    }


    // Aplicar la función oficial existente.
    scr_aplicar_datos_cargados(
        _player
    );


    scr_inventarios_data();

    scr_level_data();


    // =====================================================
    // NORMALIZAR CONSUMIBLES A 12 SLOTS
    // =====================================================

    var _consumibles =
        array_create(
            12,
            -1
        );


    if (
        variable_struct_exists(
            global.inventory_data,
            "consumibles"
        )
        &&
        is_array(
            global.inventory_data.consumibles
        )
    )
    {
        var _copy_count =
            min(
                12,
                array_length(
                    global.inventory_data.consumibles
                )
            );


        for (
            var _i = 0;
            _i < _copy_count;
            _i++
        )
        {
            _consumibles[_i] =
                global.inventory_data.consumibles[_i];
        }
    }


    global.inventory_data.consumibles =
        _consumibles;


    _player.inventory =
        global.inventory_data.consumibles;


    // =====================================================
    // REENLAZAR TODOS LOS INVENTARIOS PERSISTENTES
    // =====================================================
    //
    // Estos aliases pueden seguir apuntando al array de la
    // partida anterior si ya existían antes de cargar.
    // =====================================================

    if (
        variable_struct_exists(
            global.inventory_data,
            "toys"
        )
        &&
        is_array(
            global.inventory_data.toys
        )
    )
    {
        global.toy_inventory =
            global.inventory_data.toys;
    }


    if (
        variable_struct_exists(
            global.inventory_data,
            "equipamiento"
        )
        &&
        is_array(
            global.inventory_data.equipamiento
        )
    )
    {
        global.equipment_inventory =
            global.inventory_data.equipamiento;
    }


    if (
        variable_struct_exists(
            global.inventory_data,
            "claves"
        )
        &&
        is_array(
            global.inventory_data.claves
        )
    )
    {
        global.itemclave_inventory =
            global.inventory_data.claves;
    }


    // =====================================================
    // EQUIPO ACTIVO
    // =====================================================

    if (
        variable_struct_exists(
            global.inventory_data,
            "equipado_arma"
        )
    )
    {
        _player.equipo_arma =
            global.inventory_data.equipado_arma;
    }


    if (
        variable_struct_exists(
            global.inventory_data,
            "equipado_armadura"
        )
    )
    {
        _player.equipo_armadura =
            global.inventory_data.equipado_armadura;
    }


    global.equipped_arma =
        _player.equipo_arma;


    global.equipped_armadura =
        _player.equipo_armadura;


    // =====================================================
    // HP
    // =====================================================
    //
    // Tu guardado cura a Maya al máximo al salvar.
    // Por tanto cargar SIEMPRE debe restaurar ese estado.
    // =====================================================

    _player.hp_max =
        max(
            1,
            global.level_data.hp_max
        );


    _player.hp =
        _player.hp_max;


    global.player_hp_current =
        _player.hp;


    return true;
}
