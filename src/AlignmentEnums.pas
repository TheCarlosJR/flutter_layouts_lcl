unit AlignmentEnums;

{$mode objfpc}{$H+}

interface

type
  /// Main Axis Aligment Enum - Alinhamento da dimensao principal
TFMainAxisAlignment  = (maStart, maEnd, maCenter, maSpaceBetween, maSpaceAround);

/// Cross Axis Aligment Enum - Alinhamento da dimensao perpendicular em relacao a dimensao principal
TFCrossAxisAlignment = (caStart, caEnd, caCenter, caStretch);

implementation

end.

end.