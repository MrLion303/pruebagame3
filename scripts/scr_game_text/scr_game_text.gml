// pasar renglon \n

//--------------ANIMACIONES----------------
// scr_text_wave hace el movimiento de ola
// scr_text_shake hace que se sacuda
// scr_text_bounce hace que reboten las letras

// @param text_id
function scr_game_text(_text_id){
	
    switch(_text_id) {





        case "npc 1":
            scr_text("Hola como tai yo bien y usted? jejejej12344");
            scr_text("EL PITITO TE LO COMES HOLA SOY GERMAN");
            scr_text("Bueno... te gusta el keke?");
				scr_option("Yeah ME ENCANTA", "npc 1 - yes");
				scr_option("Ni de pedoooo", "npc 1 - no");
            break;
            
	        case "npc 1 - yes":
	            scr_text("El... keke? Oh! Claro que me gusta!",c_white, spr_noelle_normal, snd_noelle);
					scr_text_color(6, 10, c_white, c_white, c_yellow, c_yellow); scr_text_color(29, 34, c_white, c_white, c_green, c_green);
				scr_text("VIVAAAAAAAAAAA!!!");
					scr_text_wave(0, 16);
	            break;
            
			  case "npc 1 - no":
	            scr_text("que tontorron");
	            break;
        
		
		
		
		
		case "npc":
    // Diálogo con Noelle y su respectivo sprite de cabeza a la izquierda
    scr_text("Hola, soy Noelle y este es mi dialogo con retrato.", c_white, spr_noelle_normal, snd_noelle);
    scr_text("Este segundo renglon tambien se acomoda solito respetando la cabeza.", c_white, spr_noelle_normal, snd_noelle);
    
    // Diálogo normal sin sprite por si quieres alternar en la misma caja
    scr_text("Y este mensaje vuelve a ser normal sin cabeza.");
		scr_text_color(0, 5, c_white, c_white, c_green, c_green)
    break;
		
		
		
		
		
        case "npc 2":
            scr_text("Soy el original", c_white);
            scr_text("Ayudame a encontrar, por favor, a mi madre", c_white);
			scr_text("Por cierto, soy el original", c_white);
			scr_text("Star                 Walker");
				scr_text_color(0, 27, c_white, c_white, c_yellow, c_yellow);
            break;
        
		
		
		
        case "npc 3":
            scr_text("Hola como tai yo bien y usted? jejejej12344");
            scr_text("Nah... yo si");
            break;





        case "huevo":
            scr_text("Vaya... hay un hombre aqui.");
            scr_text("Te esta ofreciendo algo.");
			scr_text("Lo tomas?");
				scr_option("Si", "huevo - yes");
				scr_option("No", "huevo - no");
            break;
			
			case "huevo - yes":
				scr_text("Recibiste un huevo.");
	            break;
            
			  case "huevo - no":
	            scr_text("Aqui no hay nadie.");
	            break;




    }

}