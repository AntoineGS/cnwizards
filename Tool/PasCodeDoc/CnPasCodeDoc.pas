{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2023 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnPasCodeDoc;

{$I CnPack.inc}

interface

uses
  Classes, SysUtils, Contnrs;

type
  ECnPasCodeDocException = class(Exception);
  {* ���������ĵ��쳣}

  TCnDocType = (dtUnit, dtConst, dtVar, dtProcedure, dtProperty, dtClass, dtInterface, dtRecord);
  {* ֧���ĵ���Ԫ������}

  TCnDocScope = (dsNone, dsPrivate, dsProtected, dsPublic, dsPublished);
  {* Ԫ�صĿɼ��ԣ��޿ɼ��Ե�Ϊ dsNone}

  TCnDocBaseItem = class(TObject)
  {* �����ĵ�Ԫ�صĻ���}
  private
    FItems: TObjectList;
    FDeclareName: string;
    FDeclareType: string;
    FComment: string;
    FOwner: TCnDocBaseItem;
    FScope: TCnDocScope;
    function GetItem(Index: Integer): TCnDocBaseItem;
    procedure SetItem(Index: Integer; const Value: TCnDocBaseItem);
    function GetCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function AddItem(Item: TCnDocBaseItem): Integer;
    {* ���һ���ⲿ�Ѿ������õ��ĵ������ڲ��б�������}

    procedure DumpToStrings(Strs: TStrings; Indent: Integer = 0);
    {* �����ݱ��浽�ַ����б���}

    property DeclareName: string read FDeclareName write FDeclareName;
    {* �����͵Ķ������ƣ���ͬ�������в�ͬ�Ĺ涨}
    property DeclareType: string read FDeclareType write FDeclareType;
    {* �����͵Ķ������ͣ���ͬ������Ҳ�в�ͬ����;}
    property Comment: string read FComment write FComment;
    {* ��Ԫ�ص�ע���ĵ�}
    property Scope: TCnDocScope read FScope write FScope;
    {* ��Ԫ�صĿɼ���}
    property Owner: TCnDocBaseItem read FOwner write FOwner;
    {* ��Ԫ�ش�����һ����Ԫ��}

    property Items[Index: Integer]: TCnDocBaseItem read GetItem write SetItem; default;
    {* ��Ԫ�ص���Ԫ���б�}
    property Count: Integer read GetCount;
    {* ��Ԫ�ص���Ԫ������}
  end;

  TCnDocUnit = class(TCnDocBaseItem)
  {* ����һ��������ĵ��еĵ�Ԫ�Ķ���}
  end;

  TCnConstDocItem = class(TCnDocBaseItem)
  {* ����һ��������ĵ��еĳ�������}
  end;

  TCnVarDocItem = class(TCnDocBaseItem)
  {* ����һ��������ĵ��еı�������}
  end;

  TCnProcedureDocItem = class(TCnDocBaseItem)
  {* ����һ��������ĵ��еĺ������̶���}
  end;

  TCnTypeDocItem = class(TCnDocBaseItem)
  {* ����һ��������ĵ��е����Ͷ���}
  end;

  TCnPropertyDocItem = class(TCnDocBaseItem)
  {* ����һ��������ĵ��е����Զ���}
  end;

function CreateUnitDocFromFileName(const FileName: string): TCnDocUnit;
{* ����Դ���ļ��������ڲ��Ĵ���ע�ͣ������´����ĵ�Ԫע�Ͷ������}

implementation

uses
  CnPascalAst, mPasLex;

const
  COMMENT_NODE_TYPE = [cntLineComment, cntBlockComment];
  COMMENT_NONE = '<none>';

{ TCnDocBaseItem }

function TCnDocBaseItem.AddItem(Item: TCnDocBaseItem): Integer;
begin
  FItems.Add(Item);
  Item.Owner := Self;
  Result := FItems.Count;
end;

constructor TCnDocBaseItem.Create;
begin
  FItems := TObjectList.Create(True);
end;

destructor TCnDocBaseItem.Destroy;
begin
  inherited;
  FItems.Free;
end;

procedure TCnDocBaseItem.DumpToStrings(Strs: TStrings; Indent: Integer);
var
  I: Integer;

  function Spcs(Cnt: Integer): string;
  begin
    if Cnt < 0 then
      Result := ''
    else
    begin
      SetLength(Result, Cnt);
      FillChar(Result[1], Cnt, 32);
    end;
  end;

begin
  if Indent < 0 then
    Indent := 0;

  Strs.Add(Spcs(Indent * 2) + FDeclareName);
//  Strs.Add(Spcs(Indent * 2) + FDeclareType);
  Strs.Add(Spcs(Indent * 2) + FComment);
  Strs.Add('');

  for I := 0 to FItems.Count - 1 do
    Items[I].DumpToStrings(Strs, Indent + 1);
end;

function TCnDocBaseItem.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TCnDocBaseItem.GetItem(Index: Integer): TCnDocBaseItem;
begin
  Result := TCnDocBaseItem(FItems[Index]);
end;

procedure TCnDocBaseItem.SetItem(Index: Integer;
  const Value: TCnDocBaseItem);
begin
  FItems[Index] := Value;
end;

function CreateUnitDocFromFileName(const FileName: string): TCnDocUnit;
var
  AST: TCnPasAstGenerator;
  SL: TStrings;
  TempLeaf, UnitLeaf, IntfLeaf: TCnPasAstLeaf;
  I: Integer;

  function DocSkipToChild(ParentLeaf: TCnPasAstLeaf; var Index: Integer;
    MatchedNodeTypes: TCnPasNodeTypes; MatchedTokenKinds: TTokenKinds): TCnPasAstLeaf;
  begin
    // �� ParentLeaf �ĵ� Index ���ӽڵ㿪ʼ�ҷ��ϵĽڵ㣬���ط��ϵģ����� nil
    Result := nil;
    if Index >= ParentLeaf.Count then
      Exit;

    while Index < ParentLeaf.Count do
    begin
      if (ParentLeaf[Index].NodeType in MatchedNodeTypes) and
        (ParentLeaf[Index].TokenKind in MatchedTokenKinds) then
      begin
        Result := ParentLeaf[Index];
        Exit;
      end;
      Inc(Index);
    end;
  end;

  // �� ParentLeaf �ĵ� Index ���ӽڵ����ռ�ע�Ͳ�ƴһ�顣
  // ��� Index ��ע�ʹ����� Index �Ჽ�������һ��ע�ʹ������� Index ��һ
  function DocCollectComments(ParentLeaf: TCnPasAstLeaf; var Index: Integer): string;
  begin
    if (Index < ParentLeaf.Count) and (ParentLeaf[Index].NodeType in COMMENT_NODE_TYPE) then
    begin
      // ��ʾ��ע�ͣ�������ӵ�һ��
      SL.Clear;
      repeat
        SL.Add(ParentLeaf[Index].Text);
        Inc(Index);
      until (Index >= ParentLeaf.Count) or not (ParentLeaf[Index].NodeType in COMMENT_NODE_TYPE);
      Dec(Index); // �ص����һ��ע�ʹ�

      Result := Trim(SL.Text);
    end
    else
    begin
      Result := COMMENT_NONE;
      if Index > 0 then
        Dec(Index);
    end;
  end;

  // �����ӽڵ�����һ�����У�CONSTDECL���ӽڵ������ƣ����ֺš�����ע�Ϳ�
  procedure DocFindConsts(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
  var
    K: Integer;
    Leaf: TCnPasAstLeaf;
    Item: TCnConstDocItem;
  begin
    K := 0;
    while K < ParentLeaf.Count do
    begin
      Leaf := DocSkipToChild(ParentLeaf, K, [cntConstDecl], [tkNone]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Const Decl Exists.');

      Item := TCnConstDocItem.Create;
      if Leaf.Count > 0 then
        Item.DeclareName := Leaf[0].Text; // ������

      Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Const Semicolon Exists.');

      Inc(K); // ��������һ��������ע�͵ĵط��������ע�ͣ�K ָ��ע��ĩβ��������ǣ�K ���һ�Ե����˴β���
      Item.Comment := DocCollectComments(ParentLeaf, K);
      OwnerItem.AddItem(Item);
      Inc(K);
    end;
  end;

  // �����ӽڵ�����һ�����У�VARDECL���ӽڵ������ƣ����ֺš�����ע�Ϳ�
  procedure DocFindVars(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
  var
    K: Integer;
    Leaf: TCnPasAstLeaf;
    Item: TCnVarDocItem;
  begin
    K := 0;
    while K < ParentLeaf.Count do
    begin
      Leaf := DocSkipToChild(ParentLeaf, K, [cntVarDecl], [tkNone]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Var Decl Exists.');

      Item := TCnVarDocItem.Create;
      if Leaf.Count > 0 then
        if Leaf[0].Count > 0 then
          Item.DeclareName := Leaf[0][0].Text; // IDENTList �ĵ�һ��������

      Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Var Semicolon Exists.');

      Inc(K); // ��������һ��������ע�͵ĵط��������ע�ͣ�K ָ��ע��ĩβ��������ǣ�K ���һ�Ե����˴β���
      Item.Comment := DocCollectComments(ParentLeaf, K);
      OwnerItem.AddItem(Item);
      Inc(K);
    end;
  end;

  // ��ͬ���ڵ�����һ�飺procedure/function���ӽڵ������ƣ����ֺš�����ע�Ϳ�
  // ע������ ParentLeaf �� procedure/function �ڵ㣬Index �Ǹýڵ��ڸ��ڵ��е�����
  procedure DocFindProcedures(ParentLeaf: TCnPasAstLeaf; var Index: Integer; OwnerItem: TCnDocBaseItem);
  var
    K: Integer;
    Leaf, P: TCnPasAstLeaf;
    Item: TCnProcedureDocItem;
  begin
    K := 0;
    Leaf := DocSkipToChild(ParentLeaf, K, [cntIdent], [tkIdentifier]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create('NO Procedure/Function Ident Exists.');

    Item := TCnProcedureDocItem.Create;
    Item.DeclareName := Leaf.Text; // ����������

    // ����һ��ȥ�ҷֺ���ע��
    P := ParentLeaf.Parent;
    Leaf := DocSkipToChild(P, Index, [cntSemiColon], [tkSemiColon]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create('NO Procedure/Function Semicolon Exists.');

    Inc(Index); // ��������һ��������ע�͵ĵط��������ע�ͣ�Index ָ��ע��ĩβ��������ǣ�Index ���һ�Ե����˴β���
    Item.Comment := DocCollectComments(P, Index);
    OwnerItem.AddItem(Item);
  end;

  // ����һ�� property��ParentLeaf �� Property ��Ψһ���ڵ㣬��������ӽڵ�
  procedure DocFindProperty(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
  var
    K: Integer;
    Leaf: TCnPasAstLeaf;
    Item: TCnPropertyDocItem;
  begin
    K := 0;
    Leaf := DocSkipToChild(ParentLeaf, K, [cntIdent], [tkIdentifier]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create('NO Property Ident Exists.');

    Item := TCnPropertyDocItem.Create;
    Item.DeclareName := Leaf.Text;

    Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create('NO Property Semicolon Exists.');

    Inc(K);
    Item.Comment := DocCollectComments(ParentLeaf, K);
    OwnerItem.AddItem(Item);
  end;

  // ���� interface �� class �ĳ�Ա����������/���̡�Field�����Ե�
  procedure DocFindMembers(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
  var
    K: Integer;
    Leaf: TCnPasAstLeaf;
  begin
    K := 0;
    while K < ParentLeaf.Count do
    begin
      Leaf := ParentLeaf[K];
      if Leaf.NodeType in [cntProcedure, cntFunction] then
      begin
        DocFindProcedures(Leaf, K, OwnerItem);
        Inc(K);
      end
      else if Leaf.NodeType = cntProperty then
      begin
        DocFindProperty(Leaf, OwnerItem);
        Inc(K);
      end
      else
      begin
        Inc(K);
      end;
    end;
  end;

  // �����ӽڵ�����һ�����У�TYPEDECL���ӽڵ������ƣ����ֺš������еĵ���ע�Ϳ�
  procedure DocFindTypes(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
  var
    K, J: Integer;
    Leaf, ClassIntfRoot: TCnPasAstLeaf;
    Item: TCnTypeDocItem;
    IsIntf, IsClass: Boolean;
  begin
    K := 0;
    while K < ParentLeaf.Count do
    begin
      Leaf := DocSkipToChild(ParentLeaf, K, [cntTypeDecl], [tkNone]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Type Decl Exists.');

      Item := TCnTypeDocItem.Create;
      if Leaf.Count > 0 then
        Item.DeclareName := Leaf[0].Text; // ���õ�������

      // �ж� Leaf ���±�Ϊ 2 ���ӽڵ����ͣ������ RESTRICTEDTYPE�����ʾ�� interface��class ���⴦��
      // ����� COMMMONTYPE ���ٺ�������ӽڵ��� packed record ��һ�� record��ҲҪ���⴦��
      IsIntf := False;
      IsClass := False;
      if (Leaf.Count >= 2) and (Leaf[2].NodeType = cntRestrictedType) then
      begin
        if Leaf[2].Count > 0 then
        begin
          ClassIntfRoot := Leaf[2][0];
          if Leaf[2][0].NodeType = cntInterfaceType then
          begin
            IsIntf := True;
            J := 0;
            if (ClassIntfRoot.Count > 0) and (ClassIntfRoot[0].NodeType in COMMENT_NODE_TYPE) then
            begin
              // �޼̳й�ϵʱ���ýӿڵ�ע�Ϳ����� Leaf[2][0] �ĵ� 0 ���ӽڵ�
              Item.Comment := DocCollectComments(ClassIntfRoot, J);
            end
            else if (ClassIntfRoot.Count > 0) and (ClassIntfRoot[0].NodeType = cntInterfaceHeritage) then
            begin
              // �м̳й�ϵʱ���ýӿڵ�ע�Ϳ����� Leaf[2][0] �ĵ� 0 ���ӽڵ���ӽڵ��������ź��
              Leaf := ClassIntfRoot[0];
              if Leaf.Count > 0 then
              begin
                J := 0;
                Leaf := DocSkipToChild(Leaf, J, [cntRoundClose], [tkRoundClose]);
                if Leaf <> nil then
                begin
                  Inc(J);
                  Item.Comment := DocCollectComments(Leaf, J);
                end;
              end;
            end;
          end
          else if Leaf[2][0].NodeType = cntClassType then
          begin
            IsClass := True;
            J := 0;
            if (ClassIntfRoot.Count > 0) and (ClassIntfRoot[0].NodeType in COMMENT_NODE_TYPE) then
            begin
              // �޼̳й�ϵʱ�������ע�Ϳ����� Leaf[2][0] �ĵ� 0 ���ӽڵ�
              Item.Comment := DocCollectComments(ClassIntfRoot, J);
            end
            else if (ClassIntfRoot.Count > 0) and (ClassIntfRoot[0].NodeType = cntClassBody) then
            begin
              // �м̳й�ϵʱ���ýӿڵ�ע�Ϳ����� Leaf[2][0] �ĵ� 0 ���ӽڵ�ĵ� 0 ���ӽڵ���������ź��
              ClassIntfRoot := ClassIntfRoot[0]; // Class Body
              if ClassIntfRoot.Count > 0 then
                Leaf := ClassIntfRoot[0];        // Class Heritage

              if Leaf.Count > 0 then
              begin
                J := 0;
                Leaf := DocSkipToChild(Leaf, J, [cntRoundClose], [tkRoundClose]);
                if Leaf <> nil then
                begin
                  Inc(J);
                  Item.Comment := DocCollectComments(Leaf, J);
                end;
              end;
            end;
          end;
        end;
      end;

      if IsIntf or IsClass then
      begin
        // ClassIntfRoot ָ��Ƚ�ͨ�õ�һ�����ڵ㣬ClassBody �� interface
        // ���������������ݣ��� K ��������ϵ�λ��
        DocFindMembers(ClassIntfRoot, Item);
        OwnerItem.AddItem(Item);

        Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
        if Leaf = nil then
          raise ECnPasCodeDocException.Create('NO Type Semicolon Exists.');
        // �ҷֺţ���ûע����
        Inc(K);
      end
      else // ������ͨ����
      begin
        Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
        if Leaf = nil then
          raise ECnPasCodeDocException.Create('NO Type Semicolon Exists.');

        Inc(K); // ��������һ��������ע�͵ĵط��������ע�ͣ�K ָ��ע��ĩβ��������ǣ�K ���һ�Ե����˴β���
        Item.Comment := DocCollectComments(ParentLeaf, K);
        OwnerItem.AddItem(Item);
        Inc(K);
      end;
    end;
  end;


begin
  Result := nil;
  if not FileExists(FileName) then
    Exit;

  AST := nil;
  SL := nil;

  try
    SL := TStringList.Create;
    SL.LoadFromFile(FileName);

    AST := TCnPasAstGenerator.Create(SL.Text);
    AST.Build;

    // Root ������ֱ���� Unit �ڵ㣬Unit ���ӽڵ��Ƿֺš����֡�֮�������ע��ƴ��ע�͡�
    // ֮���� interface �ڵ㡣�� interface �ڵ�Ϊ���ڵ�ֱ���ֱ���� const��type��var��procedure��function ��ֱ���ڵ�
    // ���ÿ���ڵ㣬�����������ӽڵ㲢��ע�͡�
    UnitLeaf := nil;
    for I := 0 to AST.Tree.Root.Count - 1 do
    begin
      if (AST.Tree.Root.Items[I].NodeType = cntUnit) and (AST.Tree.Root.Items[I].TokenKind = tkUnit) then
      begin
        UnitLeaf := AST.Tree.Root.Items[I];
        Break;
      end;
    end;

    if UnitLeaf = nil then
      raise ECnPasCodeDocException.Create('NO Unit Exists.');

    Result := TCnDocUnit.Create;

    // �� Unit ��
    I := 0;
    TempLeaf := DocSkipToChild(UnitLeaf, I, [cntIdent], [tkIdentifier]);
    if TempLeaf <> nil then
      Result.DeclareName := TempLeaf.Text;

    // �ҷֺ�
    TempLeaf := DocSkipToChild(UnitLeaf, I, [cntSemiColon], [tkSemiColon]);
    if TempLeaf = nil then
      raise ECnPasCodeDocException.Create('NO Unit Semicolon Exists.');

    // �ҷֺź��һ��ע��
    Inc(I);
    Result.Comment := DocCollectComments(UnitLeaf, I);

    // �� interface �ڵ�
    IntfLeaf := DocSkipToChild(UnitLeaf, I, [cntInterfaceSection], [tkInterface]);
    if IntfLeaf = nil then
      raise ECnPasCodeDocException.Create('NO InterfaceSection Part Exists.');

    // �� interface �ڵ��µ�ֱ���ڵ��ǲ�����
    I := 0;
    while I < IntfLeaf.Count do
    begin
      case IntfLeaf[I].NodeType of
        cntConstSection: // ���� const �� resourcestring
          begin
            DocFindConsts(IntfLeaf[I], Result);
          end;
        cntVarSection:   // var ��
          begin
            DocFindVars(IntfLeaf[I], Result);
          end;
        cntTypeSection:  // ������
          begin
            // �����ӽڵ����������
            // �����ͣ�����һ�����У�TYPEDECL���ӽڵ������ƣ����ֺš�����ע�Ϳ�
            // �� class/record/interface �ȵ� TYPEDECL��ע�Ϳ������ڲ�
            DocFindTypes(IntfLeaf[I], Result);
          end;
        cntProcedure, cntFunction:
          begin
            DocFindProcedures(IntfLeaf[I], I, Result);
          end;
      end;
      Inc(I);
    end;
  finally
    SL.Free;
    AST.Free;
  end;
end;

end.
