unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, sSkinManager, sButton, sCheckBox, sLabel, ComCtrls,
  acProgressBar, ExtCtrls,Math, sGauge;

type
  TForm1 = class(TForm)
    Head: TLabel;
    Types: TLabel;
    Label1: TLabel;
    select: TLabel;
    Note: TLabel;
    line: TLabel;
    dlgOpen: TOpenDialog;
    Memo1: TMemo;
    sknmngr1: TsSkinManager;
    Archive: TsButton;
    Dearchive: TsButton;
    RLE: TsCheckBox;
    LZW: TsCheckBox;
    Huff: TsCheckBox;
    Browse: TsButton;
    Know: TsWebLabel;
    procedure BrowseClick(Sender: TObject);
    procedure ArchiveClick(Sender: TObject);
    procedure DearchiveClick(Sender: TObject);
    procedure Formcreate(Sender: TObject);
    procedure KnowClick(Sender: TObject);


   private
    { Private declarations }
  public
    { Public declarations }
  end;


 var
  Form1: TForm1;


implementation

uses  Unit2;

const sizeofbuffer=1024;
      bord1 = 0;
      bord2 = 255;
      deep=5;
{$R *.dfm}
type
  {RLE}
    TMAS = array[1..1024] of byte;
   A = file of Byte;

  Signature = record
    name:string[6];
    crc:byte;
    size: integer;
    end;

  TLog=record
    opertype:string;
    method:string;
    Ftype:string;
    Bsize:Integer;
    Rsize:Integer;
    k:Real;
    time:Cardinal;
    result: string;
    end;

{Huffman}
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

  {LZW}

  PMAS = array [1..1024] of Byte;


  Dictionary=record
    symbol:TMAS;
    used:Boolean;
    parent:integer;
    code:integer;
    end;

  TPDic=^TDic;
 TDic = record
  info:Dictionary;
  el : array[0..255] of TPDic;
  end;

  TREC=record
   symbol:TMAS;
  count:integer;
  end;

  TElement= array[0..65535] of TREC;






var
  {RLE}
   FileIn,FileOut ,FileEx: file;
   byteArray: TMAS;
   onebyte:Byte;
   readByte,index : Integer;
   Sign:Signature;
   Start,Stop:Cardinal;
   prog:integer;
   fnumb:integer;
   {Huffman}
   ArchFile:TFileName_;
   LOG: textfile;
   logstr:TLog;
   ex:Boolean;
   information1,information2,information3:string;
   {lZW}
   FileName:string;
 Head:TPDic;
 count:integer;
 P: TMAS;
 kek:integer;
 Element:TElement;
Last_code: integer;
tree : TPDic;
i: Integer;
information:string;


Procedure HeadLog;
var
 MyDIR:string;
 begin
  MyDIR:=ExtractFileDir(Application.ExeName);
  if not DirectoryExists(MyDIR+'\LOG') then
  CreateDir(MyDIR+'\LOG');
    if not (fileExists(MyDIR+'\LOG\log.txt'))
     then
      begin
        AssignFile(LOG,MyDIR+'\LOG\log.txt');
        Rewrite(LOG);
        writeln(LOG,'-----------------------------------------------------------------------------------------');
        writeln(LOG,'|Opetarion|Metod|File type| Begin size |Result  size|Compression|   Time   |    Result  |');
        writeln(LOG,'|   type  |     |         |            |            |   ratio   |          |            |');
        writeln(LOG,'-----------------------------------------------------------------------------------------');

      end
      else
      begin
         AssignFile(LOG,MyDIR+'\LOG\log.txt');
         Append(LOG);
         if (Filesize(LOG)=0) then
          begin
           writeln(LOG,'-----------------------------------------------------------------------------------------');
           writeln(LOG,'|Opetarion|Metod|File type| Begin size |Result  size|Compression|   Time   |    Result  |');
           writeln(LOG,'|   type  |     |         |            |            |   ratio   |          |            |');
           writeln(LOG,'-----------------------------------------------------------------------------------------');
          end;

      end;

end;


{---------------RLE BLOCK-------------------------}

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


function GetNextByte:byte;
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
   inc(prog);
 result := byteArray[index];
 end;

end;



procedure  writeBlock(symbolCount:Integer; byteTypeRepeat:boolean; blockSymbols:TMAS; blockSymbolsCounter:integer);
  var symbolsWrite:integer;
  begin
   if (symbolCount > 0) AND (blockSymbolsCounter > 0)then
   begin
    onebyte:= symbolCount;
    if byteTypeRepeat then  onebyte:= onebyte+128;
    BlockWrite(FileOut, onebyte,1, symbolsWrite);
    if byteTypeRepeat then  BlockWrite(FileOut,blockSymbols[1],1, symbolsWrite)
    else
    begin
      BlockWrite(FileOut,blockSymbols,blockSymbolsCounter, symbolsWrite);
    end
   end;

  end;



procedure compressrle;
var  curr,prev:Byte;

byteTypeRepeat:Boolean;
blockSymbols : TMAS;
blockSymbolsCounter,symbolCount:Integer;
symbolRepeatCount: Integer;


  begin
    symbolCount:=1;
    symbolRepeatCount:=1;

    byteTypeRepeat:=False;
    curr:=GetNextByte;
    //sg1.Progress :=Prog;
    blockSymbolsCounter:=1;
    blockSymbols[blockSymbolsCounter]:=curr;
    prev:=curr;
    curr:=GetNextByte;
   // sg1.Progress :=Prog;
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

       prev:=curr;
      curr:=GetNextByte;
      //sg1.Progress :=Prog;

      if (byteTypeRepeat=False) AND (blockSymbolsCounter > 126) then
      begin
        {writeBlock(symbolCount, byteTypeRepeat, blockSymbols, blockSymbolsCounter);
         symbolCount:=0;
        // blockSymbolsCounter:=0;
         symbolRepeatCount:=1;
         blockSymbolsCounter:=0;
         prev:=curr+1;  }
         writeBlock(symbolCount, byteTypeRepeat, blockSymbols, blockSymbolsCounter);
         symbolCount:=1;
         blockSymbolsCounter:=1;
         symbolRepeatCount:=1;
         blockSymbols[blockSymbolsCounter]:=curr;
          prev:=curr;
          curr:=GetNextByte;

      end;

      if (byteTypeRepeat=true) AND ((blockSymbolsCounter > 126) or (symbolCount>126)) then
      begin

      {writeBlock(symbolCount, byteTypeRepeat, blockSymbols, blockSymbolsCounter);
         symbolCount:=0;
         //blockSymbolsCounter:=0;
         symbolRepeatCount:=1;
         blockSymbolsCounter:=0;
         //blockSymbols[blockSymbolsCounter]:=curr;
         //prev:=curr+1;  }
          writeBlock(symbolCount, byteTypeRepeat, blockSymbols, blockSymbolsCounter);
          symbolCount:=1;
          blockSymbolsCounter:=1;
          symbolRepeatCount:=1;
          blockSymbols[blockSymbolsCounter]:=curr;
           prev:=curr;
           curr:=GetNextByte;
      end;



      except
        ShowMessage('Error');
        ex:=False;
      end;

    end;
    if FileSize(FileIn)<>0 then
    writeBlock(symbolCount, byteTypeRepeat, blockSymbols, blockSymbolsCounter);

  end;


  procedure decompressrle;
var j,count:Integer;
     s:byte;
     curr:byte;
 begin
   curr:=GetNextByte;
   while readByte<>-1 do
    begin
      count:=curr and 127;
      s:= curr shr 7;
       if s=1 then
        begin
          curr:=GetNextByte;
          for j:=1 to count do
          BlockWrite(FileOut,curr,1);
        end
       else
        begin
          for j:=1 to count do
           begin
             curr:=GetNextByte;
             BlockWrite(FileOut,curr,1);
           end;
        end;
        curr:=GetNextByte;
    end;
 end;

 procedure WriteSign(s:string);
var
 C,B:Byte;
 m:Integer;
begin
  index:=1024;
  readByte:=1024;
Sign.name:=ExtractFileExt(s);
 AssignFile(FileIn, s);
 Reset(FileIn, 1);
 B:=GetNextByte;
 C:=0;
 while readbyte<>-1 do
 begin
   C:= C + B;
   B:=GetNextByte;
   end;
Sign.crc:=C;
CloseFile(FileIn);
end;

function check(S:String):boolean;
var
C,B:Byte;
 m:integer;

 begin
   AssignFile(FileIn, s);
   Reset(FileIn, 1);
   index:=1024;
   readbyte:=1024;
   B:=GetNextByte;
   C:=0;
   while readbyte<>-1 do
    begin
      C:= C + B;
      B:=GetNextByte;
    end;
   CloseFile(FileIn);
   if C=Sign.crc then result:=True
    else result:=False;
 end;


procedure RLECompress(FileName:string);
var
d:Real;
fn,nom:string;
position:integer;
begin
  logstr.opertype:='Archive';
  logstr.method:='RLE';
  Start:=GetTickCount;
  WriteSign(FileName);
   AssignFile(FileIn, FileName);
   try
    Reset(FileIn, 1);
     fn:=ChangeFileExt(FileName,'.rle');
  While FileExists(fn) do
  begin
   nom:='('+IntToStr(fnumb)+')';
   position:=Pos(').',fn);
   if position<>0 then
     Delete(fn, Pos('(',fn), Pos(')',fn)-Pos('(',fn)+1);
   Insert(nom, fn, Pos('.',fn));
   inc(fnumb);
   end;
    AssignFile(FileOut,fn);
    ReWrite(FileOut, 1);
    index:=1024;
    readByte:=1024;
    BlockWrite(FileOut,Sign.name,6);
    BlockWrite(FileOut,Sign.crc,1);
    compressrle;
    logstr.Ftype:=Sign.name;
    logstr.Rsize:=Filesize(FileOut);
    logstr.Bsize:=FileSize(FileIn);
    if logstr.Bsize=0 then d:=100 else
    d:=((logstr.Rsize)/(logstr.Bsize))*100;
    logstr.k:=d;
    CloseFile(FileIn);
    CloseFile(FileOut);
   except
      ShowMessage('File is anavailable');
      ex:=False;
      DeleteFile(ChangeFileExt(FileName,'.rle'));
end;
Stop:=GetTickCount;
logstr.time:=Stop-Start;
if ex=True then
logstr.result:='successfull'
else logstr.result:='Failed';
Write(LOG,'|');
Write(LOG,logstr.opertype:9,'|');
Write(LOG,logstr.method:5,'|');
Write(LOG,logstr.Ftype:9,'|');
Write(LOG,logstr.Bsize:11,'B|');
Write(LOG,logstr.Rsize:11,'B|');
Write(LOG,logstr.k:11:3,'|');
Write(LOG,logstr.time:10,'ms|');
Writeln(LOG,logstr.result:11,'|');
information1:='Source file size '+IntToStr(logstr.Bsize)+' B'+#13+'Output file size '+IntToStr(logstr.Rsize)+' B'+#13+'Compression ratio '+FloatToStr(Roundto(logstr.k,-3))+#13+'Operation time '+IntToStr(logstr.time)+' ms';
end;

procedure RLEDecompress(FileName:string);
var d:real;
 fn,nom:string;
position:integer;
begin
  logstr.opertype:='Dearchive';
  logstr.method:='RLE';
  Start:=GetTickCount;
  AssignFile(FileIn,FileName);
  try
  Reset(FileIn, 1);
    BlockRead(FileIn,Sign.name,6);
    BlockRead(FileIn,Sign.crc,1);
    fn:=ChangeFileExt(FileName,Sign.name);
  While FileExists(fn) do
  begin
   nom:='('+IntToStr(fnumb)+')';
   position:=Pos(').',fn);
   if position<>0 then
     Delete(fn, Pos('(',fn), Pos(')',fn)-Pos('(',fn)+1);
   Insert(nom, fn, Pos('.',fn));
   inc(fnumb);
   end;
    AssignFile(FileOut,fn);
    ReWrite(FileOut, 1);
    index:=1024;
    readByte:=1024;
    logstr.Ftype:=Sign.name;
    decompressrle;
    logstr.Rsize:=Filesize(FileOut);
    logstr.Bsize:=FileSize(FileIn);
    if logstr.Bsize=0 then d:=100 else
    d:=((logstr.Rsize)/(logstr.Bsize))*100;
    logstr.k:=d;
    CloseFile(FileIn);
    CloseFile(FileOut);
    if Check(ChangeFileExt(FileName,Sign.name)) then
    begin
    // ShowMessage('Dearchiving successful');
     ex:=true;
     end
    else
    begin
    ShowMessage('The file is damaged');
     DeleteFile(fn);
     ex:=false;
    end;
  except
  ShowMessage('File is anavailable');
   DeleteFile(fn);
  ex:=false;
end;
Stop:=GetTickCount;
logstr.time:=Stop-Start;
if ex=True then
logstr.result:='successfull'
else logstr.result:='Failed';
Write(LOG,'|');
Write(LOG,logstr.opertype:9,'|');
Write(LOG,logstr.method:5,'|');
Write(LOG,logstr.Ftype:9,'|');
Write(LOG,logstr.Bsize:11,'B|');
Write(LOG,logstr.Rsize:11,'B|');
Write(LOG,'':11,'|');
Write(LOG,logstr.time:10,'ms|');
Writeln(LOG,logstr.result:11,'|');
 if ex=True then
  begin
   information:='Source file size '+IntToStr(logstr.Bsize)+' B'+#13+'Output file size '+IntToStr(logstr.Rsize)+' B'+#13+'Operation time '+IntToStr(logstr.time)+' ms';
   ShowMessage('      Dearchiving succesfull'+#13+information);
  end;
end;

{---------------RLE BLOCK-------------------------}



{-------------HUFFMAN BLOCK----------------------}
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
 AssignFile(f,ArchFile.Name);
  try
  Reset(f,1);
  CreateStat(ArchFile);
  ArchFile.FSize:=FileSize(f);
  While not EoF(f) do
  begin
   BlockRead(f,buf,sizeofbuffer,readbyte);
   for j:=1 to readbyte do
   inc(ArchFile.FStat.MainArray[buf[j]]^.Weight);
   end;
   CloseFile(f);
 except
 ShowMessage('File is anavailable');
 Ex:=false;
 DeleteFile(ChangeFileExt(ArchFile.Name,'.huff'));
  end;
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
   if Length(buffer) <> 0 then
  begin
    a := $FF;
    for k := 1 to Length(buffer) do
      if buffer[k] = '0' then
        a := a xor (1 shl (8 - k));
    BlockWrite(FileEx, a, 1);
  end;
end;



procedure CreateTable;
var
TFile: File ;
s,fn,nom:string;
position:Integer;
  i: Byte;
  writeCount: Integer;
begin
  fnumb:=1;
  fn:=ChangeFileExt(ArchFile.Name,'.hufftable');
  While FileExists(fn) do
  begin
   nom:='('+IntToStr(fnumb)+')';
   position:=Pos(').',fn);
   if position<>0 then
     Delete(fn, Pos('(',fn), Pos(')',fn)-Pos('(',fn)+1);
   Insert(nom, fn, Pos('.',fn));
   inc(fnumb);
   end;
  AssignFile(TFile,fn);
  Rewrite(TFile,1);
  if fileSize(FileIn)<>0 then
  begin
   BlockWrite(TFile, ArchFile.FSize, 4);
   BlockWrite(TFile, ArchFile.FStat.ByteCount, 1);
  for i := 0 to ArchFile.FStat.ByteCount do
  begin

    BlockWrite(TFile, ArchFile.FStat.MainArray[i]^.Symbol, 1);
    BlockWrite(TFile, ArchFile.FStat.MainArray[i]^.Weight, 4);
  end;
  end;
  Close(TFile);
  fnumb:=1;
end;


procedure CreateArchiv;
var
  buffer: string;
  ArrOfStr: array[0..255] of string;
  i, j,readbytea,b,a: Integer;
  buf: array[1..SizeOfBuffer] of Byte;
  CountBuf, LastBuf: Integer;
  d:Real;
  fn,nom:string;
  position:Real;
begin
  AssignFile(FileIn, ArchFile.Name);
  fn:=ChangeFileExt(ArchFile.Name,'.huff');
  While FileExists(fn) do
  begin
   nom:='('+IntToStr(fnumb)+')';
   position:=Pos(').',fn);
   if position<>0 then
     Delete(fn, Pos('(',fn), Pos(')',fn)-Pos('(',fn)+1);
   Insert(nom, fn, Pos('.',fn));
   inc(fnumb);
   end;
  Assign(FileEx,fn);
 try
    Reset(FileIn, 1);
    Rewrite(FileEx, 1);
    BlockWrite(FileEx,Sign.Name,6);
    BlockWrite(FileEx,Sign.crc,1);
    logstr.Ftype:=Sign.name;
    logstr.Bsize:=FileSize(FileIn);
    for i := 0 to 255 do
      ArrOfStr[i] := '';
    for i := 0 to ArchFile.FStat.ByteCount do
    begin
      ArrOfStr[ArchFile.FStat.MainArray[i]^.Symbol] := ArchFile.FStat.MainArray[i]^.Code;
    end;
    buffer := '';

     CreateTable;
    if Filesize(Filein)<>0 then
    begin
    while not EOF(FileIn) do
     begin
       BlockRead(FileIn, buf, SizeOfBuffer,readbyte);
       for j := 1 to readbyte do
      begin
        buffer := buffer + ArrOfStr[buf[j]];
        if Length(buffer) > 8 * SizeOfBuffer then
        begin
          WriteInFile(buffer)
          end;


      end;
     end;


    WriteInTFileName_(buffer );
    end;
    logstr.Rsize:=Filesize(FileEx);
     if logstr.Bsize=0 then d:=100 else
    d:=((logstr.Rsize)/(logstr.Bsize))*100;
    logstr.k:=d;
    CloseFile(FileIn);
    CloseFile(FileEx);
   except
    ShowMessage('File is anavailable');
    DeleteFile(fn);
    ex:=false;
   end;
 Stop:=GetTickCount;
logstr.time:=Stop-Start;
if ex=True then
logstr.result:='successfull'
else logstr.result:='Failed';
Write(LOG,'|');
Write(LOG,logstr.opertype:9,'|');
Write(LOG,logstr.method:5,'|');
Write(LOG,logstr.Ftype:9,'|');
Write(LOG,logstr.Bsize:11,'B|');
Write(LOG,logstr.Rsize:11,'B|');
Write(LOG,logstr.k:11:3,'|');
Write(LOG,logstr.time:10,'ms|');
Writeln(LOG,logstr.result:11,'|');
information2:='Source file size '+IntToStr(logstr.Bsize)+' B'+#13+'Output file size '+IntToStr(logstr.Rsize)+' B'+#13+'Compression ratio '+FloatToStr(RoundTo((logstr.k),-3))+#13+'Operation time '+IntToStr(logstr.time)+' ms';
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

   begin
   SortMainArray(FStat.MainArray,FStat.ByteCount);
   i:=0;
   while (i<FStat.ByteCount) and (FStat.MainArray[i]^.Weight<>0) do inc(i);
   if FStat.MainArray[i]^.Weight=0 then dec(i);
   FStat.ByteCount:=i;
   CreateNode(Node,FStat.MainArray,FStat.ByteCount);
   for i:=0 to FStat.ByteCount do
    FStat.MainArray[i]^.Code:=HuffCode(Node,FStat.MainArray[i]^.Symbol);
   
    CreateArchiv;
   DeleteNode(Node);
   CreateStat(ArchFile);
    end;
 end;
end;
procedure  Huffarchive(FileName:string);
begin

  logstr.opertype:='Archive';
  logstr.method:='Huf';
  Start:=GetTickCount;
  ArchFile.Name:=FileName;
  WriteSign(FileName);
  Statistic;
  CreateFile;

end;

procedure ReadTable;
var
  i: Byte;
  TFile:file;
begin


  AssignFile(TFile,ChangeFileExt(ArchFile.Name,'.hufftable'));
  If FileExists(ChangeFileExt(ArchFile.Name,'.hufftable')) then
   begin
  Reset(TFile,1);
  while not EOF(TFile) do
   begin
  BlockRead(TFile, ArchFile.FSize, 4);
  BlockRead(TFile, ArchFile.FStat.ByteCount, 1);

  for i := 0 to ArchFile.FStat.ByteCount do
  begin

    BlockRead(TFile, ArchFile.FStat.MainArray[i]^.Symbol, 1);
    BlockRead(TFile, ArchFile.FStat.MainArray[i]^.Weight, 4);
  end;
   end;
  Close(TFile);
   end
   else
   begin
    ShowMessage('No table File to dearchive');
    DeleteFile(ChangeFileExt(ArchFile.Name,'.hufftable'));
    ex:=false;
  end;

end;


procedure CreateDeArc;
var
   j: Integer;
  k,size: Byte;
  Buf: array[1..SizeOfBuffer] of Byte;
  readbyte: Integer;
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
        if ArchFile.FStat.ByteCount=0 then
        begin
           if ((CurrentPoint^.left = nil) or (CurrentPoint^.right = nil))  then
        begin
          if ArchFile.FSize<>size then
          begin
          BlockWrite(FileEx,CurrentPoint^.Symbol,1);
          inc(size);
          end;
          CurrentPoint := ArchFile.Node;
        end ;

        end
        else
        if CurrentPoint<> nil then
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
        

        end;
        end;
      end;

    end;
  end;
end;




procedure ExtractFile(var fn:string);
var d:Real;
nom:string;
position:integer;
begin
  AssignFile(FileIn, ArchFile.Name);
   try
  Reset(FileIn, 1);
  BlockRead(FileIn,Sign.name,6);
  BlockRead(FileIn,Sign.crc,1);
  fn:=ChangeFileExt(ArchFile.Name,Sign.name);
  While FileExists(fn) do
  begin
   nom:='('+IntToStr(fnumb)+')';
   position:=Pos(').',fn);
   if position<>0 then
     Delete(fn, Pos('(',fn), Pos(')',fn)-Pos('(',fn)+1);
   Insert(nom, fn, Pos('.',fn));
   inc(fnumb);
   end;
    Assign(FileEx,fn);
    Rewrite(FileEx, 1);
    CreateStat(ArchFile);
    ReadTable;
    CreateNode(ArchFile.Node, ArchFile.FStat.MainArray, ArchFile.FStat.ByteCount);
    logstr.Ftype:=Sign.name;
    CreateDeArc;
    logstr.Rsize:=Filesize(FileEx);
    logstr.Bsize:=FileSize(FileIn);
    if logstr.Bsize=0 then d:=100 else
    d:=((logstr.Rsize)/(logstr.Bsize))*100;
    logstr.k:=d;
    DeleteNode(ArchFile.Node);

    Closefile(FileIn);
    Closefile(FileEx);
  except
   ShowMessage('File is anavailable');
   DeleteFile(fn);
   ex:=false;
  end;
Stop:=GetTickCount;
logstr.time:=Stop-Start;
if ex=True then
logstr.result:='successfull'
else logstr.result:='Failed';
Write(LOG,'|');
Write(LOG,logstr.opertype:9,'|');
Write(LOG,logstr.method:5,'|');
Write(LOG,logstr.Ftype:9,'|');
Write(LOG,logstr.Bsize:11,'B|');
Write(LOG,logstr.Rsize:11,'B|');
Write(LOG,'':11,'|');
Write(LOG,logstr.time:10,'ms|');
Writeln(LOG,logstr.result:11,'|');
end;


procedure Huffdearchive(FileName:string);
var fn:string;
begin
  logstr.opertype:='Dearchive';
  logstr.method:='Huf';
  Start:=GetTickCount;
  ArchFile.name := FileName;
  ExtractFile(fn);
  if Check(ChangeFileExt(ArchFile.Name,Sign.name)) then
  begin
    if ex=True then
  begin
   information:='Source file size '+IntToStr(logstr.Bsize)+' B'+#13+'Output file size '+IntToStr(logstr.Rsize)+' B'+#13+'Operation time '+IntToStr(logstr.time)+' ms';
   ShowMessage('      Dearchiving succesfull'+#13+information);
  end;
  end
    // ShowMessage('Dearchiving successful')
  else
  begin
  ShowMessage('The file is damaged');
  DeleteFile(fn);
   end;
end;
{-------------HUFFMAN BLOCK----------------------}





{-------------------LZW BLOCK----------------------}
procedure free;
 var  symb:integer;
      Tree:TPDic;
 procedure FreeSymbol(var Tree:TPDic);
 var j:integer;
begin
if Tree=nil then exit;
for j:=bord1 to bord2 do
if Tree^.el[j]<>nil then FreeSymbol(Tree^.el[j]);
Tree:=nil;
end;
 var i:integer;
   begin
     Tree:=Head;
     for symb:=bord1 to bord2 do
      begin
         FreeSymbol(tree^.el[symb]);
      end;
    for i:=bord1 to bord2 do
    if Tree^.el[i]<>nil then
    Tree^.el[i]:=nil;
    Tree:=nil;
   end;

 {function GetNextByte:integer ;
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

  inc(kek);
    Inc(index);
 result := byteArray[index];
 end;

 end;    }



 function Foundlzw(var Tree:TPDic; s:TMAS;count:Integer;prev: integer): Integer;
var NotFindLetter: Boolean;
function MainPart(var Tree:TPDic; s:TMAS;count:Integer; prev: integer): Integer;
 var i:integer;
begin
if Tree = nil then
begin
NotFindLetter:=True;
result:=-1;
end;
if (count>1) and not NotFindLetter then
begin
prev:=Tree^.info.code;
for i:=1 to count-1 do
s[i]:=s[i+1];
result:=MainPart(Tree^.el[s[1]],s,count-1, prev);
end
else if not NotFindLetter then
begin
prev:=Tree^.info.code;
result:=Tree^.info.code;
end;
end;

begin
NotFindLetter:= False;
result:=MainPart(Tree,s,count, prev);
end;


 function NewNodeForSymb: TPDic;
var
Node:TPDic;
i:integer;
begin
New(Node);
for i:=bord1 to bord2 do Node^.el[i]:=nil;
NewNodeForSymb:=Node;
end;

 procedure SingleSymbols(var Tree:TPDic; s:string);

var letter: Byte;

begin
if Tree = nil then
begin
Tree := NewNodeForSymb;
end;

if s='' then
Tree^.info.code:=Letter
else
begin
Letter:=Ord(s[1]);
SingleSymbols(Tree^.el[Ord(s[1])],copy(s,2,length(s)-1));
end;
end;

function NewNodeForWord(var last_code: integer ):TPDic;

var
Node:TPDic;
i:integer;

begin
New(Node);
Node^.info.code:=last_code;
Inc(last_code);
for i:=bord1 to bord2 do Node^.el[i]:=nil;
NewNodeForWord:=Node;
end;



procedure Add(var Tree:TPDic; s:TMAS;count:Integer;var last_code: integer);

var
FAddLetter: Boolean;


procedure MainPart (var Tree: TPDic; s: TMAS;count:Integer; var last_code: integer);

begin
while (count<>0) and FAddLetter do
begin
if (Tree = nil) then
begin
Tree := NewNodeForWord(Last_code);
FAddLetter:=False;
end
else
begin
  for i:=1 to count-1 do
s[i]:=s[i+1];
MainPart(Tree^.el[s[1]],s,count-1,last_code);
end;
end;
FAddLetter:=False;
end;

begin
FAddLetter:=True;
MainPart(Tree,s,count,last_code);
end;


 procedure CreateTableFile(FileName:string);
 var TFile:file;
  A:TMAS;
  fn,nom:string;
position:integer;
  procedure MainPart(Tree:TPDic; count:Integer; A:TMAS);
  var i,j,c:Integer;

   begin
     for i:=bord1 to bord2 do
      begin
       if  (Tree^.el[i]<> nil) then
        begin
          c:=count;
         Inc(c);
         A[c]:=i;

            BlockWrite(TFile,Tree^.el[i]^.info.code,2);
            BlockWrite(TFile,c,2);
          for j:=1 to c do
           begin
             BlockWrite(TFile,A[j],1);
           end;
        
         MainPart(Tree^.el[i],c,A);
        end
      end;
   end;
 begin
   fnumb:=1;
   fn:=ChangeFileExt(FileName,'.lzwtable');
  While FileExists(fn) do
  begin
   nom:='('+IntToStr(fnumb)+')';
   position:=Pos(').',fn);
   if position<>0 then
     Delete(fn, Pos('(',fn), Pos(')',fn)-Pos('(',fn)+1);
   Insert(nom, fn, Pos('.',fn));
   inc(fnumb);
   end;
    AssignFile(TFile,fn);
  Rewrite(TFile,1);
  MainPart(Head,0,A);
  Close(TFile);
  fnumb:=1;
 end;

 procedure ReadTableFile(FileName:string);
 var
 i,s,j: integer;
 b,a:byte;
 begin
  AssignFile(FileIn,ChangeFileExt(FileName,'.lzwtable'));
 
    If FileExists(ChangeFileExt(FileName,'.lzwtable')) then
    begin
  Reset(FileIn,1);
  index:=1024;
  readbyte:=1024;
  kek:=1;
  a:=GetNextByte;
  b:=GetNextByte;
      while readbyte<>-1 do
        begin
         i:=b;
         i:=i shl 8;
         i:=i+a;
         a:=GetNextByte;
         b:=GetNextByte;
         s:=b;
         s:=s shl 8;
         s:=s+a;
         Element[i].count:=s;
         for j:=1 to  Element[i].count do
           begin
          Element[i].symbol[j]:=GetNextByte;
           end;

         a:=GetNextByte;
         b:=GetNextByte;
        end;
       CloseFile(FileIn);
    end
   else
   begin
     ShowMessage('No table File to dearchive');
    DeleteFile(ChangeFileExt(FileName,'.lzwtable'));
    ex:=false;
   end;
  end;

 procedure LZWDeArchiv(FileName:string);
var a,b:Byte;
i,c:integer;
d:Real;
fn,nom:string;
position:integer;
 begin
  logstr.opertype:='Dearchive';
  logstr.method:='lzw';
  Start:=GetTickCount;
   ReadTableFile(FileName);
  AssignFile(FileIn,FileName);
  try
  Reset(FileIn,1);
  BlockRead(FileIn,Sign.name,6);
  BlockRead(FileIn,Sign.crc,1);
  fn:=ChangeFileExt(FileName,Sign.name);
  While FileExists(fn) do
  begin
   nom:='('+IntToStr(fnumb)+')';
   position:=Pos(').',fn);
   if position<>0 then
     Delete(fn, Pos('(',fn), Pos(')',fn)-Pos('(',fn)+1);
   Insert(nom, fn, Pos('.',fn));
   inc(fnumb);
   end;
    AssignFile(FileEx,fn);
  Rewrite(FileEx,1);
  logstr.Ftype:=Sign.name;
  while not Eof(FileIn) do
   begin
     BlockRead(FileIn,c,2,readByte);
     for i:=1 to Element[c].count do
     BlockWrite(FileEx,Element[c].symbol[i],1);

     end;
    logstr.Rsize:=Filesize(FileEx);
    logstr.Bsize:=FileSize(FileIn);
    if logstr.Bsize=0 then d:=100 else
    d:=((logstr.Rsize)/(logstr.Bsize))*100;
    logstr.k:=d;
   Close(FileIn);
   Close(FileEx);
   if Check(ChangeFileExt(FileName,Sign.name)) then
     ex:=True
  else
  begin
  ShowMessage('The file is damaged');
  DeleteFile(fn);
  ex:=False;
   end;
  except
    ShowMessage('File is anavailable');
   DeleteFile(fn);
   ex:=false;
   end;
  Stop:=GetTickCount;
  logstr.time:=Stop-Start;
   if ex=True then
    logstr.result:='successfull'
   else logstr.result:='Failed';
  Write(LOG,'|');
  Write(LOG,logstr.opertype:9,'|');
  Write(LOG,logstr.method:5,'|');
  Write(LOG,logstr.Ftype:9,'|');
  Write(LOG,logstr.Bsize:11,'B|');
  Write(LOG,logstr.Rsize:11,'B|');
  Write(LOG,'':11,'|');
  Write(LOG,logstr.time:10,'ms|');
  Writeln(LOG,logstr.result:11,'|');
  if ex=True then
  begin
   information:='Source file size '+IntToStr(logstr.Bsize)+' B'+#13+'Output file size '+IntToStr(logstr.Rsize)+' B'+#13+'Operation time '+IntToStr(logstr.time)+' ms';
   ShowMessage('      Dearchiving succesfull'+#13+information);
  end;
 end;

 

procedure maketrue(a:integer);
var flag:Boolean;
  procedure MainPart(Curr:TPDic; a:integer);
  var i:Integer;


   begin
     if flag then
     begin
     for i:=bord1 to bord2 do
      begin
       if  (Curr^.el[i]<> nil) then
        begin
         if Curr^.el[i]^.info.code=a then
            begin
              Curr^.el[i]^.info.used:=True;
              flag:=False;
            end;

         MainPart(Curr^.el[i],A);
        end
        else
        //count:=1;
      end;
     end;
   end;
 begin
  // AssignFile(TFile,'Table.LZW');
  // Reset(TFile,1);
  flag:=true;
   MainPart(Head,a);
 end;



procedure LZWArchiv(FileName:string);
var i:Integer;
a,b:integer;
d:real;
prev: integer;
fn,nom:string;
position:integer;
begin
  logstr.opertype:='Archive';
  logstr.method:='lzw';
  Start:=GetTickCount;
  WriteSign(FileName);
  New(Tree);
  Head:=tree;
  for i:=bord1 to bord2 do Tree^.el[i]:=nil;
  AssignFile(FileIn,FileName);
 try
  fn:=ChangeFileExt(FileName,'.lzw');
  While FileExists(fn) do
  begin
   nom:='('+IntToStr(fnumb)+')';
   position:=Pos(').',fn);
   if position<>0 then
     Delete(fn, Pos('(',fn), Pos(')',fn)-Pos('(',fn)+1);
   Insert(nom, fn, Pos('.',fn));
   inc(fnumb);
   end;
    AssignFile(FileEx,fn);
  Reset(FileIn,1);
  Rewrite(FileEx,1);
  BlockWrite(FileEx,Sign.Name,6);
  BlockWrite(FileEx,Sign.crc,1);
  logstr.Ftype:=Sign.name;
  logstr.Bsize:=FileSize(FileIn);
  index:=1024;
  readbyte:=1024;
  last_code:=1;
  P[1]:=GetNextByte;
  count:=1;
  a:=-1;
  while readByte<>-1 do
  begin
   if Last_code<65000 then
   begin
    b:=Foundlzw(Tree^.el[P[1]],P,count,prev);

    if b=-1 then
    begin

      if a <> -1 then
      begin
        BlockWrite(FileEx, a, 2);
      end;
      if count<=deep then
      Add(tree^.el[P[1]],P,count,Last_code);
      P[1]:=P[count];
      count:=1;
      a:=Foundlzw(Tree^.el[P[1]],P,count,prev);
    end
    else a:=b;
    if a<>-1 then
    begin
    inc(count);
    P[count]:=GetNextByte;
    end;
   end

    else
     begin
       b:=Foundlzw(Tree^.el[P[1]],P,count,prev);
        if b=-1 then
         begin
           BlockWrite(FileEx, a, 2);
            P[1]:=P[count];
            count:=1;
            a:=Foundlzw(Tree^.el[P[1]],P,count,prev);
         end
        else a:=b ;
      inc(count);
      P[count]:=GetNextByte;
     end;
  end;
  if FileSize(FileIn)<>0 then
  begin
  a:=Foundlzw(Tree^.el[P[1]],P,count-1,prev);
  BlockWrite(FileEx,a,2);
  end;
  CreateTableFile(FileName);
  logstr.Rsize:=Filesize(FileEx);
  if logstr.Bsize=0 then d:=100 else
  d:=((logstr.Rsize)/(logstr.Bsize))*100;
  logstr.k:=d;
  Close(FileIn);
  Close(FileEx);
  free;
 except
      ShowMessage('File is anavailable');
      ex:=False;
      DeleteFile(ChangeFileExt(FileName,'.lzw'));
 end;
 logstr.time:=Stop-Start;
if ex=True then
logstr.result:='successfull'
else logstr.result:='Failed';
Write(LOG,'|');
Write(LOG,logstr.opertype:9,'|');
Write(LOG,logstr.method:5,'|');
Write(LOG,logstr.Ftype:9,'|');
Write(LOG,logstr.Bsize:11,'B|');
Write(LOG,logstr.Rsize:11,'B|');
Write(LOG,logstr.k:11:3,'|');
Write(LOG,logstr.time:10,'ms|');
Writeln(LOG,logstr.result:11,'|');
information3:='Source file size '+IntToStr(logstr.Bsize)+' B'+#13+'Output file size '+IntToStr(logstr.Rsize)+' B'+#13+'Compression ratio '+FloatToStr(RoundTo((logstr.k),-3))+#13+'Operation time '+IntToStr(logstr.time)+' ms';
end;


{-------------------LZW BLOCK----------------------}



procedure TForm1.BrowseClick(Sender: TObject);
begin
  memo1.Text:='';
  try
    if dlgOpen.Execute then
    begin
      Memo1.Text:=dlgOpen.FileName;
      //dlgOpen.Free;
    end;
    except MessageDlg('error', mtError, [mbOK], 0);
  end;

end;


procedure TForm1.ArchiveClick(Sender: TObject);
var f:file;
size,col:Integer;
n1,n2,n3,mess:string;
begin
  HeadLog;
 ex:=True;

 if FileExists(Memo1.Text) then
  begin
   AssignFile(f,Memo1.Text);
   Reset(f,1);
   Size:=FileSize(f);
   CloseFile(f);
    mess:='';
    Prog:=0;

   if RLE.Checked then
       begin
        fnumb:=1;
        RLECompress(Memo1.Text);
        n1:='       RLE';
       end;
   if Huff.Checked then
       begin
        fnumb:=1;
        Huffarchive(Memo1.Text);
       n2:='      Huffman';
       end;
   if LZW.Checked then
      begin
        fnumb:=1;
        LZWArchiv(Memo1.Text);
        n3:='       LZW';
      end;
   if (RLE.Checked=false) and (Huff.Checked=False) and (LZW.Checked=false) then
        ShowMessage('You haven''t select any technique.')
   else  if ex=True then
       begin
         if RLE.Checked then mess:=mess+#13+n1+' archiving succesflull      '+#13+information1;
         if Huff.Checked then mess:=mess+#13+n2+' archiving succesflull      '+#13+information2;
         if LZW.Checked then mess:=mess+#13+n3+' archiving succesflull      '+#13+information3;
        ShowMessage(mess);
       end
     else   ShowMessage('Something went wrong, archiving is anavailable')
  end
 else ShowMessage('Such file does not exists.');
  CloseFile(LOG);
end;

procedure TForm1.DearchiveClick(Sender: TObject);
begin
  HeadLog;
  ex:=True;
  if FileExists(Memo1.Text) then
   begin

    if ExtractFileExt(Memo1.Text)='.rle' then
    begin
      fnumb:=1;
      RLEDecompress(Memo1.Text);
       end
    else
    if ExtractFileExt(Memo1.Text)='.huff' then
    begin
      fnumb:=1;
      Huffdearchive(Memo1.Text);
     end
    else
    if ExtractFileExt(Memo1.Text)='.lzw' then
    begin
      fnumb:=1;
      LZWdearchiv(Memo1.Text) ;
    end
    else ShowMessage('Non archive file extension');
   end
  else ShowMessage('Such file does not exists.');
  CloseFile(LOG);
end;



procedure TForm1.FormCreate(Sender: TObject);
begin

Form1.Height:= 650;
Form1.Width:= 1024;
sknmngr1.SkinDirectory:=extractfilepath(application.ExeName);
sknmngr1.SkinName:='Topaz';
sknmngr1.Active:=true;
Memo1.Text:='';
end;



procedure TForm1.KnowClick(Sender: TObject);
begin
Form2.Show;
end;

end.