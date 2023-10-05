program tester;
uses crt, sysutils;

const
max=15;    //"wall cubes" or "squares" of the map
map:array[0..max,0..max] of smallint=((1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
                                      (1,2,1,0,0,0,0,0,0,0,0,0,0,0,0,1),
                                      (1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
                                      (1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
                                      (1,0,0,0,2,2,2,2,2,2,2,2,0,0,0,1),
                                      (1,0,0,0,2,0,0,0,0,0,0,2,0,0,0,1),
                                      (1,0,0,0,2,0,2,2,2,2,0,2,0,0,0,1),
                                      (1,0,0,0,2,0,2,3,9,2,0,2,0,0,0,1),
                                      (1,0,0,0,2,0,2,2,0,2,0,2,0,0,0,1),
                                      (1,0,0,0,2,0,2,2,0,2,0,2,0,0,0,1),
                                      (1,0,0,0,2,0,0,0,0,2,0,2,0,0,0,1),
                                      (1,0,0,0,2,2,2,2,2,2,0,2,0,0,0,1),
                                      (1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
                                      (1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
                                      (1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
                                      (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1));

var
k,l: integer;
name: string;

procedure generate_map();
var i,j : integer;
    mapfile : file of smallint;
begin
  Assign(mapfile, name);
  rewrite(mapfile);
  for i := 0 to max do begin
    for j := 0 to max do begin
      write(mapfile, map[i,j]);
    end;
  end;

 {for i:=0 to max do begin
  write(mapfile, map[i,0],map[i,1],map[i,2],map[i,3],map[i,4],map[i,5],map[i,6],map[i,7],map[i,8],map[i,9],map[i,10],map[i,11],map[i,12],map[i,13],map[i,14],map[i,15]);
  //map[i,j]:=StrToInt(table[i,j]);
  end;}
  Close(mapfile);
end;

begin
  clrscr;
  write('Enter a filename: ');
  readln(name); writeln;
  generate_map();
  for k := 0 to max do begin      // show ascii map on screen
    for l := 0 to max do begin
      if map[k,l] = 0 then write('  ')
                      else write(map[k,l], ' ');
    end;
    writeln;
  end;
  writeln;
end.