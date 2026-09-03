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
///
/// curacion_hp:
///     Cantidad de HP que recupera el consumible.
///     La tienda usa este valor para mostrar "HP +N".
/// =========================================================

function scr_item_db()
{
    global.item_db =
    {
        // =================================================
        // VASO DE AGUA
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

            precio_compra:
                20,

            precio_venta:
                10,

            icono_tienda:
                -1,

            // noone = color normal. Ej.: c_aqua, c_red, etc.
            color_tienda:
                noone,

            curacion_hp:
                10,

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

            precio_compra:
                40,

            precio_venta:
                20,

            icono_tienda:
                -1,

            // noone = color normal. Ej.: c_aqua, c_red, etc.
            color_tienda:
                noone,

            curacion_hp:
                20,

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
        },


        // =================================================
        // MANZANA CARAMELO
        // =================================================

        manzana_caramelo:
        {
            nombre:
                scr_loc_src(
                    "Manzana Caramelo"
                ),

            descripcion:
                scr_loc_src(
                    "Dulce por fuera y crujiente por dentro."
                ),

            tipo:
                "consumible",

            precio_compra:
                70,

            precio_venta:
                35,

            icono_tienda:
                -1,

            // noone = color normal. Ej.: c_aqua, c_red, etc.
            color_tienda:
                noone,

            curacion_hp:
                30,

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
                                _p.hp + 30
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
        },


        // =================================================
        // MANDARINA
        // =================================================

        mandarina:
        {
            nombre:
                scr_loc_src(
                    "Mandarina"
                ),

            descripcion:
                scr_loc_src(
                    "Pequeña, cítrica y refrescante."
                ),

            tipo:
                "consumible",

            precio_compra:
                30,

            precio_venta:
                15,

            icono_tienda:
                -1,

            // noone = color normal. Ej.: c_aqua, c_red, etc.
            color_tienda:
                noone,

            curacion_hp:
                15,

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
                                _p.hp + 15
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
        },


        // =================================================
        // PASTILLAS CURACIÓN
        // =================================================

        pastillas_curacion:
        {
            nombre:
                scr_loc_src(
                    "Pastillas Curación"
                ),

            descripcion:
                scr_loc_src(
                    "Pastillas que ayudan a recuperar energía."
                ),

            tipo:
                "consumible",

            precio_compra:
                120,

            precio_venta:
                60,

            icono_tienda:
                -1,

            // noone = color normal. Ej.: c_aqua, c_red, etc.
            color_tienda:
                noone,

            curacion_hp:
                50,

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
                                _p.hp + 50
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
