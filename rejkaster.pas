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
{$mode objFPC}                                  //object pascal extension on; [ or use $mode FPC or $mode DELPHI ]
uses crt, sdl2, SDL2_mixer, SDL2_image;

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
  draw_dist  = 191;                              //draw_dist := map_scale * 5 - 1; [ 191 := 16 * 5 -1 ] how far you can see in pixel
  max_Anz    = 15;                               //width and height of the (square-) map
  player_mov = 3;                                //player moves 3 pixels
  levelname  = 'test.map';                       //map name

var
  pl_x,
  pl_y              : real;                      //view position(coordinates swapped!)
  rotate            : real;                      //horizontal rotation angle  left / right
  rotateZ           : integer;                   //vertical rotation angle    up   / down
  loop              : integer;
  loop1             : real;                      //variables to the loop (loop is the relative angle of incidence of the ray)
  ray_deg           : real;                      //absolute angle of incidence of the ray
  ray_deg_sin,
  ray_deg_cos       : real;
  ray_dist          : integer;                   //loop variable like i or j
  ray_realdist      : real;                      //length of the searching ray in pixel, will be increased during the main loop
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
  rend              : PSDL_renderer;             //SDL2-specific variables
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

{$I movement.pas}
{$I rendering.pas}

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

  repeat                                                                     //beginning of the main loop
    Controls;                                                                //read keyboard
    DrawBackground(background, rotateZ);
    loop1 := 0.0;
    for loop := 0 to FOVWinX do                                              //casting a ray
    begin
      ray_deg := rotate + halfFOV - loop1;                                   //ray angle in degree
      ray_realdist := 0;
      ray_deg_cos := cos(ray_deg * degtorad);                                //cos of ray is const during calculate the ray; calculate outside of the loop!
      ray_deg_sin := sin(ray_deg * degtorad);                                //sin of ray is const during calculate the ray; calculate outside of the loop!
      for ray_dist := 1 to (5 * draw_dist) do                                //5*draw_dist: max length of the ray without hit a wall
      begin
        dist_x := ray_realdist * ray_deg_cos;                                //search for a wall in x; increase the raylength [ray_realdist] with
        dist_y := ray_realdist * ray_deg_sin;                                //a small amount [ here 0.2 pixel ] at the end of the loop
        block_posx := trunc((pl_x + dist_x) / map_scale);                    //control: if the ray hits a wall...
        block_posy := trunc((pl_y + dist_y) / map_scale);

        if (block_posx < 0) OR (block_posx > max_Anz) then block_posx := 1;  //kills the error of detecting a non-existent block
        if (block_posy < 0) OR (block_posy > max_Anz) then block_posy := 1;  //calculating the final coordinates of the ray

        if (map[block_posx, block_posy] >= 1) then draw_line(ray_realdist, block_posx, block_posy, loop1, rotateZ * 3);
        ray_realdist := ray_realdist + ray_dL;                               //increase the length of the searching ray [ ray_realdist ]
        if map[block_posx, block_posy] >= 1 then break;                      //ends the loop when a wall is detected
      end;
      loop1 := loop1 + ray_dG;                                               //change the angle of the ray [ here 0.2 degree ]
    end;
    SDL_RenderPresent(rend);                                                 //update the screen with any rendering performed since the previous call
    SDL_Delay(17);                                                           //delay 17 miliseconds equal to 60 FPS = Frames per second
  until false;                                                               //end of main loop
end.