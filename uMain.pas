unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IPPeerClient,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  System.Rtti, FMX.Grid.Style, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Controls,
  Data.Bind.Components, FMX.StdCtrls, FMX.Edit, FMX.Layouts, Fmx.Bind.Navigator,
  Data.Bind.Grid, Data.Bind.DBScope, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Grid, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  REST.Response.Adapter, REST.Client, Data.Bind.ObjectScope,
  FireDAC.Stan.StorageBin, System.IOUtils, FireDAC.Stan.StorageJSON, FMX.ListBox,
  FMX.MultiView, FMX.Objects, System.Actions, FMX.ActnList;

type
  TMainForm = class(TForm)
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    TickerMemTable: TFDMemTable;
    TickerGrid: TStringGrid;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    FDMemTable2: TFDMemTable;
    PLGrid: TStringGrid;
    BindNavigator1: TBindNavigator;
    BindSourceDB2: TBindSourceDB;
    LinkGridToDataSourceBindSourceDB2: TLinkGridToDataSource;
    Layout1: TLayout;
    Layout2: TLayout;
    IDEdit: TEdit;
    IDLBL: TLabel;
    Layout3: TLayout;
    ValueEdit: TEdit;
    ValueLBL: TLabel;
    Layout4: TLayout;
    ChangeEdit: TEdit;
    ChangeLBL: TLabel;
    Layout5: TLayout;
    BuyPriceEdit: TEdit;
    BuyPriceLBL: TLabel;
    Layout6: TLayout;
    AmountEdit: TEdit;
    AmountLBL: TLabel;
    Layout7: TLayout;
    PriceEdit: TEdit;
    PriceLBL: TLabel;
    Layout8: TLayout;
    SymbolEdit: TEdit;
    SymbolLBL: TLabel;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    LinkControlToField3: TLinkControlToField;
    LinkControlToField4: TLinkControlToField;
    LinkControlToField5: TLinkControlToField;
    LinkControlToField6: TLinkControlToField;
    LinkControlToField7: TLinkControlToField;
    Button1: TButton;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    ListBox1: TListBox;
    StyleBook1: TStyleBook;
    ToolBar1: TToolBar;
    CoinsBTN: TButton;
    MultiView1: TMultiView;
    Layout9: TLayout;
    ProfitLossEdit: TEdit;
    PLLBL: TLabel;
    PLText: TText;
    LinkControlToField8: TLinkControlToField;
    AddBTN: TButton;
    ActionList1: TActionList;
    AddCoinAction: TAction;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure AddBTNClick(Sender: TObject);
    procedure AddCoinActionExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.AddBTNClick(Sender: TObject);
begin
AddCoinAction.Execute;
end;

procedure TMainForm.AddCoinActionExecute(Sender: TObject);
begin
FDMemTable2.AppendRecord([ListBox1.Selected.Text]);
LinkGridToDataSourceBindSourceDB2.Active := False;
LinkGridToDataSourceBindSourceDB2.Active := True;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin

FDMemTable2.First;
while not FDMemTable2.EOF do
  begin
    RESTRequest1.Params.ParameterByName('id').Value := FDMemTable2.FieldByName('ID').AsString;
    RESTRequest1.Execute;

    TickerMemTable.First;
    if TickerMemTable.FieldByName('id').AsString = FDMemTable2.FieldByName('ID').AsString then
      begin
       FDMemTable2.Edit;
       FDMemTable2.FieldByName('price').AsString := TickerMemTable.FieldByName('price_usd').AsString;
       FDMemTable2.FieldByName('symbol').AsString := TickerMemTable.FieldByName('symbol').AsString;

       if (FDMemTable2.FieldByName('price').AsString<>'') AND (FDMemTable2.FieldByName('amount').AsString<>'') then
        begin
          FDMemTable2.FieldByName('value').AsCurrency := FDMemTable2.FieldByName('price').AsCurrency * FDMemTable2.FieldByName('amount').AsExtended;

          if (FDMemTable2.FieldByName('buyprice').AsString<>'') then
           begin
             FDMemTable2.FieldByName('change').AsCurrency := (FDMemTable2.FieldByName('price').AsCurrency - FDMemTable2.FieldByName('buyprice').AsCurrency);

             FDMemTable2.FieldByName('profitloss').AsCurrency := (FDMemTable2.FieldByName('change').AsCurrency * FDMemTable2.FieldByName('amount').AsExtended);
           end;
        end;

      end;
      FDMemTable2.Next;
  end;

  FDMemTable2.SaveToFile(ExtractFilePath(ParamStr(0))+'data.json',sfJSON);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
if TFile.Exists(ExtractFilePath(ParamStr(0))+'data.json') then
  FDMemTable2.LoadFromFile(ExtractFilePath(ParamStr(0))+'data.json',sfJSON);

end;

procedure TMainForm.ListBox1DblClick(Sender: TObject);
begin
AddCoinAction.Execute;
end;

end.
