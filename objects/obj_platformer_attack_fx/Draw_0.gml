/// =========================================================
/// OBJ_PLATFORMER_ATTACK_FX
/// DRAW COMPLETO
/// =========================================================
///
/// El ataque de Maya ya tiene sus propios sprites:
///
///     spr_maya_ataque_platform_derecha
///     spr_maya_ataque_platform_izquierda
///     spr_maya_ataque_platform_arriba_derecha
///     spr_maya_ataque_platform_arriba_izquierda
///     spr_maya_ataque_platform_abajo_derecha
///     spr_maya_ataque_platform_abajo_izquierda
///
/// Por eso este objeto ya NO dibuja el slash provisional
/// formado por líneas, que visualmente aparecía como ">".
///
/// El objeto puede seguir existiendo durante los pocos frames
/// del ataque porque otra lógica puede depender de su vida,
/// pero no dibuja absolutamente nada.
/// =========================================================

exit;
