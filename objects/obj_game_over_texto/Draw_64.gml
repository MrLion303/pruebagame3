// ============================================
// OBJ_GAME_OVER_TEXTO
// DRAW GUI
// ============================================


// ============================================
// GUI
// ============================================

var _gw =
    display_get_gui_width();

var _gh =
    display_get_gui_height();


// ============================================
// FUENTE
// ============================================

draw_set_font(global.font_main);

draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_colour(c_white);
draw_set_alpha(1);


// ============================================
// ESCALA
// ============================================

var _esc =
    escala_texto;


// ============================================
// FUNCIÓN PARA OBTENER EL ANCHO
// DEL RENGLÓN MÁS LARGO
// ============================================

var _ancho_texto_multilinea =
function(_texto)
{
    var _lineas =
        string_split(
            _texto,
            "\n"
        );

    var _maximo = 0;


    for (
        var i = 0;
        i < array_length(_lineas);
        i++
    )
    {
        var _w =
            string_width(
                _lineas[i]
            );


        if (_w > _maximo)
        {
            _maximo = _w;
        }
    }


    return _maximo;
};


// ============================================
// ALTURA GENERAL
// ============================================

var _ty =
    _gh * 0.62;



// ============================================================
// ESTADO 0
// DIÁLOGO PRINCIPAL
// ============================================================

if (estado == 0)
{
    var _texto =
        scr_loc(
            textos[pagina]
        );


    var _mostrar =
        string_copy(
            _texto,
            1,
            caracteres
        );


    // ========================================
    // CENTRAR ESTE BLOQUE DE TEXTO
    // ========================================

    var _ancho =
        _ancho_texto_multilinea(
            _texto
        )
        * _esc;


    var _tx =
        (_gw * 0.5)
        - (_ancho * 0.5);


    // ========================================
    // DIBUJAR TEXTO
    // ========================================

    draw_text_transformed(
        _tx,
        _ty,
        _mostrar,
        _esc,
        _esc,
        0
    );



    // ========================================================
    // OPCIONES
    // ========================================================

    if (
        pagina == 3
        && caracteres >= string_length(_texto)
    )
    {
        // ====================================
        // FADE IN DE LAS DOS OPCIONES
        // ====================================

        draw_set_alpha(
            opciones_alpha
        );


        // ====================================
        // ALTURA
        // ====================================

        var _oy =
            _ty
            + (
                string_height("A")
                * _esc
                * 2.5
            );


        // ====================================
        // TEXTOS
        // ====================================

        var _txt_despertar =
            scr_loc(
                texto_opcion_despertar
            );

        var _txt_olvidar =
            scr_loc(
                texto_opcion_olvidar
            );


        // ====================================
        // ESPACIO FIJO PARA FLECHA
        // ====================================

        var _selector_w =
            string_width("> ")
            * _esc;


        // ====================================
        // ANCHOS
        // ====================================

        var _texto_despertar_w =
            string_width(
                _txt_despertar
            )
            * _esc;


        var _texto_olvidar_w =
            string_width(
                _txt_olvidar
            )
            * _esc;


        var _opcion_despertar_w =
            _selector_w
            + _texto_despertar_w;


        var _opcion_olvidar_w =
            _selector_w
            + _texto_olvidar_w;


        // ====================================
        // SEPARACIÓN
        // ====================================

        var _separacion =
            45 * _esc;


        // ====================================
        // ANCHO TOTAL
        // ====================================

        var _ancho_total =
            _opcion_despertar_w
            + _separacion
            + _opcion_olvidar_w;


        // ====================================
        // CENTRAR FILA
        // ====================================

        var _inicio_x =
            (_gw * 0.5)
            - (_ancho_total * 0.5);



        // ====================================================
        // DESPERTAR
        // ====================================================

        var _despertar_selector_x =
            _inicio_x;


        var _despertar_texto_x =
            _despertar_selector_x
            + _selector_w;


        // Flecha aparte
        if (seleccion == 0)
        {
            draw_text_transformed(
                _despertar_selector_x,
                _oy,
                ">",
                _esc,
                _esc,
                0
            );
        }


        // La palabra SIEMPRE está
        // en la misma coordenada.
        draw_text_transformed(
            _despertar_texto_x,
            _oy,
            _txt_despertar,
            _esc,
            _esc,
            0
        );



        // ====================================================
        // OLVIDAR
        // ====================================================

        var _olvidar_selector_x =
            _inicio_x
            + _opcion_despertar_w
            + _separacion;


        var _olvidar_texto_x =
            _olvidar_selector_x
            + _selector_w;


        // Flecha aparte
        if (seleccion == 1)
        {
            draw_text_transformed(
                _olvidar_selector_x,
                _oy,
                ">",
                _esc,
                _esc,
                0
            );
        }


        // La palabra SIEMPRE está
        // en la misma coordenada.
        draw_text_transformed(
            _olvidar_texto_x,
            _oy,
            _txt_olvidar,
            _esc,
            _esc,
            0
        );


        // ====================================
        // RESTAURAR ALPHA
        // ====================================

        draw_set_alpha(1);
    }
}



// ============================================================
// ESTADO 1
// OLVIDAR
// ============================================================

else if (estado == 1)
{
    var _texto_olvidar_actual =
        scr_loc(
            texto_olvidar
        );


    var _mostrar =
        string_copy(
            _texto_olvidar_actual,
            1,
            caracteres_olvidar
        );


    // ========================================
    // CENTRAR TEXTO
    // ========================================

    var _ancho =
        _ancho_texto_multilinea(
            _texto_olvidar_actual
        )
        * _esc;


    var _tx =
        (_gw * 0.5)
        - (_ancho * 0.5);


    // ========================================
    // TEMBLOR
    // ========================================

    var _shake_x =
        irandom_range(-2, 2);

    var _shake_y =
        irandom_range(-2, 2);


    // ========================================
    // DIBUJAR
    // ========================================

    draw_text_transformed(
        _tx + _shake_x,
        _ty + _shake_y,
        _mostrar,
        _esc,
        _esc,
        0
    );
}



// ============================================================
// ESTADO 2
// FADE BLANCO DE DESPERTAR
// ============================================================

if (
    estado == 2
    ||
    estado == 3
)
{
    draw_set_colour(c_white);

    draw_set_alpha(
        fade_blanco
    );


    draw_rectangle(
        0,
        0,
        _gw,
        _gh,
        false
    );


    // Restaurar
    draw_set_alpha(1);
    draw_set_colour(c_white);
}
