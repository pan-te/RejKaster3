//~~~~~~~~~~~~~~~~Rejkaster~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~(C)by Daniel i Adam Sadlik~~~~~~~
//~~~~~~~~~~~~~~~~~~2017~~~~~~~~~~~~~~~~~~~~~
//~~|-------------------------------------|~~
//~~| Raycasting with more possibilities  |~~
//~~| version. Attention! He is retarded. |~~
//~~|                (Made in LazarusIDE) |~~
//~~|Enjoy!_______________________________|~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~12.01.2017


program rejkaster;
uses crt, sdl2, SDL2_mixer, SDL2_image;
{$ASMMODE intel}                            //assembly syntax setting, unnecessary
var
  pl_x, pl_y: real;                      //view position(coordinates swapped!)
  rotate : real;                            //rotation angle
  rotatez : integer;
  loop: integer;
  loop1: real;                                          //variables to the loop (loop is the relative angle of incidence of the ray)
  ray_deg: Real;                            //absolute angle of incidence of the ray
  ray_dist: integer;                        //distance traveled by the ray
  ray_realdist: real;
  draw_yoffset_up, draw_yoffset_down: integer;                    //distance of the beginning of the vertical line from the x-axis of the screen
  draw_yoffset2: real;
  ray_draw: Real;
  color_draw: integer;
  dist_x,dist_y:real;                       //radius vector coordinates
  block_posx,block_posy:integer;            //the point of incidence of the ray on the map
  event: tSDL_event;                        //keyboard event now not a pointertype
  rend: pSDL_renderer;                      //SDL-specific variables
  window:  pSDL_window;
  music: PMIX_music;
  Keycodes:  ^byte;                         //keyboard status
  background: pSDL_Texture;
  mouse_x: integer;                         // Cursor position
  mouse_y: integer;
  movebob_up, movebob_down: real;
  bob_phase: boolean;
  map:array[0..15,0..15] of smallint;
  levelname: string;
  //i: integer;

const                                       //Constant
//block_size=8;
//map_size=128;
fov=80;                                     //degree angle;  5*80 = 400 pixel = fov in pixel  (400x300)
halffov=40;                                 //degree angle
degtorad=0.01745;
scr_width=1200;                             //size of window  (1200x900)
scr_height=900;                             //size of window
halfheight=450;
draw_dist=191;
map_scale=16;                               //size of wall block (square of the grid)


{$I movement.pas}
{$I rendering.pas}

begin
  clrscr;
  Write('Enter level filename: ');
  Readln(levelname);
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

    repeat                                                          //beginning of the main loop
     Controls();
     DrawBackground(background, rotatez);
     loop1 := 0;
    for loop:=0 to (5*fov) do                                          //casting a ray
    begin
        ray_deg:=rotate+halffov-loop1;
        ray_realdist:=0;
        for ray_dist:=1 to 5*draw_dist do
        begin
           dist_x:= distray_x(ray_realdist,ray_deg);
           dist_y:= distray_y(ray_realdist,ray_deg);
           block_posx:=round((pl_x +dist_x)/map_scale);
           block_posy:=round((pl_y +dist_y)/map_scale);
           if (block_posx < 0) or (block_posx > 15) then block_posx:=1;
           if (block_posy < 0) or (block_posy > 15) then block_posy:=1;  //kills the error of detecting a non-existent block //calculating the final coordinates of the ray
           if (map[block_posx, block_posy]>=1) then draw_line(ray_realdist, block_posx, block_posy, loop1,rotatez*3);
           ray_realdist:=ray_realdist+0.2;
           if map[block_posx,block_posy]>=1 then break;                    //ends the loop when a wall is detected
        end;
        loop1 := loop1 + 0.2;
     end;
     SDL_RenderPresent(rend);
     SDL_Delay(17);
  until false;
end.

