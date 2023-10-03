procedure draw_line(dist: Real; posx, posy: integer; angle: Real; anglez: integer);
           var color_draw2: integer;
	   begin
           ray_draw:= dist*cos((angle - halffov)*degtorad);
	   color_draw:=trunc(dist)+1;
	   color_draw2:=trunc(color_draw*2/3);
	   case map[posx,posy] of
            1: SDL_SetRenderDrawColor(rend,192-color_draw,128-color_draw2,0,0);
	    2: SDL_SetRenderDrawColor(rend,0,128-color_draw2,192-color_draw,0);
	    3: SDL_SetRenderDrawColor(rend,129-color_draw2,128-color_draw2,192-color_draw,0);
	   end;
           draw_yoffset2:= (trunc(12*halfheight/(ray_draw+1)));
           draw_yoffset_up:=trunc(draw_yoffset2*movebob_down);
           draw_yoffset_down:=trunc(draw_yoffset2*movebob_up);
           SDL_RenderDrawLine(rend, 3*loop, halfheight-draw_yoffset_up+anglez,3*loop, halfheight+draw_yoffset_down+anglez);	//rysuję linię
           SDL_RenderDrawLine(rend, 3*loop+1, halfheight-draw_yoffset_up+anglez,3*loop+1, halfheight+draw_yoffset_down+anglez);	//rysuję linię
           SDL_RenderDrawLine(rend, 3*loop+2, halfheight-draw_yoffset_up+anglez,3*loop+2, halfheight+draw_yoffset_down+anglez);	//rysuję linię
           end;

procedure DrawBackground(bgimg: pSDL_Texture;zangle: integer) ;
         var draw_gnd_rect: tSDL_Rect;                            //not a pointertype now
         begin
               //new(draw_gnd_rect);                              //memory leak! NEW without DISPOSE!
               draw_gnd_rect.x:=0;
               draw_gnd_rect.y:=zangle*3-269;
               draw_gnd_rect.w:=scr_width;
               draw_gnd_rect.h:=scr_height+540;
               SDL_RenderCopy(rend,bgimg,nil,@draw_gnd_rect);
         end;

