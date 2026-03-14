unit RegisterFlutterLCL;

{
  FWidgets - Flutter-like layout components for Lazarus/LCL
  ---------------------------------------------------------
  Componentes que imitam o sistema de layout do Flutter.

  Componentes:
    TFRow      - Organiza filhos horizontalmente
    TFColumn   - Organiza filhos verticalmente
    TFExpanded - Ocupa o espaço restante no pai
    TFCenter   - Centraliza um único filho
    TFFlexible - Tamanho proporcional via FlexFactor

  PROTEÇÃO DE ALIGN:
    TFRow    → filhos sempre com Align = alLeft ou alRight
    TFColumn → filhos sempre com Align = alTop  ou alBottom

  OVERFLOW / SCROLL:
    TFRow    → OverflowScroll (Boolean, padrão True)
               Quando True:  scrollbar horizontal aparece ao haver overflow
               Quando False: filhos são cortados pelo ClientRect
    TFColumn → OverflowScroll (Boolean, padrão True)
               Quando True:  scrollbar vertical aparece ao haver overflow
               Quando False: filhos são cortados pelo ClientRect
    TFCenter → ScrollChild (Boolean, padrão False)
               Quando True:  scrollbars H+V aparecem se filho > ClientRect
               Quando False: filho é simplesmente centralizado (sem scroll)
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Forms,
  LCLType, LMessages, Graphics, Math,
  TFBaseLayoutUnit,
  TFRowUnit, TFColumnUnit, TFExpandedUnit, TFCenterUnit, TFFlexibleUnit;

procedure Register;

implementation

{ ===========================================================================
  Registro
  =========================================================================== }

procedure Register;
begin
  RegisterComponents('Flutter Widgets', [
    TFRow,
    TFColumn,
    TFExpanded,
    TFCenter,
    TFFlexible
  ]);
end;

end.