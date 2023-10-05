function load_music : boolean;
begin
  if Mix_OpenAudio( MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS, 4096 ) < 0 then HALT;
  music := Mix_LoadMUS('megadens.ogg');
  if music = nil then HALT;
  Mix_VolumeMusic( MIX_MAX_VOLUME );
  if Mix_PlayMusic( music, -1 ) < 0 then begin Writeln('Playback failed!');
  end else Writeln('Playback started.');
  load_music:= true;
end;

function distray_x(ray_l,alpha:real):real;
begin
  distray_x:=ray_l*cos(alpha*degtorad);
end;

function distray_y(ray_l,alpha:real):real;
begin
  distray_y:=ray_l*sin(alpha*degtorad);
end;

procedure SetPlayer(x,y:integer);
begin
  pl_x:=map_scale*x;                         // player positioned in middle of the square !
  pl_y:=map_scale*y;                         // without substract (!) half of the square !! (map_scale DIV 2 = 8)
end;

procedure load_map(mapname:string);
var i,j,k,l:integer;
    mapfile:file of smallint;
begin
  Assign(mapfile,mapname);
  Reset(mapfile);
  for i:=0 to max_Anz do
    for j:=0 to max_Anz do
      read(mapfile,map[i,j]);
  Close(mapfile);

  for k:=0 to max_Anz do
    for l:=0 to max_Anz do
    begin
      if map[k,l]=9 then
      begin
        SetPlayer(k,l);
        map[k,l]:=0;
        writeln('Player placed at X: ', k, ' Y: ', l);
        break;
      end;
    end;
  Writeln('Map loaded successfully!');
end;

procedure GameInit;
begin
  if SDL_Init(SDL_INIT_VIDEO OR SDL_INIT_AUDIO )<0 then HALT
                                                   else writeln('Initializing SDL... ok.');
  window := SDL_CreateWindow('Raycaster4',SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED,scr_width,scr_height,SDL_WINDOW_SHOWN);
  rend := SDL_CreateRenderer(window,-1,SDL_RENDERER_ACCELERATED);
  SDL_ShowCursor(0);                                                         //don't show (mouse) cursor in the window
  SDL_SetRenderDrawColor(rend, 0, 0, 0, 0);                                  //black color
  SDL_RenderClear(rend);
  SDL_RenderPresent(rend);                                                   //creating and cleaning the window
  SDL_WarpMouseInWindow(window,mouswidth,mousheight);                        //initializing MousePos
  rotate :=0.0;                                                              //angle of playerview horizontal
  rotateZ:=0;                                                                //angle of playerview vertical
end;
