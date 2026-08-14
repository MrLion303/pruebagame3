depth = -9999;

textbox_width = 300; 
textbox_height = 80; 
border = 8;          
line_sep = 18;       

line_width = textbox_width - (border * 2);

txtb_spr = [spr_textbox];
speaker_sprite = [noone];
text_sound = [snd_text];
txtb_img = 0;
txtb_img_spd = 3/30;

page = 0;
page_number = 0;
text = [""];         
text_lenght = [0];    
text_color = [c_white]; 

char[0, 0] = "";
char_x[0, 0] = 0;
char_y[0, 0] = 0;

for(var i = 0; i < 500; i++) {
    col_1[i, 0] = c_white;
    col_2[i, 0] = c_white;
    col_3[i, 0] = c_white;
    col_4[i, 0] = c_white;
    text_effect[i, 0] = "none";
}

draw_char = 0;
text_spd = 1;
setup = false;

text_sound_timer = 0;
text_sound_delay = 2;

txtb_spr_w = sprite_get_width(txtb_spr[0]);
txtb_spr_h = sprite_get_height(txtb_spr[0]);

option[0] = "";
option_link_id[0] = -1;
option_pos = 0;
option_number = 0;

text_id = "default";

scr_set_defaults_for_text();
last_free_space = 0;