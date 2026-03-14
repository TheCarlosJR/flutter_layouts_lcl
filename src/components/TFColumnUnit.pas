unit TFColumnUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Forms,
  LCLType, LMessages, Graphics, Math,
  AlignmentEnums, TFBaseLayoutUnit, TFExpandedUnit, TFFlexibleUnit;

type

  { =========================================================
    TFColumn - organiza filhos VERTICALMENTE
    OverflowScroll → habilita/desabilita scrollbar VERTICAL
    ========================================================= }
  TFColumn = class(TFBaseLayout)
  private
    FCrossAxisAlignment : TFCrossAxisAlignment;
    FMainAxisAlignment  : TFMainAxisAlignment;
    FChildAlign         : TAlign;
    procedure SetCrossAxisAlignment(AValue: TFCrossAxisAlignment);
    procedure SetMainAxisAlignment(AValue: TFMainAxisAlignment);
    procedure SetChildAlign(AValue: TAlign);
    procedure EnforceChildrenAlign;
    procedure ApplySpacedLayout;
  protected
    procedure DoLayout; override;
    procedure Loaded; override;
    procedure OnChildAdded(AChild: TControl); override;
    procedure UpdateScrollRange(ATotalMainAxis: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ValidateChildrenAlign;
  published
    { alTop (padrão) ou alBottom }
    property ChildAlign : TAlign
      read FChildAlign write SetChildAlign default alTop;
    property CrossAxisAlignment : TFCrossAxisAlignment
      read FCrossAxisAlignment write SetCrossAxisAlignment default caStretch;
    property MainAxisAlignment : TFMainAxisAlignment
      read FMainAxisAlignment write SetMainAxisAlignment default maStart;

    {
      OverflowScroll (herdado de TFBaseLayout, reexposto para o Object Inspector):
        True  → (padrão) scrollbar VERTICAL aparece quando filhos
                ultrapassam o ClientHeight do TFColumn
        False → filhos que ultrapassam são simplesmente cortados
    }
    property OverflowScroll;
  end;

implementation

constructor TFColumn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FChildAlign         := alTop;
  FCrossAxisAlignment := caStretch;
  FMainAxisAlignment  := maStart;
  Width               := 120;

  { Column: apenas scroll vertical é relevante }
  HorzScrollBar.Visible := False;
end;

procedure TFColumn.SetChildAlign(AValue: TAlign);
begin
  if not (AValue in [alTop, alBottom]) then
    raise Exception.Create(
      'TFColumn.ChildAlign: somente alTop ou alBottom são permitidos.');
  if FChildAlign = AValue then Exit;
  FChildAlign := AValue;
  EnforceChildrenAlign;
  DoLayout;
end;

procedure TFColumn.SetCrossAxisAlignment(AValue: TFCrossAxisAlignment);
begin
  if FCrossAxisAlignment = AValue then Exit;
  FCrossAxisAlignment := AValue;
  DoLayout;
end;

procedure TFColumn.SetMainAxisAlignment(AValue: TFMainAxisAlignment);
begin
  if FMainAxisAlignment = AValue then Exit;
  FMainAxisAlignment := AValue;
  DoLayout;
end;

procedure TFColumn.EnforceChildrenAlign;
var
  I    : Integer;
  Ctrl : TControl;
begin
  DisableAlign;
  try
    for I := 0 to ControlCount - 1 do
    begin
      Ctrl := Controls[I];
      if (Ctrl is TFExpanded) or (Ctrl is TFFlexible) then Continue;
      if Ctrl.Align <> FChildAlign then
        Ctrl.Align := FChildAlign;
    end;
  finally
    EnableAlign;
  end;
end;

procedure TFColumn.ValidateChildrenAlign;
begin
  EnforceChildrenAlign;
  DoLayout;
end;

procedure TFColumn.OnChildAdded(AChild: TControl);
begin
  if Assigned(AChild)
     and not (AChild is TFExpanded)
     and not (AChild is TFFlexible) then
    AChild.Align := FChildAlign;
end;

procedure TFColumn.Loaded;
begin
  inherited Loaded;
  ValidateChildrenAlign;
end;

procedure TFColumn.UpdateScrollRange(ATotalMainAxis: Integer);
begin
  if FOverflowScroll and (ATotalMainAxis > ClientHeight) then
  begin
    VertScrollBar.Range   := ATotalMainAxis;
    VertScrollBar.Page    := ClientHeight;
    VertScrollBar.Visible := True;
  end
  else
  begin
    VertScrollBar.Range   := 0;
    VertScrollBar.Visible := False;
  end;
end;

procedure TFColumn.DoLayout;
var
  I               : Integer;
  Ctrl            : TControl;
  TotalFixed      : Integer;
  TotalFlex       : Integer;
  AvailHeight     : Integer;
  CurTop          : Integer;
  FlexHeight      : Integer;
  TotalFlexFactor : Double;
  TotalUsed       : Integer;
begin
  EnforceChildrenAlign;
  if ControlCount = 0 then Exit;

  DisableAlign;
  try
    AvailHeight     := ClientHeight - Padding.Top - Padding.Bottom;
    TotalFixed      := 0;
    TotalFlex       := 0;
    TotalFlexFactor := 0.0;

    for I := 0 to ControlCount - 1 do
    begin
      Ctrl := Controls[I];
      if not Ctrl.Visible then Continue;
      if Ctrl is TFFlexible then
        TotalFlexFactor := TotalFlexFactor + TFFlexible(Ctrl).FlexFactor
      else if Ctrl is TFExpanded then
        Inc(TotalFlex)
      else
        Inc(TotalFixed, Ctrl.Height + FSpacing);
    end;

    AvailHeight := AvailHeight - TotalFixed;
    if AvailHeight < 0 then AvailHeight := 0;

    CurTop := Padding.Top;
    if (TotalFlex = 0) and (TotalFlexFactor = 0.0) then
      case FMainAxisAlignment of
        maEnd    : CurTop := ClientHeight - TotalFixed - Padding.Bottom + FSpacing;
        maCenter : CurTop := (ClientHeight - TotalFixed + FSpacing) div 2;
        else       CurTop := Padding.Top;
      end;

    for I := 0 to ControlCount - 1 do
    begin
      Ctrl := Controls[I];
      if not Ctrl.Visible then Continue;

      { CrossAxis — horizontal }
      case FCrossAxisAlignment of
        caStretch :
          begin
            Ctrl.Left  := Padding.Left;
            Ctrl.Width := ClientWidth - Padding.Left - Padding.Right;
          end;
        caStart  : Ctrl.Left := Padding.Left;
        caEnd    : Ctrl.Left := ClientWidth - Ctrl.Width - Padding.Right;
        caCenter : Ctrl.Left := (ClientWidth - Ctrl.Width) div 2;
      end;

      Ctrl.Align := alNone;

      { MainAxis — vertical }
      if Ctrl is TFFlexible then
      begin
        if TotalFlexFactor > 0 then
          FlexHeight := Round((TFFlexible(Ctrl).FlexFactor / TotalFlexFactor) * AvailHeight)
        else
          FlexHeight := 0;
        Ctrl.Top    := CurTop;
        Ctrl.Height := FlexHeight;
        Inc(CurTop, FlexHeight + FSpacing);
      end
      else if Ctrl is TFExpanded then
      begin
        FlexHeight  := IfThen(TotalFlex > 0, AvailHeight div TotalFlex, 0);
        Ctrl.Top    := CurTop;
        Ctrl.Height := FlexHeight;
        Inc(CurTop, FlexHeight + FSpacing);
      end
      else
      begin
        Ctrl.Top := CurTop;
        Inc(CurTop, Ctrl.Height + FSpacing);
      end;
    end;

    if (FMainAxisAlignment in [maSpaceBetween, maSpaceAround])
       and (TotalFlex = 0) and (TotalFlexFactor = 0.0) then
      ApplySpacedLayout;

    { Calcula altura total para decidir sobre scrollbar }
    TotalUsed := 0;
    for I := 0 to ControlCount - 1 do
    begin
      Ctrl := Controls[I];
      if not Ctrl.Visible then Continue;
      TotalUsed := Max(TotalUsed, Ctrl.Top + Ctrl.Height + Padding.Bottom);
    end;

    UpdateScrollRange(TotalUsed);

  finally
    EnableAlign;
  end;
end;

procedure TFColumn.ApplySpacedLayout;
var
  I               : Integer;
  Ctrl            : TControl;
  VisCount        : Integer;
  TotalCtrlHeight : Integer;
  Gap             : Integer;
  CurTop          : Integer;
begin
  VisCount        := 0;
  TotalCtrlHeight := 0;
  for I := 0 to ControlCount - 1 do
    if Controls[I].Visible then
    begin
      Inc(VisCount);
      Inc(TotalCtrlHeight, Controls[I].Height);
    end;
  if VisCount <= 1 then Exit;

  case FMainAxisAlignment of
    maSpaceBetween :
      begin Gap := (ClientHeight - TotalCtrlHeight) div (VisCount - 1); CurTop := 0; end;
    maSpaceAround :
      begin Gap := (ClientHeight - TotalCtrlHeight) div (VisCount + 1); CurTop := Gap; end;
    else Exit;
  end;

  for I := 0 to ControlCount - 1 do
  begin
    Ctrl := Controls[I];
    if not Ctrl.Visible then Continue;
    Ctrl.Top := CurTop;
    Inc(CurTop, Ctrl.Height + Gap);
  end;
end;

end.
