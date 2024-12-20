unit Unit1;

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.Dialogs, Xml.XMLDoc, Xml.XMLIntf, System.Variants, System.RegularExpressions,
  System.DateUtils, ACBrBase, ACBrDFe, ACBrCTe, Vcl.ComCtrls, Vcl.Buttons;

type
  TForm1 = class(TForm)
    btnCarregarCTe: TButton;
    edtPrestadorServico: TEdit;
    lblPrestadorServico: TLabel;
    edtChaveCTe: TEdit;
    lblChaveCTe: TLabel;
    edtModelo: TEdit;
    lblModelo: TLabel;
    edtNumDocumento: TEdit;
    lblNumDocumento: TLabel;
    edtSerie: TEdit;
    lblSerie: TLabel;
    edtID: TEdit;
    lblID: TLabel;
    lblDataEmissao: TLabel;
    lblDataAquisicao: TLabel;
    edtTipoCTe: TEdit;
    lblTipoCTe: TLabel;
    edtValorDocumento: TEdit;
    lblValorDocumento: TLabel;
    edtValorDesconto: TEdit;
    lblValorDesconto: TLabel;
    edtValorTotal: TEdit;
    lblValorTotal: TLabel;
    edtTipoFrete: TEdit;
    lblTipoFrete: TLabel;
    edtValorBaseICMS: TEdit;
    lblValorBaseICMS: TLabel;
    edtValorICMS: TEdit;
    lblValorICMS: TLabel;
    edtValorNaoTributado: TEdit;
    lblValorNaoTributado: TLabel;
    edtMunicipioOrigem: TEdit;
    lblMunicipioOrigem: TLabel;
    edtMunicipioDestino: TEdit;
    lblMunicipioDestino: TLabel;
    edtCSTICMS: TEdit;
    lblCSTICMS: TLabel;
    edtCFOP: TEdit;
    lblCFOP: TLabel;
    edtAliquotaICMS: TEdit;
    lblAliquotaICMS: TLabel;
    edtValorOperacao: TEdit;
    lblValorOperacao: TLabel;
    edtValorBaseCalculo: TEdit;
    lblValorBaseCalculo: TLabel;
    edtValorICMS2: TEdit;
    lblValorICMS2: TLabel;
    edtValorReducaoICMS: TEdit;
    lblValorReducaoICMS: TLabel;
    edtCodigoIBGEOrigem: TEdit;
    lblCodigoIBGEOrigem: TLabel;
    edtCodigoIBGEDestino: TEdit;
    lblCodigoIBGEDestino: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    ACBrCTe1: TACBrCTe;
    edtDataEmissao: TDateTimePicker;
    edtDataAquisicao: TDateTimePicker;
    SpeedButton1Click: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    procedure btnCarregarCTeClick(Sender: TObject);
    procedure edtValorDocumentoExit(Sender: TObject);
    procedure edtValorDescontoExit(Sender: TObject);
    procedure edtValorTotalExit(Sender: TObject);
    procedure edtValorBaseICMSExit(Sender: TObject);
    procedure edtValorICMSExit(Sender: TObject);
    procedure edtValorNaoTributadoExit(Sender: TObject);
    procedure edtAliquotaICMSChange(Sender: TObject);
    procedure edtValorOperacaoExit(Sender: TObject);
    procedure edtValorBaseCalculoExit(Sender: TObject);
    procedure edtValorICMS2Exit(Sender: TObject);
    procedure edtValorReducaoICMSExit(Sender: TObject);
  private
    procedure PreencherCampos(XMLDocument: IXMLDocument);
    function ExtrairNumeros(const Texto: string): string;
    function ObterValorOuZero(const Valor: Variant): string;
    function SubstituirPontoPorVirgula(const Valor: string): string;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnCarregarCTeClick(Sender: TObject);
var
  CaminhoArquivo: string;
  XMLDocument: IXMLDocument;
begin
  with TOpenDialog.Create(Self) do
  try
    Filter := 'Arquivo XML|*.xml';
    if Execute then
    begin
      CaminhoArquivo := FileName;
      XMLDocument := LoadXMLDocument(CaminhoArquivo);

      // Preencher os campos
      PreencherCampos(XMLDocument);
    end;
  finally
    Free;
  end;
end;

procedure TForm1.PreencherCampos(XMLDocument: IXMLDocument);
var
  RootNode, CTeNode, InfCteNode, IdeNode, EmitNode, VPrestNode, ImpNode: IXMLNode;
  RemNode, DestNode, ImpICMSNode: IXMLNode;
  NamespaceURI: string;
  DataEmissao: TDateTime;  // Vari�vel para armazenar a data
begin
  // Obter o namespace padr�o do XML
  NamespaceURI := 'http://www.portalfiscal.inf.br/cte';

  RootNode := XMLDocument.DocumentElement;

  // Navegar at� o n� CTe
  CTeNode := RootNode.ChildNodes.FindNode('CTe', NamespaceURI);
  if CTeNode = nil then Exit;

  // Navegar at� o n� infCte
  InfCteNode := CTeNode.ChildNodes.FindNode('infCte', NamespaceURI);
  if InfCteNode = nil then Exit;

  // Chave da CT-e (extrair apenas n�meros)
  edtChaveCTe.Text := ExtrairNumeros(VarToStr(InfCteNode.Attributes['Id']));

  // Navegar at� o n� ide
  IdeNode := InfCteNode.ChildNodes.FindNode('ide', NamespaceURI);
  if IdeNode <> nil then
  begin
    // Modelo
    edtModelo.Text := ObterValorOuZero(IdeNode.ChildValues['mod']);
    // N� Documento
    edtNumDocumento.Text := ObterValorOuZero(IdeNode.ChildValues['nCT']);
    // S�rie
    edtSerie.Text := ObterValorOuZero(IdeNode.ChildValues['serie']);
    // ID (remover zeros � esquerda)
    edtID.Text := IntToStr(StrToIntDef(ExtrairNumeros(ObterValorOuZero(IdeNode.ChildValues['cCT'])), 0));

    // Data de Emiss�o (converter para o formato dd/mm/yyyy)
    if TryISO8601ToDate(ObterValorOuZero(IdeNode.ChildValues['dhEmi']), DataEmissao) then
    begin
      edtDataEmissao.Date := DataEmissao;
      // Atribuir a mesma data para o campo de aquisi��o/presta��o
      edtDataAquisicao.Date := DataEmissao;
    end
    else
    begin
      edtDataEmissao.Date := Now; // Define uma data padr�o (data atual) para valores inv�lidos
      edtDataAquisicao.Date := Now;
      ShowMessage('Data Inv�lida'); // Exibe uma mensagem de erro
    end;

    // Tipo CT-e
    edtTipoCTe.Text := ObterValorOuZero(IdeNode.ChildValues['tpCTe']);
    // CFOP
    edtCFOP.Text := ObterValorOuZero(IdeNode.ChildValues['CFOP']);
    // Tipo Frete (modal)
    edtTipoFrete.Text := ObterValorOuZero(IdeNode.ChildValues['modal']);

    // C�digo IBGE e Munic�pios
    edtCodigoIBGEOrigem.Text := ObterValorOuZero(IdeNode.ChildValues['cMunIni']); // C�digo IBGE de origem
    edtMunicipioOrigem.Text := ObterValorOuZero(IdeNode.ChildValues['xMunIni']);   // Nome do munic�pio de origem

    edtCodigoIBGEDestino.Text := ObterValorOuZero(IdeNode.ChildValues['cMunFim']); // C�digo IBGE de destino
    edtMunicipioDestino.Text := ObterValorOuZero(IdeNode.ChildValues['xMunFim']);  // Nome do munic�pio de destino
  end;

  // Navegar at� o n� emit
  EmitNode := InfCteNode.ChildNodes.FindNode('emit', NamespaceURI);
  if EmitNode <> nil then
  begin
    // Prestador do Servi�o
    edtPrestadorServico.Text := ObterValorOuZero(EmitNode.ChildValues['xNome']);
  end;

  // Navegar at� o n� vPrest
  VPrestNode := InfCteNode.ChildNodes.FindNode('vPrest', NamespaceURI);
  if VPrestNode <> nil then
  begin
    // Valor Documento (Substituir "." por ",")
    edtValorDocumento.Text := SubstituirPontoPorVirgula(ObterValorOuZero(VPrestNode.ChildValues['vTPrest']));

    // Valor Total (Substituir "." por ",")
    edtValorTotal.Text := SubstituirPontoPorVirgula(ObterValorOuZero(VPrestNode.ChildValues['vRec']));

    // Valor Desconto
    edtValorDesconto.Text := '0'; // N�o est� presente diretamente, ent�o atribu�mos 0
  end;

  // Navegar at� o n� imp
  ImpNode := InfCteNode.ChildNodes.FindNode('imp', NamespaceURI);
  if ImpNode <> nil then
  begin
    // Navegar at� o n� ICMS
    ImpICMSNode := ImpNode.ChildNodes.FindNode('ICMS', NamespaceURI);
    if ImpICMSNode <> nil then
    begin
      // Navegar at� o n� filho (ICMS00, ICMSSN, etc.)
      if ImpICMSNode.HasChildNodes then
      begin
        ImpICMSNode := ImpICMSNode.ChildNodes[0]; // Pega o primeiro filho

        // CST ICMS
        edtCSTICMS.Text := ObterValorOuZero(ImpICMSNode.ChildValues['CST']);
        // Al�quota ICMS
        edtAliquotaICMS.Text := ObterValorOuZero(ImpICMSNode.ChildValues['pICMS']);
        // Valor Base de C�lculo ICMS
        edtValorBaseICMS.Text := ObterValorOuZero(ImpICMSNode.ChildValues['vBC']);
        // Valor ICMS
        edtValorICMS.Text := ObterValorOuZero(ImpICMSNode.ChildValues['vICMS']);

        // Valor Base Calculo (Adicionar ao campo Valor Opera��o)
        edtValorOperacao.Text := ObterValorOuZero(ImpICMSNode.ChildValues['vBC']);

        // Valor Redu��o ICMS (Novo)
        edtValorReducaoICMS.Text := ObterValorOuZero(ImpICMSNode.ChildValues['vRedBC']);

        // Outros valores
        edtValorBaseCalculo.Text := ObterValorOuZero(ImpICMSNode.ChildValues['vBC']);
        edtValorICMS2.Text := ObterValorOuZero(ImpICMSNode.ChildValues['vICMS']);
      end;
    end;

    // Valor Total dos Tributos
    edtValorNaoTributado.Text := ObterValorOuZero(ImpNode.ChildValues['vTotTrib']);
  end;
end;

// Fun��o para substituir "." por ","
function TForm1.SubstituirPontoPorVirgula(const Valor: string): string;
begin
  Result := StringReplace(Valor, '.', ',', [rfReplaceAll]);
end;

procedure TForm1.edtAliquotaICMSChange(Sender: TObject);
var
  Valor: Double;
begin
  if TryStrToFloat(edtValorDocumento.Text, Valor) then
    edtValorDocumento.Text := FormatFloat('0,00', Valor)
  else
    edtValorDocumento.Text := '0,00'; // Valor padr�o caso o campo esteja vazio ou inv�lido
end;

procedure TForm1.edtValorBaseCalculoExit(Sender: TObject);
var
  Valor: Double;
begin
  if TryStrToFloat(edtValorDocumento.Text, Valor) then
    edtValorDocumento.Text := FormatFloat('0,00', Valor)
  else
    edtValorDocumento.Text := '0,00'; // Valor padr�o caso o campo esteja vazio ou inv�lido
end;

procedure TForm1.edtValorBaseICMSExit(Sender: TObject);
var
  Valor: Double;
begin
  if TryStrToFloat(edtValorDocumento.Text, Valor) then
    edtValorDocumento.Text := FormatFloat('0,00', Valor)
  else
    edtValorDocumento.Text := '0,00'; // Valor padr�o caso o campo esteja vazio ou inv�lido
end;

procedure TForm1.edtValorDescontoExit(Sender: TObject);
var
  Valor: Double;
begin
 if TryStrToFloat(edtValorDocumento.Text, Valor) then
    edtValorDocumento.Text := FormatFloat('0,00', Valor)
  else
    edtValorDocumento.Text := '0,00'; // Valor padr�o caso o campo esteja vazio ou inv�lido
end;

procedure TForm1.edtValorDocumentoExit(Sender: TObject);
var
  Valor: Double;
begin
   if TryStrToFloat(edtValorDocumento.Text, Valor) then
    edtValorDocumento.Text := FormatFloat('0.00', Valor)
  else
    edtValorDocumento.Text := '0,00'; // Valor padr�o caso o campo esteja vazio ou inv�lido
end;

procedure TForm1.edtValorICMS2Exit(Sender: TObject);
var
  Valor: Double;
begin
  if TryStrToFloat(edtValorDocumento.Text, Valor) then
    edtValorDocumento.Text := FormatFloat('0.00', Valor)
  else
    edtValorDocumento.Text := '0,00'; // Valor padr�o caso o campo esteja vazio ou inv�lido
end;

procedure TForm1.edtValorICMSExit(Sender: TObject);
var
  Valor: Double;
begin
  if TryStrToFloat(edtValorDocumento.Text, Valor) then
    edtValorDocumento.Text := FormatFloat('0.00', Valor)
  else
    edtValorDocumento.Text := '0,00'; // Valor padr�o caso o campo esteja vazio ou inv�lido
end;

procedure TForm1.edtValorNaoTributadoExit(Sender: TObject);
var
  Valor: Double;
begin
  if TryStrToFloat(edtValorDocumento.Text, Valor) then
    edtValorDocumento.Text := FormatFloat('0.00', Valor)
  else
    edtValorDocumento.Text := '0,00'; // Valor padr�o caso o campo esteja vazio ou inv�lido
end;

procedure TForm1.edtValorOperacaoExit(Sender: TObject);
var
  Valor: Double;
begin
  if TryStrToFloat(edtValorDocumento.Text, Valor) then
    edtValorDocumento.Text := FormatFloat('0.,00', Valor)
  else
    edtValorDocumento.Text := '0,00'; // Valor padr�o caso o campo esteja vazio ou inv�lido
end;

procedure TForm1.edtValorReducaoICMSExit(Sender: TObject);
var
  Valor: Double;
begin
  if TryStrToFloat(edtValorDocumento.Text, Valor) then
    edtValorDocumento.Text := FormatFloat('0.00', Valor)
  else
    edtValorDocumento.Text := '0,00'; // Valor padr�o caso o campo esteja vazio ou inv�lido
end;

procedure TForm1.edtValorTotalExit(Sender: TObject);
var
  Valor: Double;
begin
if TryStrToFloat(edtValorDocumento.Text, Valor) then
    edtValorDocumento.Text := FormatFloat('0.00', Valor)
  else
    edtValorDocumento.Text := '0,00'; // Valor padr�o caso o campo esteja vazio ou inv�lido
end;

function TForm1.ExtrairNumeros(const Texto: string): string;
begin
  // Utiliza express�o regular para extrair apenas os n�meros
  Result := TRegEx.Replace(Texto, '\D', '');
end;

function TForm1.ObterValorOuZero(const Valor: Variant): string;
begin
  // Retorna o valor, ou "0" se estiver vazio ou indefinido
  if VarIsNull(Valor) or VarIsEmpty(Valor) then
    Result := '0'
  else
    Result := VarToStr(Valor);
end;

end.

