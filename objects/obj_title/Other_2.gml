//variable
global.start_room = pasillo_school
global.start_x = 668
global.start_y = 194

global.new_game = false
global.title_bottons = false

//habitaciones osea rooms IDs
global.rm0 = 0
global.rm1 = 1
global.rm2 = 2
global.rm3 = 3
global.rm4 = 4
global.rm5 = 5

if(file_exists("prueba.ini")){
	
with (instance_create_depth(85.42523, 89, 100, obj_buttons_continue))
{
    image_xscale = 0.4734906;
    image_yscale = 0.4734906;
}

	ini_open("prueba.ini")
	global.start_room = ini_read_string("Save1", "room", pasillo_school)
	global.start_x = ini_read_real("Save1", "x", 668)
	global.start_y = ini_read_real("Save1", "y", 194)
	ini_close()

} else{

with (instance_create_depth(76, 92, 100, obj_buttons))
{
    image_xscale = 0.6;
    image_yscale = 0.6;
}


}

if(global.start_room = 0){

	global.start_room = test
	
}
if(global.start_room = 1){

	global.start_room = pasillo_school
	
}
if(global.start_room = 2){

	global.start_room = toriel_salon
	
}
if(global.start_room = 3){

	global.start_room = huevo
	
}