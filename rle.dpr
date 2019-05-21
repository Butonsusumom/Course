program rle;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  System,
  Forms;

type
   TMAS = array[1..1024] of byte;
   A = file of Byte;

  Signature = record
    name:string[6];
    crc:byte;
    end;

var
  s : string;
  myFile ,f: file;
  outfile: file;
  byteArray,singelements : TMAS;
  onebyte:Byte;
  readByte,key,index : Integer;
  Sign:Signature;



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
     else readByte:=-1;

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
     if (symbolCount <> 0) AND (blockSymbolsCounter <> 0)then
     begin
      onebyte:= symbolCount;
      if byteTypeRepeat then  onebyte:= onebyte+128;
      BlockWrite(outfile, onebyte,1); //write byte
      if byteTypeRepeat then  BlockWrite(outfile,blockSymbols[1],1)
      else
        BlockWrite(outfile,blockSymbols,blockSymbolsCounter);
    end;

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
      try
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
           end;
         symbolRepeatCount:=1;
        end;

      if (byteTypeRepeat=False) AND (blockSymbolsCounter > 126) then
      begin
         writeBlock(symbolCount, byteTypeRepeat, blockSymbols, blockSymbolsCounter);
         symbolCount:=0;
         blockSymbolsCounter:=0;
      end;

      prev:=curr;
      curr:=GetNextByte1;
      except
           writeln('error');
      end;

    end;
    writeBlock(symbolCount, byteTypeRepeat, blockSymbols, blockSymbolsCounter);

  end;


  procedure decompress;
var j,count:Integer;
     s:byte;
     curr:byte;
 begin

   curr:=GetNextByte2;
   while readByte<>-1 do
    begin
      count:=curr and 127;
      s:= curr shr 7;
       if s=1 then
        begin
          curr:=GetNextByte2;
          for j:=1 to count do
          BlockWrite(myFile,curr,1);
        end
       else
        begin
          for j:=1 to count do
           begin
             curr:=GetNextByte2;
             BlockWrite(myFile,curr,1);
           end;
        end;
        curr:=GetNextByte2;
    end;
 end;

 procedure WriteSign;
var
 C:Byte;


begin
 s:='C:\work\1.jpg';
  index:=1024;
  readByte:=1024;
Sign.name:=ExtractFileExt(s);
 AssignFile(myFile, s);
 Reset(myFile, 1);
 C:=GetNextByte1;
 while readbyte<>-1 do
   C:= C xor GetNextByte1;
Sign.crc:=C;
CloseFile(myFile);
end;


begin

   Readln (key);
   case Key of
   1: begin
   WriteSign;
    s:='C:\work\1.jpg';
    AssignFile(myFile, s);
    Reset(myFile, 1);


  AssignFile(outFile,s+'.KSU');
  ReWrite(outFile, 1);
  index:=1024;
  readByte:=1024;
    BlockWrite(outFile,Sign.name,6);
    BlockWrite(outFile,Sign.crc,1);
      compress;
    CloseFile(myFile);
    CloseFile(outFile);
    Readln;
  end;

  2:
  begin
    s:='C:\work\1.jpg.KSU';
   AssignFile(outFile,s);
     Reset(outFile, 1);
     s:='C:\work\result.JPG';//Copy(s,1,Pos('.KSU',S)-1);
    AssignFile(myFile,S );
    ReWrite(myFile, 1);
    BlockRead(outFile,Sign.name,6);
    BlockRead(outFile,Sign.crc,1);
      index:=1024;
  readByte:=1024;
     // BlockRead(outFile, byteArray, 1024, readByte);
      decompress;
      //BlockWrite(outFile, byteArray, readByte, writeByte);

    CloseFile(myFile);
    CloseFile(outFile);
    Readln;
  end;
  3: begin
    s:='C:\work\1.JPG';
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
