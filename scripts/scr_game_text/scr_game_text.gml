// pasar renglon \n

//--------------ANIMACIONES----------------
// scr_text_wave hace el movimiento de ola
// scr_text_shake hace que se sacuda
// scr_text_bounce hace que reboten las letras

// @param text_id
function scr_game_text(_text_id){
	
    switch(_text_id) {





        case "npc 1":
            scr_text(scr_loc("Hola como tai yo bien y usted? jejejej12344"));
            scr_text(scr_loc("EL PITITO TE LO COMES HOLA SOY GERMAN Wiwiwiwo"));
            scr_text(scr_loc("Bueno... te gusta el keke?"));
				scr_option(scr_loc("Yeah ME ENCANTA"), "npc 1 - yes");
				scr_option(scr_loc("Ni de pedoooo"), "npc 1 - no");
            break;
            
	        case "npc 1 - yes":
	            scr_text(scr_loc("El... keke? Oh! Claro que me gusta!"),c_white, spr_noelle_normal, snd_noelle);
					scr_text_color(6, 10, c_white, c_white, c_yellow, c_yellow); scr_text_color(29, 34, c_white, c_white, c_green, c_green);
				scr_text(scr_loc("VIVAAAAAAAAAAA!!!"));
					scr_text_wave(0, 16);
	            break;
            
			  case "npc 1 - no":
	            scr_text(scr_loc("que tontorron"));
	            break;
        
		
		
		
		
		case "npc":
    // Diálogo con Noelle y su respectivo sprite de cabeza a la izquierda
    scr_text(scr_loc("Hola, soy Noelle y este es mi dialogo con retrato."), c_white, spr_noelle_normal, snd_noelle);
    scr_text(scr_loc("Este segundo renglon tambien se acomoda solito respetando la cabeza."), c_white, spr_noelle_normal, snd_noelle);
    
    // Diálogo normal sin sprite por si quieres alternar en la misma caja
    scr_text(scr_loc("Y este mensaje vuelve a ser normal sin cabeza."));
		scr_text_color(0, 5, c_white, c_white, c_green, c_green)
    break;
		
		
		
		
		
        case "npc 2":
            scr_text(scr_loc("Soy el original"), c_white);
            scr_text(scr_loc("Ayudame a encontrar, por favor, a mi madre"), c_white);
			scr_text(scr_loc("Por cierto, soy el original"), c_white);
			scr_text(scr_loc("Star                 Walker"));
				scr_text_color(0, 27, c_white, c_white, c_yellow, c_yellow);
            break;
        
		
		
		
        case "npc 3":
            scr_text(scr_loc("Hola como tai yo bien y usted? jejejej12344"));
            scr_text(scr_loc("Nah... yo si"));
            break;





        case "huevo":
            scr_text(scr_loc("Vaya... hay un hombre aqui."));
            scr_text(scr_loc("Te esta ofreciendo algo."));
			scr_text(scr_loc("Lo tomas?"));
				scr_option(scr_loc("Si"), "huevo - yes");
				scr_option(scr_loc("No"), "huevo - no");
            break;
			
			case "huevo - yes":
				scr_text(scr_loc("Recibiste un huevo."));
	            break;
            
			  case "huevo - no":
	            scr_text(scr_loc("Aqui no hay nadie."));
	            break;




    }

}
