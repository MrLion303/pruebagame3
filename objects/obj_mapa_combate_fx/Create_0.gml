/// =========================================================
/// OBJ_MAPA_COMBATE_FX
/// CREATE
/// =========================================================
///
/// Gestiona:
///
/// - oscurecimiento del entorno con fade
/// - transición gradual de Maya a rojo
/// - enemigos y balas sin oscurecer
/// - HUD independiente de combate en mapa
/// - i-frames de daño
/// - congelación de 1 segundo antes del Game Over
///
/// Se crea automáticamente.
/// NO hace falta ponerlo en la room.
/// =========================================================

persistent =
    false;


// Depth alto:
// su Draw GUI ocurre después del mundo.
depth =
    1000000;


danger_active =
    false;


// Oscuridad solicitada por los enemigos activos.
oscuridad_actual =
    0;


// Último nivel de oscuridad válido.
// Se conserva durante el fade-out.
oscuridad_base =
    0;


// =========================================================
// FADE DEL ESTADO DE PELIGRO
// =========================================================
//
// 0 = mapa normal
// 1 = peligro completamente aplicado
//
// Controla conjuntamente:
//
//     oscurecimiento
//     Maya roja
//     resaltado de enemigos/balas
// =========================================================

fx_anim =
    0;


// 12 frames a 30 FPS ≈ 0.4 segundos.
fx_anim_speed =
    1 / 12;


// -1 = no hay muerte en proceso.
death_timer =
    -1;


// =========================================================
// HUD DE COMBATE EN MAPA
// =========================================================

hud_anim =
    0;


hud_anim_speed =
    1 / 12;


// El HUD de mapa es más pequeño que el de batalla normal.
hud_size_factor =
    0.78;


// Estado de la cabeza de Maya al recibir daño.
hud_hp_anterior =
    -1;


hud_timer_dolor =
    0;




// =========================================================
// SCREEN SHAKE POR DAÑO DE PROYECTILES DE MAPA
// =========================================================
//
// Se aplica sobre la cámara normal de la room.
// NO modifica el seguimiento permanente de obj_player.
//
// Valores por defecto:
//     7 frames
//     3 píxeles de fuerza inicial
// =========================================================

map_shake_timer =
    0;


map_shake_duration =
    7;


map_shake_strength =
    3;


// Offset realmente aplicado el frame anterior.
// Sirve para evitar cualquier deriva acumulativa.
map_shake_prev_x =
    0;


map_shake_prev_y =
    0;


// Última posición final de cámara a la que nosotros
// aplicamos shake. Si el seguimiento automático de la room
// ya cambió la cámara antes del próximo End Step,
// no intentamos "deshacer" un offset que ya no existe.
map_shake_last_cam_x =
    0;


map_shake_last_cam_y =
    0;


map_shake_was_applied =
    false;


if (
    !variable_global_exists(
        "gameover_death_freeze_active"
    )
)
{
    global.gameover_death_freeze_active =
        false;
}
