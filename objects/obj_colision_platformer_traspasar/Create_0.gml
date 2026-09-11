/// =========================================================
/// OBJ_COLISION_PLATFORMER_TRASPASAR
/// CREATE
/// =========================================================
///
/// Plataforma one-way:
///
///     desde abajo:
///         se atraviesa.
///
///     desde arriba:
///         funciona como suelo.
///
///     lateral:
///         no bloquea.
///
/// Si el objeto tiene sprite/máscara, el sistema usa su bbox.
///
/// Si NO tiene sprite, usa estas dimensiones de fallback.
/// =========================================================

active =
    true;


// Solo se usan si el objeto NO tiene sprite/máscara.
platform_width =
    32;


platform_height =
    8;


// Tolerancia de la superficie superior.
surface_margin =
    2;


// Es una colisión lógica; normalmente no queremos dibujarla.
visible =
    false;
