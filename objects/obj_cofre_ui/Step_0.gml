// =========================================================
// OBJ_COFRE_UI
// STEP
// =========================================================


// =========================================================
// BLOQUEAR PAUSA Y JUGADOR
// =========================================================

keyboard_clear(ord("C"));
keyboard_clear(vk_control);


if (instance_exists(obj_player))
{
    obj_player.puede_moverse = false;
}


// =========================================================
// BLOQUEO INICIAL
// =========================================================

if (input_lock > 0)
{
    input_lock--;

    exit;
}


// =========================================================
// GENERAR INVENTARIO ACTUAL
// =========================================================

var _inventario =
    scr_cofre_inventario_lista();


var _total_inv =
    array_length(
        _inventario
    );


// Seguridad del cursor.
if (_total_inv <= 0)
{
    inventario_index = 0;
    inventario_scroll = 0;
}
else
{
    inventario_index =
        clamp(
            inventario_index,
            0,
            _total_inv - 1
        );
}


// =========================================================
// =========================================================
// MODO: ELIGIENDO DESTINO EN EL COFRE
// =========================================================
// =========================================================
//
// Aquí ya seleccionamos previamente un objeto
// del inventario.
//
// Ahora únicamente elegimos dónde guardarlo.
// =========================================================

if (transferencia_activa)
{
    var _movio =
        false;


    // =====================================================
    // ABAJO
    // =====================================================

    if (keyboard_check_pressed(vk_down))
    {
        if (cofre_index < 49)
        {
            cofre_index++;

            _movio = true;
        }
    }


    // =====================================================
    // ARRIBA
    // =====================================================

    if (keyboard_check_pressed(vk_up))
    {
        if (cofre_index > 0)
        {
            cofre_index--;

            _movio = true;
        }
    }


    if (_movio)
    {
        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // =====================================================
    // SCROLL DEL COFRE
    // =====================================================

    if (cofre_index < cofre_scroll)
    {
        cofre_scroll =
            cofre_index;
    }


    if (
        cofre_index
        >=
        cofre_scroll
        +
        filas_visibles
    )
    {
        cofre_scroll =
            cofre_index
            -
            filas_visibles
            +
            1;
    }


    cofre_scroll =
        clamp(
            cofre_scroll,
            0,
            50 - filas_visibles
        );


    // =====================================================
    // CANCELAR TRANSFERENCIA
    // =====================================================

    if (
        keyboard_check_pressed(ord("X"))
        ||
        keyboard_check_pressed(vk_left)
    )
    {
        transferencia_activa =
            false;


        panel_actual =
            0;


        transfer_tipo = "";
        transfer_slot = -1;
        transfer_key = -1;
        transfer_inv_index = -1;


        audio_play_sound(
            snd_menumove,
            10,
            false
        );


        exit;
    }


    // =====================================================
    // CONFIRMAR DESTINO
    // =====================================================

    if (
        keyboard_check_pressed(ord("Z"))
        ||
        keyboard_check_pressed(vk_enter)
    )
    {
        // -------------------------------------------------
        // COMPROBAR QUE EL ITEM DE ORIGEN TODAVÍA EXISTE
        // -------------------------------------------------

        var _origen_actual =
            scr_cofre_inv_get(
                transfer_tipo,
                transfer_slot
            );


        if (_origen_actual != transfer_key)
        {
            // Algo cambió inesperadamente.
            transferencia_activa = false;
            panel_actual = 0;


            if (audio_is_playing(snd_error))
            {
                audio_stop_sound(snd_error);
            }


            audio_play_sound(
                snd_error,
                10,
                false
            );


            exit;
        }


        // -------------------------------------------------
        // ITEM QUE ACTUALMENTE ESTÁ EN EL SLOT DEL COFRE
        // -------------------------------------------------

        var _item_cofre =
            global.chest_data[
                cofre_index
            ];


        var _transferencia_correcta =
            false;


        // =================================================
        // DESTINO VACÍO
        // =================================================

        if (!is_struct(_item_cofre))
        {
            // Quitar objeto del inventario.
            scr_cofre_inv_set(
                transfer_tipo,
                transfer_slot,
                -1
            );


            // Guardarlo en el cofre.
            global.chest_data[
                cofre_index
            ] =
            {
                tipo:
                    transfer_tipo,

                key:
                    transfer_key
            };


            _transferencia_correcta =
                true;
        }


        // =================================================
        // DESTINO OCUPADO
        // =================================================

        else
        {
            // =================================================
            // MISMO TIPO
            // =================================================
            //
            // Ejemplo:
            //
            // Inventario = Manzana
            // Cofre       = Agua
            //
            // Ambos son consumibles.
            //
            // Se intercambian directamente.
            // =================================================

            if (
                _item_cofre.tipo
                ==
                transfer_tipo
            )
            {
                var _key_cofre =
                    _item_cofre.key;


                // Objeto del cofre -> slot original.
                scr_cofre_inv_set(
                    transfer_tipo,
                    transfer_slot,
                    _key_cofre
                );


                // Objeto seleccionado -> cofre.
                global.chest_data[
                    cofre_index
                ] =
                {
                    tipo:
                        transfer_tipo,

                    key:
                        transfer_key
                };


                _transferencia_correcta =
                    true;
            }


            // =================================================
            // TIPOS DIFERENTES
            // =================================================
            //
            // Ejemplo:
            //
            // Inventario = Manzana
            // Cofre = Espada
            //
            // La espada debe volver al inventario de equipo.
            // =================================================

            else
            {
                var _slot_para_item_cofre =
                    scr_cofre_inv_slot_vacio(
                        _item_cofre.tipo
                    );


                // No existe sitio para devolver
                // el objeto del cofre.
                if (_slot_para_item_cofre == -1)
                {
                    if (audio_is_playing(snd_error))
                    {
                        audio_stop_sound(snd_error);
                    }


                    audio_play_sound(
                        snd_error,
                        10,
                        false
                    );


                    exit;
                }


                // -----------------------------------------
                // DEVOLVER OBJETO DEL COFRE
                // -----------------------------------------

                scr_cofre_inv_set(
                    _item_cofre.tipo,
                    _slot_para_item_cofre,
                    _item_cofre.key
                );


                // -----------------------------------------
                // QUITAR OBJETO ORIGINAL DEL INVENTARIO
                // -----------------------------------------

                scr_cofre_inv_set(
                    transfer_tipo,
                    transfer_slot,
                    -1
                );


                // -----------------------------------------
                // GUARDAR OBJETO SELECCIONADO EN COFRE
                // -----------------------------------------

                global.chest_data[
                    cofre_index
                ] =
                {
                    tipo:
                        transfer_tipo,

                    key:
                        transfer_key
                };


                _transferencia_correcta =
                    true;
            }
        }


        // =================================================
        // TRANSFERENCIA TERMINADA
        // =================================================

        if (_transferencia_correcta)
        {
            scr_inventarios_sync();


            audio_play_sound(
                snd_menumove,
                10,
                false
            );


            transferencia_activa =
                false;


            panel_actual =
                0;


            transfer_tipo = "";
            transfer_slot = -1;
            transfer_key = -1;
            transfer_inv_index = -1;


            // ---------------------------------------------
            // REGENERAR INVENTARIO
            // ---------------------------------------------

            _inventario =
                scr_cofre_inventario_lista();


            _total_inv =
                array_length(
                    _inventario
                );


            if (_total_inv > 0)
            {
                inventario_index =
                    clamp(
                        inventario_index,
                        0,
                        _total_inv - 1
                    );
            }
            else
            {
                inventario_index = 0;
                inventario_scroll = 0;
            }
        }
    }


    // No ejecutar la navegación normal.
    exit;
}


// =========================================================
// =========================================================
// MODO NORMAL
// =========================================================
// =========================================================


// =========================================================
// CERRAR
// =========================================================

if (keyboard_check_pressed(ord("X")))
{
    audio_play_sound(
        snd_menumove,
        10,
        false
    );


    instance_destroy();

    exit;
}


// =========================================================
// INVENTARIO
// =========================================================

if (panel_actual == 0)
{
    var _movio =
        false;


    // =====================================================
    // ABAJO
    // =====================================================

    if (
        keyboard_check_pressed(vk_down)
        &&
        _total_inv > 0
    )
    {
        if (
            inventario_index
            <
            _total_inv - 1
        )
        {
            inventario_index++;

            _movio = true;
        }
    }


    // =====================================================
    // ARRIBA
    // =====================================================

    if (
        keyboard_check_pressed(vk_up)
        &&
        _total_inv > 0
    )
    {
        if (inventario_index > 0)
        {
            inventario_index--;

            _movio = true;
        }
    }


    if (_movio)
    {
        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // =====================================================
    // SCROLL INVENTARIO
    // =====================================================

    if (_total_inv > 0)
    {
        if (
            inventario_index
            <
            inventario_scroll
        )
        {
            inventario_scroll =
                inventario_index;
        }


        if (
            inventario_index
            >=
            inventario_scroll
            +
            filas_visibles
        )
        {
            inventario_scroll =
                inventario_index
                -
                filas_visibles
                +
                1;
        }


        inventario_scroll =
            clamp(
                inventario_scroll,
                0,
                max(
                    0,
                    _total_inv
                    -
                    filas_visibles
                )
            );
    }


    // =====================================================
    // DERECHA
    //
    // Permite entrar manualmente al cofre
    // para sacar objetos.
    // =====================================================

    if (keyboard_check_pressed(vk_right))
    {
        panel_actual =
            1;


        audio_play_sound(
            snd_menumove,
            10,
            false
        );


        exit;
    }


    // =====================================================
    // Z = SELECCIONAR OBJETO PARA GUARDAR
    // =====================================================

    if (
        keyboard_check_pressed(ord("Z"))
        ||
        keyboard_check_pressed(vk_enter)
    )
    {
        if (_total_inv <= 0)
        {
            if (audio_is_playing(snd_error))
            {
                audio_stop_sound(snd_error);
            }


            audio_play_sound(
                snd_error,
                10,
                false
            );


            exit;
        }


        var _item =
            _inventario[
                inventario_index
            ];


        // Guardar qué item elegimos.
        transfer_tipo =
            _item.tipo;

        transfer_slot =
            _item.slot;

        transfer_key =
            _item.key;

        transfer_inv_index =
            inventario_index;


        // Entrar a selección de destino.
        transferencia_activa =
            true;


        panel_actual =
            1;


        audio_play_sound(
            snd_menumove,
            10,
            false
        );


        exit;
    }
}


// =========================================================
// COFRE — MODO NORMAL
// =========================================================

else
{
    var _movio =
        false;


    // =====================================================
    // ABAJO
    // =====================================================

    if (keyboard_check_pressed(vk_down))
    {
        if (cofre_index < 49)
        {
            cofre_index++;

            _movio = true;
        }
    }


    // =====================================================
    // ARRIBA
    // =====================================================

    if (keyboard_check_pressed(vk_up))
    {
        if (cofre_index > 0)
        {
            cofre_index--;

            _movio = true;
        }
    }


    if (_movio)
    {
        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // =====================================================
    // SCROLL DEL COFRE
    // =====================================================

    if (cofre_index < cofre_scroll)
    {
        cofre_scroll =
            cofre_index;
    }


    if (
        cofre_index
        >=
        cofre_scroll
        +
        filas_visibles
    )
    {
        cofre_scroll =
            cofre_index
            -
            filas_visibles
            +
            1;
    }


    cofre_scroll =
        clamp(
            cofre_scroll,
            0,
            50 - filas_visibles
        );


    // =====================================================
    // IZQUIERDA = VOLVER AL INVENTARIO
    // =====================================================

    if (keyboard_check_pressed(vk_left))
    {
        panel_actual =
            0;


        audio_play_sound(
            snd_menumove,
            10,
            false
        );


        exit;
    }


    // =====================================================
    // Z = SACAR OBJETO DEL COFRE
    // =====================================================

    if (
        keyboard_check_pressed(ord("Z"))
        ||
        keyboard_check_pressed(vk_enter)
    )
    {
        var _entrada =
            global.chest_data[
                cofre_index
            ];


        // Slot vacío.
        if (!is_struct(_entrada))
        {
            if (audio_is_playing(snd_error))
            {
                audio_stop_sound(snd_error);
            }


            audio_play_sound(
                snd_error,
                10,
                false
            );


            exit;
        }


        // Buscar espacio en el inventario correcto.
        var _slot_libre =
            scr_cofre_inv_slot_vacio(
                _entrada.tipo
            );


        if (_slot_libre == -1)
        {
            if (audio_is_playing(snd_error))
            {
                audio_stop_sound(snd_error);
            }


            audio_play_sound(
                snd_error,
                10,
                false
            );


            exit;
        }


        // Cofre -> inventario.
        scr_cofre_inv_set(
            _entrada.tipo,
            _slot_libre,
            _entrada.key
        );


        // Vaciar slot.
        global.chest_data[
            cofre_index
        ] =
            -1;


        scr_inventarios_sync();


        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }
}