/// =========================================================
/// SCR_ITEMS_DATA
/// =========================================================
///
/// Base de datos de consumibles.
///
/// CAMPOS DE TIENDA:
///
/// precio_compra:
///     Cuánto cuesta comprar UNA unidad.
///
/// precio_venta:
///     Cuántos Sueños recibes al vender UNA unidad.
///
/// icono_tienda:
///     Sprite que SOLO usa obj_shop_controller.
///     No lo usa el inventario normal ni el cofre.
///
/// icono:
///     Se conserva por compatibilidad con el sistema anterior.
/// =========================================================

function scr_item_db()
{
    global.item_db =
    {
        // =================================================
        // AGUA
        // =================================================

        agua:
        {
            nombre:
                scr_loc_src(
                    "Vaso de Agua"
                ),

            descripcion:
                scr_loc_src(
                    "Ayuda a hidratarte"
                ),

            tipo:
                "consumible",


            // ---------------------------------------------
            // TIENDA
            // ---------------------------------------------

            precio_compra:
                20,

            precio_venta:
                10,

            // Pon aquí, por ejemplo:
            //
            // icono_tienda: spr_shop_agua
            //
            // -1 significa que no se dibuja icono.
            icono_tienda:
                -1,


            // ---------------------------------------------
            // EFECTO
            // ---------------------------------------------

            efecto:
                function()
                {
                    var _p =
                        obj_player;

                    if (instance_exists(_p))
                    {
                        _p.hp =
                            min(
                                _p.hp_max,
                                _p.hp + 10
                            );
                    }

                    audio_play_sound(
                        snd_health,
                        10,
                        false
                    );
                },


            // Campo antiguo.
            // La tienda NO utiliza este campo.
            icono:
                -1
        },


        // =================================================
        // MANZANA
        // =================================================

        manzana:
        {
            nombre:
                scr_loc_src(
                    "Manzana"
                ),

            descripcion:
                scr_loc_src(
                    "Rica y crujiente"
                ),

            tipo:
                "consumible",


            // ---------------------------------------------
            // TIENDA
            // ---------------------------------------------

            precio_compra:
                40,

            precio_venta:
                20,

            // Pon aquí el sprite exclusivo de tienda.
            icono_tienda:
                -1,


            // ---------------------------------------------
            // EFECTO
            // ---------------------------------------------

            efecto:
                function()
                {
                    var _p =
                        obj_player;

                    if (instance_exists(_p))
                    {
                        _p.hp =
                            min(
                                _p.hp_max,
                                _p.hp + 20
                            );
                    }

                    audio_play_sound(
                        snd_health,
                        10,
                        false
                    );
                },


            icono:
                -1
        }
    };
}
