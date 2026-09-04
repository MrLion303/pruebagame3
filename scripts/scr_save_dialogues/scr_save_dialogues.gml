/// =========================================================
/// SCR_SAVE_DIALOGUES
/// =========================================================
///
/// Base de datos de diálogos de los puntos de guardado.
///
/// Cada diálogo define AQUÍ MISMO si puede repetirse:
///
///     repeatable: true
///
/// o si solamente debe aparecer una vez:
///
///     repeatable: false
///
/// El Creation Code del punto solo necesita elegir el diálogo:
///
///     save_dialogue_id = "escuela";
///
/// Si no especificas nada:
///
///     save_dialogue_id = "default";
///
/// NO necesitas indicar la room.
/// scr_guardar_juego() ya guarda automáticamente la room actual.
///
/// Los textos usan scr_loc_src() para ser compatibles con
/// el sistema de traducción.
/// =========================================================


// =========================================================
// CREAR UNA LÍNEA
// =========================================================

function scr_save_dialogue_line(
    _texto,
    _head = noone,
    _snd = snd_text,
    _color = c_white
)
{
    return {
        texto:
            _texto,

        head:
            _head,

        snd:
            _snd,

        color:
            _color
    };
}


// =========================================================
// CREAR UN DIÁLOGO
// =========================================================
//
// _repeatable:
//
//     false
//         Se muestra una sola vez.
//
//     true
//         Se muestra CADA VEZ que vuelves a interactuar
//         con ese punto de guardado.
//
// =========================================================

function scr_save_dialogue(
    _repeatable,
    _lines
)
{
    return {
        repeatable:
            _repeatable,

        lines:
            _lines
    };
}


// =========================================================
// OBTENER DIÁLOGO
// =========================================================

function scr_save_dialogue_data(_id)
{
    if (
        !is_string(_id)
        ||
        _id == ""
    )
    {
        _id =
            "default";
    }


    switch (_id)
    {
        // =================================================
        // DEFAULT
        // =================================================
        //
        // NO REPETIBLE.
        //
        // Si el punto de guardado no tiene Creation Code,
        // este será el diálogo que aparecerá la primera vez.
        // =================================================

        case "default":

            return scr_save_dialogue(
                false,

                [
                    scr_save_dialogue_line(
                        scr_loc_src(
                            "* Sientes que este lugar quedará grabado en tu memoria."
                        )
                    )
                ]
            );


        // =================================================
        // ESCUELA
        // =================================================
        //
        // NO REPETIBLE.
        //
        // Creation Code:
        //
        //     save_dialogue_id = "escuela";
        //
        // =================================================

        case "escuela":

            return scr_save_dialogue(
                true, // FALSE SIGNIFICA NO SE REPITE, TRUE SI SE REPITE

                [
                    scr_save_dialogue_line(
                        scr_loc_src(
                            "* Por un instante, el silencio de la escuela parece tranquilizarte."
                        )
                    ),

                    scr_save_dialogue_line(
                        scr_loc_src(
                            "* Sientes que podrías recordar este momento por mucho tiempo."
                        )
                    )
                ]
            );


        // =================================================
        // PASILLO
        // =================================================
        //
        // REPETIBLE.
        //
        // Este diálogo aparecerá CADA VEZ antes de abrir
        // la interfaz de guardado.
        //
        // Creation Code:
        //
        //     save_dialogue_id = "pasillo";
        //
        // =================================================

        case "pasillo":

            return scr_save_dialogue(
                true,

                [
                    scr_save_dialogue_line(
                        scr_loc_src(
                            "* El eco de tus pasos desaparece lentamente."
                        )
                    )
                ]
            );


        // =================================================
        // EJEMPLO CON RETRATO / SONIDO / COLOR
        // =================================================
        //
        // REPETIBLE.
        //
        // Puedes borrar este ejemplo si no lo necesitas.
        // =================================================

        case "ejemplo_repetible":

            return scr_save_dialogue(
                true,

                [
                    scr_save_dialogue_line(
                        scr_loc_src(
                            "* Este texto se reproducirá cada vez que uses este guardado."
                        ),
                        noone,
                        snd_text,
                        c_white
                    )
                ]
            );


        // =================================================
        // ID NO ENCONTRADO
        // =================================================
        //
        // Fallback seguro al diálogo default.
        // =================================================

        default:

            return scr_save_dialogue(
                false,

                [
                    scr_save_dialogue_line(
                        scr_loc_src(
                            "* Sientes que este lugar quedará grabado en tu memoria."
                        )
                    )
                ]
            );
    }
}
