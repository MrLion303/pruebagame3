/// =========================================================
/// OBJ_GAME_OVER_TEXTO
/// BEGIN STEP
/// PLATAFORMERO V5
/// =========================================================
///
/// En cuanto existe la pantalla de Game Over, el modo
/// plataformero deja de existir.
///
/// Esto evita:
//
///     - sprites de plataforma en game_over;
///     - gravedad/momentum residual;
///     - Silicio en modo plataforma;
///     - cambios de modo pendientes.
///
/// La partida que se cargue después vuelve a ser una partida
/// normal y solo entrará otra vez al plataformero mediante
/// su trigger correspondiente.
// =========================================================

if (
    room == game_over
)
{
    if (
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active
    )
    {
        scr_platformer_force_normal_mode();
    }
    else
    {
        // También limpiar cualquier cambio pendiente que haya
        // quedado justo antes de morir.
        scr_platformer_init();


        global.platformer_mode_pending =
            false;


        global.platformer_mode_pending_enable =
            false;


        global.platformer_mode_pending_room =
            -1;
    }
}
