function load_music() : boolean;
         begin
           if Mix_OpenAudio( MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS, 4096 ) < 0 then HALT;
	   music := Mix_LoadMUS('megadens.ogg');
           if music = nil then HALT;
           Mix_VolumeMusic( MIX_MAX_VOLUME );
           if Mix_PlayMusic( music, -1 ) < 0 then begin Writeln('Playback failed!');
           end else Writeln('Playback started.');
           load_music:= true;
   end;
   
function distray_x(ray_l,alpha:real): real;
         begin
         distray_x:=ray_l*cos(alpha*degtorad);
         end;

function distray_y(ray_l,alpha:real): real;
         begin
         distray_y:=ray_l*sin(alpha*degtorad);
         end;
	 
	 procedure SetPlayer(x,y:integer);
	 begin
		  pl_x:=map_scale*x+8;
		  pl_y:=map_scale*y+8;
	 end;
	 
procedure load_map(mapname:string);
	 var i,j, k,l: integer;
		mapfile: file of integer;
	 begin
		Assign(mapfile, mapname);
		 Reset(mapfile);
		 for i:=0 to 15 do begin
			 for j:=0 to 15 do begin
				 read(mapfile, map[i,j]);
			 end;
		 end;
		 Close(mapfile);
		 for k:=0 to 15 do begin
			 for l:=0 to 15 do begin
				if map[k,l]=9 then begin
					SetPlayer(k,l);
					map[k,l]:=0;
					break;
			 end;
		end;
	end;
			 Writeln('Map loaded successfully!');
	end;
	 
procedure GameInit();
	 begin
		   if SDL_Init( SDL_INIT_VIDEO or SDL_INIT_AUDIO ) < 0 then begin HALT;
		  end else writeln ('Initializing SDL... ok.');;
		  window:= SDL_CreateWindow('RejKaster4',64,64,scr_width,scr_height,SDL_WINDOW_SHOWN);    //SDL_CreateWindow('RejKaster4',SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED,scr_width,scr_height,SDL_WINDOW_SHOWN);
		  new(event);                                               //tworzenie eventu
		  rend:= SDL_CreateRenderer(window,-1,SDL_RENDERER_SOFTWARE);
		  SDL_ShowCursor(0);
		  SDL_SetRenderDrawColor(rend, 0,0,0,0);
		  SDL_RenderClear(rend);
		  SDL_RenderPresent(rend);                                   //stworzenie i wyczyszczenie okna
		  rotate:=90;
		  rotatez:=0;
	end;

