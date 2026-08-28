// =========================================================
// OBJ_NEW_GAME_TRANSITION
// STEP
// =========================================================


// =========================================================
// FASE 0
// CUBRIR EL TÍTULO
// =========================================================

if (fase == 0)
{
    progreso += velocidad;


    if (progreso >= 1)
    {
        progreso = 1;


        // =================================================
        // NUEVA PARTIDA
        // =================================================
        //
        // IMPORTANTE:
        //
        // NO SE TOCA save.ini.
        // NO SE BORRA Save1, Save2 ni Save3.
        // =================================================


        // Tiempo desde cero.
        scr_init_playtime();


        // Nueva partida.
        global.new_game = true;


        // Destino inicial.
        global.start_room =
            destino_room;

        global.start_x =
            destino_x;

        global.start_y =
            destino_y;


        // =================================================
        // REINICIAR NIVEL
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
        // REINICIAR INVENTARIOS GLOBALES
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


        // Toys iniciales.
        global.inventory_data.toys[0] =
            "brillitos";

        global.inventory_data.toys[1] =
            "pegamento";


        // Equipo inicial.
        global.inventory_data.equipamiento[0] =
            "espada_basica";

        global.inventory_data.equipamiento[1] =
            "armadura_basica";


        global.toy_inventory =
            global.inventory_data.toys;


        global.equipment_inventory =
            global.inventory_data.equipamiento;


        // =================================================
        // COFRE VACÍO
        // =================================================

        global.chest_data =
            array_create(
                50,
                -1
            );


        // =================================================
        // CAMBIAR ROOM
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
// RETIRAR TRANSICIÓN
// =========================================================

else if (fase == 1)
{
    progreso -= velocidad;


    if (progreso <= 0)
    {
        progreso = 0;


        // Desbloquear jugador.
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
        }


        persistent =
            false;


        instance_destroy();


        exit;
    }
}