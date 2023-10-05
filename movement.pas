{$I misc.pas}
function QuitProgram(): boolean;
         begin
             //dispose( event );
             //Writeln('Keyboard disposed.');
             SDL_DestroyRenderer( rend );
             Writeln('Renderer destroyed.');
             SDL_DestroyWindow( window );
             Writeln('Window destroyed.');
             Mix_FreeMusic( music );
             Writeln('Music unloaded.');
             Mix_CloseAudio;
             Writeln('Audio closed.');
             SDL_Quit;
             Writeln('Exit gracefully.');
             QuitProgram:=true;
             Halt;
         end;

procedure Set_Movebob();
          begin
            if ((movebob_up>1.0) and (bob_phase=false)) then begin
               movebob_up:= movebob_up-0.05;
               movebob_down:=movebob_down+0.05;
               end;
            if ((movebob_up<=1.0) and (bob_phase=false)) then bob_phase:=true;
            if ((movebob_up<1.5) and (bob_phase=true)) then begin
               movebob_up:= movebob_up+0.05;
               movebob_down:=movebob_down-0.05;
            end;
            if ((movebob_up>=1.5) and (bob_phase=true)) then bob_phase:=false;
          end;

procedure Stop_Bobbing();
          begin
             movebob_up:=1;
             movebob_down:=1;
             bob_phase:=false;
          end;
	
procedure Controls();
	begin
	 while SDL_PollEvent(@event) = 1 do
     begin                                                                //control
        if event.key.keysym.sym = SDLK_ESCAPE then QuitProgram();         //event.key.keysym.sym without pointer
     end;

     Keycodes := SDL_GetKeyboardState(nil);

     if (Keycodes[SDL_SCANCODE_W] = 1) OR (Keycodes[SDL_SCANCODE_UP] = 1)then
     begin
          {if(map[round((pl_x + distray_x(9,rotate))/16), round((pl_y + distray_y(9,rotate))/16)] = 0) then begin
          pl_x := pl_x + distray_x(3,rotate);
          pl_y := pl_y + distray_y(3,rotate);
          end;
	  writeln('Y: ', pl_y:0:2);
          writeln('X: ', pl_x:0:2);}

          if map[round((pl_x + distray_x(player_mov,rotate))/map_scale),round(pl_y/map_scale)] = 0 then
          begin
            pl_x := pl_x + distray_x(player_mov,rotate);
          end;
          if map[round(pl_x/map_scale),round((pl_y + distray_y(player_mov,rotate))/map_scale)] = 0 then
          begin
            pl_y := pl_y + distray_y(player_mov,rotate);
          end;
          Set_Movebob();
     end;

     if (Keycodes[SDL_SCANCODE_S] = 1) OR (Keycodes[SDL_SCANCODE_DOWN] = 1) then
     begin
          //if(map[round((pl_x - distray_x(9,rotate))/16), round((pl_y - distray_y(9,rotate))/16)] = 0) then begin
          //pl_x := pl_x - distray_x(3,rotate);
          //pl_y := pl_y - distray_y(3,rotate);
//          writeln('X: ', pl_y);                                        //displays the player's position (as you can see, the board is read differently than I expected, damn it)
//          writeln('Y: ', pl_x);
          //end;

          if map[round((pl_x - distray_x(player_mov,rotate))/map_scale),round(pl_y/map_scale)] = 0 then
          begin
            pl_x := pl_x - distray_x(player_mov,rotate);
          end;
          if map[round(pl_x/map_scale),round((pl_y - distray_y(player_mov,rotate))/map_scale)] = 0 then
          begin
            pl_y := pl_y - distray_y(player_mov,rotate);
          end;
          Set_Movebob();
     end;

     if (Keycodes[SDL_SCANCODE_W] = 0) AND (Keycodes[SDL_SCANCODE_S] = 0) AND
     (Keycodes[SDL_SCANCODE_UP] = 0) AND (Keycodes[SDL_SCANCODE_DOWN] = 0) then Stop_Bobbing();

     if (Keycodes[SDL_SCANCODE_A] = 1) OR (Keycodes[SDL_SCANCODE_LEFT] = 1) then
     begin
          //if(map[round((pl_x + distray_x(9,rotate))/16), round((pl_y + distray_y(9,rotate))/16)] = 0) then begin
          //pl_x := pl_x + distray_x(3,rotate);
          //pl_y := pl_y + distray_y(3,rotate);
//          writeln('X: ', pl_y);                                        //displays the player's position (as you can see, the board is read differently than I expected, damn it)
//          writeln('Y: ', pl_x);
          //end;

          if map[round((pl_x + distray_x(player_mov,rotate+90))/map_scale),round(pl_y/map_scale)] = 0 then
          begin
            pl_x := pl_x + distray_x(player_mov,rotate+90);
          end;
          if map[round(pl_x/map_scale),round((pl_y + distray_y(player_mov,rotate+90))/map_scale)] = 0 then
          begin
            pl_y := pl_y + distray_y(player_mov,rotate+90);
          end;
     end;
     if (Keycodes[SDL_SCANCODE_D] = 1) OR (Keycodes[SDL_SCANCODE_RIGHT] = 1) then
     begin
          //if(map[round((pl_x - distray_x(9,rotate))/16), round((pl_y - distray_y(9,rotate))/16)] = 0) then begin
          //pl_x := pl_x - distray_x(3,rotate);
          //pl_y := pl_y - distray_y(3,rotate);
//          writeln('X: ', pl_y);                                        //displays the player's position (as you can see, the board is read differently than I expected, damn it)
//          writeln('Y: ', pl_x);
          //end;

          if map[round((pl_x + distray_x(player_mov,rotate-90))/map_scale),round(pl_y/map_scale)] = 0 then
          begin
            pl_x := pl_x + distray_x(player_mov,rotate-90);
          end;
          if map[round(pl_x/map_scale),round((pl_y + distray_y(player_mov,rotate-90))/map_scale)] = 0 then
          begin
            pl_y := pl_y + distray_y(player_mov,rotate-90);
          end;
     end;

     SDL_GetMouseState(@mouse_x,@mouse_y);

     rotate := rotate+round((mouswidth-mouse_x)/3);                            //rotate horizontal;  rotate players view / direction
     rotatez := rotatez+round((mousheight-mouse_y)/2);                          //rotate vertical;    looking up or down

     SDL_WarpMouseInWindow(window,mouswidth,mousheight);                 //move the mouse cursor to the given position withhin the window ?!
                                                                         //screenwindow = 1200x900; Mouse-width/height: 400x300 
     if rotatez >= 90 then rotatez := 90;                                //mouse positioned little left/under the middle of the screen
     if rotatez <= -90 then rotatez := -90;

     if rotate > 360 then rotate := rotate - 360;
     if rotate <=  0 then rotate := rotate + 360;                        
end;