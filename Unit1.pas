unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, XPMan, ExtCtrls, Menus, ComCtrls;

type
  first=array [-1..9,-1..9] of integer;{тип основного массива}
  second=array [0..81,1..2] of integer;{тип буферного массива}

type
  TForm1 = class(TForm)
    Fon: TImage;
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Create(x,y,c:integer);
    procedure New(count:integer);
    procedure Click(Sender: TObject);
    procedure Restart;
    procedure Enter(e1,e2:boolean);
    procedure Wave(x1,y1:integer);
    procedure Data(sc,ndl:integer);
    procedure DestroyLines;
    procedure DestroySpheres(x,y,kol,i,j:integer);
    function Find(x,y:integer):TImage;
    function EmptyPos(aEP:first):integer;
    function FindLine(x,y,i,j:integer):integer;
    function ExitMap(x,y:integer):boolean;
    procedure N8Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  hw:integer=30;

var
  Form1:TForm1;
  a:first;
  b1:second;
  bb1:integer;
  b2:second;
  bb2:integer;
  b1b2:boolean;
  move,k:integer;
  way:boolean;
  img:TImage;
  mainflag:boolean=false;
  DestroyFlag:boolean;
  s:byte=0;
  m:byte=0;
  h:byte=0;
  Score,NumDelLines:integer ;

implementation

{$R *.dfm}

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  s:=s+1;
  if s=60 then
  begin
    s:=0;
    m:=m+1;
  end;
  if m=60 then
  begin
    m:=0;
    h:=h+1;
  end;
  if h=24 then
  begin
    m:=0;
    s:=0;
    h:=0;
  end;
  Statusbar1.Panels[2].Text:='Время: '
                 +copy('0'+inttostr(h),length('0'+inttostr(h))-1,2)+':'
                 +copy('0'+inttostr(m),length('0'+inttostr(m))-1,2)+':'
                 +copy('0'+inttostr(s),length('0'+inttostr(s))-1,2);
end;

procedure TForm1.Enter(e1,e2:boolean);
var
  i,j:integer;
begin
if e1 then
begin
  for i:=0 to 8 do
    for j:=0 to 8 do
      a[i,j]:=126;
  for j:=-1 to 9 do
  begin
    a[-1,j]:=-100;
    a[9,j]:=-100;
    a[j,-1]:=-100;
    a[j,9]:=-100;
  end;
end;
if e2 then
begin
  for i:=0 to 8 do
    for j:=0 to 8 do
      if a[i,j]>=0 then
        a[i,j]:=126;
end;
end;

function TForm1.EmptyPos(aEP:first):integer;
var
  i,j,count:integer;
begin
  count:=0;
  for i:=0 to 8 do
   for j:=0 to 8 do
     if aEP[i,j]=126 then
       count:=count+1;
  result:=count;
end;

function TForm1.Find(x,y:integer):TImage;
var
  i:integer;
begin
  for i:=ComponentCount-1 downto 0 do
    if (Components[i] is TImage) and ((Components[i] as TImage).Name<>'Fon')
    and ((Components[i] as TImage).Left=y) and ((Components[i] as TImage).Top=x) then
    begin
      Result:=(Components[i] as TImage);
      exit;
    end;
end;

procedure TForm1.Create(x,y,c:integer);
begin
  with TImage.Create(self) do
  begin
    Autosize:=true;
    Transparent:=true;
    Left:=x;
    Top:=y;
    Picture.LoadFromFile('Bitmaps\'+inttostr(c)+'.bmp');
    Parent:=form1;
    Onclick:=Click;
  end;
end;

procedure TForm1.New(count:integer);
var
  i,j,c,q:integer;
  label Back;
begin
  if EmptyPos(a)>3 then
  begin
    for q:=1 to count do
    begin
      Back:
      i:=random(9);
      j:=random(9);
      c:=random(7)+1;
      if a[i,j]=126 then
      begin
        a[i,j]:=-1*c;
        Create(j*hw,i*hw,c);
      end
      else
        goto Back;
    end;
  end
  else
  begin
    ShowMessage('Вы проиграли.');
    Restart;
    New(3);
  end;
end;

procedure TForm1.Restart;
var
  i:integer;
  label Back;
begin
  Enter(true,false);
  Score:=0;
  NumDelLines:=0;
  for i:=ComponentCount-1 downto 0 do
    if (Components[i] is TImage) and (TImage(Components[i]).Name<>'Fon') then
      (Components[i] as TImage).Destroy;
  Statusbar1.Panels[0].Text:='Уничтожено линий: 0';
  Statusbar1.Panels[1].Text:='Очки: 0';
  Statusbar1.Panels[2].Text:='Время: 00:00:00';
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i,j,q:integer;
begin
  randomize;
  doublebuffered:=true;
  Score:=0;
  NumDelLines:=0;
  Enter(true,false);
  New(3);
end;

procedure TForm1.Data(sc,ndl:integer);
begin
  Score:=Score+sc;
  NumDelLines:=NumDelLines+ndl;
  Statusbar1.Panels[0].Text:='Уничтожено линий: '+inttostr(NumDelLines);
  Statusbar1.Panels[1].Text:='Очки: '+inttostr(Score);
end;

procedure TForm1.Click(Sender: TObject);
begin
  mainflag:=true;
  img:=(sender as TImage);
end;

procedure TForm1.FonMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if mainflag then
  begin
    Wave(x,y);
    Enter(false,true);
    if way then
    begin
      DestroyLines;
      if DestroyFlag=false then
      begin
        New(3);
        DestroyLines;
      end;
    end;
  end;
end;

procedure TForm1.Wave(x1,y1:integer);
var
  i,j,ii,jj,q,buf,bufx,bufy:integer;
begin
  {wave}
  b1[0,1]:=y1 div hw;
  b1[0,2]:=x1 div hw;
  a[b1[0,1],b1[0,2]]:=0;
  buf:=a[img.Top div hw,img.Left div hw];
  a[img.Top div hw,img.Left div hw]:=127;
  b1b2:=true;
  bb1:=0;
  bb2:=-1;
  k:=1;
  move:=1;
  way:=false;
  while (k>0) and (way<>true) do
  begin
    k:=0;
    if b1b2=true then
    begin
    for q:=0 to bb1 do
    begin
      if a[ b1[q,1]-1 , b1[q,2] ]=127 then
      begin
        way:=true;
        ii:=b1[q,1]-1;
        jj:=b1[q,2];
      end
      else
      if a[ b1[q,1]-1 , b1[q,2] ]=126 then
      begin
        a[ b1[q,1]-1 , b1[q,2] ]:=move;
        bb2:=bb2+1;
        b2[bb2,1]:=b1[q,1]-1;
        b2[bb2,2]:=b1[q,2];
        k:=k+1;
      end;
      if a[ b1[q,1]+1 , b1[q,2] ]=127 then
      begin
        way:=true;
        ii:=b1[q,1]+1;
        jj:=b1[q,2];
      end
      else
      if a[ b1[q,1]+1 , b1[q,2] ]=126 then
      begin
        a[ b1[q,1]+1 , b1[q,2] ]:=move;
        bb2:=bb2+1;
        b2[bb2,1]:=b1[q,1]+1;
        b2[bb2,2]:=b1[q,2];
        k:=k+1;
      end;
      if a[ b1[q,1] , b1[q,2]-1 ]=127 then
      begin
        way:=true;
        ii:=b1[q,1];
        jj:=b1[q,2]-1;
      end
      else
      if a[ b1[q,1] , b1[q,2]-1 ]=126 then
      begin
        a[ b1[q,1] , b1[q,2]-1 ]:=move;
        bb2:=bb2+1;
        b2[bb2,1]:=b1[q,1];
        b2[bb2,2]:=b1[q,2]-1;
        k:=k+1;
      end;
      if a[ b1[q,1] , b1[q,2]+1 ]=127 then
      begin
        way:=true;
        ii:=b1[q,1];
        jj:=b1[q,2]+1;
      end
      else
      if a[ b1[q,1] , b1[q,2]+1 ]=126 then
      begin
        a[ b1[q,1] , b1[q,2]+1 ]:=move;
        bb2:=bb2+1;
        b2[bb2,1]:=b1[q,1];
        b2[bb2,2]:=b1[q,2]+1;
        k:=k+1;
      end;
    end;
    b1b2:=false;
    bb1:=-1;
    end
    else
    begin
    for q:=0 to bb2 do
    begin
      if a[ b2[q,1]-1 , b2[q,2] ]=127 then
      begin
        way:=true;
        ii:=b2[q,1]-1;
        jj:=b2[q,2];
      end
      else
      if a[ b2[q,1]-1 , b2[q,2] ]=126 then
      begin
        a[ b2[q,1]-1 , b2[q,2] ]:=move;
        bb1:=bb1+1;
        b1[bb1,1]:=b2[q,1]-1;
        b1[bb1,2]:=b2[q,2];
        k:=k+1;
      end;
      if a[ b2[q,1]+1 , b2[q,2] ]=127 then
      begin
        way:=true;
        ii:=b2[q,1]+1;
        jj:=b2[q,2];
      end
      else
      if a[ b2[q,1]+1 , b2[q,2] ]=126 then
      begin
        a[ b2[q,1]+1 , b2[q,2] ]:=move;
        bb1:=bb1+1;
        b1[bb1,1]:=b2[q,1]+1;
        b1[bb1,2]:=b2[q,2];
        k:=k+1;
      end;
      if a[ b2[q,1] , b2[q,2]-1 ]=127 then
      begin
        way:=true;
        ii:=b2[q,1];
        jj:=b2[q,2]-1;
      end
      else
      if a[ b2[q,1] , b2[q,2]-1 ]=126 then
      begin
        a[ b2[q,1] , b2[q,2]-1 ]:=move;
        bb1:=bb1+1;
        b1[bb1,1]:=b2[q,1];
        b1[bb1,2]:=b2[q,2]-1;
        k:=k+1;
      end;
      if a[ b2[q,1] , b2[q,2]+1 ]=127 then
      begin
        way:=true;
        ii:=b2[q,1];
        jj:=b2[q,2]+1;
      end
      else
      if a[ b2[q,1] , b2[q,2]+1 ]=126 then
      begin
        a[ b2[q,1] , b2[q,2]+1 ]:=move;
        bb1:=bb1+1;
        b1[bb1,1]:=b2[q,1];
        b1[bb1,2]:=b2[q,2]+1;
        k:=k+1;
      end;
    end;
    b1b2:=true;
    bb2:=-1;
    end;
    move:=move+1;
  end;
  {road}
  if way=true then
  begin
    for i:=move-2 downto 0 do
    begin
      if a[ ii-1 , jj ]=i then
      begin
        for q:=1 to hw div 2 do
        begin
          img.Top:=img.Top-2;
          sleep(1);
          form1.Refresh;
        end;
        ii:=ii-1;
      end;
      if a[ ii+1 , jj ]=i then
      begin
        for q:=1 to hw div 2 do
        begin
          img.Top:=img.Top+2;
          sleep(1);
          form1.Refresh;
        end;
        ii:=ii+1;
      end;
      if a[ ii , jj-1 ]=i then
      begin
        for q:=1 to hw div 2 do
        begin
          img.Left:=img.Left-2;
          sleep(1);
          form1.Refresh;
        end;
        jj:=jj-1;
      end;
      if a[ ii , jj+1 ]=i then
      begin
        for q:=1 to hw div 2 do
        begin
          img.Left:=img.Left+2;
          sleep(1);
          form1.Refresh;
        end;
        jj:=jj+1;
      end;
    end;
    a[ii,jj]:=buf;
    mainflag:=false;
  end
  else
    a[img.Top div hw,img.Left div hw]:=buf;
end;

procedure TForm1.DestroySpheres(x,y,kol,i,j:integer);
var
  n,dx,dy:integer;
  image:TImage;
begin
  n:=0;
  dx:=x;
  dy:=y;
  while n<>kol do
  begin
    image:=Find(dx*hw,dy*hw);
    image.Destroy;
    a[dx,dy]:=126;
    n:=n+1;
    dx:=dx+i;
    dy:=dy+j;
  end;
  Data(kol,1);
  DestroyFlag:=true;
end;

function TForm1.FindLine(x,y,i,j:integer):integer;
var
  dx,dy,kol:integer;
begin
  dx:=x;
  dy:=y;
  kol:=0;
  while a[x,y]=a[dx,dy] do
  begin
    if ExitMap(dx,dy)=true then
    begin
      dx:=dx+i;
      dy:=dy+j;
      kol:=kol+1;
    end
    else
      break;
  end;
  result:=kol;
end;

procedure TForm1.DestroyLines;
var
  kol,i,j,fl1,fl2,fl3,fl4:integer;
begin
  DestroyFlag:=false;
  for j:=0 to 8 do
    for i:=0 to 8 do
    if a[i,j]<>126 then
    begin
      fl1:=FindLine(i,j,1,0);
      fl2:=FindLine(i,j,1,1);
      fl3:=FindLine(i,j,0,1);
      fl4:=FindLine(i,j,-1,1);
      if fl1>4 then
        DestroySpheres(i,j,fl1,1,0)
      else
      if fl2>4 then
        DestroySpheres(i,j,fl2,1,1)
      else
      if fl3>4 then
        DestroySpheres(i,j,fl3,0,1)
      else
      if fl4>4 then
        DestroySpheres(i,j,fl4,-1,1);
    end;
end;

function TForm1.ExitMap(x,y:integer):boolean;
begin
  ExitMap:=false;
  if (x>=0) and (x<=8) and (y>=0) and (y<=8) then
    ExitMap:=true;
end;

procedure TForm1.N8Click(Sender: TObject);
begin
  Form1.close;
end;

procedure TForm1.N3Click(Sender: TObject);
begin
  Restart;
  New(3);
end;

procedure TForm1.N5Click(Sender: TObject);
{SaveGame}
var
  i,j:integer;
begin
  AssignFile(output,'Save.txt');
  Rewrite(output);
  for i:=0 to 8 do
    for j:=0 to 8 do
      Write(a[i,j],' ');
  Write(Score,' ',NumDelLines);
  closefile(output);
end;

procedure TForm1.N6Click(Sender: TObject);
{LoadGame}
var
  i,j:integer;
  scr,ndell:integer;
begin
  Restart;
  AssignFile(input,'Save.txt');
  Reset(input);
  for i:=0 to 8 do
    for j:=0 to 8 do
    begin
      Read(a[i,j]);
      if a[i,j]<>126 then
        Create(j*30,i*30,-1*a[i,j]);
    end;
  Read(scr,ndell);
  Data(scr,ndell);
  CloseFile(input);
end;

procedure TForm1.N9Click(Sender: TObject);
begin
  ShowMessage('Курсовая работа. 3 курс. 2семестр. Выполнил Хорло Игорь. 31 Группа');
end;

end.
