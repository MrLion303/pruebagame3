// =========================================================
// OBJ_GAME
// EVENTO: DRAW GUI
// =========================================================

// Solo dibujamos si el interruptor está en true
if (mostrar_info)
{
    draw_set_color(c_white);

    var jugador = instance_find(obj_player, 0);

    if (jugador != noone)
    {
        var _escala = 0.6;

        // Posición inicial
        var _y = 20;

        // Distancia entre líneas
        var _espacio = 20;


        // =====================================================
        // COORDENADAS Y ROOM
        // =====================================================

        draw_text_transformed(
            20,
            _y,
            scr_loc("Jugador X: ") + string(jugador.x),
            _escala,
            _escala,
            0
        );

        _y += _espacio;


        draw_text_transformed(
            20,
            _y,
            scr_loc("Jugador Y: ") + string(jugador.y),
            _escala,
            _escala,
            0
        );

        _y += _espacio;


        draw_text_transformed(
            20,
            _y,
            scr_loc("Room: ") + string(room_get_name(room)),
            _escala,
            _escala,
            0
        );

        _y += _espacio;


        // =====================================================
        // FPS
        // =====================================================

        draw_text_transformed(
            20,
            _y,
            scr_loc("FPS: ")
            + string(fps)
            + " / "
            + string(game_get_speed(gamespeed_fps)),
            _escala,
            _escala,
            0
        );

        _y += _espacio;


        // =====================================================
        // IDIOMA ACTUAL
        // =====================================================

        var _idioma_actual;

        if (scr_language_is_english())
        {
            _idioma_actual = "English";
        }
        else
        {
            _idioma_actual = "Español";
        }


        draw_text_transformed(
            20,
            _y,
            scr_loc("Idioma: ") + _idioma_actual,
            _escala,
            _escala,
            0
        );

        _y += _espacio;


        // =====================================================
        // MÚSICA SONANDO
        // =====================================================

        var _musica_actual = scr_loc_src("Ninguna");


        // Escaneamos los primeros 1000 assets buscando audio.
        for (var _i = 0; _i < 1000; _i++)
        {
            if (audio_exists(_i))
            {
                if (audio_is_playing(_i))
                {
                    var _nombre_audio = audio_get_name(_i);

                    // Solo sonidos que empiecen por mus_
                    if (string_starts_with(_nombre_audio, "mus_"))
                    {
                        _musica_actual = _nombre_audio;
                        break;
                    }
                }
            }
        }


        // =====================================================
        // DIBUJAR NOMBRE DE LA MÚSICA
        // =====================================================

        draw_text_transformed(
            20,
            _y,
            scr_loc("Musica: ") + scr_loc(_musica_actual),
            _escala,
            _escala,
            0
        );
    }
}