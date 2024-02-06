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
//without memory holes; tested with: fpc -Criot -gl -gh raycaster_all.pas
//last changes:  13.12.23

program raycaster;
{$mode objFPC}                                  //object pascal extension on; [ or use $mode FPC or $mode DELPHI ]
uses crt, SDL2, SDL2_mixer, SDL2_image;

const
  FOV        = 80;                               //Field of View: 80 degree
  halfFOV    = 40;                               //degree
  FOVWinX    = 400;                              //Field of View: 400 pixel; x direction
  FOVWinY    = 300;                              //Field of View: 300 pixel; y direction
  ray_dL     = 0.2;                              //const to increase the length of the ray
  ray_dG     = 0.2;                              //const to increase the angle of the ray in degree
  degtorad   = 0.01745;                          //(Pi / 180 Grad) = (RAD to Grad)
  scr_width  = 1200;                             //Screen width
  scr_height = 900;                              //Screen height
  halfheight = 450;
  mouswidth  = 400;                              //theoretical half of screenwidth = 600;  will be mousePos startpoint in game
  mousheight = 300;                              //theoretical half of screenheight= 450;
  map_scale  = 16;                               //can also be larger: [ 32 or 64 ]: size of wall block (square of the grid)
  div_SHR    = 4;                                //[div by mapscale] [= 16] can translated to [SHR 4]  div_SHR MUST be 2^x = map_scale!!!!
                                                 //16=2^4   32=2^5   64=2^6  128=2^7... map_scale=2^div_SHR !!
  draw_dist  = 191;                              //draw_dist := map_scale * 5 - 1; [ 191 := 16 * 5 -1 ] how far you can see in pixel
  max_Anz    = 15;                               //width and height of the (square-) map
  player_mov = 3;                                //player moves 3 pixels
  levelname  = 'test.map';                       //map name

var
  pl_x,
  pl_y              : real;                      //view position(coordinates swapped!)
  rotate,                                        //horizontal rotation angle  left / right
  rotateZ           : real;                      //vertical rotation angle    up   / down
  draw_yoffset_up,
  draw_yoffset_down : integer;                   //distance of the beginning of the vertical line from the x-axis of the screen
  draw_yoffset2     : real;
  ray_draw          : real;
  color_draw        : integer;
  event             : TSDL_event;                //keyboard event
  renderer          : PSDL_renderer;             //SDL2-specific variables
  window            : PSDL_window;
  music             : PMIX_music;
  Keycodes          : ^byte;                     //keyboard status
  background        : PSDL_Texture;
  mouse_x           : integer;                   //mousecursor position
  mouse_y           : integer;
  movebob_up,
  movebob_down      : real;
  bob_phase         : boolean;
  map               : array[0..max_Anz, 0..max_Anz] of smallint;

function load_music : boolean;
begin
  if Mix_OpenAudio( MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS, 4096 ) < 0 then HALT;
  music := Mix_LoadMUS('megadens.ogg');
  if music = nil then HALT;
  Mix_VolumeMusic( MIX_MAX_VOLUME );
  if Mix_PlayMusic( music, -1 ) < 0 then begin Writeln('Playback failed!'); Writeln;
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
  pl_x := map_scale * x + map_scale DIV 2;           // player positioned in middle of the square !
  pl_y := map_scale * y + map_scale DIV 2;           // with add half of the square !! (map_scale DIV 2 = 8)
end;

procedure load_map(mapname : string);
var i, j, k, l : integer;
    mapfile : file of smallint;
begin
  Assign(mapfile, mapname);                          //old school :)
  {$i-} Reset(mapfile); {$i+}                        //looking for errors
  if IOResult = 0 then                               //if all ok then loading map
  begin
    for i := 0 to max_Anz do
      for j := 0 to max_Anz do
        read(mapfile, map[i, j]);
    Close(mapfile);
  end
  else
  begin
    writeln('Map Datafile not found!');              //there was no map!
    Halt(1);
  end;

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
  if SDL_Init( SDL_INIT_VIDEO OR SDL_INIT_AUDIO ) < 0 then HALT
                                                      else writeln ('Initializing SDL... ok.');
  window := SDL_CreateWindow('Raycaster4', SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, Scr_Width, Scr_Height, SDL_WINDOW_SHOWN);
  if window = NIL then writeln(SDL_GetError);
  renderer := SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
  if renderer = NIL then writeln(SDL_GetError);
  SDL_ShowCursor(0);                                                         //don't show (mouse) cursor in the window
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);                              //black color
  SDL_RenderClear(renderer);
  SDL_RenderPresent(renderer);                                               //creating and cleaning the window
  SDL_WarpMouseInWindow(window, mouswidth, mousheight);                      //initializing MousePos
  rotate  := 0.0;                                                            //angle of playerview horizontal
  rotateZ := 0;                                                              //angle of playerview vertical
end;

function QuitProgram: boolean;
begin
  Writeln('Keyboard disposed.');
  SDL_DestroyRenderer( renderer );
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
  if ((movebob_up > 1.0) AND (bob_phase = false)) then
  begin
    movebob_up   := movebob_up   - 0.05;
    movebob_down := movebob_down + 0.05;
 end;
 if ((movebob_up <= 1.0) AND (bob_phase = false)) then bob_phase := true;
 if ((movebob_up <  1.5) AND (bob_phase = true)) then
 begin
   movebob_up   := movebob_up   + 0.05;
   movebob_down := movebob_down - 0.05;
 end;
 if ((movebob_up >= 1.5) AND (bob_phase = true)) then bob_phase := false;
end;

procedure Stop_Bobbing;
begin
  movebob_up   := 1;
  movebob_down := 1;
  bob_phase    := false;
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

  while SDL_PollEvent(@event) = 1 do                     //control
  begin
    if event.key.keysym.sym = SDLK_ESCAPE then QuitProgram();
  end;

  Keycodes := SDL_GetKeyboardState(nil);

  if (Keycodes[SDL_SCANCODE_W] = 1) OR (Keycodes[SDL_SCANCODE_UP] = 1) then          //forward
  begin
    if map[trunc(pl_x + distray_x1) SHR div_SHR, trunc(pl_y) SHR div_SHR] = 0 then   //if not a wall then
      pl_x := pl_x + distray_x1;                                                     //new x-position for player
    if map[trunc(pl_x) SHR div_SHR, trunc(pl_y + distray_y1) SHR div_SHR] = 0 then   //if not a wall then
      pl_y := pl_y + distray_y1;                                                     //new y-position for player
    Set_Movebob;
  end;

  if (Keycodes[SDL_SCANCODE_S] = 1) OR (Keycodes[SDL_SCANCODE_DOWN] = 1) then        //backward
  begin
    if map[trunc(pl_x - distray_x1) SHR div_SHR, trunc(pl_y) SHR div_SHR] = 0 then
      pl_x := pl_x - distray_x1;
    if map[trunc(pl_x) SHR div_SHR, trunc(pl_y - distray_y1) SHR div_SHR] = 0 then
      pl_y := pl_y - distray_y1;
    Set_Movebob();
  end;

  if (Keycodes[SDL_SCANCODE_W] = 0)  AND (Keycodes[SDL_SCANCODE_S] = 0) AND          //no keypress no movement
     (Keycodes[SDL_SCANCODE_UP] = 0) AND (Keycodes[SDL_SCANCODE_DOWN] = 0) then Stop_Bobbing();

  if (Keycodes[SDL_SCANCODE_A] = 1) OR (Keycodes[SDL_SCANCODE_LEFT] = 1) then        //left
  begin
    if map[trunc(pl_x + distray_xp90) SHR div_SHR, trunc(pl_y) SHR div_SHR] = 0 then
      pl_x := pl_x + distray_xp90;
    if map[trunc(pl_x) SHR div_SHR, trunc(pl_y + distray_yp90) SHR div_SHR] = 0 then
      pl_y := pl_y + distray_yp90;
  end;

  if (Keycodes[SDL_SCANCODE_D] = 1) OR (Keycodes[SDL_SCANCODE_RIGHT] = 1) then       //right
  begin
    if map[trunc(pl_x + distray_xm90) SHR div_SHR, trunc(pl_y) SHR div_SHR] = 0 then
      pl_x := pl_x + distray_xm90;
    if map[trunc(pl_x) SHR div_SHR, trunc(pl_y + distray_ym90) SHR div_SHR] = 0 then
      pl_y := pl_y + distray_ym90;
  end;

  SDL_GetMouseState(@mouse_x, @mouse_y);

  rotate1  := rotate1  + ((mouswidth  - mouse_x) / 3);                       //rotate horizontal;  rotate players view angle / direction
  rotateZ1 := rotateZ1 + ((mousheight - mouse_y) / 2);                       //rotate vertical;    looking up or down

  SDL_WarpMouseInWindow(window, mouswidth, mousheight);                      //move the mouse cursor to the given position withhin the window ?!
                                                                             //screenwindow = 1200x900; Mouse-width/height: 400x300
  if rotateZ1 >=  90 then rotateZ1 :=  90;                                   //mouse positioned little left/under the middle of the screen
  if rotateZ1 <= -90 then rotateZ1 := -90;

  if rotate1 > 360 then rotate1 := rotate1 - 360;
  if rotate1 <=  0 then rotate1 := rotate1 + 360;
end;

procedure draw_line(dist : real; posx, posy, loop : integer; angle, angleZ : real);
var r1, r2, g, b : byte;
    angleZ1, y_up, y_down,
    color_draw2 : integer;
    source, target : TSDL_Rect;

begin
  angleZ1 := TRUNC(angleZ);                                                  //helping variable
  ray_draw := dist * cos((angle - halfFOV) * degtorad);                      //reduce fisheye effect
  color_draw  := trunc(dist) + 1;
  color_draw2 := trunc(color_draw * 2 / 3);
  r1 := 192 - color_draw;                                                    //red
  r2 := 129 - color_Draw2;                                                   //red
  g  := 128 - color_draw2;                                                   //green
  b  := 192 - color_draw;                                                    //blue

  case map[posx, posy] of
    1: SDL_SetRenderDrawColor(renderer, r1, g, 0, 0);                        //colors: red green blue
    2: SDL_SetRenderDrawColor(renderer,  0, g, b, 0);
    3: SDL_SetRenderDrawColor(renderer, r2, g, b, 0);
  end;
  draw_yoffset2     := trunc(12 * halfheight / (ray_draw + 1));
  draw_yoffset_up   := trunc(draw_yoffset2 * movebob_down);
  draw_yoffset_down := trunc(draw_yoffset2 * movebob_up);

  y_up   := halfheight - draw_yoffset_up   + angleZ1;                        //y pos helping var
  y_down := halfheight + draw_yoffset_down + angleZ1;                        //y pos helping var

  SDL_RenderDrawLine(renderer, 3 * loop,     y_up, 3 * loop,     y_down);    //draw a linie
  SDL_RenderDrawLine(renderer, 3 * loop + 1, y_up, 3 * loop + 1, y_down);    //draw a linie
  SDL_RenderDrawLine(renderer, 3 * loop + 2, y_up, 3 * loop + 2, y_down);    //draw a linie
//  SDL_RenderDrawLine(renderer, 4 * loop + 3, y_up, 4 * loop + 3, y_down);    //draw a linie
end;

procedure DrawBackground(bgImg : PSDL_Texture; angleZ : real);
var draw_gnd_rect : TSDL_Rect;
begin
  draw_gnd_rect.x := 0;
  draw_gnd_rect.y := trunc(angleZ) * 3 - 269;
  draw_gnd_rect.w := scr_width;
  draw_gnd_rect.h := scr_height + 540;
  SDL_RenderCopy(renderer, bgImg, nil, @draw_gnd_rect);
end;

procedure gameloop(rotate1, rotateZ1 : real);
var loop_             : integer;
    loop1             : real;                      //variables to the loop (loop is the relative angle of incidence of the ray)
    ray_dist          : integer;                   //loop variable like i or j
    ray_realdist,                                  //length of the searching ray in pixel, will be increased during the main loop
    ray_deg,                                       //absolute angle of incidence of the ray
    ray_deg_sin,                                   //help var for sin(ray_deg)
    ray_deg_cos,                                   //help var for cos(ray_deg)
    dist_x,
    dist_y            : real;                      //radius vector coordinates
    block_posx,
    block_posy        : integer;                   //the point of incidence of the ray on the map

begin
  loop1 := 0.0;
  for loop_ := 0 to FOVWinX do                                              //casting a ray
  begin
    ray_deg := rotate1 + halfFOV - loop1;                                   //ray angle in degree
    ray_realdist := 0;
    ray_deg_cos := cos(ray_deg * degtorad);                                //cos of ray is const during calculate the ray; calculate outside of the loop!
    ray_deg_sin := sin(ray_deg * degtorad);                                //sin of ray is const during calculate the ray; calculate outside of the loop!

    for ray_dist := 1 to (5 * draw_dist) do                                //5*draw_dist: max length of the ray without hit a wall
    begin
      dist_x := ray_realdist * ray_deg_cos;                                //search for a wall in x; increase the raylength [ray_realdist] with
      dist_y := ray_realdist * ray_deg_sin;                                //a small amount [ here 0.2 pixel ] at the end of the loop
      block_posx := trunc(pl_x + dist_x) SHR div_SHR;                      //control: if the ray hits a wall...
      block_posy := trunc(pl_y + dist_y) SHR div_SHR;

      if (block_posx < 0) OR (block_posx > max_Anz) then block_posx := 1;  //kills the error of detecting a non-existent block
      if (block_posy < 0) OR (block_posy > max_Anz) then block_posy := 1;  //calculating the final coordinates of the ray

      if (map[block_posx, block_posy] >= 1) then
        draw_line(ray_realdist, block_posx, block_posy, loop_, loop1, rotateZ1 * 3);

      ray_realdist := ray_realdist + ray_dL;                               //increase the length of the searching ray [ ray_realdist ]
      if map[block_posx, block_posy] >= 1 then break;                      //ends the loop when a wall is detected
    end;
    loop1 := loop1 + ray_dG;                                               //change the angle of the ray [ here 0.2 degree ]
  end;
end;

begin
  clrscr;
  load_map(levelname);
  GameInit();
  load_music();
  background := IMG_LoadTexture(renderer, 'back.png');
  Stop_Bobbing();

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

  repeat                                                                     //beginning of the main loop
    Controls(rotate, rotateZ);                                               //read keyboard
    DrawBackground(background, rotateZ);
    gameloop(rotate, rotateZ);
    SDL_RenderPresent(renderer);                                             //update the screen with any rendering performed since the previous call
    SDL_Delay(17);                                                           //delay 17 miliseconds equal to 60 FPS = Frames per second
  until false;                                                               //end of main loop
end.
