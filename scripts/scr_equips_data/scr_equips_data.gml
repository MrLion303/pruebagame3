/// =========================================================
/// SCR_EQUIPS_DATA
/// =========================================================
///
/// Base de datos de armas y armaduras.
/// =========================================================

function scr_equips_data()
{
    global.equip_db =
    {
        // =================================================
        // PALO
        // =================================================
        //
        // Se conserva el ID espada_basica para no romper
        // guardados anteriores; solo cambia el nombre visible.
        // =================================================

        espada_basica:
        {
            nombre:
                scr_loc_src(
                    "Palo"
                ),

            tipo:
                "arma",

            ataque:
                3,

            defensa:
                0,

            descripcion:
                scr_loc_src(
                    "Un palo de madera sencillo."
                ),

            precio_compra:
                100,

            precio_venta:
                50,

            icono_tienda:
                -1,

            // noone = color normal. Ej.: c_aqua, c_red, etc.
            color_tienda:
                noone
        },


        // =================================================
        // CUCHILLO
        // =================================================

        cuchillo:
        {
            nombre:
                scr_loc_src(
                    "Cuchillo"
                ),

            tipo:
                "arma",

            ataque:
                5,

            defensa:
                0,

            descripcion:
                scr_loc_src(
                    "Un cuchillo afilado."
                ),

            precio_compra:
                160,

            precio_venta:
                80,

            icono_tienda:
                -1,

            // noone = color normal. Ej.: c_aqua, c_red, etc.
            color_tienda:
                noone
        },


        // =================================================
        // CUTTER
        // =================================================

        cutter:
        {
            nombre:
                scr_loc_src(
                    "Cutter"
                ),

            tipo:
                "arma",

            ataque:
                7,

            defensa:
                0,

            descripcion:
                scr_loc_src(
                    "Una herramienta con una hoja retráctil."
                ),

            precio_compra:
                220,

            precio_venta:
                110,

            icono_tienda:
                -1,

            // noone = color normal. Ej.: c_aqua, c_red, etc.
            color_tienda:
                noone
        },


        // =================================================
        // PIJAMA
        // =================================================
        //
        // Se conserva el ID armadura_basica para no romper
        // guardados anteriores; solo cambia el nombre visible.
        // =================================================

        armadura_basica:
        {
            nombre:
                scr_loc_src(
                    "Pijama"
                ),

            tipo:
                "armadura",

            ataque:
                0,

            defensa:
                2,

            descripcion:
                scr_loc_src(
                    "Un pijama cómodo."
                ),

            precio_compra:
                80,

            precio_venta:
                40,

            icono_tienda:
                -1,

            // noone = color normal. Ej.: c_aqua, c_red, etc.
            color_tienda:
                noone
        }
    };
}
