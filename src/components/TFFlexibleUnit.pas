unit TFFlexibleUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Forms,
    LCLType, LMessages, Graphics, Math,
    TFBaseLayoutUnit;

type
  { =========================================================
    TFFlexible - tamanho proporcional dentro de TFRow/TFColumn
    Não possui scroll próprio — é gerenciado pelo pai.
    ========================================================= }
  TFFlexible = class(TPanel)
  private
    FFlexFactor : Double;
    procedure SetFlexFactor(AValue: Double);
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure RequestLayout;
  published
    property FlexFactor : Double read FFlexFactor write SetFlexFactor;
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

constructor TFFlexible.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFlexFactor := 1.0;
  BevelOuter  := bvNone;
  BevelInner  := bvNone;
  Caption     := '';
end;

procedure TFFlexible.SetFlexFactor(AValue: Double);
begin
  if FFlexFactor = AValue then Exit;
  if AValue <= 0 then AValue := 0.1;
  FFlexFactor := AValue;
  RequestLayout;
end;

procedure TFFlexible.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if Assigned(AParent) and (AParent is TFBaseLayout) then
    TFBaseLayout(AParent).DoLayout;
end;

procedure TFFlexible.RequestLayout;
begin
  if Assigned(Parent) and (Parent is TFBaseLayout) then
    TFBaseLayout(Parent).DoLayout;
end;

end.
end;