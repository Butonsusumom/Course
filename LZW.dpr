program LZW;

{$APPTYPE CONSOLE}

uses
  SysUtils;

type
  TMAS = array [1..4096] of byte;
  PMAS = array [1..1024] of Byte;
  Dictionary=record
    symbol:TMAS;
    count:Integer;
    used:Boolean;
    code:integer;
    end;

  TPDic=^TDic;
 TDic = record
  info:Dictionary;
  AdressOfNext:TPDic;
  end;

var FileName:string;
 Head,Curr:TPDic;
 FileIn,FileEx:file;
 index,readbyte,count:integer;
 P: TMAS;
 ByteArray: PMAS;
 C:Byte;
 TFile: file ;



 function GetNextByte:integer ;
 begin

  if(index = readByte) then
  begin
    if not Eof(FileIn) then begin
      BlockRead(FileIn, byteArray, 1024, readByte);
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



 function Found(A:TMAS;c:Integer{;b:byte}):integer;
 var request:TMAS;
 i:integer;
 flag:Boolean;
 Current:TPDic;
 begin
   result:=-1;

   { Inc(c);
    A[c]:=b; }
    Current := Head;

  while (Current^.AdressOfNext <> Nil) and (result=-1)  do
    begin
     Current := Current^.AdressOfNext;
     flag:=True;
     for i:=1 to c do
      if (Current^.Info.symbol[i] <> A[i]) then
      flag:=False;
      if flag=True then
        result:=Current^.Info.code;

     end;
    end;





procedure SingleSymbols;
var
i,g:Byte;

s:TMAS;
 begin
   index:=1024;
   readbyte:=1024;
  New(Head);
  Curr := Head;
  Curr^.AdressOfNext := Nil;
   i:=0;
   AssignFile(FileIn,FileName);
   Reset(FileIn,1);
  // g:=GetNextByte;
  s[1]:=GetNextByte;
    while readbyte<>-1 do
    begin
     // if Found(s,0,g)=-1 then
     if Found(s,1)=-1 then
      begin
      New(Curr^.AdressOfNext);
       Curr^.AdressOfNext^.AdressOfNext := Nil;
       Curr^.AdressOfNext^.info.symbol[1]:=s[1];
       Curr^.AdressOfNext^.info.count:=1;
       Curr^.AdressOfNext^.info.used:=false;
       Curr^.AdressOfNext^.info.code:=i;
       Curr:=Curr^.AdressOfNext;
       inc(i);
      end;
      s[1]:=GetNextByte;
      end;
      CloseFile(FileIn);
 end;






procedure Add(a:TMAS;c:integer);
 begin
    Curr:=Head;
                while Curr^.AdressOfNext<>nil do
                 begin
                   Curr:=Curr^.AdressOfNext;
                 end;

                  New(Curr^.AdressOfNext);
                 Curr^.AdressOfNext^.AdressOfNext := Nil;
                 Curr^.AdressOfNext^.info.used:=false;
                 Curr^.AdressOfNext^.Info.Symbol:=a;
                  Curr^.AdressOfNext^.Info.Count:=c;
                 if (Curr^.AdressOfNext = Head) then
                  begin
                   Curr^.AdressOfNext^.Info.code:= 0;
                  end
                 else
                 Curr^.AdressOfNext^.Info.code := Curr^.Info.code + 1;

 end;



 {procedure CreateTableFile;
 TFile:file;
 begin
   AssignFile(TFile,'Table.LZW');
   Reset(TFile,1);


 end; }

 procedure ReadTable;
 var
 Current: TPDic;
 i: integer;
 b:byte;
 begin
  AssignFile(FileIn,'C:\work\Table.LZW');
  Reset(FileIn,1);
  index:=1024;
  readbyte:=1024;
  New(Head);
            Current := Head;
            Current^.AdressOfNext := Nil;
      while readbyte<>-1 do
        begin
         New(Current^.AdressOfNext);
         Current := Current^.AdressOfNext;
         Current^.Info.code:=GetNextByte;
         Current^.Info.count:=GetNextByte;
         for i:=1 to  Current^.Info.count do
           begin
           Current^.Info.symbol[i]:=GetNextByte;
           end;
         Current^.AdressOfNext := Nil;
        end;
       CloseFile(FileIn);
  end;

 procedure DeArchiv;
var a,b,c:Byte;
Current:TPDic;
i:integer;
 begin
   ReadTable;
  AssignFile(FileEx,FileName);
  AssignFile(FileIn,'C:\work\2.txt.LZW');
  Rewrite(FileEx,1);
  Reset(FileIn,1);

  index:=1024;
  readbyte:=1024;
  a:=GetNextByte;
  b:=GetNextByte;
  while readbyte<>-1 do
   begin
     c:= 10 * (b and $0F) + (a and $0F);
       Current := Head;
    while (Current^.AdressOfNext <> Nil)  do
     begin
      Current := Current^.AdressOfNext;
       if Current^.Info.code=c then
       begin
           // BlockWrite(FileEx,Current^.Info.code,1);
           // BlockWrite(FileEx,Current^.Info.count,1);
            for i:=1 to Current^.Info.count do
             BlockWrite(FileEx,Current^.Info.symbol[i],1);
       end;
     end;

    // BlockWrite(FileEx,c,1);
     a:=GetNextByte;
     b:=GetNextByte;
   end;


 end;

 procedure WriteTable;
 var
 Current:TPDic;
 i:integer;
 begin
    AssignFile(TFile,'C:\work\Table.LZW');
  Rewrite(TFile,1);
    Current := Head;
  while (Current^.AdressOfNext <> Nil)  do
    begin
      Current := Current^.AdressOfNext;
       if Current^.Info.used then
       begin
            BlockWrite(TFile,Current^.Info.code,1);
            BlockWrite(TFile,Current^.Info.count,1);
            for i:=1 to Current^.Info.count do
             BlockWrite(TFile,Current^.Info.symbol[i],1);
       end;
    end;

 end;

 procedure maketrue(b:integer);

  var
 Current:TPDic;
 i:integer;
 begin
    Current := Head;
  while (Current^.AdressOfNext <> Nil)  do
    begin
      Current := Current^.AdressOfNext;
      if Current^.Info.code=b then
       begin
          Current^.Info.used:=True;
       end;

    end;

 end;



procedure Archiv;
var i:Integer;
a,b:integer;
begin
  SingleSymbols;

  AssignFile(FileIn,FileName);
  AssignFile(FileEx,FileName+'.LZW');
  Reset(FileIn,1);
  Rewrite(FileEx,1);

  index:=1024;
  readbyte:=1024;
  //P:=0;
  P[1]:=GetNextByte;
  C:=GetNextByte;
  count:=1;
while readByte<>-1 do
  begin
    a:=Found(P,count);
    inc(count);
   P[count]:=C;
     b:=Found(P,count);
   if b<>-1 then
   begin
      C:=GetNextByte;
    end
   else
    begin

      BlockWrite(FileEx,a,2);
      MakeTrue(a);
      Add(P,count);
          P[1]:=P[count];
          C:=GetNextByte;
          count:=1;
  end;

  end;
  a:=Found(P,count);
  BlockWrite(FileEx,a,2);
  MakeTrue(a);
  WriteTable;
    Close(FileIn);
    Close(FileEx);
end;

var F:file;
g:integer;
key:integer;

begin
  Readln(key);
  case key of
    1: begin
        FileName:='C:\work\2.txt';
        Archiv;
         Readln;
       end;
    2: begin
        FileName:='C:\work\resLZW.txt';
        Dearchiv;
       end;
       end;
end.
