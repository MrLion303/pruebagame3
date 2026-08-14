// 1. Efecto de Fade In al aparecer
if (image_alpha < 1)
{
    image_alpha += 0.05;
    if (image_alpha > 1) { image_alpha = 1; }
}

// 2. Tu código original de selección
ini_open("prueba.ini")
if(image_index = 0 and (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter))){

	room_goto(global.start_room)
	var instantiated = instance_create_layer(global.start_x, global.start_y, "Player", obj_player)
	global.new_game = false

}
ini_close()