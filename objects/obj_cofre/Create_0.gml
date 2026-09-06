
// =========================================================
// OBJ_COFRE
// CREATE
// =========================================================

scr_cofre_init();


// =========================================================
// COLISIÓN FÍSICA DEL TAMAÑO DEL SPRITE
// =========================================================
//
// El movimiento de Maya comprueba colisiones contra el
// objeto padre `colision`. El cofre mantiene su lógica como
// objeto independiente, así que creamos un proxy invisible
// de `colision` usando EXACTAMENTE el mismo sprite, origen,
// escala y ángulo del cofre.
//
// De esta forma el cofre bloquea físicamente al jugador sin
// tener que modificar todo el sistema de movimiento/hielo.
// =========================================================

mask_index =
    sprite_index;

cofre_collision_proxy =
    noone;


if (
    sprite_index != -1
    &&
    sprite_exists(sprite_index)
)
{
    cofre_collision_proxy =
        instance_create_depth(
            x,
            y,
            depth + 1,
            colision
        );


    if (
        cofre_collision_proxy != noone
        &&
        instance_exists(cofre_collision_proxy)
    )
    {
        cofre_collision_proxy.sprite_index =
            sprite_index;

        cofre_collision_proxy.mask_index =
            sprite_index;

        cofre_collision_proxy.image_index =
            image_index;

        cofre_collision_proxy.image_speed =
            0;

        cofre_collision_proxy.image_xscale =
            image_xscale;

        cofre_collision_proxy.image_yscale =
            image_yscale;

        cofre_collision_proxy.image_angle =
            image_angle;

        cofre_collision_proxy.visible =
            false;
    }
}


// =========================================================
// DISTANCIA DE INTERACCIÓN
// =========================================================
//
// Antes: 40
// Ahora: 20
//

interaccion_distancia = 20;


// Cuánto puede desviarse el jugador lateralmente
// mientras mira hacia el cofre.
interaccion_tolerancia = 18;


// El objeto físico no necesita ser persistente.
persistent = false;

scr_depth_sort_register(id);

