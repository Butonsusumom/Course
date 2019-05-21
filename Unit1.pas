unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Head: TLabel;
    Types: TLabel;
    Label1: TLabel;
    select: TLabel;
    Note: TLabel;
    status: TLabel;
    line: TLabel;
    dlgOpen: TOpenDialog;
    RLE: TCheckBox;
    LZW: TCheckBox;
    Huff: TCheckBox;
    Archiv: TButton;
    Dearchiv: TButton;
    Memo1: TMemo;
    Know: TLabel;
    Browse: TButton;
    procedure BrowseClick(Sender: TObject);
    procedure ArchivClick(Sender: TObject);
    procedure DearchivClick(Sender: TObject);
     private
    { Private declarations }
  public
    { Public declarations }
  end;


 var
  Form1: TForm1;

implementation

{$R *.dfm}
type
    TMAS = array[1..1024] of byte;
   A = file of Byte;

  Signature = record
    name:string[6];
    crc:byte;
    end;
var   FileName:string;
   s : string;
  FileIn,FileOut ,f: file;
  byteArray,singelements : TMAS;
  onebyte:Byte;
  readByte,key,index : Integer;
  Sign:Signature;

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
 result := byteArray[index];
 end;

end;



procedure  writeBlock(symbolCount:Integer; byteTypeRepeat:boolean; blockSymbols:TMAS; blockSymbolsCounter:integer);
var i:integer;
  begin
     if (symbolCount <> 0) AND (blockSymbolsCounter <> 0)then
     begin
      onebyte:= symbolCount;
      if byteTypeRepeat then  onebyte:= onebyte+128;
      BlockWrite(FileOut, onebyte,1);
      if byteTypeRepeat then  BlockWrite(FileOut,blockSymbols[1],1)
      else
        BlockWrite(FileOut,blockSymbols,blockSymbolsCounter);
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
    blockSymbolsCounter:=1;
    blockSymbols[blockSymbolsCounter]:=curr;
    prev:=curr;
    curr:=GetNextByte;

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
      curr:=GetNextByte;
      except
        ShowMessage('Error');
      end;

    end;
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
 C:Byte;
begin
  index:=1024;
  readByte:=1024;
Sign.name:=ExtractFileExt(s);
 AssignFile(FileIn, s);
 Reset(FileIn, 1);
 C:=GetNextByte;
 while readbyte<>-1 do
   C:= C xor GetNextByte;
Sign.crc:=C;
CloseFile(FileIn);
end;

function check(S:String):boolean;
var
C:Byte;
 begin
   AssignFile(FileIn, s);
   Reset(FileIn, 1);
   index:=1024;
   readbyte:=1024;
   C:=GetNextByte;
   while readbyte<>-1 do
   C:= C xor GetNextByte;
   CloseFile(FileIn);
   if C=Sign.crc then result:=True
    else result:=False;
 end;


procedure RLECompress(FileName:string);
begin
  WriteSign(FileName);
   AssignFile(FileIn, FileName);
   try
    Reset(FileIn, 1);
    AssignFile(FileOut,ChangeFileExt(FileName,'.rle'));
    ReWrite(FileOut, 1);
    index:=1024;
    readByte:=1024;
    BlockWrite(FileOut,Sign.name,6);
    BlockWrite(FileOut,Sign.crc,1);
    compressrle;
    CloseFile(FileIn);
    CloseFile(FileOut);
   except
      ShowMessage('File is anavailable');
end;
end;

procedure RLEDecompress(FileName:string);
begin
  AssignFile(FileIn,FileName);
  try
  Reset(FileIn, 1);
    BlockRead(FileIn,Sign.name,6);
    BlockRead(FileIn,Sign.crc,1);
    AssignFile(FileOut,ChangeFileExt(FileName,Sign.name) );
    ReWrite(FileOut, 1);
      index:=1024;
  readByte:=1024;
      decompressrle;
    CloseFile(FileIn);
    CloseFile(FileOut);
    if Check(ChangeFileExt(FileName,Sign.name)) then
     ShowMessage('Dearchiving successful')
    else ShowMessage('The file is damaged');
  except ShowMessage('File is anavailable');
end;
end;

{---------------RLE BLOCK-------------------------}







procedure TForm1.BrowseClick(Sender: TObject);
begin
   if dlgOpen.Execute then
begin
  Memo1.Text:=dlgOpen.FileName;
end;

end;


procedure TForm1.ArchivClick(Sender: TObject);
begin
 if FileExists(Memo1.Text) then
  begin
   if RLE.Checked then
        RLECompress(Memo1.Text);
   if (RLE.Checked=false) and (Huff.Checked=False) and (LZW.Checked=false) then
        ShowMessage('You haven''t select any technique.')
   else ShowMessage('Archiving successful');
  end
 else ShowMessage('Such file does not exists.');
end;

procedure TForm1.DearchivClick(Sender: TObject);
begin
  if FileExists(Memo1.Text) then
   begin
    if ExtractFileExt(Memo1.Text)='.rle' then
      RLEDecompress(Memo1.Text);
   end
  else ShowMessage('Such file does not exists.');
end;

end.