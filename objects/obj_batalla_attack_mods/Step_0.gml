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
        // AGRANDAR ARO
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
