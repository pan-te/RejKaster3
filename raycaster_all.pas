//~~~~~~~~~~~~~~~~Raycaster~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~(C)by Daniel i Adam Sadlik~~~~~~~
//~~~~~~~~~~~~~~~~~~2017~~~~~~~~~~~~~~~~~~~~~
//~~|-------------------------------------|~~
//~~| Raycasting version with more        |~~
//~~| posibilities. Attention!            |~~
//~~| He is retarded.                     |~~
//~~| (Made in LazarusIDE)                |~~
//~~| Enjoy!                              |~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~12.01.2017
//without memory holes; testet with:
//fpc -Criot -gl -gh raycaster_all.pas  24.09.2023

program raycaster;
{ $mode FPC //not necessary now }

uses crt, sdl2, SDL2_mixer, SDL2_image;

const                                            //Constant
//block_size=8;
//map_size=128;
  fov        = 80;
  halffov    = 40;
  degtorad   = 0.01745;
  scr_width  = 1200;
  scr_height = 900;
  halfheight = 450;
  draw_dist  = 191;
  map_scale  = 16;                               //can also be larger: 32 or 64
  max_Anz    = 15;                               //width and height of the map
  levelname  = 'test.map';                       //map name

var
  pl_x,
  pl_y              : real;                      //view position(coordinates swapped!)
  rotate            : real;                      //rotation angle
  rotatez           : integer;
  loop              : integer;
  loop1             : real;                      //variables to the loop (loop is the relative angle of incidence of the ray)
  ray_deg           : real;                      //absolute angle of incidence of the ray
  ray_dist          : integer;                   //distance traveled by the ray
  ray_realdist      : real;
  draw_yoffset_up,
  draw_yoffset_down : integer;                   //distance of the beginning of the vertical line from the x-axis of the screen
  draw_yoffset2     : real;
  ray_draw          : real;
  color_draw        : integer;
  dist_x,
  dist_y            : real;                      //radius vector coordinates
  block_posx,
  block_posy        : integer;                   //the point of incidence of the ray on the map
  event             : TSDL_event;                //keyboard event
  rend              : PSDL_renderer;             //SDL-specific variables
  window            : PSDL_window;
  music             : PMIX_music;
  Keycodes          : ^byte;                     //keyboard status
  background        : PSDL_Texture;
  mouse_x           : integer;                   //Cursor position
  mouse_y           : integer;
  movebob_up,
  movebob_down      : real;
  bob_phase         : boolean;
  map               : array[0..max_Anz, 0..max_Anz] of smallint;
  //levelname: string;
  //i: integer;

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

function distray_x(ray_l, alpha : real) : real;
begin
  distray_x := ray_l * cos(alpha * degtorad);
end;

function distray_y(ray_l, alpha : real) : real;
begin
  distray_y := ray_l * sin(alpha * degtorad);
end;

procedure SetPlayer(x, y : integer);
begin
  pl_x := map_scale * x;    // player positioned in middle of the square ?!
  pl_y := map_scale * y;    // without adding half of the square !! (map_scale DIV 2 = 8)
end;

procedure load_map(mapname : string);
var i, j, k, l : integer;
    mapfile : file of smallint;
begin
  Assign(mapfile, mapname);
  Reset(mapfile);
  for i := 0 to max_Anz do
    for j := 0 to max_Anz do
      read(mapfile, map[i, j]);
  Close(mapfile);

  for k := 0 to max_Anz do
    for l := 0 to max_Anz do
    begin
      if map[k, l] = 9 then
      begin
        SetPlayer(k, l);
        map[k, l] := 0;
        writeln('Player placed at X: ', k, ' Y: ', l);
        break;
      end;
    end;
  Writeln('Map loaded successfully!');
end;

procedure GameInit;
begin
  if SDL_Init( SDL_INIT_VIDEO or SDL_INIT_AUDIO ) < 0 then HALT
                                                      else writeln ('Initializing SDL... ok.');
  window := SDL_CreateWindow('Raycaster4', SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, scr_width, scr_height, SDL_WINDOW_SHOWN);
  rend := SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
  SDL_ShowCursor(0);
  SDL_SetRenderDrawColor(rend, 0, 0, 0, 0);
  SDL_RenderClear(rend);
  SDL_RenderPresent(rend);                                   //creating and cleaning the window
  SDL_WarpMouseInWindow(window, 400, 300);                   //Initializing the mouse-coordinates !!!
  rotate  := 0.0;
  rotatez := 0;
end;

function QuitProgram: boolean;
begin
  Writeln('Keyboard disposed.');
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
  QuitProgram := true;
  Halt;
end;

procedure Set_Movebob;
begin
  if ((movebob_up > 1.0) and (bob_phase = false)) then
  begin
    movebob_up   := movebob_up   - 0.05;
    movebob_down := movebob_down + 0.05;
 end;
 if ((movebob_up <= 1.0) and (bob_phase = false)) then bob_phase := true;
 if ((movebob_up <  1.5) and (bob_phase = true)) then
 begin
   movebob_up   := movebob_up   + 0.05;
   movebob_down := movebob_down - 0.05;
 end;
 if ((movebob_up >= 1.5) and (bob_phase = true)) then bob_phase := false;
end;

procedure Stop_Bobbing;
begin
  movebob_up   := 1;
  movebob_down := 1;
  bob_phase    := false;
end;

procedure Controls;
begin
  while SDL_PollEvent(@event) = 1 do
  begin                                                                //control
    if event.key.keysym.sym = SDLK_ESCAPE then QuitProgram();
  end;

  Keycodes := SDL_GetKeyboardState(nil);

  if (Keycodes[SDL_SCANCODE_W] = 1) OR (Keycodes[SDL_SCANCODE_UP] = 1) then
  begin
    if map[round((pl_x + distray_x(3, rotate)) / map_scale), round(pl_y / map_scale)] = 0 then
      pl_x := pl_x + distray_x(3, rotate);
    if map[round(pl_x / map_scale), round((pl_y + distray_y(3, rotate)) / map_scale)] = 0 then
      pl_y := pl_y + distray_y(3, rotate);
    Set_Movebob;
  end;

  if (Keycodes[SDL_SCANCODE_S] = 1) OR (Keycodes[SDL_SCANCODE_DOWN] = 1) then
  begin
    if map[round((pl_x - distray_x(3, rotate)) / map_scale), round(pl_y / map_scale)] = 0 then
      pl_x := pl_x - distray_x(3, rotate);
    if map[round(pl_x / map_scale), round((pl_y - distray_y(3, rotate)) / map_scale)] = 0 then
      pl_y := pl_y - distray_y(3, rotate);
    Set_Movebob();
  end;

  if (Keycodes[SDL_SCANCODE_W] = 0) and  (Keycodes[SDL_SCANCODE_S] = 0) then Stop_Bobbing();

  if (Keycodes[SDL_SCANCODE_A] = 1) OR (Keycodes[SDL_SCANCODE_LEFT] = 1) then
  begin
    if map[round((pl_x + distray_x(3, rotate + 90)) / map_scale), round(pl_y / map_scale)] = 0 then
      pl_x := pl_x + distray_x(3, rotate + 90);
    if map[round(pl_x / map_scale), round((pl_y + distray_y(3, rotate + 90)) / map_scale)] = 0 then
      pl_y := pl_y + distray_y(3, rotate + 90);
  end;

  if (Keycodes[SDL_SCANCODE_D] = 1) OR (Keycodes[SDL_SCANCODE_RIGHT] = 1) then
  begin
    if map[round((pl_x + distray_x(3, rotate - 90)) / map_scale), round(pl_y / map_scale)] = 0 then
      pl_x := pl_x + distray_x(3, rotate - 90);
    if map[round(pl_x / map_scale), round((pl_y + distray_y(3, rotate - 90)) / map_scale)] = 0 then
      pl_y := pl_y + distray_y(3, rotate - 90);
  end;

  SDL_GetMouseState(@mouse_x, @mouse_y);

  rotate  := rotate  + round((400 - mouse_x) / 3);
  rotatez := rotatez + round((300 - mouse_y) / 2);

  SDL_WarpMouseInWindow(window, 400, 300);

  if rotatez >=  90 then rotatez :=  90;
  if rotatez <= -90 then rotatez := -90;

  if rotate > 360 then rotate := rotate - 360;
  if rotate <=  0 then rotate := rotate + 360;   // ??? rotate <= 0 or or rotate < 0 or rotate > 0 ???????????
end;

procedure draw_line(dist : real; posx, posy : integer; angle : real; anglez : integer);
var color_draw2 : integer;

begin
  ray_draw := dist * cos((angle - halffov) * degtorad);
  color_draw  := trunc(dist) + 1;
  color_draw2 := trunc(color_draw * 2 / 3);
  case map[posx, posy] of
    1: SDL_SetRenderDrawColor(rend, 192 - color_draw,  128 - color_draw2, 0,                0);
    2: SDL_SetRenderDrawColor(rend, 0,                 128 - color_draw2, 192 - color_draw, 0);
    3: SDL_SetRenderDrawColor(rend, 129 - color_draw2, 128 - color_draw2, 192 - color_draw, 0);
  end;
  draw_yoffset2 := (trunc(12 * halfheight / (ray_draw + 1)));
  draw_yoffset_up :=   trunc(draw_yoffset2 * movebob_down);
  draw_yoffset_down := trunc(draw_yoffset2 * movebob_up);
  SDL_RenderDrawLine(rend, 3 * loop,     halfheight - draw_yoffset_up + anglez, 3 * loop,     halfheight + draw_yoffset_down + anglez);	//draw a linie
  SDL_RenderDrawLine(rend, 3 * loop + 1, halfheight - draw_yoffset_up + anglez, 3 * loop + 1, halfheight + draw_yoffset_down + anglez);	//draw a linie
  SDL_RenderDrawLine(rend, 3 * loop + 2, halfheight - draw_yoffset_up + anglez, 3 * loop + 2, halfheight + draw_yoffset_down + anglez);	//draw a linie
end;

procedure DrawBackground(bgimg : PSDL_Texture; zangle : integer) ;
var draw_gnd_rect : TSDL_Rect;
begin
  draw_gnd_rect.x := 0;
  draw_gnd_rect.y := zangle * 3 - 269;
  draw_gnd_rect.w := scr_width;
  draw_gnd_rect.h := scr_height + 540;
  SDL_RenderCopy(rend, bgimg, nil, @draw_gnd_rect);
end;

begin
  clrscr;
  //Write('Enter level filename: ');
  //Readln(levelname);
  load_map(levelname);
  GameInit();
  load_music();
  background := IMG_LoadTexture(rend, 'back.png');
  Stop_Bobbing();
  //SDL_Delay(10000);
  Writeln('================Raycaster 4================');
  Writeln('Copyright by Perfection Games Studios, 2017');
  Writeln('======Rendering engine: Daniel Sadlik======');
  Writeln('====Input and collisions: Adam Sadlik======');
  Writeln('===========================================');
  Writeln('===Controls:===============================');
  Writeln('==WASD-----movement========================');
  Writeln('==Mouse:---look around(up,down,left,right)=');
  Writeln('==Esc------quit program====================');
  Writeln('==================Enjoy====================');
  Writeln();

  repeat                                                                //beginning of the main loop
    Controls;
    DrawBackground(background, rotatez);
    loop1 := 0;
    for loop := 0 to (5 * fov) do                                       //casting a ray
    begin
      ray_deg := rotate + halffov - loop1;
      ray_realdist := 0;
      for ray_dist := 1 to (5 * draw_dist) do
      begin
        dist_x := distray_x(ray_realdist, ray_deg);
        dist_y := distray_y(ray_realdist, ray_deg);
        block_posx := round((pl_x + dist_x) / map_scale);
        block_posy := round((pl_y + dist_y) / map_scale);
        if (block_posx < 0) or (block_posx > max_Anz) then block_posx := 1;  //kills the error of detecting a non-existent block
        if (block_posy < 0) or (block_posy > max_Anz) then block_posy := 1;  //calculating the final coordinates of the ray
        if (map[block_posx, block_posy] >= 1) then draw_line(ray_realdist, block_posx, block_posy, loop1, rotatez * 3);
        ray_realdist := ray_realdist + 0.2;
        if map[block_posx, block_posy] >= 1 then break;                      //ends the loop when a wall is detected
      end;
      loop1 := loop1 + 0.2;
    end;
    SDL_RenderPresent(rend);
    SDL_Delay(17);
  until false;
end.
