{**********************************************************************}
{                                                                      }
{    "The contents of this file are subject to the Mozilla Public      }
{    License Version 1.1 (the "License"); you may not use this         }
{    file except in compliance with the License. You may obtain        }
{    a copy of the License at http://www.mozilla.org/MPL/              }
{                                                                      }
{    Software distributed under the License is distributed on an       }
{    "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express       }
{    or implied. See the License for the specific language             }
{    governing rights and limitations under the License.               }
{                                                                      }
{    The Initial Developer of the Original DWS Code is Matthias        }
{    Ackermann.                                                        }
{    For other initial contributors, see DWS contributors.txt          }
{    Ackermann.                                                        }
{    DWS code is currently maintained by Eric Grange.                  }
{                                                                      }
{    Current maintainer of the IDE utility: Brian Frost                }
{                                                                      }
{**********************************************************************}
unit UDwsIdeDemoForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  dwsExprs,
  Dialogs, StdCtrls, dwsComp, dwsFunctions, dwsVCLGUIFunctions;

type
  TBaseObj = class( TObject )
  PRIVATE
   FScriptObj : Variant;
  end;


  TSubObj1 = class( TBaseObj )
  PUBLIC
    function GetOne : integer;
  end;

  TDemoUnitObj = class( TBaseObj )
    constructor Create;
    destructor  Destroy; override;
  PRIVATE
    FSubObj1 : TSubObj1;
  PUBLIC
    function GetOne : integer;
    function GetSubObj1 : TSubObj1;
  end;


  TDwsIdeDemoForm = class(TForm)
    Button1: TButton;
    DelphiWebScript1: TDelphiWebScript;
    DemoUnit: TdwsUnit;
    procedure Button1Click(Sender: TObject);
    function DelphiWebScript1NeedUnit(const unitName: string;
      var unitSource: string): IdwsUnit;
    procedure dwsUnit1FunctionsMyUnitRecEval(info: TProgramInfo);
    procedure DemoUnitClassesTDemoUnitObjMethodsGetOneEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure DemoUnitInstancesDemoUnitObjInstantiate(info: TProgramInfo;
      var ExtObject: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DemoUnitClassesTSubObj1MethodsGetOneEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure DemoUnitClassesTDemoUnitObjMethodsGetSubObj1Eval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure DemoUnitClassesTDemoUnitObjConstructorsCreateEval(
      Info: TProgramInfo; var ExtObject: TObject);
    procedure DemoUnitClassesTSubObj1ConstructorsCreateEval(Info: TProgramInfo;
      var ExtObject: TObject);
    procedure DemoUnitClassesTDemoUnitObjCleanUp(ExternalObject: TObject);
    procedure DemoUnitClassesTSubObj1CleanUp(ExternalObject: TObject);
  private
    { Private declarations }
    FDemoUnitObj : TDemoUnitObj;
  public
    { Public declarations }
  end;


var
  DwsIdeDemoForm: TDwsIdeDemoForm;

implementation

{$R *.dfm}
uses
  SynHighlighterDWS,
  UDwsIdeDefs,
  UDwsIdeForm;




procedure TDwsIdeDemoForm.Button1Click(Sender: TObject);
begin
  // This opens the IDE - note that there is an overloaded version which includes
  // some IDE options such as highlighter, font etc.
  DwsIDE_ShowModal( DelphiWebScript1 );
end;

function TDwsIdeDemoForm.DelphiWebScript1NeedUnit(const unitName: string;
  var unitSource: string): IdwsUnit;
var
  SL : TStrings;
  sFileName : string;
  I : integer;
begin
  for I := 0 to DelphiWebScript1.Config.ScriptPaths.Count-1 do
    begin
    sFileName := DelphiWebScript1.Config.ScriptPaths[I] + '\' + UnitName + '.pas';
    if FileExists( sFileName ) then
      begin
      SL := TStringList.Create;
      try
        SL.LoadFromFile( sFileName );
        UnitSource := SL.Text;
      finally
        SL.Free;
      end;
      Exit;
      end;
    end;
  Raise Exception.CreateFmt( 'Unit file name not found "%s"', [unitName]);
end;






procedure TDwsIdeDemoForm.DemoUnitClassesTDemoUnitObjCleanUp(
  ExternalObject: TObject);
begin
  if ExternalObject <> FDemoUnitObj then
    FreeAndNil( ExternalObject );
end;

procedure TDwsIdeDemoForm.DemoUnitClassesTDemoUnitObjConstructorsCreateEval(
  Info: TProgramInfo; var ExtObject: TObject);
begin
  ExtObject := TDemoUnitObj.Create;
end;

procedure TDwsIdeDemoForm.DemoUnitClassesTDemoUnitObjMethodsGetOneEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
  Info.ResultAsInteger:= (ExtObject as TDemoUnitObj).GetOne;
end;


procedure TDwsIdeDemoForm.DemoUnitClassesTDemoUnitObjMethodsGetSubObj1Eval(
  Info: TProgramInfo; ExtObject: TObject);
var
  DemoUnitObj: TDemoUnitObj;
  SubObj1 : TSubObj1;
begin
  DemoUnitObj := ExtObject as TDemoUnitObj;
  SubObj1 := DemoUnitObj.GetSubObj1;

  if VarIsEmpty(SubObj1.FScriptObj) then
    SubObj1.FScriptObj := Info.Vars[SubObj1.ClassName].GetConstructor('Create',
      SubObj1).Call.Value;
  Info.ResultAsVariant := SubObj1.FScriptObj;
end;





procedure TDwsIdeDemoForm.DemoUnitClassesTSubObj1CleanUp(
  ExternalObject: TObject);
begin
  FreeAndNil( ExternalObject );
end;

procedure TDwsIdeDemoForm.DemoUnitClassesTSubObj1ConstructorsCreateEval(
  Info: TProgramInfo; var ExtObject: TObject);
begin
  ExtObject := TSubObj1.Create;
end;

procedure TDwsIdeDemoForm.DemoUnitClassesTSubObj1MethodsGetOneEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
  Info.ResultAsInteger:= (ExtObject as TSubObj1).GetOne;
end;

procedure TDwsIdeDemoForm.DemoUnitInstancesDemoUnitObjInstantiate(
  info: TProgramInfo; var ExtObject: TObject);
begin
  If not Assigned( FDemoUnitObj ) then
   FDemoUnitObj := TDemoUnitObj.Create;

  ExtObject := FDemoUnitObj;
end;

procedure TDwsIdeDemoForm.dwsUnit1FunctionsMyUnitRecEval(info: TProgramInfo);
begin
  Info.Vars['Result'].Member['One'].Value:=1;
  Info.Vars['Result'].Member['Two'].Value:=2;
end;

procedure TDwsIdeDemoForm.FormDestroy(Sender: TObject);
begin
  FDemoUnitObj.Free;
end;

{ TDemoUnitObj }

constructor TDemoUnitObj.Create;
begin
  inherited;
  FSubObj1 := TSubObj1.Create;
end;

destructor TDemoUnitObj.Destroy;
begin
  FSubObj1.Free;
  inherited;
end;

function TDemoUnitObj.GetOne: integer;
begin
  Result := 1;
end;

function TDemoUnitObj.GetSubObj1: TSubObj1;
begin
  Result := FSubObj1;
end;

{ TSubObj1 }

function TSubObj1.GetOne: integer;
begin
  Result := 1;
end;

end.
