/// =========================================================
/// SCR_SPRITES_IDIOMA
///
/// Sistema de localización para SPRITES COLOCADOS
/// DIRECTAMENTE EN LOS ROOMS mediante Asset Layers.
///
/// Para añadir uno nuevo:
///
/// [sprite_español, sprite_ingles],
///
/// =========================================================


// =========================================================
// REGISTRO DE SPRITES TRADUCIBLES
// =========================================================

function scr_sprites_idioma_registro() {

    return [

        // =================================================
        // AÑADE AQUÍ TODOS LOS PARES QUE QUIERAS
        // =================================================

        [spr_pruebaidioma, spr_pruebaidioma_english]

        // Ejemplos:
        //
        // [spr_cartel_escuela, spr_cartel_escuela_english],
        // [spr_tutorial_z, spr_tutorial_z_english],
        // [spr_letrero_hotel, spr_letrero_hotel_english],
        // [spr_poster, spr_poster_english]

    ];
}


// =========================================================
// INICIALIZAR
// =========================================================

function scr_sprites_idioma_init() {

    global.sprites_idioma = scr_sprites_idioma_registro();

}


// =========================================================
// OBTENER VARIANTE DEL SPRITE
// =========================================================

function scr_sprite_idioma(_sprite) {

    if (!variable_global_exists("sprites_idioma")) {
        scr_sprites_idioma_init();
    }

    var _ingles = scr_language_is_english();

    for (var i = 0; i < array_length(global.sprites_idioma); i++) {

        var _par = global.sprites_idioma[i];

        var _es = _par[0];
        var _en = _par[1];

        // Reconocemos tanto la versión española
        // como la versión inglesa.
        if (_sprite == _es || _sprite == _en) {

            if (_ingles) {
                return _en;
            }
            else {
                return _es;
            }
        }
    }

    // Si no está registrado, no tocarlo.
    return _sprite;
}


// =========================================================
// APLICAR LOCALIZACIÓN A LOS SPRITES DEL ROOM
// =========================================================

function scr_sprites_idioma_aplicar_room() {

    if (!variable_global_exists("sprites_idioma")) {
        scr_sprites_idioma_init();
    }

    // Obtener TODAS las capas del room actual.
    var _layers = layer_get_all();

    if (!is_array(_layers)) {
        return;
    }


    // =====================================================
    // RECORRER CAPAS
    // =====================================================

    for (var l = 0; l < array_length(_layers); l++) {

        var _layer = _layers[l];

        // Obtener todos los elementos de esta capa.
        var _elements = layer_get_all_elements(_layer);

        if (!is_array(_elements)) {
            continue;
        }


        // =================================================
        // RECORRER ELEMENTOS
        // =================================================

        for (var e = 0; e < array_length(_elements); e++) {

            var _element = _elements[e];


            // ---------------------------------------------
            // SOLO SPRITES COLOCADOS EN ASSET LAYERS
            // ---------------------------------------------

            if (layer_get_element_type(_element) == layerelementtype_sprite) {

                // Sprite que actualmente tiene el elemento.
                var _sprite_actual = layer_sprite_get_sprite(_element);

                if (_sprite_actual != -1) {

                    // Buscar su versión según idioma.
                    var _sprite_nuevo = scr_sprite_idioma(_sprite_actual);


                    // Solo cambiarlo si realmente corresponde.
                    if (_sprite_nuevo != _sprite_actual) {

                        layer_sprite_change(
                            _element,
                            _sprite_nuevo
                        );

                    }
                }
            }
        }
    }
}
