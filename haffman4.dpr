program haffman4;

{$APPTYPE CONSOLE}



  uses
  Windows,
  SysUtils,
  Forms;

type
  TPNode=^PNode;
  PNode = record
   Symbol:Byte;
   Weight:integer;
   Code:string;
   left,right:TPNode;
   end;

   BytesWithStat = array[0..255] of TPNode;

  TWeightTable=record
   MainArray:BytesWithStat;
   ByteCount:byte;
   end;

  TFileName_=record
   Name:string;
   FSize:integer;
   FStat:TWeightTable;
   Node: TPNode;
   end;

////  Integer_ = array[1..4] of Byte;


const sizeofbuffer=1024;
var key:integer;
    FileName:string;
    ArchFile:TFileName_;
      FileIn, FileEx: file;


 procedure CreateStat(var a:TFileName_);
var
  i: Byte;
begin
 with a.FStat do
 begin
  ByteCount := 255;
  for i := 0 to ByteCount do
  begin
    New(MainArray[i]);
    with MainArray[i]^ do
    begin
      Symbol := i;
      Weight := 0;
      left := nil;
      right := nil;
    end;
  end;
  end;
end;


 procedure Statistic;
var
f:file;
i,j:integer;
buf:array[1..sizeofbuffer] of byte;
countbuf,lastbuf: integer;
readbyte:integer;
begin
 AssignFile(f,FileName);

  Reset(f,1);
  CreateStat(ArchFile);
  ArchFile.FSize:=FileSize(f);
  While not EoF(f) do
  begin
   BlockRead(f,buf,sizeofbuffer,readbyte);
   for j:=1 to readbyte do
   inc(ArchFile.FStat.MainArray[buf[j]]^.Weight);
   end;
 // for i:=1 to 255 do
 // writeln(ArchFile.FStat.MainArray[i]^.Symbol,'   ',ArchFile.FStat.MainArray[i]^.Weight);
   CloseFile(f);

end;

procedure SortMainArray(var a: BytesWithStat; LengthOfMass: byte);
var
  i, j: Byte;
  b: TPNode;
begin
  if LengthOfMass <> 0 then
    for j := 0 to LengthOfMass-1  do
    begin
      for i := 0 to LengthOfMass -1 do
      begin
        if a[i]^.Weight < a[i + 1]^.Weight then
        begin
          b := a[i];
          a[i] := a[i + 1];
          a[i + 1] := b;
        end;

      end;

    end;
end;


procedure CreateNode(var Root: TPNode; MainArray: BytesWithStat; last: byte);
var
  Node: TPNode;
begin
  if last <> 0 then
  begin
    SortMainArray(MainArray, last);
    new(Node);
    Node^.Weight := MainArray[last - 1]^.Weight + MainArray[last]^.Weight;
    Node^.left := MainArray[last - 1];
    Node^.right := MainArray[last];
    MainArray[last - 1] := Node;

    if last = 1 then
    begin
      Root := Node;
    end
    else
    begin
      CreateNode(Root, MainArray, last - 1);
    end;
  end
  else
    Root := MainArray[last];

end;

function Found(Node: TPNode; i: byte): Boolean;
begin

  if (Node = nil) then
    Found := False
  else
  begin
    if ((Node^.left = nil) or (Node^.right = nil)) and (Node^.Symbol = i) then
      Found := True
    else
      Found := Found(Node^.left, i) or Found(Node^.right, i);
  end;
end;

function HuffCodeHelp(Node: TPNode; i: Byte): string;
begin

  if (Node = nil) then
    HuffCodeHelp := '+'
  else
  begin
    if (Found(Node^.left, i)) then
      HuffCodeHelp := '0' + HuffCodeHelp(Node^.left, i)
    else
    begin
      if Found(Node^.right, i) then
        HuffCodeHelp := '1' + HuffCodeHelp(Node^.right, i)
      else
      begin
        if (Node^.left = nil) and (Node^.right = nil) and (Node^.Symbol = i) then
          HuffCodeHelp := '+'
        else
          HuffCodeHelp := '';
      end;
    end;
  end;
end;

function HuffCode(Node: TPNode; i: Byte): string;
var
  s: string;
begin
  s := HuffCodeHelp(Node, i);
 // s := s;
  if (s = '+') then
    HuffCode := '0'
  else
    HuffCode := Copy(s, 1, length(s) - 1);
end;


procedure WriteInFile(var buffer: string);
var
  i, j: Integer;
  k: Byte;
  buf: array[1..2 * SizeOfBuffer] of byte;
begin
  i := Length(buffer) div 8;
  for j := 1 to i do
  begin
    buf[j] := 0;
    for k := 1 to 8 do
    begin
      if buffer[(j - 1) * 8 + k] = '1' then

        buf[j] := buf[j] or (1 shl (8 - k));

    end;

  end;
  BlockWrite(FileEx, buf, i);
  Delete(buffer, 1, i * 8);

end;



procedure WriteInTFileName_(var buffer: string);
var
  a, k: byte;
begin
  WriteInFile(buffer);
 // if length(buffer) >= 8 then
//    Writeln('? ???????? ???-?? ?? ???...')
 // else
   if Length(buffer) <> 0 then
  begin
    a := $FF;
    for k := 1 to Length(buffer) do
      if buffer[k] = '0' then
        a := a xor (1 shl (8 - k));
    BlockWrite(FileEx, a, 1);
  end;
end;


{procedure CreateTableFile;
begin

end; }

procedure CreateTableFile;
var
TFile: File ;
s:string;
// b: Integer_;
  i: Byte;
  writeCount: Integer;
begin
  s:=FileName+'.table';

  AssignFile(TFile,s);
  Rewrite(TFile,1);
  // IntegerToByte(ArchFile.FSize, b);
 BlockWrite(TFile, ArchFile.FSize, 4);
 Writeln(ArchFile.FSize);

  BlockWrite(TFile, ArchFile.FStat.ByteCount, 1);
Writeln(ArchFile.FStat.ByteCount);
  for i := 0 to ArchFile.FStat.ByteCount do
  begin

    BlockWrite(TFile, ArchFile.FStat.MainArray[i]^.Symbol, 1);
    //write(ArchFile.FStat.MainArray[i]^.Symbol,'     ');
    //IntegerToByte(ArchFile.FStat.MainArray[i]^.Weight, b);
    BlockWrite(TFile, ArchFile.FStat.MainArray[i]^.Weight, 4);
   // writeln(ArchFile.FStat.MainArray[i]^.Weight);
  end;
  Close(TFile);
end;


procedure CreateArchiv;
var
  buffer: string;
  ArrOfStr: array[0..255] of string;
  i, j,readbyte: Integer;
  buf: array[1..SizeOfBuffer] of Byte;
  CountBuf, LastBuf: Integer;
begin

  AssignFile(FileIn, ArchFile.Name);

  Assign(FileEx,'C:\work\1.KSU');
 try
    Reset(FileIn, 1);
    Rewrite(FileEx, 1);
    for i := 0 to 255 do
      ArrOfStr[i] := '';
    for i := 0 to ArchFile.FStat.ByteCount do
    begin
      ArrOfStr[ArchFile.FStat.MainArray[i]^.Symbol] := ArchFile.FStat.MainArray[i]^.Code;
    end;
  //  for i:=1 to 255 do
  //   Writeln( ArrOfStr[i]);
   // CountBuf := ArchFile.FSize div SizeOfBuffer;
   // LastBuf := ArchFile.FSize mod SizeOfBuffer;
    buffer := '';
   CreateTableFile;

    while not EOF(FileIn) do
     begin
       BlockRead(FileIn, buf, SizeOfBuffer,readbyte);
       for j := 1 to readbyte do
      begin
        buffer := buffer + ArrOfStr[buf[j]];
        if Length(buffer) > 8 * SizeOfBuffer then
        begin
          WriteInFile(buffer);
          writeln(buffer);
          end;


      end;
     end;


    WriteInTFileName_(buffer );

  finally

    CloseFile(FileIn);
    CloseFile(FileEx);
   end;

end;

procedure DeleteNode(Root: TPNode);
begin

  if Root <> nil then
  begin
    DeleteNode(Root^.left);
    DeleteNode(Root^.right);
    Dispose(Root);
    Root := nil;
  end;
end;

procedure CreateFile;
var
i:byte;
 begin
   with ArchFile do
   begin
   SortMainArray(FStat.MainArray,FStat.ByteCount);
  // for i:=1 to 8 do
  // writeln(FStat.MainArray[i]^.Symbol,'   ',FStat.MainArray[i]^.Weight);
   i:=0;
   while (i<FStat.ByteCount) and (FStat.MainArray[i]^.Weight<>0) do inc(i);
   if FStat.MainArray[i]^.Weight=0 then dec(i);
   FStat.ByteCount:=i;
   CreateNode(Node,FStat.MainArray,FStat.ByteCount);
   for i:=0 to FStat.ByteCount do
    FStat.MainArray[i]^.Code:=HuffCode(Node,FStat.MainArray[i]^.Symbol);
    //for i:=1 to 8 do
  // writeln(FStat.MainArray[i]^.Symbol,'   ',FStat.MainArray[i]^.Weight,'  ',FStat.MainArray[i]^.Code);
    CreateArchiv;
   DeleteNode(Node);
   CreateStat(ArchFile);
    end;
 end;

procedure  archive;
begin
  ArchFile.Name:=FileName;
  Statistic;
  CreateFile;

end;

procedure ReadTable;
var
  //b: Integer_;
  SymbolSt,readByte: Integer;
  count_, SymbolId, i: Byte;
  TFile:file;
begin
  AssignFile(TFile,'C:\work\1.JPG.table');
  Reset(TFile,1);

 BlockRead(TFile, ArchFile.FSize, 4);


  BlockRead(TFile, ArchFile.FStat.ByteCount, 1);
  
  for i := 0 to ArchFile.FStat.ByteCount do
  begin

    BlockRead(TFile, ArchFile.FStat.MainArray[i]^.Symbol, 1);
    BlockRead(TFile, ArchFile.FStat.MainArray[i]^.Weight, 4);
  end;
  Close(TFile)

end;


procedure CreateDeArc;
var
  i, j: Integer;
  k,size: Byte;
  Buf: array[1..SizeOfBuffer] of Byte;
  CountBuf, LastBuf,readbyte: Integer;

  CurrentPoint: TPNode;
begin
  CurrentPoint := ArchFile.Node;
  size:=0;
  while not Eof(FileIn)  do
  begin
    BlockRead(FileIn, Buf, SizeOfBuffer,readbyte);

    for j := 1 to readbyte do
    begin

      for k := 1 to 8 do
      begin
        if (Buf[j] and (1 shl (8 - k))) <> 0 then
          CurrentPoint := CurrentPoint^.right
        else
          CurrentPoint := CurrentPoint^.left;
        if ((CurrentPoint^.left = nil) or (CurrentPoint^.right = nil))  then
        begin
          if ArchFile.FSize<>size then
          begin
          BlockWrite(FileEx,CurrentPoint^.Symbol,1);
          inc(size);
          end;
          CurrentPoint := ArchFile.Node;
        end


      end;

    end;
  end;
end;




procedure ExtractFile;
begin
  AssignFile(FileIn, ArchFile.Name);
  AssignFile(FileEx, 'C:\work\res.JPG');


    Reset(FileIn, 1);
    Rewrite(FileEx, 1);
    CreateStat(ArchFile);
    ReadTable;
    CreateNode(ArchFile.Node, ArchFile.FStat.MainArray, ArchFile.FStat.ByteCount);
    CreateDeArc;
    DeleteNode(ArchFile.Node);

    Closefile(FileIn);
    Closefile(FileEx);



  end;


procedure dearchive;
begin
  ArchFile.name := FileName;
  ExtractFile;
end;

  begin
     readln(key);
     case key of
     1: begin
       FileName:='C:\work\1.JPG';
       archive;
     end;
     2: begin
       FileName:='C:\work\1.KSU';
       dearchive;
     end;
  end;
  end.

