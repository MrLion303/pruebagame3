/// =========================================================
/// SCR_EQUIPS_DATA
/// =========================================================
///
/// Base de datos de armas y armaduras.
///
/// CAMPOS DE TIENDA:
///
/// precio_compra
/// precio_venta
/// icono_tienda
///
/// icono_tienda SOLO es leído por la tienda.
/// No altera EQUIP, cofre ni inventario.
/// =========================================================

function scr_equips_data()
{
    global.equip_db =
    {
        // =================================================
        // ESPADA BÁSICA
        // =================================================

        espada_basica:
        {
            nombre:
                scr_loc_src(
                    "Espada palo"
                ),

            tipo:
                "arma",

            ataque:
                3,

            defensa:
                0,

            descripcion:
                scr_loc_src(
                    "Una espada de madera inofensiva."
                ),


            // ---------------------------------------------
            // TIENDA
            // ---------------------------------------------

            precio_compra:
                100,

            precio_venta:
                50,

            // Ejemplo:
            // icono_tienda: spr_shop_espada_palo
            icono_tienda:
                -1
        },


        // =================================================
        // ARMADURA BÁSICA
        // =================================================

        armadura_basica:
        {
            nombre:
                scr_loc_src(
                    "Ropa vieja"
                ),

            tipo:
                "armadura",

            ataque:
                0,

            defensa:
                2,

            descripcion:
                scr_loc_src(
                    "Te protege un poco del frio."
                ),


            // ---------------------------------------------
            // TIENDA
            // ---------------------------------------------

            precio_compra:
                80,

            precio_venta:
                40,

            // Ejemplo:
            // icono_tienda: spr_shop_ropa_vieja
            icono_tienda:
                -1
        }
    };
}
