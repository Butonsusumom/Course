unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, sMemo, sLabel, sScrollBar, ImgList, ExtCtrls;

type
  TForm2 = class(TForm)
    Know1: TsLabel;
    Know2: TsLabel;
    Know3: TsLabel;
    Know4: TsLabel;
    Know5: TsLabel;
    Know6: TsLabel;
    Know7: TsLabel;
    Know8: TsLabel;
    Know9: TsLabel;
    Know10: TsLabel;
    Know11: TsLabel;
    Know12: TsLabel;
    img1: TImage;
    procedure FormCreate(Sender: TObject);



  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses MainUnit;

{$R *.dfm}


procedure TForm2.FormCreate(Sender: TObject);
begin
Form2.Height:= 750;
Form2.Width:= 650;
form2.VertScrollBar.Tracking:=true;
end;






end.
