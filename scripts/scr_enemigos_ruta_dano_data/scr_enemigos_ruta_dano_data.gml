/// =========================================================
/// SCR_ENEMIGOS_RUTA_DANO_DATA
/// =========================================================
///
/// sigilo_factor_vision multiplica rango_peligro mientras
/// Maya está en Sigilo.
/// =========================================================

function scr_enemigos_ruta_dano_data(_id)
{
    switch (_id)
    {
        case "ruta_dano_01":
            return
            {
                ruta_puntos:
                [
                    { x: 200, y: 200 },
                    { x: 360, y: 200 },
                    { x: 360, y: 360 },
                    { x: 200, y: 360 }
                ],

                ruta_velocidad: 3.0,

                rango_peligro: 180,
                sigilo_factor_vision: 0.50,

                oscuridad: 0.44,

                dano_contacto: 8,
                invulnerabilidad_frames: 16
            };
    }


    show_debug_message(
        "[ENEMIGO RUTA DAÑO] ID desconocido: "
        +
        string(_id)
    );


    return
    {
        ruta_puntos:
        [
            { x: 0, y: 0 },
            { x: 64, y: 0 }
        ],

        ruta_velocidad: 2.0,

        rango_peligro: 160,
        sigilo_factor_vision: 0.50,

        oscuridad: 0.38,

        dano_contacto: 5,
        invulnerabilidad_frames: 16
    };
}
