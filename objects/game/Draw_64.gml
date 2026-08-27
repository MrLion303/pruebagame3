// Solo dibujamos si el interruptor está en true
if (mostrar_info)
{
    draw_set_color(c_white);

    var jugador = instance_find(obj_player, 0);

    if (jugador != noone)
    {
        var _escala = 0.6; 
        
        // Usamos esta variable para calcular el espacio hacia abajo automáticamente
        var _y = 20; 
        var _espacio = 20; // Distancia entre cada línea de texto

        // Coordenadas y Room
        draw_text_transformed(20, _y, "Jugador X: " + string(jugador.x), _escala, _escala, 0); _y += _espacio;
        draw_text_transformed(20, _y, "Jugador Y: " + string(jugador.y), _escala, _escala, 0); _y += _espacio;
        draw_text_transformed(20, _y, "Room: " + string(room_get_name(room)), _escala, _escala, 0); _y += _espacio;
        
        // --- FPS ---
        // Muestra los FPS actuales y el máximo al que debería ir el juego (ej: 60 / 60)
        draw_text_transformed(20, _y, "FPS: " + string(fps) + " / " + string(game_get_speed(gamespeed_fps)), _escala, _escala, 0); _y += _espacio;

        // --- MÚSICA SONANDO ---
        var _musica_actual = "Ninguna";
        
        // Escaneamos los primeros 1000 assets del juego buscando audios
        // (Si tienes un juego masivo con miles de sonidos, puedes subir el 1000)
        for (var _i = 0; _i < 1000; _i++) 
        {
            if (audio_exists(_i)) // Si el ID pertenece a un audio válido
            {
                if (audio_is_playing(_i)) // Si ese audio está sonando ahora mismo
                {
                    var _nombre_audio = audio_get_name(_i);
                    
                    // Verificamos si empieza exactamente con "mus_"
                    if (string_starts_with(_nombre_audio, "mus_")) 
                    {
                        _musica_actual = _nombre_audio;
                        break; // Como ya encontramos la música, detenemos la búsqueda para ahorrar memoria
                    }
                }
            }
        }
        
        // Dibujamos el nombre de la música
        draw_text_transformed(20, _y, "Musica: " + _musica_actual, _escala, _escala, 0);
    }
}