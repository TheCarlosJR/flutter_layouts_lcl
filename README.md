# Flutter Layout Widgets for Lazarus

<img src="https://raw.githubusercontent.com/TheCarlosJR/flutter_layouts_lcl/refs/heads/main/icon.png" alt="Logo image - Lazarus with Flutter mixed" width="100" height="100">

Componentes visuais para **Lazarus / FreePascal** que imitam o sistema de layout do **Flutter**, todos herdados e adaptados de `TScrollBox`.

---

## Componentes disponíveis

| Componente   | Equivalente Flutter | Descrição |
|---|---|---|
| `TFRow`      | `Row`               | Organiza filhos **horizontalmente** |
| `TFColumn`   | `Column`            | Organiza filhos **verticalmente** |
| `TFExpanded` | `Expanded`          | Ocupa o **espaço restante** no pai |
| `TFCenter`   | `Center`            | **Centraliza** o filho (H + V) |
| `TFFlexible` | `Flexible`          | Tamanho **proporcional** via `FlexFactor` |

---

## Instalação

### Pré-requisitos

- Lazarus 2.x ou superior
- FreePascal 3.x ou superior

### Passo a passo

1. **Abra o Lazarus**
2. Vá em **Package → Open Package File (.lpk)**
3. Navegue até a pasta do projeto e selecione **`FlutterWidgets.lpk`**
4. Na janela do pacote, clique em **Compile** e depois em **Install**
5. O Lazarus irá reiniciar automaticamente
6. Após reiniciar, os componentes estarão disponíveis na aba **"Flutter Widgets"** da paleta de componentes

---

## Estrutura dos arquivos

```
flutter_layouts_lcl/
├── FlutterLayoutsLCL.lpk   ← arquivo do pacote Lazarus
├── FlutterLayoutsLCL.pas   ← unidade principal
├── FlutterLayoutsLCL.ppu   ← arquivo compilado
├── README.md               ← esta documentação
├── lib/
│   └── x86_64-linux/
│       ├── FlutterLayoutsLCL.ppu
│       └── flutterwidgets.compiled
└── src/
    ├── AlignmentEnums.pas
    ├── AlignmentEnums.ppu
    ├── RegisterFlutterLCL.pas
    └── components/
        ├── TFBaseLayout.pas
        ├── TFBaseLayoutUnit.pas
        ├── TFBaseLayoutUnit.ppu
        ├── TFCenterUnit.pas
        ├── TFColumnUnit.pas
        ├── TFExpandedUnit.pas
        ├── TFExpandedUnit.ppu
        ├── TFFlexibleUnit.pas
        ├── TFFlexibleUnit.ppu
        ├── TFRowUnit.pas
        └── TFRowUnit.ppu
```

---

## Propriedades de Scroll por componente

| Componente    | Propriedade      | Padrão  | Scroll ativado quando...                          | Direção         |
|---|---|---|---|---|
| `TFRow`       | `OverflowScroll` | `True`  | largura total dos filhos > `ClientWidth`          | Horizontal ↔   |
| `TFColumn`    | `OverflowScroll` | `True`  | altura total dos filhos  > `ClientHeight`         | Vertical ↕     |
| `TFCenter`    | `ScrollChild`    | `False` | filho maior que `ClientWidth` ou `ClientHeight`   | Horizontal + Vertical |
| `TFExpanded`  | —                | —       | Não se aplica (sem filhos gerenciados)            | —               |
| `TFFlexible`  | —                | —       | Não se aplica (sem filhos gerenciados)            | —               |

---

## TFRow — linha horizontal

### OverflowScroll

```pascal
// Padrão (True): scrollbar horizontal aparece ao haver overflow
MeuRow.OverflowScroll := True;

// False: filhos que ultrapassam o ClientWidth são cortados
MeuRow.OverflowScroll := False;
```

Exemplo com overflow proposital:

```pascal
var
  Row : TFRow;
  I   : Integer;
  Btn : TButton;
begin
  Row := TFRow.Create(Self);
  Row.Parent          := Self;
  Row.Align           := alTop;
  Row.Height          := 48;
  Row.Spacing         := 6;
  Row.OverflowScroll  := True; // scrollbar H aparece quando necessário

  for I := 1 to 15 do          // 15 botões → overflow garantido
  begin
    Btn := TButton.Create(Self);
    Btn.Parent  := Row;
    Btn.Caption := 'Tab ' + IntToStr(I);
    Btn.Width   := 90;
  end;
end;
```

### Propriedades completas

| Propriedade          | Tipo                   | Padrão      | Descrição |
|---|---|---|---|
| `OverflowScroll`     | `Boolean`              | `True`      | Habilita scroll horizontal ao haver overflow |
| `ChildAlign`         | `TAlign`               | `alLeft`    | `alLeft` ou `alRight` |
| `CrossAxisAlignment` | `TFCrossAxisAlignment` | `caStretch` | Alinhamento no eixo vertical |
| `MainAxisAlignment`  | `TFMainAxisAlignment`  | `maStart`   | Distribuição no eixo horizontal |
| `Spacing`            | `Integer`              | `4`         | Espaço em pixels entre filhos |

---

## TFColumn — coluna vertical

### OverflowScroll

```pascal
// Padrão (True): scrollbar vertical aparece ao haver overflow
MinhaColuna.OverflowScroll := True;

// False: filhos que ultrapassam o ClientHeight são cortados
MinhaColuna.OverflowScroll := False;
```

Exemplo com lista longa:

```pascal
var
  Col : TFColumn;
  I   : Integer;
  Lbl : TLabel;
begin
  Col := TFColumn.Create(Self);
  Col.Parent         := Self;
  Col.Align          := alClient;
  Col.Spacing        := 4;
  Col.OverflowScroll := True; // scrollbar V aparece quando necessário

  for I := 1 to 30 do         // 30 itens → overflow em telas pequenas
  begin
    Lbl := TLabel.Create(Self);
    Lbl.Parent  := Col;
    Lbl.Caption := 'Item ' + IntToStr(I);
    Lbl.Height  := 24;
  end;
end;
```

### Propriedades completas

| Propriedade          | Tipo                   | Padrão      | Descrição |
|---|---|---|---|
| `OverflowScroll`     | `Boolean`              | `True`      | Habilita scroll vertical ao haver overflow |
| `ChildAlign`         | `TAlign`               | `alTop`     | `alTop` ou `alBottom` |
| `CrossAxisAlignment` | `TFCrossAxisAlignment` | `caStretch` | Alinhamento no eixo horizontal |
| `MainAxisAlignment`  | `TFMainAxisAlignment`  | `maStart`   | Distribuição no eixo vertical |
| `Spacing`            | `Integer`              | `4`         | Espaço em pixels entre filhos |

---

## TFExpanded — expansão de espaço

Ocupa o espaço restante no pai. **Não possui propriedade de scroll** — o scroll é gerenciado pelo `TFRow` ou `TFColumn` pai.

```pascal
var
  Row     : TFRow;
  BtnBack : TButton;
  Spacer  : TFExpanded;
  BtnNext : TButton;
begin
  Row := TFRow.Create(Self);
  Row.Parent := Self;
  Row.Align  := alTop;
  Row.Height := 48;

  BtnBack := TButton.Create(Self);
  BtnBack.Parent  := Row;
  BtnBack.Caption := 'Voltar';
  BtnBack.Width   := 80;

  Spacer := TFExpanded.Create(Self);
  Spacer.Parent := Row; // empurra BtnNext para a direita

  BtnNext := TButton.Create(Self);
  BtnNext.Parent  := Row;
  BtnNext.Caption := 'Próximo';
  BtnNext.Width   := 80;
end;
```

| Propriedade | Tipo      | Padrão | Descrição |
|---|---|---|---|
| `Flex`      | `Integer` | `1`    | Proporção inteira de espaço entre múltiplos `TFExpanded` |

---

## TFCenter — centralização

### ScrollChild

```pascal
// Padrão (False): filho centralizado, cortado se for maior que o TFCenter
MeuCenter.ScrollChild := False;

// True: scrollbars H e V aparecem se o filho for maior que o TFCenter
MeuCenter.ScrollChild := True;
```

Exemplo com imagem grande rolável:

```pascal
var
  Centro : TFCenter;
  Img    : TImage;
begin
  Centro := TFCenter.Create(Self);
  Centro.Parent      := Self;
  Centro.Align       := alClient;
  Centro.ScrollChild := True; // permite rolar se a imagem for maior

  Img := TImage.Create(Self);
  Img.Parent  := Centro;
  Img.Width   := 1920; // imagem maior que a tela
  Img.Height  := 1080;
  Img.Stretch := False;
end;
```

| Propriedade   | Tipo      | Padrão  | Descrição |
|---|---|---|---|
| `ScrollChild` | `Boolean` | `False` | Habilita scrollbars H+V quando o filho é maior que o `TFCenter` |

---

## TFFlexible — proporção de espaço

Sem propriedade de scroll — gerenciado pelo pai.

```pascal
var
  Row   : TFRow;
  FxA   : TFFlexible;
  FxB   : TFFlexible;
begin
  Row := TFRow.Create(Self);
  Row.Parent := Self;
  Row.Align  := alBottom;
  Row.Height := 40;

  FxA := TFFlexible.Create(Self);
  FxA.Parent     := Row;
  FxA.FlexFactor := 3.0; // ocupa 3/4
  FxA.Color      := $00A5D6A7;

  FxB := TFFlexible.Create(Self);
  FxB.Parent     := Row;
  FxB.FlexFactor := 1.0; // ocupa 1/4
  FxB.Color      := $00EF9A9A;
end;
```

| Propriedade   | Tipo     | Padrão | Descrição |
|---|---|---|---|
| `FlexFactor`  | `Double` | `1.0`  | Proporção relativa de espaço (mínimo `0.1`) |

---

## Referência: CrossAxisAlignment

| Valor       | Em `TFRow` (eixo vertical)            | Em `TFColumn` (eixo horizontal)       |
|---|---|---|
| `caStretch` | Filhos ocupam altura total            | Filhos ocupam largura total           |
| `caStart`   | Filhos alinhados ao topo              | Filhos alinhados à esquerda           |
| `caEnd`     | Filhos alinhados à base               | Filhos alinhados à direita            |
| `caCenter`  | Filhos centralizados verticalmente    | Filhos centralizados horizontalmente  |

---

## Referência: MainAxisAlignment

| Valor            | Descrição |
|---|---|
| `maStart`        | Filhos agrupados no início (padrão) |
| `maEnd`          | Filhos agrupados no final |
| `maCenter`       | Filhos agrupados no centro |
| `maSpaceBetween` | Espaço igual **entre** os filhos |
| `maSpaceAround`  | Espaço igual **ao redor** de cada filho |

> `maSpaceBetween` e `maSpaceAround` são ignorados quando há `TFExpanded` ou
> `TFFlexible` no mesmo container.

---

## Proteção de Align

```
Usuário tenta mudar Align de um filho (Object Inspector ou código)
              │
              ▼
   TControl.SetAlign() → Realign() → DoLayout() no pai
              │
              ▼
   ┌──────────────────────────────────────────┐
   │  EnforceChildrenAlign()    ← PROTEÇÃO    │
   │  Para cada filho:                        │
   │    se Align ≠ ChildAlign                 │
   │      → Ctrl.Align := ChildAlign          │
   └──────────────────────────────────────────┘
```

> `TFExpanded` e `TFFlexible` são sempre excluídos da proteção.

---

## Licença

MIT — livre para uso, modificação e distribuição.
