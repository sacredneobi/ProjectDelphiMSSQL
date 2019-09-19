unit uConsumpion;

interface

uses
  FireDAC.Comp.Client, uConnection;

type
  TConsumpionData = class
  private
    FListGoods: TFDMemTable;
    FDone: Boolean;
    FClientID: Integer;
    FConsumpionID: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    property ConsumpionID: Integer read FConsumpionID write FConsumpionID;
    property Done: Boolean read FDone write FDone;
    property ClientID: Integer read FClientID write FClientID;
    property ListGoods: TFDMemTable read FListGoods;
    procedure LoadFromQuery(aQuery : TSQuery);
  end;

implementation

uses
  Data.DB, uResStrings, System.SysUtils;

{ TConsumpionData }

constructor TConsumpionData.Create;
var
  oFloatField : TFloatField;
  oStringField : TStringField;
  oIntField: TIntegerField;
begin
  FListGoods := TFDMemTable.Create(nil);

  oIntField := TIntegerField.Create(FListGoods);
  oIntField.FieldName := TConsumpionData_ID_FieldName;
  oIntField.FieldKind := fkData;
//  oIntField.Visible := False;
  oIntField.DataSet := FListGoods;

  oIntField := TIntegerField.Create(FListGoods);
  oIntField.DisplayLabel := TConsumpionData_GoodID;
  oIntField.FieldName := TConsumpionData_GoodID_FieldName;
  oIntField.FieldKind := fkData;
  oIntField.DataSet := FListGoods;

  oStringField := TStringField.Create(FListGoods);
  oStringField.DisplayLabel := TConsumpionData_GoodName;
  oStringField.FieldName := TConsumpionData_GoodName_FieldName;
  oStringField.Size := 255;
  oStringField.DisplayWidth := 100;
  oStringField.FieldKind := fkData;
  oStringField.DataSet := FListGoods;

  oFloatField := TFloatField.Create(FListGoods);
  oFloatField.DisplayLabel := TConsumpionData_GoodCount;
  oFloatField.FieldName := TConsumpionData_GoodCount_FieldName;
  oFloatField.FieldKind := fkData;
  oFloatField.DataSet := FListGoods;

  oFloatField := TFloatField.Create(FListGoods);
  oFloatField.DisplayLabel := TConsumpionData_GoodPrice;
  oFloatField.FieldName := TConsumpionData_GoodPrice_FieldName;
  oFloatField.FieldKind := fkData;
  oFloatField.DataSet := FListGoods;

  oFloatField := TFloatField.Create(FListGoods);
  oFloatField.DisplayLabel := TConsumpionData_GoodSum;
  oFloatField.FieldName := TConsumpionData_GoodSum_FieldName;
  oFloatField.FieldKind := fkData;
  oFloatField.DataSet := FListGoods;

  oIntField := TIntegerField.Create(FListGoods);
  oIntField.FieldName := TConsumpionData_Delete_FieldName;
  oIntField.FieldKind := fkData;
//  oIntField.Visible := False;
  oIntField.DataSet := FListGoods;

  oIntField := TIntegerField.Create(FListGoods);
  oIntField.FieldName := TConsumpionData_Modif_FieldName;
  oIntField.FieldKind := fkData;
//  oIntField.Visible := False;
  oIntField.DataSet := FListGoods;

  oIntField := TIntegerField.Create(FListGoods);
  oIntField.FieldName := TConsumpionData_New_FieldName;
  oIntField.FieldKind := fkData;
//  oIntField.Visible := False;
  oIntField.DataSet := FListGoods;

end;

destructor TConsumpionData.Destroy;
begin
  if Assigned(FListGoods) then
  begin
    FreeAndNil(FListGoods);
  end;
  inherited;
end;

procedure TConsumpionData.LoadFromQuery(aQuery: TSQuery);
var
  oMark: TBookmark;
  i: Integer;
  oField: TField;
begin
  oMark := aQuery.Query.GetBookmark;
  aQuery.Query.DisableControls;
  FListGoods.Active := False;
  FListGoods.Active := True;
  FListGoods.DisableControls;
  try
    aQuery.Query.First;
    while Not aQuery.Query.Eof do
    begin
      FListGoods.Append;
      for i := 0 to aQuery.Query.FieldCount-1 do
      begin
        oField := FListGoods.FindField(aQuery.Query.Fields[i].FieldName);
        if (oField <> nil) and (oField.DataType = aQuery.Query.Fields[i].DataType) then
        begin
          oField.Value := aQuery.Query.Fields[i].Value;
        end;
      end;
      FListGoods.FieldByName(TConsumpionData_Delete_FieldName).Value := 0;
      FListGoods.FieldByName(TConsumpionData_Modif_FieldName).Value := 0;
      FListGoods.FieldByName(TConsumpionData_New_FieldName).Value := 0;
      FListGoods.Post;
      aQuery.Query.Next;
    end;
  finally
    FListGoods.Filter := TConsumpionData_Delete_FieldName+' = 0';
    FListGoods.Filtered := True;
    FListGoods.First;
    FListGoods.EnableControls;
    aQuery.Query.Bookmark := oMark;
    aQuery.Query.EnableControls;
  end;
end;

end.
