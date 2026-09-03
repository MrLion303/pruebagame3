/// =========================================================
/// SCR_SHOP_DATA
/// =========================================================
///
/// Aquí se personaliza CADA tienda.
///
/// El ID de la tienda es el nombre del room:
///
/// shop_1 -> case "shop_1"
/// shop_2 -> case "shop_2"
///
/// =========================================================


// =========================================================
// LÍNEA DE DIÁLOGO
// =========================================================
///
/// _texto:
///     Texto de esa línea.
///
/// _cabeza:
///     Sprite de cabeza/emoción.
///
/// _sonido:
///     Sonido de habla por letras.
///
/// _color:
///     Color del texto.
/// =========================================================

function scr_shop_dialog_line(
    _texto,
    _cabeza = noone,
    _sonido = snd_text,
    _color = c_white
)
{
    return {
        texto:
            _texto,

        cabeza:
            _cabeza,

        sonido:
            _sonido,

        color:
            _color
    };
}


// =========================================================
// OPCIÓN DE TALK
// =========================================================

function scr_shop_talk_option(
    _nombre,
    _dialogos
)
{
    return {
        nombre:
            _nombre,

        dialogos:
            _dialogos
    };
}


// =========================================================
// ARTÍCULO QUE UNA TIENDA VENDE
// =========================================================
//
// _tipo:
//     "item"  -> global.item_db
//     "equip" -> global.equip_db
//
// El precio y el icono se leen de scr_items_data /
// scr_equips_data.
// =========================================================

function scr_shop_stock(
    _tipo,
    _id,
    _color_nombre = noone
)
{
    return {
        tipo:
            _tipo,

        id:
            _id,

        // noone = usar color_tienda del objeto o blanco.
        // Ejemplo: scr_shop_stock("item", "manzana", c_red)
        color_nombre:
            _color_nombre
    };
}


// =========================================================
// DATOS DE TIENDA
// =========================================================

function scr_shop_data(_shop_id)
{
    switch (_shop_id)
    {
        // =================================================
        // SHOP 1
        // =================================================

        case "shop_1":

            return {
                // -----------------------------------------
                // IDENTIDAD
                // -----------------------------------------

                nombre:
                    scr_loc_src(
                        "Tienda 1"
                    ),


                // -----------------------------------------
                // SPRITE DE LAS CAJAS
                // -----------------------------------------
                //
                // Debe ser un sprite configurado como
                // Nine Slice en GameMaker.
                //
                // Puedes cambiarlo por otro sprite en
                // cualquier otra tienda.
                // -----------------------------------------

                caja_sprite:
                    spr_box_shop_1,


                // -----------------------------------------
                // VENDEDOR - IMAGEN GRANDE
                // -----------------------------------------

                vendedor_sprite:
                    noone,


                // -----------------------------------------
                // VALORES DEFAULT DE DIÁLOGO
                // -----------------------------------------

                vendedor_cabeza_default:
                    noone,

                vendedor_sonido_default:
                    snd_text,

                vendedor_color_default:
                    c_white,


                // -----------------------------------------
                // MENSAJE NORMAL DE LA CAJA IZQUIERDA
                // -----------------------------------------

                mensaje_idle:
                    scr_loc_src(
                        "* Bienvenido. ¿Qué puedo hacer por ti?"
                    ),


                // -----------------------------------------
                // ARTÍCULOS A LA VENTA
                // -----------------------------------------

                items_venta:
                [
                    // Consumibles.
                    scr_shop_stock(
                        "item",
                        "agua"
                    ),

                    scr_shop_stock(
                        "item",
                        "manzana"
                    ),

                    scr_shop_stock(
                        "item",
                        "manzana_caramelo"
                    ),

                    scr_shop_stock(
                        "item",
                        "mandarina"
                    ),

                    scr_shop_stock(
                        "item",
                        "pastillas_curacion"
                    ),


                    // Toys.
                    scr_shop_stock(
                        "toy",
                        "brillitos"
                    ),

                    scr_shop_stock(
                        "toy",
                        "pegamento"
                    ),


                    // Armas.
                    scr_shop_stock(
                        "equip",
                        "espada_basica"
                    ),

                    scr_shop_stock(
                        "equip",
                        "cuchillo"
                    ),

                    scr_shop_stock(
                        "equip",
                        "cutter"
                    ),


                    // Armadura.
                    scr_shop_stock(
                        "equip",
                        "armadura_basica"
                    )
                ],


                // -----------------------------------------
                // OPCIONES DE HABLAR
                // -----------------------------------------

                talk_options:
                [
                    // =====================================
                    // SALUDOS
                    // =====================================

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


                    // =====================================
                    // SOBRE ESTA TIENDA
                    // =====================================

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


                    // =====================================
                    // ¿QUÉ SON LOS SUEÑOS?
                    // =====================================

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


                // -----------------------------------------
                // DIÁLOGO DE DESPEDIDA
                // -----------------------------------------
                //
                // Este diálogo se muestra en la CAJA DE
                // DIÁLOGO IZQUIERDA, NO en la caja de TALK.
                //
                // Puedes poner varias líneas y cada una
                // puede tener cabeza, sonido y color.
                // -----------------------------------------

                despedida_dialogos:
                [
                    scr_shop_dialog_line(
                        scr_loc_src(
                            "* Gracias por venir. Vuelve pronto."
                        )
                    )
                ],


                // -----------------------------------------
                // DESTINO DE SALIDA
                // -----------------------------------------
                //
                // Si salida_room != noone:
                // al terminar la despedida cambia de room.
                //
                // Si salida_room == noone:
                // solamente cierra la interfaz de tienda
                // y devuelve el control al jugador.
                //
                // Cuando sepas exactamente a qué room y
                // coordenadas debe volver shop_1, cambia
                // estos cuatro valores.
                // -----------------------------------------

                salida_room:
                    noone,

                salida_x:
                    0,

                salida_y:
                    0,

                salida_face:
                    2
            };


        // =================================================
        // TIENDA NO CONFIGURADA
        // =================================================

        default:

            return {
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
