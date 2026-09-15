/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// STEP COMPLETO
/// =========================================================

if (room != bbs)
    exit;


if (!f_refresh_refs())
    exit;


var _ui =
    ui_ref;


// =========================================================
// OUTRO DEL ARO CARGADO
// =========================================================
//
// La entrada del ataque circular ya usa:
//
//     circle_intro_progress
//
// de 0 -> 1.
//
// Draw GUI End utiliza ese valor para convertir suavemente:
//
//     caja horizontal -> caja 128x128
//
// Para volver al estado normal NO necesitamos otro sistema
// visual: recorremos exactamente el mismo valor al revés:
//
//     1 -> 0
//
// mientras custom_mode sigue siendo "circle".
//
// La diana desaparece al comenzar este OUTRO y la caja vuelve
// suavemente a su tamaño horizontal original.
//
// =========================================================

if (
    !variable_instance_exists(
        id,
        "circle_outro_active"
    )
)
{
    circle_outro_active =
        false;

    circle_outro_timer =
        0;

    circle_outro_frames =
        max(
            1,
            circle_intro_frames
        );
}


if (circle_outro_active)
{
    circle_outro_timer++;


    var _outro_t =
        clamp(
            circle_outro_timer
            /
            max(
                1,
                circle_outro_frames
            ),
            0,
            1
        );


    // 1 -> 0.
    //
    // Draw GUI End ya aplica su easing normal sobre este valor,
    // por lo que visualmente obtenemos la misma transformación
    // pero en sentido contrario.
    circle_intro_progress =
        1
        -
        _outro_t;


    // La diana ya desapareció.
    circle_ready =
        false;

    circle_started =
        false;

    circle_active =
        false;


    if (
        circle_outro_timer
        >=
        circle_outro_frames
    )
    {
        circle_outro_active =
            false;

        circle_outro_timer =
            0;

        circle_intro_progress =
            0;


        // Aplicar el daño únicamente cuando la caja terminó
        // de regresar a su estado horizontal.
        f_apply_custom_damage_final();


        // Ahora sí pasar al popup normal del resultado.
        f_start_final_feedback();
    }


    exit;
}


// =========================================================
// ESPERA FINAL: 1 SEGUNDO CON TARGET / DIANA EN PANTALLA
// =========================================================

if (custom_hold_active)
{
    custom_hold_timer++;


    if (
        custom_hold_timer
        >=
        custom_hold_duration
    )
    {
        custom_hold_active =
            false;


        // =================================================
        // ARO CARGADO
        // =================================================
        //
        // Antes se hacía:
        //
        //     aplicar daño
        //     -> cerrar modo circle
        //     -> caja horizontal instantánea
        //
        // Ahora:
        //
        //     termina hold
        //     -> diana desaparece
        //     -> caja 128x128 vuelve suavemente a horizontal
        //     -> aplicar daño
        //     -> popup
        //
        // =================================================

        if (custom_mode == "circle")
        {
            circle_outro_active =
                true;

            circle_outro_timer =
                0;

            circle_outro_frames =
                max(
                    1,
                    circle_intro_frames
                );

            circle_intro_active =
                false;

            circle_intro_timer =
                circle_intro_frames;

            circle_intro_progress =
                1;

            circle_ready =
                false;

            circle_started =
                false;

            circle_active =
                false;


            keyboard_clear(
                ord("Z")
            );

            keyboard_clear(
                vk_enter
            );


            exit;
        }


        // Multi-barra conserva el comportamiento anterior.
        f_apply_custom_damage_final();


        f_start_final_feedback();
    }


    exit;
}


// =========================================================
// MULTI-BARRA
// =========================================================

if (custom_mode == "multi")
{
    // -----------------------------------------------------
    // TODAS LAS BARRAS SE MUEVEN A LA VEZ
    // -----------------------------------------------------

    for (
        var _i = 0;
        _i < multi_count;
        _i++
    )
    {
        if (!multi_done[_i])
        {
            multi_positions[_i] +=
                multi_speed
                *
                multi_direction;
        }
    }


    // -----------------------------------------------------
    // CONFIRMAR LA BARRA QUE VA PRIMERO
    // -----------------------------------------------------

    if (
        !custom_wait_release
        &&
        custom_accept_pressed
        &&
        multi_next < multi_count
    )
    {
        f_resolve_multi_bar(
            multi_next,
            false
        );


        if (custom_mode != "multi")
            exit;
    }


    // -----------------------------------------------------
    // SI LA BARRA LÍDER SALE DEL TARGET = MISS
    // -----------------------------------------------------

    if (
        multi_next < multi_count
        &&
        !multi_done[
            multi_next
        ]
    )
    {
        var _passed =
            (
                multi_direction > 0
                &&
                multi_positions[
                    multi_next
                ]
                >=
                multi_max_x
            )
            ||
            (
                multi_direction < 0
                &&
                multi_positions[
                    multi_next
                ]
                <=
                multi_min_x
            );


        if (_passed)
        {
            f_resolve_multi_bar(
                multi_next,
                true
            );
        }
    }


    exit;
}


// =========================================================
// ATAQUE CIRCULAR
// =========================================================

if (custom_mode == "circle")
{
    // =====================================================
    // 1. ANIMACIÓN DE ENTRADA
    // =====================================================
    // La caja horizontal se encoge durante 10 frames.
    // Todavía NO corre el tiempo jugable y NO se acepta Z.
    // =====================================================

    if (circle_intro_active)
    {
        circle_intro_timer++;


        circle_intro_progress =
            clamp(
                circle_intro_timer
                /
                max(
                    1,
                    circle_intro_frames
                ),
                0,
                1
            );


        if (
            circle_intro_timer
            >=
            circle_intro_frames
        )
        {
            circle_intro_active =
                false;

            circle_intro_progress =
                1;

            circle_ready =
                true;

            circle_timer =
                0;

            circle_started =
                false;

            circle_radius =
                circle_radius_start;

            // Requerir Z/Enter suelto antes de aceptar un
            // nuevo inicio de carga.
            circle_input_armed =
                false;
        }


        exit;
    }


    // =====================================================
    // 2. DIANA VISIBLE = TIEMPO CORRIENDO
    // =====================================================
    // El jugador tiene una ventana limitada desde el mismo
    // momento en que aparece la diana, incluso aunque todavía
    // no haya pulsado Z.
    // =====================================================

    if (circle_ready)
    {
        circle_timer++;


        // -------------------------------------------------
        // EMPEZAR CARGA CON UNA PULSACIÓN NUEVA
        // -------------------------------------------------

        if (
            circle_input_armed
            &&
            !circle_started
            &&
            custom_accept_pressed
        )
        {
            circle_started =
                true;
        }


        // -------------------------------------------------
        // AGRANDAR ARO CONTINUAMENTE MIENTRAS Z SIGA ABAJO
        // -------------------------------------------------
        //
        // custom_accept_held viene de keyboard_check_direct(),
        // así keyboard_clear() ya NO corta la carga.
        // -------------------------------------------------

        if (
            circle_started
            &&
            custom_accept_held
        )
        {
            circle_radius =
                min(
                    circle_radius_max,
                    circle_radius
                    +
                    circle_speed
                );
        }


        // -------------------------------------------------
        // SOLTAR DESPUÉS DE EMPEZAR
        // -------------------------------------------------

        if (
            circle_started
            &&
            !custom_accept_held
        )
        {
            f_resolve_circle_hit();
            exit;
        }


        // -------------------------------------------------
        // SE ACABÓ EL TIEMPO
        // -------------------------------------------------
        // Si nunca pulsó Z = MISS.
        // Si sí estaba cargando = se evalúa el tamaño actual.
        // -------------------------------------------------

        if (
            circle_timer
            >=
            circle_limit
        )
        {
            f_resolve_circle_hit();
            exit;
        }
    }
}
