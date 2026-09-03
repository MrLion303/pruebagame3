/// =========================================================
/// OBJ_NEW_GAME_TRANSITION
/// STEP
/// =========================================================


// =========================================================
// FASE 0
// CUBRIR PANTALLA
// =========================================================

if (fase == 0)
{
    transicion_progreso += transicion_velocidad;


    if (transicion_progreso >= 1)
    {
        transicion_progreso = 1;


        // =================================================
        // NUEVA PARTIDA
        // =================================================

        scr_init_playtime();

        global.new_game = true;


        // Nueva partida = party vacía.
        scr_party_reset();


        global.start_room = destino_room;
        global.start_x = destino_x;
        global.start_y = destino_y;


        // =================================================
        // NIVEL
        // =================================================

        global.level_data =
        {
            nivel: 1,

            exp_actual: 0,
            exp_siguiente: 100,

            ataque_base: 0,
            defensa_base: 0,

            hp_max: 80,

            nivel_max: 20
        };


        // =================================================
        // INVENTARIO
        // =================================================

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


        // =================================================
        // COFRE
        // =================================================

        global.chest_data =
            array_create(
                50,
                -1
            );


        // =================================================
        // CINEMÁTICAS VISTAS
        // =================================================

        global.cutscene_flags =
            {};


        // =================================================
        // CAMBIO DE ROOM
        // =================================================
        //
        // IMPORTANTE:
        // el cambio ocurre SOLO cuando la pantalla
        // ya está completamente cubierta.
        // =================================================

        fase = 1;


        room_goto(
            destino_room
        );


        exit;
    }
}


// =========================================================
// FASE 1
// ESPERAR ROOM START
// =========================================================

else if (fase == 1)
{
    // No hacemos nada.
    //
    // El evento Room Start cambiará a fase 2.
}


// =========================================================
// FASE 2
// DESCUBRIR PANTALLA
// =========================================================

else if (fase == 2)
{
    transicion_progreso -=
        transicion_velocidad;


    if (transicion_progreso <= 0)
    {
        transicion_progreso = 0;


        // =================================================
        // DEVOLVER CONTROL
        // =================================================

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


        persistent = false;


        instance_destroy();


        exit;
    }
}
