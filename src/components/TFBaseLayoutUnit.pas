unit TFBaseLayoutUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Forms,
  LCLType, LMessages, Graphics, Math;

type
  TPaddingRecord = record
    Top    : Integer;
    Bottom : Integer;
    Left   : Integer;
    Right  : Integer;
  end;

  { =========================================================
    TFBaseLayout - base herdada de TScrollBox
    ========================================================= }
  TFBaseLayout = class(TScrollBox)
  protected
    FSpacing        : Integer;
    FOverflowScroll : Boolean;
    FPadding        : TPaddingRecord;
    procedure SetSpacing(AValue: Integer);
    procedure SetOverflowScroll(AValue: Boolean);
    function GetPadding: TPaddingRecord;
    procedure Resize; override;
    procedure Loaded; override;
    procedure CMControlChange(var Msg: TLMessage); message CM_CONTROLCHANGE;
    procedure OnChildAdded(AChild: TControl); virtual;
    procedure UpdateScrollRange(ATotalMainAxis: Integer); virtual; abstract;
  public
    procedure DoLayout; virtual;
    constructor Create(AOwner: TComponent); override;
    property Padding : TPaddingRecord read GetPadding;
  published
    { Espaço em pixels entre os filhos }
    property Spacing : Integer read FSpacing write SetSpacing default 4;

    {
      OverflowScroll:
        True  → (padrão) scrollbar aparece quando filhos ultrapassam o tamanho
        False → filhos são cortados pelo ClientRect (sem scroll)
      Cada subclasse expõe esta propriedade explicitamente no published
      para que apareça no Object Inspector com hint correto.
    }
    property OverflowScroll : Boolean
      read FOverflowScroll write SetOverflowScroll default True;

    property Align;
    property Anchors;
    property BorderStyle;
    property BorderWidth;
    property Color;
    property Constraints;
    property Cursor;
    property Enabled;
    property Font;
    property Height;
    property Hint;
    property Left;
    property Name;
    property ParentColor;
    property ParentFont;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Tag;
    property Top;
    property Visible;
    property Width;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

implementation

constructor TFBaseLayout.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSpacing        := 4;
  FOverflowScroll := True;
  FPadding.Top    := 0;
  FPadding.Bottom := 0;
  FPadding.Left   := 0;
  FPadding.Right  := 0;
  AutoScroll      := False;  { gerenciamos manualmente }
  BorderStyle     := bsNone;
  Color           := clBtnFace;

  HorzScrollBar.Visible  := False;
  HorzScrollBar.Tracking := True;
  VertScrollBar.Visible  := False;
  VertScrollBar.Tracking := True;
end;

procedure TFBaseLayout.SetSpacing(AValue: Integer);
begin
  if FSpacing = AValue then Exit;
  FSpacing := AValue;
  DoLayout;
end;

procedure TFBaseLayout.SetOverflowScroll(AValue: Boolean);
begin
  if FOverflowScroll = AValue then Exit;
  FOverflowScroll := AValue;
  { Ao desabilitar, esconde as scrollbars imediatamente }
  if not FOverflowScroll then
  begin
    HorzScrollBar.Visible := False;
    VertScrollBar.Visible := False;
  end;
  DoLayout;
end;

function TFBaseLayout.GetPadding: TPaddingRecord;
begin
  Result := FPadding;
end;

procedure TFBaseLayout.DoLayout;
begin
  { Implementado nas subclasses }
end;

procedure TFBaseLayout.Resize;
begin
  inherited Resize;
  DoLayout;
end;

procedure TFBaseLayout.Loaded;
begin
  inherited Loaded;
  DoLayout;
end;

procedure TFBaseLayout.CMControlChange(var Msg: TLMessage);
begin
  inherited;
  if Msg.WParam = 1 then
    OnChildAdded(TControl(Msg.LParam));
  DoLayout;
end;

procedure TFBaseLayout.OnChildAdded(AChild: TControl);
begin
  { Subclasses implementam }
end;

end.
end;