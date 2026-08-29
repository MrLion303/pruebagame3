/// =========================================================
/// OBJ_CUTSCENE_TRIGGER
/// CREATE
/// =========================================================
//
// La visibilidad se controla desde las propiedades
// del objeto/instancia en GameMaker.
// =========================================================


// Puedes cambiar esto desde el Creation Code
// de cada instancia.

if (
    !variable_instance_exists(
        id,
        "cutscene_id"
    )
)
{
    cutscene_id = "";
}


if (
    !variable_instance_exists(
        id,
        "one_shot"
    )
)
{
    one_shot = true;
}


// Evita repetir continuamente mientras
// el jugador permanezca encima.
player_was_inside = false;