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
  Strs.Add(Spcs(Indent * 2) + FDeclareType);
  Strs.Add(Spcs(Indent * 2) + FComment);

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

  function SkipToChild(ParentLeaf: TCnPasAstLeaf; var Index: Integer;
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

  function CollectComments(ParentLeaf: TCnPasAstLeaf; var Index: Integer): string;
  begin
    if (Index < ParentLeaf.Count) and (ParentLeaf[Index].NodeType in COMMENT_NODE_TYPE) then
    begin
      // ��ʾ��ע�ͣ�������ӵ�һ��
      SL.Clear;
      repeat
        SL.Add(ParentLeaf[Index].Text);
        Inc(Index);
      until (Index >= ParentLeaf.Count) or not (ParentLeaf[Index].NodeType in COMMENT_NODE_TYPE);

      Result := Trim(SL.Text);
    end
    else
      Result := COMMENT_NONE;
  end;

  // �����ӽڵ�����һ�����У�CONSTDECL���ӽڵ������ƣ����ֺš�����ע�Ϳ�
  procedure FindConsts(ParentLeaf: TCnPasAstLeaf; OwerItem: TCnDocBaseItem);
  var
    K: Integer;
    Leaf: TCnPasAstLeaf;
    Item: TCnConstDocItem;
  begin
    K := 0;
    while K < ParentLeaf.Count do
    begin
      Leaf := SkipToChild(ParentLeaf, K, [cntConstDecl], [tkNone]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Const Decl Exists.');

      Item := TCnConstDocItem.Create;
      if Leaf.Count > 0 then
        Item.DeclareName := Leaf[0].Text; // ������

      Leaf := SkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Const Semicolon Exists.');

      Inc(K); // ��������һ��������ע�͵ĵط�
      Item.Comment := CollectComments(ParentLeaf, K);
      OwerItem.AddItem(Item);
      Inc(K);
    end;
  end;

  // �����ӽڵ�����һ�����У�VARDECL���ӽڵ������ƣ����ֺš�����ע�Ϳ�
  procedure FindVars(ParentLeaf: TCnPasAstLeaf; OwerItem: TCnDocBaseItem);
  var
    K: Integer;
    Leaf: TCnPasAstLeaf;
    Item: TCnVarDocItem;
  begin
    K := 0;
    while K < ParentLeaf.Count do
    begin
      Leaf := SkipToChild(ParentLeaf, K, [cntVarDecl], [tkNone]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Var Decl Exists.');

      Item := TCnVarDocItem.Create;
      if Leaf.Count > 0 then
        Item.DeclareName := Leaf[0].Text; // ������

      Leaf := SkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Var Semicolon Exists.');

      Inc(K); // ��������һ��������ע�͵ĵط�
      Item.Comment := CollectComments(ParentLeaf, K);
      OwerItem.AddItem(Item);
      Inc(K);
    end;
  end;

  // ��ͬ���ڵ�����һ�飺procedure/function���ӽڵ������ƣ����ֺš�����ע�Ϳ�
  // ע������ ParentLeaf �� procedure/function �ڵ㣬Index �Ǹýڵ��ڸ��ڵ��е�����
  procedure FindProcedures(ParentLeaf: TCnPasAstLeaf; var Index: Integer; OwerItem: TCnDocBaseItem);
  var
    K: Integer;
    Leaf, P: TCnPasAstLeaf;
    Item: TCnProcedureDocItem;
  begin
    K := 0;
    Leaf := SkipToChild(ParentLeaf, K, [cntIdent], [tkIdentifier]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create('NO Procedure/Function Ident Exists.');

    Item := TCnProcedureDocItem.Create;
    Item.DeclareName := Leaf.Text; // ����������

    // ����һ��ȥ�ҷֺ���ע��
    P := ParentLeaf.Parent;
    Leaf := SkipToChild(P, Index, [cntSemiColon], [tkSemiColon]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create('NO Procedure/Function Semicolon Exists.');

    Inc(Index); // ��������һ��������ע�͵ĵط�
    Item.Comment := CollectComments(P, Index);
    OwerItem.AddItem(Item);
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
    TempLeaf := SkipToChild(UnitLeaf, I, [cntIdent], [tkIdentifier]);
    if TempLeaf <> nil then
      Result.DeclareName := TempLeaf.Text;

    // �ҷֺ�
    TempLeaf := SkipToChild(UnitLeaf, I, [cntSemiColon], [tkSemiColon]);
    if TempLeaf = nil then
      raise ECnPasCodeDocException.Create('NO Unit Semicolon Exists.');

    // �ҷֺź��һ��ע��
    Inc(I);
    Result.Comment := CollectComments(UnitLeaf, I);

    // �� interface �ڵ�
    IntfLeaf := SkipToChild(UnitLeaf, I, [cntInterfaceSection], [tkInterface]);
    if IntfLeaf = nil then
      raise ECnPasCodeDocException.Create('NO InterfaceSection Part Exists.');

    // �� interface �ڵ��µ�ֱ���ڵ��ǲ�����
    I := 0;
    while I < IntfLeaf.Count do
    begin
      case IntfLeaf[I].NodeType of
        cntConstSection: // ���� const �� resourcestring
          begin
            FindConsts(IntfLeaf[I], Result);
          end;
        cntVarSection:   // var ��
          begin
            FindVars(IntfLeaf[I], Result);
          end;
        cntTypeSection:  // ������
          begin
            // �����ӽڵ����������
            // �����ͣ�����һ�����У�TYPEDECL���ӽڵ������ƣ����ֺš�����ע�Ϳ�
            // �� class/record/interface �ȵ� TYPEDECL��ע�Ϳ������ڲ�
          end;
        cntProcedure, cntFunction:
          begin
            FindProcedures(IntfLeaf[I], I, Result);
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
