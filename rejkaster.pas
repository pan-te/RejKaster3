//~~~~~~~~~~~~~~~~Rejkaster~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~(C)by Daniel i Adam Sadlik~~~~~~~
//~~~~~~~~~~~~~~~~~~2017~~~~~~~~~~~~~~~~~~~~~
//~~|-------------------------------------|~~
//~~| Raycasting w możliwie najłatwiejszej|~~
//~~|wersji. Uwaga! Jest upośledzony.     |~~
//~~|             (Wykonano w LazarusIDE) |~~
//~~|Enjoy!_______________________________|~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~12.01.2017


program rejkaster;
uses sdl2, SDL2_mixer, SDL2_image;
{$ASMMODE intel}                            //ustawienie składni assemblera, niepotrzebne
var
  pl_x, pl_y: real;                      //pozycja widoku(koordynaty zamienione!)
  rotate : real;                            //kąt rotacji
  rotatez : integer;
  loop: integer;
  loop1: real;                                          //zmienne do pętli (loop to względny kąt padania promienia)
  ray_deg: Real;                            //bezwzględny kąt padania promienia
  ray_dist: integer;                        //dystans przebyty przez promień
  ray_realdist: real;
  draw_yoffset_up, draw_yoffset_down: integer;                    //odległość początku pionowej linii od osi x ekranu
  draw_yoffset2: real;
  ray_draw: Real;
  color_draw: integer;
  dist_x,dist_y:real;                       //koordynaty wektora promienia
  block_posx,block_posy:integer;            //punkt padania promienia na mapie
  event: pSDL_event;                        //event klawiatury
  rend: pSDL_renderer;                      //zmienne specyficzne dla SDL
  window:  pSDL_window;
  music: PMIX_music;
  Keycodes:  ^byte;                         //stan klawiatury
  background: pSDL_Texture;
  mouse_x: integer;                         // Pozycja kursora
  mouse_y: integer;
  movebob_up, movebob_down: real;
  bob_phase: boolean;
  map:array[0..15,0..15] of integer;
  levelname: string;
  //i: integer;

const
//block_size=8;
//map_size=128;
fov=80;
halffov=40;
degtorad=0.01745;
scr_width=1200;                              //stałe
scr_height=900;
halfheight=450;
draw_dist=191;
map_scale=16;


{$I movement.pas}
{$I rendering.pas}

begin
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
  
    repeat                                                          //początek głównej pętli
     Controls();
     DrawBackground(background, rotatez);
     loop1 := 0;
    for loop:=0 to (5*fov) do                                          //rzucanie promienia
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
           if (block_posy < 0) or (block_posy > 15) then block_posy:=1;  //masakruje błąd detekcji nieistniejącego bloku //wyliczanie końcowych koordynatów promienia
           if (map[block_posx, block_posy]>=1) then draw_line(ray_realdist, block_posx, block_posy, loop1,rotatez*3);
           ray_realdist:=ray_realdist+0.2;
           if map[block_posx,block_posy]>=1 then break;                    //kończy pętle po wykryciu ściany
        end;
        loop1 := loop1 + 0.2;
     end;
     SDL_RenderPresent(rend);
     SDL_Delay(17);
  until false;
end.

