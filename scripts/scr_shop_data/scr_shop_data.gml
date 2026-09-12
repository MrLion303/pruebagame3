/// =========================================================
/// SCR_SHOP_DATA
/// =========================================================
///
/// TODOS LOS PRECIOS = 0.
///
/// Las armas eliminadas:
///
///     lanza_tardia
///     cuchillas_tardias
///
/// YA NO aparecen en shop_1.
/// =========================================================


function scr_shop_dialog_line(
    _texto,
    _cabeza = noone,
    _sonido = snd_text,
    _color = c_white
)
{
    return
    {
        texto: _texto,
        cabeza: _cabeza,
        sonido: _sonido,
        color: _color
    };
}


function scr_shop_talk_option(
    _nombre,
    _dialogos
)
{
    return
    {
        nombre: _nombre,
        dialogos: _dialogos
    };
}


function scr_shop_stock(
    _tipo,
    _id,
    _color_nombre = noone
)
{
    return
    {
        tipo: _tipo,
        id: _id,
        color_nombre: _color_nombre
    };
}


// =========================================================
// FORZAR PRECIOS
// =========================================================

function scr_shop_db_prices_zero(_db)
{
    if (!is_struct(_db))
        return;


    var _names =
        variable_struct_get_names(
            _db
        );


    for (
        var _i = 0;
        _i < array_length(_names);
        _i++
    )
    {
        var _data =
            variable_struct_get(
                _db,
                _names[_i]
            );


        if (is_struct(_data))
        {
            _data.precio_compra =
                0;

            _data.precio_venta =
                0;
        }
    }
}


function scr_shop_all_prices_zero()
{
    if (variable_global_exists("item_db"))
        scr_shop_db_prices_zero(global.item_db);

    if (variable_global_exists("toy_db"))
        scr_shop_db_prices_zero(global.toy_db);

    if (variable_global_exists("equip_db"))
        scr_shop_db_prices_zero(global.equip_db);
}


// =========================================================
// TIENDA
// =========================================================

function scr_shop_data(_shop_id)
{
    scr_shop_all_prices_zero();


    switch (_shop_id)
    {
        case "shop_1":

            return
            {
                nombre:
                    scr_loc_src(
                        "Tienda 1"
                    ),

                caja_sprite:
                    spr_box_shop_1,

                vendedor_sprite:
                    noone,

                vendedor_cabeza_default:
                    noone,

                vendedor_sonido_default:
                    snd_text,

                vendedor_color_default:
                    c_white,

                mensaje_idle:
                    scr_loc_src(
                        "* Bienvenido. Todo cuesta 0 Sueños."
                    ),


                items_venta:
                [
                    // CONSUMIBLES
                    scr_shop_stock("item", "agua"),
                    scr_shop_stock("item", "manzana"),
                    scr_shop_stock("item", "manzana_caramelo"),
                    scr_shop_stock("item", "mandarina"),
                    scr_shop_stock("item", "pastillas_curacion"),

                    // TOYS
                    scr_shop_stock("toy", "brillitos"),
                    scr_shop_stock("toy", "pegamento"),
                    scr_shop_stock("toy", "flash"),
                    scr_shop_stock("toy", "rompearmadura"),
                    scr_shop_stock("toy", "lastre"),

                    // ARMAS BASE
                    scr_shop_stock("equip", "espada_basica"),
                    scr_shop_stock("equip", "raqueta_tenis"),
                    scr_shop_stock("equip", "cuchillo"),
                    scr_shop_stock("equip", "cutter"),

                    // ARMAS MODULARES
                    scr_shop_stock("equip", "baston_vital"),
                    scr_shop_stock("equip", "espada_certera"),
                    scr_shop_stock("equip", "dagas_gemelas"),
                    scr_shop_stock("equip", "garras_triples"),
                    scr_shop_stock("equip", "aro_cargado"),
                    scr_shop_stock("equip", "aro_gemelo_vital"),

                    // ARMADURAS
                    scr_shop_stock("equip", "armadura_basica"),
                    scr_shop_stock("equip", "zapatos_rapidos")
                ],


                talk_options:
                [
                    scr_shop_talk_option(
                        scr_loc_src(
                            "Saludos"
                        ),

                        [
                            scr_shop_dialog_line(
                                scr_loc_src(
                                    "* ¡Hola! Bienvenido a la tienda."
                                )
                            ),

                            scr_shop_dialog_line(
                                scr_loc_src(
                                    "* Mira todo lo que quieras."
                                )
                            )
                        ]
                    ),


                    scr_shop_talk_option(
                        scr_loc_src(
                            "Sobre esta tienda"
                        ),

                        [
                            scr_shop_dialog_line(
                                scr_loc_src(
                                    "* Aquí vendo algunas cosas que podrían serte útiles."
                                )
                            ),

                            scr_shop_dialog_line(
                                scr_loc_src(
                                    "* También puedo comprarte objetos que ya no necesites."
                                )
                            )
                        ]
                    ),


                    scr_shop_talk_option(
                        scr_loc_src(
                            "¿Qué son los Sueños?"
                        ),

                        [
                            scr_shop_dialog_line(
                                scr_loc_src(
                                    "* Los Sueños son la moneda que usamos por aquí."
                                ),
                                noone,
                                snd_text,
                                c_yellow
                            ),

                            scr_shop_dialog_line(
                                scr_loc_src(
                                    "* Puedes conseguirlos en tus aventuras y gastarlos en tiendas."
                                )
                            )
                        ]
                    )
                ],


                despedida_dialogos:
                [
                    scr_shop_dialog_line(
                        scr_loc_src(
                            "* Gracias por venir. Vuelve pronto."
                        )
                    )
                ],


                salida_room:
                    noone,

                salida_x:
                    0,

                salida_y:
                    0,

                salida_face:
                    2
            };


        default:

            return
            {
                nombre:
                    scr_loc_src(
                        "Tienda sin configurar"
                    ),

                caja_sprite:
                    spr_box_shop_1,

                vendedor_sprite:
                    noone,

                vendedor_cabeza_default:
                    noone,

                vendedor_sonido_default:
                    snd_text,

                vendedor_color_default:
                    c_white,

                mensaje_idle:
                    scr_loc_src(
                        "* Esta tienda todavía no está configurada."
                    ),

                items_venta:
                    [],

                talk_options:
                    [],

                despedida_dialogos:
                [
                    scr_shop_dialog_line(
                        scr_loc_src(
                            "* Hasta luego."
                        )
                    )
                ],

                salida_room:
                    noone,

                salida_x:
                    0,

                salida_y:
                    0,

                salida_face:
                    2
            };
    }
}
