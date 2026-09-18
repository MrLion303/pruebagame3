/// =========================================================
/// OBJ_BATALLA_UI
/// DRAW BEGIN COMPLETO
/// =========================================================
///
/// - Conserva el arreglo del crash por `anim_index`.
/// - El retrato de diálogo YA se centra directamente dentro
///   del Draw GUI real de obj_batalla_ui.
/// - El viejo helper visual deja de utilizarse.
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
// DESACTIVAR EL HELPER VIEJO DEL RETRATO
// =========================================================
//
// Si quedó una instancia creada por una versión anterior,
// destruirla para que no vuelva a pintar encima del retrato
// que ahora dibuja correctamente el propio Draw GUI.
// =========================================================

var _old_visual_fix_obj =
    asset_get_index(
        "obj_batalla_ui_visual_fix"
    );


if (_old_visual_fix_obj != -1)
{
    with (_old_visual_fix_obj)
    {
        instance_destroy();
    }
}
