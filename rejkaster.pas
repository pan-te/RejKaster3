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
uses sdl2;

var
  pl_x, pl_y: integer;                      //pozycja widoku(koordynaty zamienione!)
  rotate : real;                            //kąt rotacji
  loop: integer;
  loop1: real;                                          //zmienne do pętli (loop to względny kąt padania promienia)
  ray_deg: Real;                            //bezwzględny kąt padania promienia
  ray_dist, ray_draw: integer;              //dystans przebyty przez promień
  draw_yoffset: integer;                    //odległość początku pionowej linii od osi x ekranu
  dist_x,dist_y:real;                       //koordynaty wektora promienia
  block_posx,block_posy:integer;            //punkt padania promienia na mapie
  event: pSDL_event;                        //
  rend: pSDL_renderer;                      // zmienne specyficzne dla SDL
  window:  pSDL_window;                     //
  Keycodes:  ^byte;

const
//block_size=8;
//map_size=128;
fov=80;
scr_width=800;                              //stałe
scr_height=600;
halfheight=300;
draw_dist=1000;
map:array[0..15,0..15] of integer =((1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),    //Jedyna słuszna mapa
                                    (1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
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

begin

  SDL_init(SDL_INIT_VIDEO);
  window:= SDL_CreateWindow('RejKaster3',0,0,scr_width,scr_height,SDL_WINDOW_SHOWN);
  new(event);                                               //tworzenie eventu
  rend:= SDL_CreateRenderer(window,-1,SDL_RENDERER_ACCELERATED);
  SDL_SetRenderDrawColor(rend, 0,0,0,0);
  SDL_RenderClear(rend);
  SDL_RenderPresent(rend);                                   //stworzenie i wyczyszczenie okna
  rotate:=90;
  pl_x:=64;
  pl_y:=96;
  //SDL_Delay(10000);
  repeat                                                          //początek głównej pętli
     writeln('X: ', pl_y);                                        //wyświetla pozycje gracza (jak widać tablica czytana jest inaczej niż przewidywałem kurwa jej mać)
     writeln('Y: ', pl_x);
     while SDL_PollEvent(event) = 1 do
     begin                                                                //{sterowanie
        if event^.key.keysym.sym = SDLK_ESCAPE then halt;            //przejście do markera stop(linia 128)
        (*if event^.key.keysym.sym = SDLK_LEFT then rotate := rotate-3;
        if event^.key.keysym.sym = SDLK_RIGHT then rotate := rotate+3;
        if event^.key.keysym.sym = SDLK_UP then
        begin
             pl_x := pl_x + round(distray_x(3,rotate));
             pl_y := pl_y + round(distray_y(3,rotate));
        end;
                if event^.key.keysym.sym = SDLK_DOWN then
        begin
             pl_x := pl_x - round(distray_x(3,rotate));
             pl_y := pl_y - round(distray_y(3,rotate));
        end;*)
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
        pl_x := pl_x + round(distray_x(3,rotate));
        pl_y := pl_y + round(distray_y(3,rotate));
     end;
     if Keycodes[SDL_SCANCODE_DOWN] = 1 then
     begin
        pl_x := pl_x - round(distray_x(3,rotate));
        pl_y := pl_y - round(distray_y(3,rotate));
     end;

     if rotate > 360 then rotate := rotate - 360;
     if rotate > 0 then rotate := rotate + 360;                           //sterowanie}

     SDL_SetRenderDrawColor(rend, 0,0,0,0);
     SDL_RenderClear(rend);
    for loop:=0 to (10*fov) do                                          //rzucanie promienia
    begin
        loop1 := loop/10;
        ray_deg:=rotate+30-loop1;
        for ray_dist:=1 to draw_dist do
        begin
           dist_x:= distray_x(ray_dist,ray_deg);
           dist_y:= distray_y(ray_dist,ray_deg);
           block_posx:=round((pl_x +dist_x) / 8);
           block_posy:=round((pl_y +dist_y) / 8);                       //wyliczanie końcowych koordynatów promienia
           if (block_posx < 0) or (block_posx > 15) then block_posx:=1;
           if (block_posy < 0) or (block_posy > 15) then block_posy:=1;  //masakruje błąd detekcji nieistniejącego bloku
           ray_draw:= ray_dist * round(cos((loop1 - (fov/2))*pi/180));
           if map[block_posx,block_posy]>=1 then begin                   //detekcja kolizji promienia
                      case map[block_posx,block_posy] of
                      1: SDL_SetRenderDrawColor(rend,255-ray_dist*2,0,0,128);		//wybieram kolor bloku
                      2: SDL_SetRenderDrawColor(rend,0,0,255-ray_dist*2,128);
           end;
           draw_yoffset:= round(halfheight/ray_draw*8)-1 ;						//ustawiam długość linii
           SDL_RenderDrawLine(rend, scr_width-loop, halfheight-draw_yoffset,scr_width-loop, halfheight+draw_yoffset);	//rysuję linię
           end;
           if map[block_posx,block_posy]>=1 then break;                    //kończy pętle po wykryciu ściany
        end;
     end;
     SDL_RenderPresent(rend);                                              //wyświetla bufor obrazu
     SDL_Delay(17);
  until false;
end.

