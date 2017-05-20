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
  draw_yoffset: integer;                    //odległość początku pionowej linii od osi x ekranu
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

const
//block_size=8;
//map_size=128;
fov=80;
halffov=40;
degtorad=0.01745;
scr_width=800;                              //stałe
scr_height=600;
halfheight=300;
draw_dist=255;
map_scale=16;
map:array[0..15,0..15] of integer =((1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),    //Jedyna słuszna mapa
                                    (1,2,1,0,0,0,0,0,0,0,0,0,0,0,0,1),
                                    (1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
                                    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
                                    (1,0,0,0,2,2,2,2,2,2,2,2,0,0,0,1),
                                    (1,0,0,0,2,0,0,0,0,0,0,2,0,0,0,1),
                                    (1,0,0,0,2,0,2,2,2,2,0,2,0,0,0,1),
                                    (1,0,0,0,2,0,2,1,0,2,0,2,0,0,0,1),
                                    (1,0,0,0,2,0,2,2,0,2,0,2,0,0,0,1),
                                    (1,0,0,0,2,0,2,2,0,2,0,2,0,0,0,1),
                                    (1,0,0,0,2,0,0,0,0,2,0,2,0,0,0,1),
                                    (1,0,0,0,2,2,2,2,2,2,0,2,0,0,0,1),
                                    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
                                    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
                                    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
                                    (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1));

function distray_x(ray_l,alpha:real): real;
         begin
         distray_x:=ray_l*cos(alpha*pi/180);
         end;
function distray_y(ray_l,alpha:real): real;
         begin
         distray_y:=ray_l*sin(alpha*pi/180);
         end;

function draw_line(dist: Real; posx, posy: integer; angle: Real; anglez: integer): boolean;
           begin
           ray_draw:= dist*cos((angle - halffov)*degtorad);
           if map[posx,posy]>=1 then begin
                      color_draw:=trunc(dist)+1;
                      case map[posx,posy] of
                      1: SDL_SetRenderDrawColor(rend,255-color_draw,0,0,128);
                      2: SDL_SetRenderDrawColor(rend,0,0,255-color_draw,128);
                      end;
           draw_yoffset2:= (halfheight*12/ray_draw)-1;
           draw_yoffset:=round(draw_yoffset2);
           SDL_RenderDrawLine(rend, 2*loop, halfheight-draw_yoffset+anglez,2*loop, halfheight+draw_yoffset+anglez);	//rysuję linię
           SDL_RenderDrawLine(rend, 2*loop+1, halfheight-draw_yoffset+anglez,2*loop+1, halfheight+draw_yoffset+anglez);	//rysuję linię
           draw_line := true;
           end;
           end;

function load_music() : boolean;
         begin
           music := Mix_LoadMUS('megadens.ogg');
           if music = nil then HALT;
           Mix_VolumeMusic( MIX_MAX_VOLUME );
           if Mix_PlayMusic( music, -1 ) < 0 then begin Writeln('Playback failed!');
           end else Writeln('Playback started.');
           load_music:= true;
         end;

function QuitProgram(): boolean;
         begin
             dispose( event );
             Writeln('Keyboard disposed.');
             SDL_DestroyRenderer( rend );
             Writeln('Renderer destroyed.');
             SDL_DestroyWindow( window );
             Writeln('Window destroyed');
             Mix_FreeMusic( music );
             Writeln('Music unloaded.');
             Mix_CloseAudio;
             Writeln('Audio closed.');
             SDL_Quit;
             Writeln('Exit gracefully.');
             QuitProgram:=true;
             Halt;
         end;

function DrawBackground(bgimg: pSDL_Texture;zangle: integer) : boolean;
         var draw_gnd_rect: pSDL_Rect;
         begin
               new(draw_gnd_rect);
               draw_gnd_rect^.x:=0;
               draw_gnd_rect^.y:=zangle*3-270;
               draw_gnd_rect^.w:=800;
               draw_gnd_rect^.h:=1140;
               SDL_RenderCopy(rend,bgimg,nil,draw_gnd_rect);
         end;

begin

  if SDL_Init( SDL_INIT_VIDEO or SDL_INIT_AUDIO ) < 0 then begin HALT;
  end else writeln ('Initializing SDL... ok.');;
  window:= SDL_CreateWindow('RejKaster4',SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED,scr_width,scr_height,SDL_WINDOW_SHOWN);
  new(event);                                               //tworzenie eventu
  rend:= SDL_CreateRenderer(window,-1,SDL_RENDERER_SOFTWARE);
  SDL_ShowCursor(0);
  SDL_SetRenderDrawColor(rend, 0,0,0,0);
  SDL_RenderClear(rend);
  SDL_RenderPresent(rend);                                   //stworzenie i wyczyszczenie okna
  rotate:=90;
  pl_x:=128;
  pl_y:=192;
  if Mix_OpenAudio( MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS, 4096 ) < 0 then HALT;
  load_music();
  background := IMG_LoadTexture(rend, 'back.png');
  //SDL_Delay(10000);
  Writeln('================Raycaster 4================');
  Writeln('Copyright by Perfection Games Studios, 2017');
  repeat                                                          //początek głównej pętli
    while SDL_PollEvent(event) = 1 do
     begin                                                                //sterowanie
        if event^.key.keysym.sym = SDLK_ESCAPE then QuitProgram();
     end;

     Keycodes := SDL_GetKeyboardState(nil);

     if Keycodes[SDL_SCANCODE_W] = 1 then
     begin
          {if(map[round((pl_x + distray_x(9,rotate))/16), round((pl_y + distray_y(9,rotate))/16)] = 0) then begin
          pl_x := pl_x + distray_x(3,rotate);
          pl_y := pl_y + distray_y(3,rotate);
//          writeln('X: ', pl_y);                                        //wyświetla pozycje gracza (jak widać tablica czytana jest inaczej niż przewidywałem kurwa jej mać)
//          writeln('Y: ', pl_x);
          end;}

          if map[round((pl_x + distray_x(3,rotate))/16),round(pl_y/16)] = 0 then
          begin
            pl_x := pl_x + distray_x(3,rotate);
          end;
          if map[round(pl_x/16),round((pl_y + distray_y(3,rotate))/16)] = 0 then
          begin
            pl_y := pl_y + distray_y(3,rotate);
          end;
     end;
     if Keycodes[SDL_SCANCODE_S] = 1 then
     begin
          //if(map[round((pl_x - distray_x(9,rotate))/16), round((pl_y - distray_y(9,rotate))/16)] = 0) then begin
          //pl_x := pl_x - distray_x(3,rotate);
          //pl_y := pl_y - distray_y(3,rotate);
//          writeln('X: ', pl_y);                                        //wyświetla pozycje gracza (jak widać tablica czytana jest inaczej niż przewidywałem kurwa jej mać)
//          writeln('Y: ', pl_x);
          //end;

          if map[round((pl_x - distray_x(3,rotate))/16),round(pl_y/16)] = 0 then
          begin
            pl_x := pl_x - distray_x(3,rotate);
          end;
          if map[round(pl_x/16),round((pl_y - distray_y(3,rotate))/16)] = 0 then
          begin
            pl_y := pl_y - distray_y(3,rotate);
          end;
     end;
     if Keycodes[SDL_SCANCODE_A] = 1 then
     begin
          //if(map[round((pl_x + distray_x(9,rotate))/16), round((pl_y + distray_y(9,rotate))/16)] = 0) then begin
          //pl_x := pl_x + distray_x(3,rotate);
          //pl_y := pl_y + distray_y(3,rotate);
//          writeln('X: ', pl_y);                                        //wyświetla pozycje gracza (jak widać tablica czytana jest inaczej niż przewidywałem kurwa jej mać)
//          writeln('Y: ', pl_x);
          //end;

          if map[round((pl_x + distray_x(3,rotate+90))/16),round(pl_y/16)] = 0 then
          begin
            pl_x := pl_x + distray_x(3,rotate+90);
          end;
          if map[round(pl_x/16),round((pl_y + distray_y(3,rotate+90))/16)] = 0 then
          begin
            pl_y := pl_y + distray_y(3,rotate+90);
          end;
     end;
     if Keycodes[SDL_SCANCODE_D] = 1 then
     begin
          //if(map[round((pl_x - distray_x(9,rotate))/16), round((pl_y - distray_y(9,rotate))/16)] = 0) then begin
          //pl_x := pl_x - distray_x(3,rotate);
          //pl_y := pl_y - distray_y(3,rotate);
//          writeln('X: ', pl_y);                                        //wyświetla pozycje gracza (jak widać tablica czytana jest inaczej niż przewidywałem kurwa jej mać)
//          writeln('Y: ', pl_x);
          //end;

          if map[round((pl_x + distray_x(3,rotate-90))/16),round(pl_y/16)] = 0 then
          begin
            pl_x := pl_x + distray_x(3,rotate-90);
          end;
          if map[round(pl_x/16),round((pl_y + distray_y(3,rotate-90))/16)] = 0 then
          begin
            pl_y := pl_y + distray_y(3,rotate-90);
          end;
     end;

     SDL_GetMouseState(@mouse_x,@mouse_y);

     rotate := rotate+round((400-mouse_x)/3);
     rotatez := rotatez+round((300-mouse_y)/2);

     SDL_WarpMouseInWindow(window,400,300);

     if rotatez > 90 then rotatez := 90;
     if rotatez < -90 then rotatez := -90;

     if rotate > 360 then rotate := rotate - 360;
     if rotate > 0 then rotate := rotate + 360;

     //SDL_SetRenderDrawColor(rend, 0,0,0,0);
     //SDL_RenderClear(rend);
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

