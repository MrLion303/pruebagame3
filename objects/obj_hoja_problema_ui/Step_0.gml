/// =========================================================
/// OBJ_HOJA_PROBLEMA_UI - STEP
/// =========================================================

// =========================================================
// INICIALIZACIÓN TARDÍA
// =========================================================
//
// El objeto del mundo asigna sheet_config_id DESPUÉS de que
// Create se ejecuta.
//
// =========================================================

if (!sheet_initialized)
{
    sheet_config =
        scr_problem_sheet_config(
            sheet_config_id
        );


    if (is_undefined(sheet_config))
    {
        show_debug_message(
            "[HOJA] Configuración inexistente: "
            +
            string(
                sheet_config_id
            )
        );


        instance_destroy();

        exit;
    }


    if (
        !variable_struct_exists(
            sheet_config,
            "problems"
        )
        ||
        !is_array(
            sheet_config.problems
        )
    )
    {
        show_debug_message(
            "[HOJA] La configuración no tiene problems[]."
        );


        instance_destroy();

        exit;
    }


    problem_count =
        clamp(
            array_length(
                sheet_config.problems
            ),
            1,
            3
        );


    selected_problem =
        0;


    if (instance_exists(obj_player))
    {
        saved_player =
            instance_find(
                obj_player,
                0
            );


        if (
            saved_player != noone
            &&
            instance_exists(saved_player)
        )
        {
            saved_player_can_move =
                saved_player.puede_moverse;


            saved_player.puede_moverse =
                false;


            saved_player.movimiento =
                false;
        }
    }


    // Si el puzzle ya estaba resuelto, mostrar la hoja resuelta.
    if (
        variable_struct_exists(
            sheet_config,
            "puzzle_id"
        )
        &&
        scr_puzzle_is_completed(
            sheet_config.puzzle_id
        )
    )
    {
        for (
            var _i = 0;
            _i < problem_count;
            _i++
        )
        {
            problem_status[_i] =
                1;


            answer_texts[_i] =
                string(
                    sheet_config.problems[_i].answer
                );
        }


        sheet_completed_sent =
            true;
    }


    sheet_initialized =
        true;
}


// =========================================================
// MANTENER MAYA BLOQUEADA
// =========================================================

if (
    saved_player != noone
    &&
    instance_exists(saved_player)
)
{
    saved_player.puede_moverse =
        false;


    saved_player.movimiento =
        false;
}


if (input_lock > 0)
{
    input_lock--;

    exit;
}


// =========================================================
// CERRAR
// =========================================================

if (
    keyboard_check_pressed(
        ord("X")
    )
    ||
    keyboard_check_pressed(
        vk_shift
    )
    ||
    keyboard_check_pressed(
        vk_escape
    )
)
{
    instance_destroy();

    exit;
}


// =========================================================
// CAMBIAR PROBLEMA SELECCIONADO
// =========================================================

if (
    keyboard_check_pressed(
        vk_up
    )
)
{
    selected_problem =
        max(
            0,
            selected_problem - 1
        );
}


if (
    keyboard_check_pressed(
        vk_down
    )
)
{
    selected_problem =
        min(
            problem_count - 1,
            selected_problem + 1
        );
}


// =========================================================
// ESCRIBIR NÚMEROS
// =========================================================

if (
    problem_status[
        selected_problem
    ]
    !=
    1
)
{
    for (
        var _digit = 0;
        _digit <= 9;
        _digit++
    )
    {
        if (
            keyboard_check_pressed(
                ord("0")
                +
                _digit
            )
        )
        {
            if (
                string_length(
                    answer_texts[
                        selected_problem
                    ]
                )
                <
                8
            )
            {
                answer_texts[
                    selected_problem
                ]
                +=
                string(
                    _digit
                );
            }
        }
    }


    // Permitir respuestas negativas.
    if (
        keyboard_check_pressed(
            ord("-")
        )
        &&
        answer_texts[
            selected_problem
        ]
        ==
        ""
    )
    {
        answer_texts[
            selected_problem
        ]
        =
        "-";
    }


    if (
        keyboard_check_pressed(
            vk_backspace
        )
    )
    {
        var _txt =
            answer_texts[
                selected_problem
            ];


        var _len =
            string_length(
                _txt
            );


        if (_len > 0)
        {
            answer_texts[
                selected_problem
            ]
            =
            string_delete(
                _txt,
                _len,
                1
            );
        }
    }
}


// =========================================================
// CONFIRMAR RESPUESTA
// =========================================================

var _confirm =
    keyboard_check_pressed(
        ord("Z")
    )
    ||
    keyboard_check_pressed(
        vk_enter
    );


if (_confirm)
{
    var _index =
        selected_problem;


    if (
        problem_status[_index]
        !=
        1
    )
    {
        var _problem =
            sheet_config.problems[
                _index
            ];


        var _answer_text =
            answer_texts[
                _index
            ];


        var _valid_input =
            (
                _answer_text != ""
                &&
                _answer_text != "-"
            );


        var _correct =
            false;


        if (_valid_input)
        {
            var _typed =
                real(
                    _answer_text
                );


            var _expected =
                real(
                    _problem.answer
                );


            _correct =
                abs(
                    _typed
                    -
                    _expected
                )
                <
                0.0001;
        }


        if (_correct)
        {
            problem_status[_index] =
                1;


            if (
                variable_struct_exists(
                    sheet_config,
                    "correct_sound"
                )
            )
            {
                scr_problem_sheet_play_sound(
                    sheet_config.correct_sound
                );
            }


            // Seleccionar el siguiente pendiente.
            for (
                var _next = _index + 1;
                _next < problem_count;
                _next++
            )
            {
                if (
                    problem_status[_next]
                    !=
                    1
                )
                {
                    selected_problem =
                        _next;

                    break;
                }
            }
        }
        else
        {
            problem_status[_index] =
                -1;


            if (
                variable_struct_exists(
                    sheet_config,
                    "wrong_sound"
                )
            )
            {
                scr_problem_sheet_play_sound(
                    sheet_config.wrong_sound
                );
            }
        }
    }


    // =====================================================
    // ¿TODOS RESUELTOS?
    // =====================================================

    var _all_correct =
        true;


    for (
        var _i = 0;
        _i < problem_count;
        _i++
    )
    {
        if (
            problem_status[_i]
            !=
            1
        )
        {
            _all_correct =
                false;

            break;
        }
    }


    if (
        _all_correct
        &&
        !sheet_completed_sent
    )
    {
        if (
            variable_struct_exists(
                sheet_config,
                "puzzle_id"
            )
        )
        {
            scr_puzzle_set_completed(
                sheet_config.puzzle_id,
                true
            );
        }


        sheet_completed_sent =
            true;
    }
}
