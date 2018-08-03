unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs, ComCtrls,
  BGRABitmap, BGRABitmapTypes, BGRAShape, BCLabel, BCButton, LCLIntF, StdCtrls;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    BCButton1: TButton;
    BCLabel1: TBCLabel;
    BGRAShape1: TBGRAShape;
    OpenDialog1: TOpenDialog;
    ProgressBar1: TProgressBar;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure BCButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
  private
    SourceFile: string;
    DestDir: string;
    procedure SaveIcons;
    procedure SelectOutput(srcFile: string);
    procedure ProcessIcons;
    procedure ProcessIconsTerminate(Sender: TObject);
  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormDropFiles(Sender: TObject; const FileNames: array of string);
begin
  if not ProgressBar1.Visible then
    SelectOutput(FileNames[0]);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  ProgressBar1.Visible := False;
  ProgressBar1.Style := TProgressBarStyle.pbstMarquee;
end;

procedure TfrmMain.BCButton1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    SelectOutput(OpenDialog1.FileName);
  end;
end;

procedure TfrmMain.SaveIcons;
begin
  ProgressBar1.Visible := True;
  BCButton1.Visible := False;
  BCLabel1.Caption := 'Saving icons...';
  TThread.ExecuteInThread(@ProcessIcons, @ProcessIconsTerminate);
end;

procedure TfrmMain.SelectOutput(srcFile: string);
begin
  case LowerCase(ExtractFileExt(srcFile)) of
    '.png', '.bmp', '.jpg':
    begin
      if SelectDirectoryDialog1.Execute then
      begin
        SourceFile := srcFile;
        DestDir := IncludeTrailingPathDelimiter(SelectDirectoryDialog1.FileName);
        SaveIcons;
      end;
    end
    else
      ShowMessage('File extension "' + ExtractFileExt(srcFile) +
        '" not supported. Supported .png, .bmp and .jpg.');
  end;
end;

procedure TfrmMain.ProcessIcons;

  function DoCalculateDestRect(AWidth, AHeight, ADestWidth, ADestHeight: integer): TRect;
  var
    PicWidth: integer;
    PicHeight: integer;
    ImgWidth: integer;
    ImgHeight: integer;
    w: integer;
    h: integer;
  begin
    PicWidth := AWidth;
    PicHeight := AHeight;
    ImgWidth := ADestWidth;
    ImgHeight := ADestHeight;
    w := ImgWidth;
    h := (PicHeight * w) div PicWidth;
    if h > ImgHeight then
    begin
      h := ImgHeight;
      w := (PicWidth * h) div PicHeight;
    end;
    PicWidth := w;
    PicHeight := h;

    Result := Rect(0, 0, PicWidth, PicHeight);
    OffsetRect(Result, (ImgWidth - PicWidth) div 2, (ImgHeight - PicHeight) div 2);
  end;

  procedure SaveIcon(s: string; w, h: integer; src: TBGRABitmap; c: TBGRAPixel);
  var
    bmp, tmp: TBGRABitmap;
    r: TRect;
  begin
    bmp := TBGRABitmap.Create(w, h, c);

    r := DoCalculateDestRect(src.Width, src.Height, w, h);

    src.ResampleFilter := rfBestQuality;
    tmp := src.Resample(r.Width, r.Height) as TBGRABitmap;
    bmp.PutImage(r.Left, r.Top, tmp, dmDrawWithTransparency);
    tmp.Free;

    bmp.SaveToFile(DestDir + s + '.png');
    bmp.Free;
  end;

var
  bmp: TBGRABitmap;
begin
  bmp := TBGRABitmap.Create(SourceFile);
  try
    // Android Icons
    SaveIcon('android_36x36_ldpi', 36, 36, bmp, BGRAPixelTransparent);
    SaveIcon('android_48x48_mdpi', 48, 48, bmp, BGRAPixelTransparent);
    SaveIcon('android_72x72_hdpi', 72, 72, bmp, BGRAPixelTransparent);
    SaveIcon('android_96x96_xhdpi', 96, 96, bmp, BGRAPixelTransparent);
    SaveIcon('android_144x144_xxhdpi', 144, 144, bmp, BGRAPixelTransparent);
    // Android Splash
    SaveIcon('android_splash_426x320_small', 426, 320, bmp, BGRABlack);
    SaveIcon('android_splash_470x320_normal', 470, 320, bmp, BGRABlack);
    SaveIcon('android_splash_640x480_large', 640, 480, bmp, BGRABlack);
    SaveIcon('android_splash_960x720_xlarge', 960, 720, bmp, BGRABlack);
    // iOS Icons
    SaveIcon('ios_57x57', 57, 57, bmp, BGRAPixelTransparent);
    SaveIcon('ios_60x60', 60, 60, bmp, BGRAPixelTransparent);
    SaveIcon('ios_87x87', 87, 87, bmp, BGRAPixelTransparent);
    SaveIcon('ios_114x114', 114, 114, bmp, BGRAPixelTransparent);
    SaveIcon('ios_120x120', 120, 120, bmp, BGRAPixelTransparent);
    SaveIcon('ios_180x180', 180, 180, bmp, BGRAPixelTransparent);
    // iOS Launch Image
    SaveIcon('ios_launch_320x480', 320, 480, bmp, BGRABlack);
    SaveIcon('ios_launch_640x960', 640, 960, bmp, BGRABlack);
    SaveIcon('ios_launch_640x1136', 640, 1136, bmp, BGRABlack);
    SaveIcon('ios_launch_750x1334', 750, 1334, bmp, BGRABlack);
    SaveIcon('ios_launch_1125x2436', 1125, 2436, bmp, BGRABlack);
    SaveIcon('ios_launch_2436x1125', 2436, 1125, bmp, BGRABlack);
    SaveIcon('ios_launch_1242x2208', 1242, 2208, bmp, BGRABlack);
    SaveIcon('ios_launch_2208x1242', 2208, 1242, bmp, BGRABlack);
    // iOS Spotlight Search Icon
    SaveIcon('ios_spotlight_29x29', 29, 29, bmp, BGRABlack);
    SaveIcon('ios_spotlight_40x40', 40, 40, bmp, BGRABlack);
    SaveIcon('ios_spotlight_58x58', 58, 58, bmp, BGRABlack);
    SaveIcon('ios_spotlight_80x80', 80, 80, bmp, BGRABlack);
  finally
    bmp.Free;
  end;
end;

procedure TfrmMain.ProcessIconsTerminate(Sender: TObject);
begin
  ProgressBar1.Visible := False;
  BCLabel1.Caption := 'Done! Drop another image here';
  BCButton1.Visible := True;
end;

end.
