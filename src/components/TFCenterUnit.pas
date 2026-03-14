unit TFCenterUnit;

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
    TFCenter - centraliza automaticamente o primeiro filho
    ScrollChild → habilita/desabilita scrollbars H+V quando
                  o filho é maior que o TFCenter
    ========================================================= }
  TFCenter = class(TScrollBox)
  private
    FScrollChild : Boolean;
    FPadding     : TPaddingRecord;
    function GetPadding: TPaddingRecord;
    procedure SetScrollChild(AValue: Boolean);
    procedure CenterChild;
    procedure UpdateCenterScroll;
  protected
    procedure Resize; override;
    procedure CMControlChange(var Msg: TLMessage); message CM_CONTROLCHANGE;
  public
    constructor Create(AOwner: TComponent); override;
    property Padding : TPaddingRecord read GetPadding;
  published
    {
      ScrollChild:
        False → (padrão) filho é centralizado; se for maior que o TFCenter
                ele será cortado pelo ClientRect
        True  → scrollbars horizontal E vertical aparecem quando o filho
                é maior que o TFCenter, permitindo rolar para ver o conteúdo
    }
    property ScrollChild : Boolean
      read FScrollChild write SetScrollChild default False;

    property Align;
    property ParentColor;
    property ShowHint;
    property TabOrder;
    property Tag;
    property Top;
    property Visible;
    property Width;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

implementation

constructor TFCenter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FScrollChild   := False;
  FPadding.Top    := 0;
  FPadding.Bottom := 0;
  FPadding.Left   := 0;
  FPadding.Right  := 0;
  AutoScroll     := False;
  BorderStyle    := bsNone;
  Color          := clBtnFace;

  { Inicia com ambas scrollbars ocultas (ScrollChild = False) }
  HorzScrollBar.Visible  := False;
  HorzScrollBar.Tracking := True;
  VertScrollBar.Visible  := False;
  VertScrollBar.Tracking := True;
end;

procedure TFCenter.SetScrollChild(AValue: Boolean);
begin
  if FScrollChild = AValue then Exit;
  FScrollChild := AValue;
  { Ao desabilitar, garante que scrollbars somem imediatamente }
  if not FScrollChild then
  begin
    HorzScrollBar.Visible := False;
    VertScrollBar.Visible := False;
  end;
  CenterChild;
end;

function TFCenter.GetPadding: TPaddingRecord;
begin
  Result := FPadding;
end;

procedure TFCenter.UpdateCenterScroll;
var
  Ctrl        : TControl;
  NeedHorz    : Boolean;
  NeedVert    : Boolean;
begin
  if (not FScrollChild) or (ControlCount = 0) then
  begin
    HorzScrollBar.Visible := False;
    VertScrollBar.Visible := False;
    Exit;
  end;

  Ctrl := Controls[0];
  if not Ctrl.Visible then
  begin
    HorzScrollBar.Visible := False;
    VertScrollBar.Visible := False;
    Exit;
  end;

  NeedHorz := Ctrl.Width  > ClientWidth;
  NeedVert := Ctrl.Height > ClientHeight;

  { Scrollbar horizontal }
  if NeedHorz then
  begin
    HorzScrollBar.Range   := Ctrl.Width  + Padding.Left + Padding.Right;
    HorzScrollBar.Page    := ClientWidth;
    HorzScrollBar.Visible := True;
  end
  else
  begin
    HorzScrollBar.Range   := 0;
    HorzScrollBar.Visible := False;
  end;

  { Scrollbar vertical }
  if NeedVert then
  begin
    VertScrollBar.Range   := Ctrl.Height + Padding.Top + Padding.Bottom;
    VertScrollBar.Page    := ClientHeight;
    VertScrollBar.Visible := True;
  end
  else
  begin
    VertScrollBar.Range   := 0;
    VertScrollBar.Visible := False;
  end;
end;

procedure TFCenter.CenterChild;
var
  Ctrl : TControl;
begin
  if ControlCount = 0 then Exit;
  Ctrl := Controls[0];
  if not Ctrl.Visible then Exit;

  Ctrl.Align := alNone;

  if FScrollChild then
  begin
    { Com scroll: posiciona no início; scrollbars cuidam do resto }
    Ctrl.Left := Max(0, (ClientWidth  - Ctrl.Width)  div 2);
    Ctrl.Top  := Max(0, (ClientHeight - Ctrl.Height) div 2);
    UpdateCenterScroll;
  end
  else
  begin
    { Sem scroll: centraliza normalmente }
    Ctrl.Left := (ClientWidth  - Ctrl.Width)  div 2;
    Ctrl.Top  := (ClientHeight - Ctrl.Height) div 2;
    HorzScrollBar.Visible := False;
    VertScrollBar.Visible := False;
  end;
end;

procedure TFCenter.Resize;
begin
  inherited Resize;
  CenterChild;
end;

procedure TFCenter.CMControlChange(var Msg: TLMessage);
begin
  inherited;
  CenterChild;
end;

end.
