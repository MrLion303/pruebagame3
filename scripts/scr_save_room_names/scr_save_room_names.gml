/// =========================================================
/// SCR_SAVE_ROOM_NAMES
/// =========================================================
///
/// Aquí administras el nombre que aparece en los slots de
/// guardado para cada room.
///
/// NO depende de IDs numéricas como global.rm1/global.rm2.
/// Usa el nombre interno real del asset de room.
///
/// Para agregar una nueva habitación:
///
///     case "rm_mi_habitacion":
///         return scr_loc_src("Mi Habitación");
///
/// "rm_mi_habitacion" = nombre del asset en GameMaker.
/// "Mi Habitación"    = texto visible en el guardado.
///
/// Los nombres visibles usan scr_loc_src(), así que también
/// entran al sistema de traducción.
/// =========================================================

function scr_save_room_name(_room_asset)
{
    var _internal_name =
        room_get_name(
            _room_asset
        );


    switch (_internal_name)
    {
        // =================================================
        // ROOMS ACTUALES
        // =================================================

        case "pasillo_school":

            return scr_loc_src(
                "Pasillo School"
            );


        case "toriel_salon":

            return scr_loc_src(
                "Salón de Toriel"
            );


        case "huevo":

            return scr_loc_src(
                "El Huevo"
            );

case "rm_gerson":

    return scr_loc_src(
        "Tienda de Gerson"
    );
        // =================================================
        // EJEMPLO PARA UNA ROOM NUEVA
        // =================================================
        //
        // case "rm_gerson":
        //
        //     return scr_loc_src(
        //         "Tienda de Gerson"
        //     );
        //
        // =================================================
    }


    // -----------------------------------------------------
    // COMPATIBILIDAD CON LAS ROOMS ANTIGUAS
    // -----------------------------------------------------
    //
    // Tu sistema viejo usaba IDs 0..3.
    // Lo conservamos como respaldo para que saves antiguos
    // sigan mostrando los mismos nombres.
    // -----------------------------------------------------

    if (_room_asset == 0)
    {
        return scr_loc_src(
            "Test"
        );
    }


    if (_room_asset == 1)
    {
        return scr_loc_src(
            "Pasillo School"
        );
    }


    if (_room_asset == 2)
    {
        return scr_loc_src(
            "Salón de Toriel"
        );
    }


    if (_room_asset == 3)
    {
        return scr_loc_src(
            "El Huevo"
        );
    }


    return scr_loc_src(
        "Desconocido"
    );
}
