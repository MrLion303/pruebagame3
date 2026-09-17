/// =========================================================
/// SCR_NOTIJERAS_DIALOGOS
/// =========================================================
///
/// Diálogos que puede mostrar obj_barrera_cortable cuando Maya
/// intenta interactuar con ella SIN tener las Tijeras Jardín.
///
/// En el Creation Code de CADA barrera puedes elegir uno:
///
///     dialogo_sin_tijeras = "olvido_importante";
///     dialogo_sin_tijeras = "no_olvidas_importante";
///     dialogo_sin_tijeras = "falta_algo_mas";
///     dialogo_sin_tijeras = "olvidaste_algo_mas";
///     dialogo_sin_tijeras = "lianas";
///     dialogo_sin_tijeras = "cables";
///     dialogo_sin_tijeras = "cuerdas";
///
/// También existe:
///
///     dialogo_sin_tijeras = "tipo_barrera";
///
/// que elige automáticamente lianas/cables/cuerdas según
/// tipo_barrera.
/// =========================================================


// =========================================================
// NORMALIZAR ID
// =========================================================

function scr_notijeras_dialogo_normalize(
    _dialogo_id,
    _tipo_barrera = "lianas"
)
{
    var _id =
        string_lower(
            string(_dialogo_id)
        );


    if (
        _id == "tipo_barrera"
        ||
        _id == "tipo"
        ||
        _id == "automatico"
        ||
        _id == "automático"
    )
    {
        return scr_tijeras_barrera_normalize_type(
            _tipo_barrera
        );
    }


    switch (_id)
    {
        case "olvido_importante":
        case "no_olvidas_importante":
        case "falta_algo_mas":
        case "olvidaste_algo_mas":
        case "lianas":
        case "cables":
        case "cuerdas":
            return _id;
    }


    return "olvido_importante";
}


// =========================================================
// CREAR TEXTO CON PRIMERA LÍNEA ROJA
// =========================================================

function scr_notijeras_texto_tipo(
    _primera_linea,
    _segunda_linea
)
{
    // Los dos parámetros ya llegan localizados. Los textos fuente
    // se escriben como literales scr_loc_src(...) en cada case para
    // que el exportador ES/EN pueda detectarlos correctamente.
    var _red_text =
        _primera_linea;


    var _normal_text =
        _segunda_linea;


    var _full_text =
        _red_text
        +
        "\n"
        +
        _normal_text;


    scr_text(
        _full_text,
        c_white,
        noone,
        snd_text
    );


    // Solo la primera frase queda roja.
    if (string_length(_red_text) > 0)
    {
        scr_text_color(
            0,
            string_length(_red_text) - 1,
            c_red,
            c_red,
            c_red,
            c_red
        );
    }
}


// =========================================================
// MOSTRAR DIÁLOGO
// =========================================================
///
/// Devuelve true si creó el diálogo.
/// Devuelve false si ya había una caja de texto abierta.
/// =========================================================

function scr_notijeras_dialogos(
    _dialogo_id,
    _tipo_barrera = "lianas"
)
{
    if (instance_exists(obj_textbox))
    {
        return false;
    }


    var _id =
        scr_notijeras_dialogo_normalize(
            _dialogo_id,
            _tipo_barrera
        );


    var _textbox =
        instance_create_depth(
            0,
            0,
            -9999,
            obj_textbox
        );


    if (
        _textbox == noone
        ||
        !instance_exists(_textbox)
    )
    {
        return false;
    }


    // -----------------------------------------------------
    // DIÁLOGOS GENÉRICOS
    // -----------------------------------------------------

    switch (_id)
    {
        case "olvido_importante":

            scr_text(
                scr_loc(
                    scr_loc_src(
                        "Parece que te olvidas de algo importante."
                    )
                )
            );

            break;


        case "no_olvidas_importante":

            scr_text(
                scr_loc(
                    scr_loc_src(
                        "¿No te olvidas de algo importante?"
                    )
                )
            );

            break;


        case "falta_algo_mas":

            scr_text(
                scr_loc(
                    scr_loc_src(
                        "Maya siente que hace falta algo más..."
                    )
                )
            );

            break;


        case "olvidaste_algo_mas":

            scr_text(
                scr_loc(
                    scr_loc_src(
                        "Parece que olvidaste algo más"
                    )
                )
            );

            break;


        // -------------------------------------------------
        // LIANAS
        // -----------------------------------------------------

        case "lianas":

            scr_notijeras_texto_tipo(
                scr_loc(scr_loc_src("Parecen alguna clase de lianas.")),
                scr_loc(scr_loc_src("Quizá Maya podría cortarlas con algo"))
            );

            break;


        // -------------------------------------------------
        // CABLES
        // -------------------------------------------------

        case "cables":

            scr_notijeras_texto_tipo(
                scr_loc(scr_loc_src("Parecen alguna clase de cables.")),
                scr_loc(scr_loc_src("Quizá Maya podría cortarlos con algo"))
            );

            break;


        // -------------------------------------------------
        // CUERDAS
        // -------------------------------------------------

        case "cuerdas":

            scr_notijeras_texto_tipo(
                scr_loc(scr_loc_src("Parecen alguna clase de cuerdas.")),
                scr_loc(scr_loc_src("Quizá Maya podría cortarlas con algo"))
            );

            break;
    }


    // Consumir el mismo Z / Enter con el que se abrió el texto.
    keyboard_clear(ord("Z"));
    keyboard_clear(vk_enter);


    // Evitar que la misma pulsación llegue a otro objeto del mundo.
    if (instance_exists(obj_menu_manager))
    {
        var _menu =
            instance_find(
                obj_menu_manager,
                0
            );


        if (
            _menu != noone
            &&
            instance_exists(_menu)
            &&
            variable_instance_exists(
                _menu,
                "interaction_release_block"
            )
        )
        {
            _menu.interaction_release_block =
                2;
        }
    }


    return true;
}
