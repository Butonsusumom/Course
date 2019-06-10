program SkyArchiver;



uses
  Forms,
  Windows,
  MainUnit in 'MainUnit.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  //Application.CreateForm(TAdd_OutForm, Add_OutForm);
  Application.Run;
end.
