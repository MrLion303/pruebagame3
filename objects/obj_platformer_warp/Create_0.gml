/// =========================================================
/// OBJ_PLATFORMER_WARP - CREATE
/// =========================================================

if (!variable_instance_exists(id, "target_room"))
{
    target_room =
        noone;
}

if (!variable_instance_exists(id, "target_x"))
{
    target_x =
        0;
}

if (!variable_instance_exists(id, "target_y"))
{
    target_y =
        0;
}

if (!variable_instance_exists(id, "target_facing"))
{
    target_facing =
        1;
}

if (!variable_instance_exists(id, "target_platformer"))
{
    target_platformer =
        true;
}

if (!variable_instance_exists(id, "interaction_distance"))
{
    // Muy cerca del trigger.
    interaction_distance =
        24;
}

if (!variable_instance_exists(id, "interaction_x_margin"))
{
    // Se reutiliza como tolerancia del eje perpendicular:
    //
    // - si miras izquierda/derecha: tolerancia vertical.
    // - si miras arriba/abajo: tolerancia horizontal.
    interaction_x_margin =
        12;
}

if (!variable_instance_exists(id, "show_prompt"))
{
    show_prompt =
        true;
}

if (!variable_instance_exists(id, "prompt_text"))
{
    prompt_text =
        "[Z]";
}

if (!variable_instance_exists(id, "interaction_enabled"))
{
    interaction_enabled =
        true;
}

transitioning =
    false;

prompt_visible =
    false;
