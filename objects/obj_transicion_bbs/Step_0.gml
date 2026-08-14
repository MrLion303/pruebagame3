// Control de desbloqueo al volver a la room original
if (room != bbs) {
    if (instance_exists(obj_player)) {
        // Si el jugador estaba bloqueado, revisamos si ya soltó todas las teclas de movimiento
        if (!obj_player.puede_moverse) {
            if (!keyboard_check(vk_right) && !keyboard_check(vk_left) && !keyboard_check(vk_up) && !keyboard_check(vk_down)) {
                obj_player.puede_moverse = true; // Ahora sí, recupera el control limpio
            }
        }
    }
}

// Si ya estamos en la room de batalla y la animacion esta retrocediendo
if (room == bbs && image_index < 1) {
    instance_destroy();
}
