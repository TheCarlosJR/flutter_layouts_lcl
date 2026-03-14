unit TFExpandedUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Forms,
  LCLType, LMessages, Graphics, Math,
  TFBaseLayoutUnit;

type

  { =========================================================
    TFExpanded - ocupa todo o espaço restante no pai Row/Column
    Não possui scroll próprio — é gerenciado pelo pai.
    ========================================================= }
  TFExpanded = class(TPanel)
  private
    FFlex : Integer;
    procedure SetFlex(AValue: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetParent(AParent: TWinControl); override;
  published
    property Flex : Integer read FFlex write SetFlex default 1;
    property Align;
    property Anchors;
    property BorderStyle;
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

constructor TFExpanded.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFlex      := 1;
  BevelOuter := bvNone;
  BevelInner := bvNone;
  Caption    := '';
  Align      := alClient;
end;

procedure TFExpanded.SetFlex(AValue: Integer);
begin
  if FFlex = AValue then Exit;
  if AValue < 1 then AValue := 1;
  FFlex := AValue;
  if Assigned(Parent) and (Parent is TFBaseLayout) then
    TFBaseLayout(Parent).DoLayout;
end;

procedure TFExpanded.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if Assigned(AParent) and (AParent is TFBaseLayout) then
    TFBaseLayout(AParent).DoLayout;
end;

end.
end;