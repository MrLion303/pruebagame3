/// =========================================================
/// OBJ_SHOP_CONTROLLER
/// BEGIN STEP - NUEVO EVENTO
/// =========================================================
///
/// Añade Zapatos Rápidos al stock de shop_1 sin reescribir
/// scr_shop_data completo.
/// =========================================================

if (
    !variable_instance_exists(
        id,
        "_zapatos_stock_preparado"
    )
)
{
    _zapatos_stock_preparado =
        false;
}


if (_zapatos_stock_preparado)
{
    exit;
}


_zapatos_stock_preparado =
    true;


// Solo la tienda 1.
if (
    !variable_instance_exists(
        id,
        "shop_id"
    )
    ||
    shop_id != "shop_1"
    ||
    !is_struct(shop_data)
    ||
    !variable_struct_exists(
        shop_data,
        "items_venta"
    )
    ||
    !is_array(
        shop_data.items_venta
    )
)
{
    exit;
}


// El equipo debe existir en la base de datos de la
// actualización anterior.
if (
    !variable_global_exists(
        "equip_db"
    )
    ||
    !is_struct(
        global.equip_db
    )
    ||
    !variable_struct_exists(
        global.equip_db,
        "zapatos_rapidos"
    )
)
{
    exit;
}


// Evitar duplicados.
var _ya_existe =
    false;


for (
    var _i = 0;
    _i < array_length(
        shop_data.items_venta
    );
    _i++
)
{
    var _stock =
        shop_data.items_venta[
            _i
        ];


    if (
        is_struct(_stock)
        &&
        variable_struct_exists(
            _stock,
            "id"
        )
        &&
        _stock.id
        ==
        "zapatos_rapidos"
    )
    {
        _ya_existe =
            true;

        break;
    }
}


if (!_ya_existe)
{
    array_push(
        shop_data.items_venta,
        scr_shop_stock(
            "equip",
            "zapatos_rapidos"
        )
    );
}
