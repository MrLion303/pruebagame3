// --- INTERRUPTOR DE DEBUG (Coordenadas) ---
// Si presionas F3, el texto se oculta o se muestra
if (keyboard_check_pressed(vk_f3))
{
    mostrar_info = !mostrar_info;
}

// --- CONTADOR DE TIEMPO DE JUEGO ---
// Suma 1 frame al contador mientras estés jugando
if (variable_global_exists("playtime_frames")) {
    global.playtime_frames += 1;
}