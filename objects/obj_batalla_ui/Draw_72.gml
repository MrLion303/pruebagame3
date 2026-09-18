/// =========================================================
/// OBJ_BATALLA_UI
/// DRAW BEGIN COMPLETO
/// =========================================================
///
/// - Conserva el arreglo del crash por `anim_index`.
/// - Ya NO cambia el origen de ningún sprite.
/// - Crea el helper visual que corrige solamente el retrato
///   grande del diálogo en Draw GUI End.
/// =========================================================


// =========================================================
// BLINDAJE DE DATOS DE ENEMIGOS
// =========================================================

if (
    variable_instance_exists(
        id,
        "enemigos"
    )
    &&
    is_array(
        enemigos
    )
)
{
    var _enemy_count =
        array_length(
            enemigos
        );


    for (
        var _enemy_i = 0;
        _enemy_i < _enemy_count;
        _enemy_i++
    )
    {
        var _enemy_data =
            enemigos[
                _enemy_i
            ];


        if (!is_struct(_enemy_data))
        {
            continue;
        }


        if (
            !variable_struct_exists(
                _enemy_data,
                "anim_index"
            )
        )
        {
            variable_struct_set(
                _enemy_data,
                "anim_index",
                0
            );
        }


        if (
            !variable_struct_exists(
                _enemy_data,
                "shake_timer"
            )
        )
        {
            variable_struct_set(
                _enemy_data,
                "shake_timer",
                0
            );
        }


        if (
            !variable_struct_exists(
                _enemy_data,
                "derrotado"
            )
        )
        {
            variable_struct_set(
                _enemy_data,
                "derrotado",
                false
            );
        }


        enemigos[
            _enemy_i
        ] =
            _enemy_data;
    }
}


// =========================================================
// ASEGURAR HELPER VISUAL
// =========================================================

var _visual_fix_obj =
    asset_get_index(
        "obj_batalla_ui_visual_fix"
    );


if (
    _visual_fix_obj != -1
    &&
    instance_number(
        _visual_fix_obj
    )
    <=
    0
)
{
    instance_create_depth(
        0,
        0,
        -100000000,
        _visual_fix_obj
    );
}
