/// scr_bosses_cinematica_bbs
/// Base de datos de cinematica y dialogos especiales de bosses.
/// Cada ID devuelve un arreglo de estructuras compatibles
/// con obj_batalla_ui.f_procesar_dialogo().

function scr_bosses_cinematica_bbs(_id_cinematica) {

    var _dialogos = [];

    switch (_id_cinematica) {

        // =========================================================
        // BOSS DE PRUEBA
        // =========================================================
        case "boss_prueba_20":

            _dialogos = [
                {
                    texto: "* El enemigo se detiene de repente...",
                    head: noone,
                    snd: snd_text,
                    music: snd_nosound // <-- ESTO DETIENE LA MÚSICA ACTUAL
                },
                {
                    texto: "* Una energía extraña comienza a rodearlo.",
                    head: noone,
                    snd: snd_text
                    // Al no poner "music", la música se queda como estaba (silencio en este caso)
                },
                {
                    texto: "¿De verdad creíste que esto sería tan fácil?",
                    head: spr_bbs_prota_head,
                    snd: snd_noelle,
                    music: mus_battle_1 // <-- ESTO REPRODUCE LA NUEVA MÚSICA
                },
                {
                    texto: "* El boss parece prepararse para continuar la batalla.",
                    head: noone,
                    snd: snd_text
                }
            ];

            break;


        // =========================================================
        // DEFAULT
        // =========================================================
        default:

            _dialogos = [];

            break;
    }

    return _dialogos;
}