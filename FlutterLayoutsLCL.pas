{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit FlutterLayoutsLCL;

{$warn 5023 off : no warning about unused units}
interface

uses
  RegisterFlutterLCL, TFBaseLayoutUnit, TFRowUnit, TFColumnUnit, 
  TFExpandedUnit, TFCenterUnit, TFFlexibleUnit, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('RegisterFlutterLCL', @RegisterFlutterLCL.Register);
end;

initialization
  RegisterPackage('FlutterLayoutsLCL', @Register);
end.
