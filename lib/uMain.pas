unit uMain;

interface

uses
  uConnection, FireDAC.Stan.Param, uConsumpion;

function GetListConsumpionComposition(aID : Integer) : TSQuery;
procedure ActionModif(aData : TConsumpionData);

implementation

uses
  Data.DB, uResStrings, System.SysUtils;

function GetListConsumpionComposition(aID : Integer) : TSQuery;
var
  oQuery: TMyQuery;
begin
  Result := TSQuery.Create(
    Connect,
    'SELECT '+sLineBreak+
    '   cc.ID, '+sLineBreak+
    '  	cc.ConsumpionID, '+sLineBreak+
    '   cc.Count as GoodCount, '+sLineBreak+
    '   cc.GoodID as GoodID, '+sLineBreak+
    '   cc.ID, '+sLineBreak+
    '   cc.Price as GoodPrice, '+sLineBreak+
    '   cc.Sum as GoodSum, '+sLineBreak+
	  '   g.Name as GoodName '+sLineBreak+
    ' '+sLineBreak+
    'FROM Consumpion_Compositions cc '+sLineBreak+
    'INNER JOIN Goods g ON (g.ID = cc.GoodID) '+sLineBreak+
    ' '+sLineBreak+
    'WHERE cc.ConsumpionID = :ID'
    );
  Result.Query.ParamByName('ID').AsInteger := aID;
  if Not Result.Open(oQuery) then
  begin
    FreeAndNil(Result);
  end;
end;

procedure ActionModif(aData : TConsumpionData);
var
  oSQLDelete: TSQuery;
  oSQLModif: TSQuery;
  oSQLNew: TSQuery;
  procedure CheckAndDelete(aValue : Integer);
  begin
    if aValue = 1 then
    begin
      oSQLDelete.Query.ParamByName('ID').Value := aData.ConsumpionID;
      oSQLDelete.ExecSQL();
    end;
  end;

  procedure CheckAndModif(aValue : Integer; aFields : TFields);
  var
    oField: TField;
  begin
    if aValue = 1 then
    begin
      oField := aFields.FindField(TConsumpionData_ID_FieldName);
      if oField = nil then
      begin
        Exit;
      end;
      oSQLModif.Query.ParamByName('ID').Value := oField.Value;
      oField := aFields.FindField(TConsumpionData_GoodCount_FieldName);
      if oField = nil then
      begin
        Exit;
      end;
      oSQLModif.Query.ParamByName('Count').Value := oField.Value;
      oField := aFields.FindField(TConsumpionData_GoodPrice_FieldName);
      if oField = nil then
      begin
        Exit;
      end;
      oSQLModif.Query.ParamByName('Price').Value := oField.Value;
      oSQLModif.ExecSQL();
    end;
  end;

  procedure CheckAndNew(aValue : Integer; aFields : TFields);
  var
    oField: TField;
  begin
    if aValue = 1 then
    begin
      oSQLNew.Query.ParamByName('ConsumpionID').Value := aData.ConsumpionID;

      oField := aFields.FindField(TConsumpionData_GoodID_FieldName);
      if oField = nil then
      begin
        Exit;
      end;
      oSQLNew.Query.ParamByName('GoodID').Value := oField.Value;
      oField := aFields.FindField(TConsumpionData_GoodCount_FieldName);
      if oField = nil then
      begin
        Exit;
      end;
      oSQLNew.Query.ParamByName('Count').Value := oField.Value;
      oField := aFields.FindField(TConsumpionData_GoodPrice_FieldName);
      if oField = nil then
      begin
        Exit;
      end;
      oSQLNew.Query.ParamByName('Price').Value := oField.Value;
      oSQLNew.ExecSQL();
    end;
  end;
begin
  aData.ListGoods.First;
  oSQLDelete := TSQuery.Create(Connect, 'DELETE Consumpion_Compositions WHERE ID = :ID');
  oSQLModif  := TSQuery.Create(Connect, 'UPDATE Consumpion_Compositions Set Count = :Count, Price = :Price WHERE ID = :ID');
  oSQLNew    := TSQuery.Create(Connect, 'INSERT Consumpion_Compositions (ConsumpionID, Count, GoodID, Price) VALUES (:ConsumpionID, :Count, :GoodID, :Price)');
  try
    while Not aData.ListGoods.Eof do
    begin
      CheckAndDelete(aData.ListGoods.FieldByName(TConsumpionData_Delete_FieldName).AsInteger);
      CheckAndModif(aData.ListGoods.FieldByName(TConsumpionData_Modif_FieldName).AsInteger, aData.ListGoods.Fields);
      CheckAndNew(aData.ListGoods.FieldByName(TConsumpionData_New_FieldName).AsInteger, aData.ListGoods.Fields);
      aData.ListGoods.Next;
    end;
  finally
    FreeAndNil(oSQLDelete);
    FreeAndNil(oSQLModif);
    FreeAndNil(oSQLNew);
  end;
end;

end.