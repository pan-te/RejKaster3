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

procedure Controls(VAR rotate1, rotateZ1 : real);
          VAR distray_x1,   distray_y1,
              distray_xp90, distray_yp90,
              distray_xm90, distray_ym90 : real;

          begin
            distray_x1   := distray_x(player_mov, rotate1);        //dx: player will be there when he moves one step forward
            distray_y1   := distray_y(player_mov, rotate1);        //dy: player will be there when he moves one step forward
            distray_xp90 := distray_x(player_mov, rotate1 + 90);   //dx: player will be there when he moves one step sideward
            distray_yp90 := distray_y(player_mov, rotate1 + 90);   //dy
            distray_xm90 := distray_x(player_mov, rotate1 - 90);   //dx: player will be there when he moves one step sideward
            distray_ym90 := distray_y(player_mov, rotate1 - 90);   //dy


            while SDL_PollEvent(@event) = 1 do
            begin                                                                //control
              if event.key.keysym.sym = SDLK_ESCAPE then QuitProgram();         //event.key.keysym.sym without pointer
            end;

            Keycodes := SDL_GetKeyboardState(nil);

            if (Keycodes[SDL_SCANCODE_W] = 1) OR (Keycodes[SDL_SCANCODE_UP] = 1)then
            begin
              {if(map[trunc((pl_x + distray_x(9,rotate))/16), trunc((pl_y + distray_y(9,rotate))/16)] = 0) then begin
                pl_x := pl_x + distray_x(3,rotate);
                pl_y := pl_y + distray_y(3,rotate);
              end;
              writeln('Y: ', pl_y:0:2);
              writeln('X: ', pl_x:0:2);}

            if map[trunc(pl_x + distray_x1) SHR div_SHR, trunc(pl_y) SHR div_SHR] = 0 then   //if not a wall then
            begin
              pl_x := pl_x + distray_x1;                                                     //new x-position for player
            end;
            if map[trunc(pl_x) SHR div_SHR, trunc(pl_y + distray_y1) SHR div_SHR] = 0 then   //if not a wall then
            begin
              pl_y := pl_y + distray_y1;
            end;                                                     //new y-position for player
            Set_Movebob();
          end;

          if (Keycodes[SDL_SCANCODE_S] = 1) OR (Keycodes[SDL_SCANCODE_DOWN] = 1) then
          begin
            //if(map[trunc((pl_x - distray_x(9,rotate))/16), trunc((pl_y - distray_y(9,rotate))/16)] = 0) then begin
            //pl_x := pl_x - distray_x(3,rotate);
            //pl_y := pl_y - distray_y(3,rotate);
            //writeln('X: ', pl_y);                                        //displays the player's position (as you can see, the board is read differently than I expected, damn it)
            //writeln('Y: ', pl_x);
            //end;

            if map[trunc(pl_x - distray_x1) SHR div_SHR,trunc(pl_y) SHR div_SHR] = 0 then
            begin
              pl_x := pl_x - distray_x1;
            end;
            if map[trunc(pl_x) SHR div_SHR, trunc(pl_y - distray_y1) SHR div_SHR] = 0 then
            begin
              pl_y := pl_y - distray_y1;
            end;
            Set_Movebob();
          end;

          if (Keycodes[SDL_SCANCODE_W] = 0)  AND (Keycodes[SDL_SCANCODE_S] = 0) AND
             (Keycodes[SDL_SCANCODE_UP] = 0) AND (Keycodes[SDL_SCANCODE_DOWN] = 0) then Stop_Bobbing();

          if (Keycodes[SDL_SCANCODE_A] = 1) OR (Keycodes[SDL_SCANCODE_LEFT] = 1) then
          begin
            //if(map[trunc((pl_x + distray_x(9,rotate))/16), trunc((pl_y + distray_y(9,rotate))/16)] = 0) then begin
            //pl_x := pl_x + distray_x(3,rotate);
            //pl_y := pl_y + distray_y(3,rotate);
            //writeln('X: ', pl_y);                                        //displays the player's position (as you can see, the board is read differently than I expected, damn it)
            //writeln('Y: ', pl_x);
            //end;

            if map[trunc(pl_x + distray_xp90) SHR div_SHR, trunc(pl_y) SHR div_SHR] = 0 then
            begin
              pl_x := pl_x + distray_xp90;
            end;
            if map[trunc(pl_x) SHR div_SHR, trunc(pl_y + distray_yp90) SHR div_SHR] = 0 then
            begin
              pl_y := pl_y + distray_yp90;
            end;
          end;

          if (Keycodes[SDL_SCANCODE_D] = 1) OR (Keycodes[SDL_SCANCODE_RIGHT] = 1) then
          begin
            //if(map[trunc((pl_x - distray_x(9,rotate))/16), trunc((pl_y - distray_y(9,rotate))/16)] = 0) then begin
            //pl_x := pl_x - distray_x(3,rotate);
            //pl_y := pl_y - distray_y(3,rotate);
            //writeln('X: ', pl_y);                                        //displays the player's position (as you can see, the board is read differently than I expected, damn it)
            //writeln('Y: ', pl_x);
            //end;

            if map[trunc(pl_x + distray_xm90) SHR div_SHR, trunc(pl_y) SHR div_SHR] = 0 then
            begin
              pl_x := pl_x + distray_xm90;
            end;
            if map[trunc(pl_x) SHR div_SHR, trunc(pl_y + distray_ym90) SHR div_SHR] = 0 then
            begin
              pl_y := pl_y + distray_ym90;
            end;
          end;

          SDL_GetMouseState(@mouse_x,@mouse_y);

          rotate1 := rotate1+((mouswidth-mouse_x)/3);                           //rotate horizontal;  rotate players view / direction
          rotatez1 := rotatez1+((mousheight-mouse_y)/2);                        //rotate vertical;    looking up or down

          SDL_WarpMouseInWindow(window,mouswidth,mousheight);                 //move the mouse cursor to the given position withhin the window ?!
                                                                         //screenwindow = 1200x900; Mouse-width/height: 400x300
          if rotatez1 >= 90 then rotatez1 := 90;                                //mouse positioned little left/under the middle of the screen
          if rotatez1 <= -90 then rotatez1 := -90;

          if rotate1 > 360 then rotate1 := rotate1 - 360;
          if rotate1 <=  0 then rotate1 := rotate1 + 360;
        end;
