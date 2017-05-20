//~~~~~~~~~~~~~~~~Rejkaster~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~(C)by Daniel Sadlik~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~2017~~~~~~~~~~~~~~~~~~~~~
//~~|-------------------------------------|~~
//~~| Raycasting w możliwie najłatwiejszej|~~
//~~|wersji. Uwaga! Jest upośledzony.     |~~
//~~|             (Wykonano w LazarusIDE) |~~
//~~|Enjoy!_______________________________|~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~12.01.2017


program rejkaster;
uses sdl2, SDL2_mixer;
{$ASMMODE intel}                            //ustawienie składni assemblera, niepotrzebne
var
  pl_x, pl_y: integer;                      //pozycja widoku(koordynaty zamienione!)
  rotate : real;                            //kąt rotacji
  loop: integer;
  loop1: real;                                          //zmienne do pętli (loop to względny kąt padania promienia)
  ray_deg: Real;                            //bezwzględny kąt padania promienia
  ray_dist: integer;                        //dystans przebyty przez promień
  ray_draw, draw_yoffset: integer;          //odległość obiektu od płaszczyzny ekranu, odległość początku pionowej linii od osi x ekranu
  dist_x,dist_y:real;                       //koordynaty wektora promienia
  block_posx,block_posy:integer;            //punkt padania promienia na mapie
  abakan: integer;                          //zmienna używana przy ścianach leżących w osi y
  event: pSDL_event;                        //event klawiatury
  rend: pSDL_renderer;                      //zmienne specyficzne dla SDL
  window:  pSDL_window;
  music: PMIX_music;
  Keycodes:  ^byte;                         //stan klawiatury

const
//block_size=8;
//map_size=128;
fov=80;
halffov=40;
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

function draw_line(dist, posx, posy: integer; angle: Real; horizontal: boolean): boolean;
           begin
           ray_draw:= round(dist*cos((angle - (fov/2))*pi/180));
           if map[posx,posy]>=1 then begin
                      case horizontal of
                      true: abakan:= 255-dist;
                      false: abakan:= 0;
                      end;
                      case map[posx,posy] of
                      1: SDL_SetRenderDrawColor(rend,255-dist,abakan,0,128);
                      2: SDL_SetRenderDrawColor(rend,0,abakan,255-dist,128);
                      end;
           draw_yoffset:= round(halfheight/ray_draw*12)-1 ;
           SDL_RenderDrawLine(rend, scr_width-loop, halfheight-draw_yoffset,scr_width-loop, halfheight+draw_yoffset);	//rysuję linię
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

begin

  if SDL_Init( SDL_INIT_VIDEO or SDL_INIT_AUDIO ) < 0 then begin HALT;
  end else writeln ('Initializing SDL... ok.');;
  window:= SDL_CreateWindow('RejKaster3',0,0,scr_width,scr_height,SDL_WINDOW_SHOWN);
  new(event);                                               //tworzenie eventu
  rend:= SDL_CreateRenderer(window,-1,SDL_RENDERER_ACCELERATED);
  SDL_SetRenderDrawColor(rend, 0,0,0,0);
  SDL_RenderClear(rend);
  SDL_RenderPresent(rend);                                   //stworzenie i wyczyszczenie okna
  rotate:=90;
  pl_x:=128;
  pl_y:=192;
if Mix_OpenAudio( MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS, 4096 ) < 0 then HALT;
  load_music();
  //SDL_Delay(10000);
  Writeln('============Raycaster 4===========');
  Writeln('Copyright by Daniel Sadlik, 2017');
  repeat                                                          //początek głównej pętli
     while SDL_PollEvent(event) = 1 do
     begin                                                                //{sterowanie
        if event^.key.keysym.sym = SDLK_ESCAPE then QuitProgram();
     end;

     Keycodes := SDL_GetKeyboardState(nil);

     if Keycodes[SDL_SCANCODE_LEFT] = 1 then
     begin
          rotate := rotate-3;
     end;
     if Keycodes[SDL_SCANCODE_RIGHT] = 1 then
     begin
          rotate := rotate+3;
     end;
     if Keycodes[SDL_SCANCODE_UP] = 1 then
     begin
          if(map[round((pl_x + distray_x(9,rotate))/16), round((pl_y + distray_y(9,rotate))/16)] = 0) then begin
          pl_x := pl_x + round(distray_x(3,rotate+2));
          pl_y := pl_y + round(distray_y(3,rotate+2));
          writeln('X: ', pl_y);                                        //wyświetla pozycje gracza (jak widać tablica czytana jest inaczej niż przewidywałem kurwa jej mać)
          writeln('Y: ', pl_x);
          end;
     end;
     if Keycodes[SDL_SCANCODE_DOWN] = 1 then
     begin
          if(map[round((pl_x - distray_x(9,rotate))/16), round((pl_y - distray_y(9,rotate))/16)] = 0) then begin
          pl_x := pl_x - round(distray_x(3,rotate+2));
          pl_y := pl_y - round(distray_y(3,rotate+2));
          writeln('X: ', pl_y);                                        //wyświetla pozycje gracza (jak widać tablica czytana jest inaczej niż przewidywałem kurwa jej mać)
          writeln('Y: ', pl_x);
          end;
     end;

     if rotate > 360 then rotate := rotate - 360;
     if rotate > 0 then rotate := rotate + 360;                           //sterowanie}

     SDL_SetRenderDrawColor(rend, 0,0,0,0);
     SDL_RenderClear(rend);
    for loop:=0 to (10*fov) do                                          //rzucanie promienia
    begin
        loop1 := loop/10;
        ray_deg:=rotate+halffov-loop1;
        for ray_dist:=1 to draw_dist do
        begin
           dist_x:= distray_x(ray_dist,ray_deg);
           dist_y:= distray_y(ray_dist,ray_deg);
           block_posx:=round((pl_x +dist_x)/map_scale);
           block_posy:=round((pl_y +dist_y)/map_scale);
           if (block_posx < 0) or (block_posx > 15) then block_posx:=1;
           if (block_posy < 0) or (block_posy > 15) then block_posy:=1;  //masakruje błąd detekcji nieistniejącego bloku //wyliczanie końcowych koordynatów promienia
           if (map[block_posx, block_posy]>=1) then draw_line(ray_dist, block_posx, block_posy, loop1, false);
           if (map[block_posx, block_posy]>=1) and (round(pl_x +dist_x) mod map_scale = 0) then begin
           draw_line(ray_dist, block_posx, block_posy, loop1, true);
           end;
           if map[block_posx,block_posy]>=1 then break;                    //kończy pętle po wykryciu ściany
        end;
     end;
     SDL_RenderPresent(rend);                                              //wyświetla bufor obrazu
     SDL_Delay(17);
  until false;
end.

