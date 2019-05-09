program rle;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  Forms;

type
   TMAS = array[1..1024] of byte;

var
  s : string;
  myFile : file;
  outfile: file;
  byteArray,singelements : TMAS;
  onebyte:Byte;
  readByte,key,index : Integer;



  function ByteToBin(bt:byte):String;
var
i:Integer;
b:byte;
begin
Result:='';
For i:=7 downto 0 do
begin
b:=bt shr i;
b:=b and $1;
If b=1 then
Result:=Result+'1'
else
Result:=Result+'0';
end;
end;


function GetNextByte1:byte;
begin

  if(index = readByte) then
  begin
    if not Eof(myFile) then begin
      BlockRead(myFile, byteArray, 1024, readByte);
      index := 0;
     end
     else

  end;
  if readByte<>-1 then
  begin
    Inc(index);
 result := byteArray[index];
 end;

end;




function GetNextByte2:byte;
begin

  if(index = readByte) then
  begin
    if not Eof(outFile) then begin
      BlockRead(outFile, byteArray, 1024, readByte);
      index := 0;
     end
     else readbyte:=-1 
  end;
  if readByte<>-1 then
  begin
    Inc(index);
 result:= byteArray[index];
 end;

end;



procedure  writeBlock(symbolCount:Integer; byteTypeRepeat:boolean; blockSymbols:TMAS; blockSymbolsCounter:integer);
var i:integer;
  begin
     //formirate work byte
     //write bytes  from array
     onebyte:= symbolCount-1;
     if byteTypeRepeat then  onebyte:= onebyte+128-1;
     if symbolCount<>0 then
    BlockWrite(outfile, onebyte,1); //write byte
    if byteTypeRepeat then   BlockWrite(outfile,blockSymbols[1],1)
    else
     for i:=1 to blockSymbolsCounter do
    BlockWrite(outfile,blockSymbols[i],1);

  end;



procedure compress;
var  curr,prev:Byte;

byteTypeRepeat:Boolean;
blockSymbols : TMAS;
blockSymbolsCounter,symbolCount:Integer;
symbolRepeatCount: Integer;


  begin

    symbolCount:=1;
    symbolRepeatCount:=1;

    byteTypeRepeat:=False;
    curr:=GetNextByte1;
    blockSymbolsCounter:=1;
    blockSymbols[blockSymbolsCounter]:=curr;
    prev:=curr;
    curr:=GetNextByte1;

    while readByte<>-1 do
    begin
      Inc(symbolCount);
      Inc(blockSymbolsCounter);
      blockSymbols[blockSymbolsCounter]:=curr;

      if curr = prev then
        begin
          Inc(symbolRepeatCount);
          if (byteTypeRepeat=False) and (symbolRepeatCount > 2) then
          begin
            blockSymbolsCounter:=blockSymbolsCounter-symbolRepeatCount;
            symbolCount:=symbolCount-symbolRepeatCount;
            writeBlock(symbolCount, byteTypeRepeat, blockSymbols, blockSymbolsCounter);
            symbolCount:=symbolRepeatCount;
            blockSymbolsCounter:=1;
            blockSymbols[blockSymbolsCounter]:=curr;
            byteTypeRepeat:=True;
          end
        end
      else
       begin

           if byteTypeRepeat then
           begin
            blockSymbolsCounter:=blockSymbolsCounter-1;
            symbolCount:=symbolCount-1;
            writeBlock(symbolCount, byteTypeRepeat, blockSymbols, blockSymbolsCounter);
            symbolCount:=1;
            blockSymbolsCounter:=1;
            blockSymbols[blockSymbolsCounter]:=curr;
            byteTypeRepeat:=False;
            //symbolRepeatCount:=1;
           end;
         symbolRepeatCount:=1;
        end;

      prev:=curr;
      curr:=GetNextByte1;

    end;

  end;


  procedure compress3;
var  count0,count1,i:Integer;
 begin
   count1:=1;    // inticialize counters for different posledovatelnostey
   count0:=0;
   for i:=1 to readbyte do
    begin
      if byteArray[i]=byteArray[i+1] then
      begin
          inc(count1);
          if (Count0<>0) and (count1>2) then
          begin
           onebyte:=0+count0-2 ;                // make a byte , use +2 becouse we count 1 extra symbol
           BlockWrite(outfile,onebyte,1); //write byte
           BlockWrite(outfile,singelements,count0-1);
           count0:=0;                 // write array
          end;

          end
      else
       begin
         if count1=2 then               //add to array twice used elements
         begin
           count0:=count0+count1-1;
         singelements[count0-1]:=byteArray[i];

         count1:=1;
         end;
          if (count1>2)  then
           begin
             onebyte:=128+count1-2;// make a byte
             BlockWrite(outfile,onebyte,1);//write byte
             BlockWrite(outfile,byteArray[i],1); //write symbol
            count1:=1;
           end;
          if i=1 then Inc(count0);
         if count0>0 then
          singelements[count0]:=bytearray[i]; //formirate asn array
           Inc(count0);
       end;


    end;

     end;







  procedure decompress2;
var j,count:Integer;
     s:string;
     curr:byte;
 begin
   curr:=GetNextByte2;
   while readByte<>-1 do
    begin
      count:=curr and 127;
     s:= ByteToBin(curr);
       if s[1]='1' then
        begin
          count:=count+2;
          curr:=GetNextByte2;
          for j:=1 to count do
          BlockWrite(myFile,curr,1);
        end
       else
        begin
          count:=count+1;
          for j:=1 to count do
           begin
             curr:=GetNextByte2;
             BlockWrite(myFile,curr,1);
           end;
        end;
        curr:=GetNextByte2;
    end;
 end;

begin

   Readln (key);
   case Key of
   1: begin

    s:='C:\work\3.JPG';
  AssignFile(myFile, s);
  Reset(myFile, 1);

  AssignFile(outFile,s+'.KSU');
  ReWrite(outFile, 1);
  index:=1024;
  readByte:=1024;
      compress;
    CloseFile(myFile);
    CloseFile(outFile);
    Readln;
  end;
  
  2:
  begin
    s:='C:\work\3.JPG.KSU';
   AssignFile(outFile,s);
     Reset(outFile, 1);
     s:=Copy(s,1,Pos('.KSU',S)-1);
    AssignFile(myFile,S );
    ReWrite(myFile, 1);
      index:=1024;
  readByte:=1024;
     // BlockRead(outFile, byteArray, 1024, readByte);
      decompress2;
      //BlockWrite(outFile, byteArray, readByte, writeByte);
   
    CloseFile(myFile);
    CloseFile(outFile);
    Readln;
  end;
  3: begin
    s:='C:\work\3.JPG';
    AssignFile(myFile, s);
    Reset(myFile, 1);
     s:='C:\work\RED2.JPG';
  AssignFile(outFile, s);
  Rewrite(outFile, 1);
  index:=1024;
  readbyte:=1024;
  while readByte<>-1 do
   begin
     onebyte:=GetNextByte1;
     BlockWrite(outfile,onebyte,1);
   end;
  end;

  end;
end.
