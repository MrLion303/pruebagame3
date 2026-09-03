
/// =========================================================
/// OBJ_BUTTONS
/// STEP
///
/// 0 = NUEVO
/// 1 = SALIR
/// 2 = IDIOMA
/// =========================================================


// =========================================================
// TRANSICIÓN DE NUEVO JUEGO
// =========================================================

if (newgame_transition_active)
{
    // =====================================================
    // FASE 1
    // CERRAR HASTA NEGRO
    // =====================================================

    if (newgame_transition_phase == 1)
    {
        newgame_transition_progress +=
            newgame_transition_speed;


        if (newgame_transition_progress >= 1)
        {
            newgame_transition_progress =
                1;


            // =============================================
            // CREAR NUEVA PARTIDA
            // =============================================

            scr_init_playtime();


            global.new_game =
                true;


            global.start_room =
                newgame_room;


            global.start_x =
                newgame_x;


            global.start_y =
                newgame_y;


            global.player_hp_current =
                80;


            // =============================================
            // NIVEL
            // =============================================

            global.level_data =
            {
                nivel:
                    1,

                exp_actual:
                    0,

                exp_siguiente:
                    100,

                ataque_base:
                    0,

                defensa_base:
                    0,

                hp_max:
                    80,

                nivel_max:
                    20
            };


            // =============================================
            // INVENTARIO
            // =============================================

            global.inventory_data =
            {
                consumibles:
                [
                    "agua",
                    "manzana",

                    -1,
                    -1,
                    -1,
                    -1,
                    -1,
                    -1,
                    -1,
                    -1,
                    -1,
                    -1
                ],

                toys:
                    array_create(
                        30,
                        -1
                    ),

                equipamiento:
                    array_create(
                        51,
                        -1
                    ),

                equipado_arma:
                    -1,

                equipado_armadura:
                    -1
            };


            global.inventory_data.toys[0] =
                "brillitos";


            global.inventory_data.toys[1] =
                "pegamento";


            global.inventory_data.equipamiento[0] =
                "espada_basica";


            global.inventory_data.equipamiento[1] =
                "armadura_basica";


            global.toy_inventory =
                global.inventory_data.toys;


            global.equipment_inventory =
                global.inventory_data.equipamiento;


            // =============================================
            // COFRE
            // =============================================

            global.chest_data =
                array_create(
                    50,
                    -1
                );


            // =============================================
            // CINEMÁTICAS VISTAS
            // =============================================

            global.cutscene_flags =
                {};


            // =============================================
            // CAMBIO DE ROOM
            // =============================================
            //
            // El objeto debe sobrevivir porque él mismo
            // retirará la pantalla negra después.
            // =============================================

            persistent =
                true;


            newgame_transition_phase =
                2;


            room_goto(
                newgame_room
            );


            exit;
        }
    }


    // =====================================================
    // FASE 2
    // ROOM START SE ENCARGA
    // =====================================================

    else if (newgame_transition_phase == 2)
    {
        // Esperar.
    }


    // =====================================================
    // FASE 3
    // ABRIR TRANSICIÓN
    // =====================================================

    else if (newgame_transition_phase == 3)
    {
        newgame_transition_progress -=
            newgame_transition_speed;


        if (newgame_transition_progress <= 0)
        {
            newgame_transition_progress =
                0;


            // =============================================
            // DEVOLVER MOVIMIENTO
            // =============================================

            if (instance_exists(obj_player))
            {
                if (
                    variable_instance_exists(
                        obj_player,
                        "puede_moverse"
                    )
                )
                {
                    obj_player.puede_moverse =
                        true;
                }


                if (
                    variable_instance_exists(
                        obj_player,
                        "can_move"
                    )
                )
                {
                    obj_player.can_move =
                        true;
                }
            }


            persistent =
                false;


            instance_destroy();


            exit;
        }
    }


    // Mientras ocurre la transición no aceptar controles.
    exit;
}


// =========================================================
// FADE IN DEL MENÚ
// =========================================================

if (image_alpha < 1)
{
    image_alpha += 0.05;


    if (image_alpha > 1)
    {
        image_alpha =
            1;
    }
}


// =========================================================
// IDIOMA
// =========================================================

scr_loc_init();


var _frame_actual =
    floor(
        image_index
    );


var _sprite_deseado =
    scr_language_is_english()
    ?
    spr_buttons_english
    :
    _sprite_spanish;


if (sprite_index != _sprite_deseado)
{
    sprite_index =
        _sprite_deseado;


    image_index =
        _frame_actual;


    image_speed =
        0;
}


// =========================================================
// BLOQUEAR SI HAY MENÚ DE SAVE
// =========================================================

if (instance_exists(obj_save_menu))
{
    exit;
}


// =========================================================
// ABAJO
// =========================================================

if (keyboard_check_pressed(vk_down))
{
    image_index++;


    if (image_index > 2)
    {
        image_index =
            0;
    }


    audio_play_sound(
        snd_menumove,
        10,
        false
    );
}


// =========================================================
// ARRIBA
// =========================================================

if (keyboard_check_pressed(vk_up))
{
    image_index--;


    if (image_index < 0)
    {
        image_index =
            2;
    }


    audio_play_sound(
        snd_menumove,
        10,
        false
    );
}


// =========================================================
// CONFIRMAR
// =========================================================

var _confirmar =
    keyboard_check_pressed(ord("Z"))
    ||
    keyboard_check_pressed(vk_enter);


if (_confirmar)
{
    var _seleccion =
        floor(
            image_index
        );


    // =====================================================
    // NUEVO JUEGO
    // =====================================================

    if (_seleccion == 0)
    {
        // La partida comienza: quitar música del título.
        if (audio_exists(mus_menu))
        {
            audio_stop_sound(
                mus_menu
            );
        }


        audio_play_sound(
            snd_shineselect,
            10,
            false
        );


        newgame_transition_active =
            true;


        newgame_transition_phase =
            1;


        newgame_transition_progress =
            0;


        // Necesitamos persistencia para sobrevivir
        // al próximo room_goto.
        persistent =
            true;


        keyboard_clear(
            ord("Z")
        );


        keyboard_clear(
            vk_enter
        );


        exit;
    }


    // =====================================================
    // SALIR
    // =====================================================

    if (_seleccion == 1)
    {
        audio_play_sound(
            snd_menumove,
            10,
            false
        );


        game_end();


        exit;
    }


    // =====================================================
    // IDIOMA
    // =====================================================

    if (_seleccion == 2)
    {
        audio_play_sound(
            snd_menumove,
            10,
            false
        );


        var _seleccion_guardada =
            floor(
                image_index
            );


        scr_language_toggle();


        sprite_index =
            scr_language_is_english()
            ?
            spr_buttons_english
            :
            _sprite_spanish;


        image_index =
            _seleccion_guardada;


        image_speed =
            0;


        image_alpha =
            0;


        exit;
    }
}

