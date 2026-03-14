unit TFRowUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Forms,
  LCLType, LMessages, Graphics, Math,
  TFBaseLayoutUnit, AlignmentEnums,
  TFFlexibleUnit, TFExpandedUnit;

type
  { =========================================================
    TFRow - organiza filhos HORIZONTALMENTE
    OverflowScroll → habilita/desabilita scrollbar HORIZONTAL
    ========================================================= }
  TFRow = class(TFBaseLayout)
  private
    FCrossAxisAlignment : TFCrossAxisAlignment;
    FMainAxisAlignment  : TFMainAxisAlignment;
    FChildAlign         : TAlign;
    procedure SetCrossAxisAlignment(AValue: TFCrossAxisAlignment);
    procedure SetMainAxisAlignment(AValue: TFMainAxisAlignment);
    procedure SetChildAlign(AValue: TAlign);
    procedure EnforceChildrenAlign;
    procedure ApplySpacedLayout;
  public
    procedure DoLayout; override;
    procedure Loaded; override;
    procedure OnChildAdded(AChild: TControl); override;
    procedure UpdateScrollRange(ATotalMainAxis: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ValidateChildrenAlign;
  published
    { alLeft (padrão) ou alRight }
    property ChildAlign : TAlign
      read FChildAlign write SetChildAlign default alLeft;
    property CrossAxisAlignment : TFCrossAxisAlignment
      read FCrossAxisAlignment write SetCrossAxisAlignment default caStretch;
    property MainAxisAlignment : TFMainAxisAlignment
      read FMainAxisAlignment write SetMainAxisAlignment default maStart;

    {
      OverflowScroll (herdado de TFBaseLayout, reexposto para o Object Inspector):
        True  → (padrão) scrollbar HORIZONTAL aparece quando filhos
                ultrapassam o ClientWidth do TFRow
        False → filhos que ultrapassam são simplesmente cortados
    }
    property OverflowScroll;
  end;

implementation

constructor TFRow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FChildAlign         := alLeft;
  FCrossAxisAlignment := caStretch;
  FMainAxisAlignment  := maStart;
  Height              := 48;

  { Row: apenas scroll horizontal é relevante }
  VertScrollBar.Visible := False;
end;

procedure TFRow.SetChildAlign(AValue: TAlign);
begin
  if not (AValue in [alLeft, alRight]) then
    raise Exception.Create(
      'TFRow.ChildAlign: somente alLeft ou alRight são permitidos.');
  if FChildAlign = AValue then Exit;
  FChildAlign := AValue;
  EnforceChildrenAlign;
  DoLayout;
end;

procedure TFRow.SetCrossAxisAlignment(AValue: TFCrossAxisAlignment);
begin
  if FCrossAxisAlignment = AValue then Exit;
  FCrossAxisAlignment := AValue;
  DoLayout;
end;

procedure TFRow.SetMainAxisAlignment(AValue: TFMainAxisAlignment);
begin
  if FMainAxisAlignment = AValue then Exit;
  FMainAxisAlignment := AValue;
  DoLayout;
end;

procedure TFRow.EnforceChildrenAlign;
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

procedure TFRow.ValidateChildrenAlign;
begin
  EnforceChildrenAlign;
  DoLayout;
end;

procedure TFRow.OnChildAdded(AChild: TControl);
begin
  if Assigned(AChild)
     and not (AChild is TFExpanded)
     and not (AChild is TFFlexible) then
    AChild.Align := FChildAlign;
end;

procedure TFRow.Loaded;
begin
  inherited Loaded;
  ValidateChildrenAlign;
end;

procedure TFRow.DoLayout;
var
  I               : Integer;
  Ctrl            : TControl;
  TotalFixed      : Integer;
  TotalFlex       : Integer;
  AvailWidth      : Integer;
  CurLeft         : Integer;
  FlexWidth       : Integer;
  TotalFlexFactor : Double;
  TotalUsed       : Integer;
begin
  EnforceChildrenAlign;
  if ControlCount = 0 then Exit;

  DisableAlign;
  try
    AvailWidth      := ClientWidth;
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
        Inc(TotalFixed, Ctrl.Width + FSpacing);
    end;

    AvailWidth := AvailWidth - TotalFixed;
    if AvailWidth < 0 then AvailWidth := 0;

CurLeft := 0;
      if (TotalFlex = 0) and (TotalFlexFactor = 0.0) then
        case FMainAxisAlignment of
          maEnd    : CurLeft := ClientWidth - TotalFixed + FSpacing;
          maCenter : CurLeft := (ClientWidth - TotalFixed + FSpacing) div 2;
          else       CurLeft := 0;
      end;

    for I := 0 to ControlCount - 1 do
    begin
      Ctrl := Controls[I];
      if not Ctrl.Visible then Continue;

      { CrossAxis — vertical }
      case FCrossAxisAlignment of
        caStretch :
          begin
              Ctrl.Top    := 0;
              Ctrl.Height := ClientHeight;
            end;
          caStart  : Ctrl.Top := 0;
          caEnd    : Ctrl.Top := ClientHeight - Ctrl.Height;
          caCenter : Ctrl.Top := (ClientHeight - Ctrl.Height) div 2;
        end;

      if Ctrl is TFFlexible then
      begin
        if TotalFlexFactor > 0 then
          FlexWidth := Round((TFFlexible(Ctrl).FlexFactor / TotalFlexFactor) * AvailWidth)
        else
          FlexWidth := 0;
        Ctrl.Left  := CurLeft;
        Ctrl.Width := FlexWidth;
        Inc(CurLeft, FlexWidth + FSpacing);
      end
      else if Ctrl is TFExpanded then
      begin
        FlexWidth  := IfThen(TotalFlex > 0, AvailWidth div TotalFlex, 0);
        Ctrl.Left  := CurLeft;
        Ctrl.Width := FlexWidth;
        Inc(CurLeft, FlexWidth + FSpacing);
      end
      else
      begin
        Ctrl.Left := CurLeft;
        Inc(CurLeft, Ctrl.Width + FSpacing);
      end;
    end;

    if (FMainAxisAlignment in [maSpaceBetween, maSpaceAround])
       and (TotalFlex = 0) and (TotalFlexFactor = 0.0) then
      ApplySpacedLayout;

    { Calcula largura total para decidir sobre scrollbar }
    TotalUsed := 0;
    for I := 0 to ControlCount - 1 do
    begin
      Ctrl := Controls[I];
      if not Ctrl.Visible then Continue;
      TotalUsed := Max(TotalUsed, Ctrl.Left + Ctrl.Width);
    end;

    UpdateScrollRange(TotalUsed);

  finally
    EnableAlign;
  end;
end;

procedure TFRow.ApplySpacedLayout;
var
  I              : Integer;
  Ctrl           : TControl;
  VisCount       : Integer;
  TotalCtrlWidth : Integer;
  Gap            : Integer;
  CurLeft        : Integer;
begin
  VisCount       := 0;
  TotalCtrlWidth := 0;
  for I := 0 to ControlCount - 1 do
    if Controls[I].Visible then
    begin
      Inc(VisCount);
      Inc(TotalCtrlWidth, Controls[I].Width);
    end;
  if VisCount <= 1 then Exit;

  case FMainAxisAlignment of
    maSpaceBetween :
      begin Gap := (ClientWidth - TotalCtrlWidth) div (VisCount - 1); CurLeft := 0; end;
    maSpaceAround :
      begin Gap := (ClientWidth - TotalCtrlWidth) div (VisCount + 1); CurLeft := Gap; end;
    else Exit;
  end;

  for I := 0 to ControlCount - 1 do
  begin
    Ctrl := Controls[I];
    if not Ctrl.Visible then Continue;
    Ctrl.Left := CurLeft;
    Inc(CurLeft, Ctrl.Width + Gap);
  end;
end;

procedure TFRow.UpdateScrollRange(ATotalMainAxis: Integer);
begin
  { OverflowScroll = True E conteúdo maior que área visível → mostra scrollbar }
  if FOverflowScroll and (ATotalMainAxis > ClientWidth) then
  begin
    HorzScrollBar.Range   := ATotalMainAxis;
    HorzScrollBar.Page    := ClientWidth;
    HorzScrollBar.Visible := True;
  end
  else
  begin
    HorzScrollBar.Range   := 0;
    HorzScrollBar.Visible := False;
  end;

end;

end.
end;