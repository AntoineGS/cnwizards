{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2022 CnPack ������                       }
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

unit CnPascalAST;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�Pascal ��������﷨�����ɵ�Ԫ
* ��Ԫ���ߣ���Х��LiuXiao�� liuxiao@cnpack.org; http://www.cnpack.org
* ��    ע��ͬʱ֧�� Unicode �ͷ� Unicode ������
* ����ƽ̨��2022.09.24 V1.0
*               ������Ԫ��������ʵ�ֹ��ܻ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, TypInfo, mPasLex, CnPasWideLex, CnTree, CnContainers;

type
  ECnPascalAstException = class(Exception);

{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}  // 2005 ����
  TCnGeneralPasLex = TCnPasWideLex;
  TCnGeneralLexBookmark = TCnPasWideBookmark;
{$ELSE}                               // 5 6 7
  TCnGeneralPasLex = TmwPasLex;
  TCnGeneralLexBookmark = TmwPasLexBookmark;
{$ENDIF}

  TCnPasNodeType = (
    cntInvalid,

    cntSpace,
    cntLineComment,
    cntBlockComment,

    cntComma,
    cntSemiColon,
    cntColon,
    cntRelOps,
    cntAddOps,
    cntMulOps,
    cntRange,
    cntHat,
    cntDot,

    cntSquareOpen,
    cntSquareClose,
    cntRoundOpen,
    cntRoundClose,

    cntAssign,

    cntInt,
    cntFloat,
    cntString,
    cntIdent,

    cntConst,
    cntIndex,
    cntRead,
    cntWrite,
    cntImplements,
    cntDefault,
    cntStored,
    cntNodefault,
    cntReadonly,
    cntWriteonly,

    cntUsesClause,
    cntUsesDecl,
    cntTypeSection,
    cntTypeDecl,
    cntTypeKeyword,
    cntTypeID,
    cntRestrictedType,
    cntCommonType,

    cntEnumeratedList,
    cntEmumeratedIdent,
    cntVariantSection,

    cntArrayType,
    cntOrdinalType,
    cntSubrangeType,
    cntSetType,
    cntFileType,
    cntOf,
    cntStringType,
    cntProcedureType,

    cntRecord,
    cntFieldList,
    cntFieldDecl,
    cntRecVariant,
    cntIdentList,

    cntSetConstructor,
    cntSetElement,

    cntProcedureHeading,
    cntFunctionHeading,
    cntProperty,
    cntPropertyInterface,
    cntPropertySpecifiers,
    cntPropertyParameterList,

    cntLabelId,
    cntSimpleStatement,

    cntExpressionList,
    cntConstExpression,
    cntExpression,
    cntSimpleExpression,
    cntDesignator,
    cntQualId,
    cntTerm,
    cntFactor,

    cntEnd
  );

  TCnPasAstLeaf = class(TCnLeaf)
  {* Text ���Դ��Ӧ���ַ���}
  private
    FNodeType: TCnPasNodeType;
    FTokenKind: TTokenKind;
  public
    property NodeType: TCnPasNodeType read FNodeType write FNodeType;
    {* �﷨���ڵ�����}
    property TokenKind: TTokenKind read FTokenKind write FTokenKind;
    {* Pascal Token ���ͣ�ע���еĽڵ㱾��û��ʵ�ʶ�Ӧ�� Token���� tkNone ����}
  end;

  TCnPasAstTree = class(TCnTree)

  end;

  TCnPasAstGenerator = class
  private
    FLex: TCnGeneralPasLex;
    FTree: TCnPasAstTree;
    FStack: TCnObjectStack;
    FCurrentRef: TCnPasAstLeaf;
    FLocked: Integer;
    procedure Lock;
    procedure Unlock;
  protected
    procedure PushLeaf(ALeaf: TCnPasAstLeaf);
    procedure PopLeaf;

    procedure MatchCreateLeafAndPush(AToken: TTokenKind; NodeType: TCnPasNodeType = cntInvalid);
    // ����ǰ Token ����һ���ڵ㣬��Ϊ FCurrentRef �����һ���ӽڵ㣬�ٰ� FCurrentRef �����ջ������ȡ�� FCurrentRef
    function MatchCreateLeaf(AToken: TTokenKind; NodeType: TCnPasNodeType = cntInvalid): TCnPasAstLeaf;
    // ����ǰ Token ����һ���ڵ㣬��Ϊ FCurrentRef �����һ���ӽڵ�
    procedure NextToken;
    // Lex ��ǰ�н�����һ����Ч Token�������ע�ͣ������������Ȳ�������������ָ�
    function ForwardToken: TTokenKind;
    // ȡ��һ����Ч Token ������ǰ�н����ڲ�ʹ����ǩ���лָ�
  public
    constructor Create(const Source: string); virtual;
    destructor Destroy; override;

    property Tree: TCnPasAstTree read FTree;
    {* Build ��Ϻ���﷨��}

    // ��Щ�﷨�����ǹؼ��ֿ�ͷ��֮����һ���ӽڵ����

    // ����Щ�����Ԫ���㣬�������������Ҫ�Ǹ��ڵ㣬Ԫ�����ӽڵ㣬���Ƿ�����Ҫ��������
    procedure Build;

    // Build ϵ�к���ִ�����FLex ��Ӧ Next ��β��֮�����һ�� Token
    procedure BuildTypeSection;
    {* ���� type �ؼ���ʱ�����ã��½� type �ڵ㣬�����Ƕ�� typedecl �ӷֺţ�ÿ�� typedecl ���½ڵ�}
    procedure BuildTypeDecl;
    {* �� BuildTypeSection ѭ�����ã�ÿ������һ���ڵ㲢���������� typedecl �ڲ���Ԫ�ص��ӽڵ�}
    procedure BulidRestrictedType;
    {* ��������}
    procedure BuildCommonType;
    {* ������ͨ����}
    
    procedure BuildEnumeratedType;
    {* ��װһ��ö�����ͣ�(a, b) ����}
    procedure BuildEnumeratedList;
    {* ��װһ��ö�������е��б�(a, b) �����е� a, b}
    procedure BuildEmumeratedIdent;
    {* ��װһ��ö�������еĵ���}

    procedure BuildStructType;
    procedure BuildArrayType;
    procedure BuildSetType;
    procedure BuildFileType;
    procedure BuildRecordType;
    procedure BuildProcedureType;
    procedure BuildPointerType;
    procedure BuildStringType;
    procedure BuildOrdinalType;
    procedure BuildSubrangeType;
    procedure BuildOrdIdentType;
    procedure BuildTypeID;

    procedure BuildClassType;
    procedure BuildObjectType;
    procedure BuildInterfaceType;

    procedure BuildFieldList;
    procedure BuildClassVisibility;
    procedure BuildClassMethod;
    procedure BuildClassProperty;
    procedure BuildClassTypeSection;
    procedure BuildClassConstSection;
    procedure BuildVarSection;
    procedure BuildRecVariant;
    procedure BuildFieldDecl;
    procedure BuildVariantSection;

    procedure BuildPropertyInterface;
    procedure BuildPropertyParameterList;
    procedure BuildPropertySpecifiers;

    procedure BuildFunctionHeading;
    procedure BuildProcedureHeading;

    procedure BuildUsesClause;
    {* ���� uses �ؼ���ʱ�����ã��½� uses �ڵ㣬�����Ƕ�� usesdecl �Ӷ��ţ�ÿ�� uses ���½ڵ�}
    procedure BuildUsesDecl;
    {* �� BuildUsesClause ѭ�����ã�ÿ������һ���ڵ㲢���������� usesdecl �ڲ���Ԫ�ص��ӽڵ�}

    procedure BuildSetConstructor;
    {* ��װһ�����ϱ��ʽ���г���ڵ�}
    procedure BuildSetElement;
    {* ��װһ������Ԫ��}

    procedure BuildLabelId;
    {* ��װһ�� LabelId}
    procedure BuildSimpleStatement;
    {* ��װһ������䣬���� Designator��Designator ������ĸ�ֵ��inherited��Goto ��
      ע�⣬��俪ͷ�������С���ţ��޷�ֱ���ж��� Designator ������ (a)[0] := 1 ���֡�
            ���� SimpleStatement/Factor ������ (Caption := '') ����}
    procedure BuildExpressionList;
    {* ��װһ�����ʽ�б��ɶ��ŷָ�}
    procedure BuildExpression;
    {* ��װһ�����ʽ���ñ��ʽ�� SimpleExpression ���Ԫ���������}
    procedure BuildConstExpression;
    {* ��װһ�������ʽ�������ڱ��ʽ}
    procedure BuildSimpleExpression;
    {* ��װһ���򵥱��ʽ����Ҫ�� Term ��ɣ�Term ֮���� AddOp ����}
    procedure BuildTerm;
    {* ��װһ�� Term����Ҫ�� Factor ��ɣ�Factor ֮���� MulOp ����}
    procedure BuildFactor;
    {* ��װһ�� Factor����Ȼ���������﷨���г��˼򵥱�ʶ�������򵥲��֣��г���ڵ�
      �����ڲ�ȴ�� Designator ���ֵ��߼���ʶ������λ�ͼ򵥱�ʶ����ͬ��@ ������}
    procedure BuildDesignator;
    {* ��װһ�� Designator ��ʶ������Ҫ�������ŵĶ�ά�����±ꡢ�Լ�С���ŵ� FunctionCall���Լ�ָ���ָ^ �Լ��� . �ͺ�������ʶ���������� @
      �����ָ�ܹ�ͨ���⼸�������������ȥ�ĵ��߼���ʶ�������Գ����� := ���󷽣���ͳ����� := �ҷ��� Expression �ǲ�ͬ��}
    procedure BuildQualId;
    {* ��װһ�� QualId����Ҫ�� Ident �Լ� (Designator as Type)����Ϊ Designator ����ʼ����}

    procedure BuildIdentList;
    procedure BuildIdent;
    {* ��װһ����ʶ�������Դ����}

  end;

function PascalAstNodeTypeToString(AType: TCnPasNodeType): string;

implementation

resourcestring
  SCnErrorStack = 'Stack Empty';
  SCnErrorNoMatchNodeType = 'No Matched Node Type';
  SCnErrorTokenNotMatch = 'Token NOT Matched';

const
  SpaceTokens = [tkCRLF, tkCRLFCo, tkSpace];
  CommentTokens = [tkSlashesComment, tkAnsiComment, tkBorComment];
  RelOpTokens = [tkGreater, tkLower, tkGreaterEqual, tkLowerEqual, tkNotEqual,
    tkEqual, tkIn, tkAs, tkIs];
  AddOPTokens = [tkPlus, tkMinus, tkOr, tkXor];
  MulOpTokens = [tkStar, tkDiv, tkSlash, tkMod, tkAnd, tkShl, tkShr];
  VisibilityTokens = [tkPublic, tkPublished, tkProtected, tkPrivate];
  ProcedureTokens = [tkProcedure, tkFunction, tkConstructor, tkDestructor];
  PropertySpecifiersTokens = [tkDispid, tkRead, tkIndex, tkWrite, tkStored,
    tkImplements, tkDefault, tkNodefault, tkReadonly, tkWriteonly];

function PascalAstNodeTypeToString(AType: TCnPasNodeType): string;
begin
  Result := GetEnumName(TypeInfo(TCnPasNodeType), Ord(AType));

  if Length(Result) > 3 then
  begin
    Delete(Result, 1, 3);
    Result := UpperCase(Result);
  end;
end;

function NodeTypeFromToken(AToken: TTokenKind): TCnPasNodeType;
begin
  case AToken of
    // Section
    tkUses: Result := cntUsesClause;
    tkType: Result := cntTypeSection;

    // ����
    tkEnd: Result := cntEnd;

    // Ԫ�أ�ע��
    tkBorComment, tkAnsiComment: Result := cntBlockComment;
    tkSlashesComment: Result := cntLineComment;

    // Ԫ�أ���ʶ�������֡��ַ�����
    tkIdentifier: Result := cntIdent;
    tkInteger, tkNumber: Result := cntInt; // ʮ��������������ͨ����
    tkFloat: Result := cntFloat;
    tkAsciiChar, tkString: Result := cntString;

    // Ԫ�أ��������������
    tkComma: Result := cntComma;
    tkSemiColon: Result := cntSemiColon;
    tkColon: Result := cntColon;
    tkDotDot: Result := cntRange;
    tkPoint: Result := cntDot;
    tkPointerSymbol: Result := cntHat;
    tkAssign: Result := cntAssign;

    tkPlus, tkMinus, tkOr, tkXor: Result := cntAddOps;
    tkStar, tkDiv, tkSlash, tkMod, tkAnd, tkShl, tkShr: Result := cntMulOps;
    tkGreater, tkLower, tkGreaterEqual, tkLowerEqual, tkNotEqual, tkEqual, tkIn, tkAs, tkIs:
      Result := cntRelOps;

    tkSquareOpen: Result := cntSquareOpen;
    tkSquareClose: Result := cntSquareClose;
    tkRoundOpen: Result := cntRoundOpen;
    tkRoundClose: Result := cntRoundClose;

    // ����
    tkArray: Result := cntArrayType;
    tkSet: Result := cntSetType;
    tkFile: Result := cntFileType;
    tkOf: Result := cntOf;
    tkRecord, tkPacked: Result := cntRecord;

    // ����
    tkProperty: Result := cntProperty;
    tkConst: Result := cntConst;
    tkIndex: Result := cntIndex;
    tkRead: Result := cntRead;
    tkWrite: Result := cntWrite;
    tkImplements: Result := cntImplements;
    tkDefault: Result := cntDefault;
    tkStored: Result := cntStored;
    tkNodefault: Result := cntNodefault;
    tkReadonly: Result := cntReadonly;
    tkWriteonly: Result := cntWriteonly;
  else
    raise ECnPascalAstException.Create(SCnErrorNoMatchNodeType + ' '
      + GetEnumName(TypeInfo(TTokenKind), Ord(AToken)));
  end;
end;

{ TCnPasASTGenerator }

procedure TCnPasAstGenerator.Build;
begin

end;

procedure TCnPasAstGenerator.BuildArrayType;
begin
  MatchCreateLeafAndPush(tkArray);

  try
    if FLex.TokenID = tkSquareOpen then
    begin
      MatchCreateLeafAndPush(tkSquareOpen);
      try
        repeat
          BuildOrdinalType;
          if FLex.TokenID = tkComma then
            MatchCreateLeaf(tkComma)
          else
            Break;
        until False;
      finally
        PopLeaf;
      end;
      MatchCreateLeaf(tkSquareClose);
    end;

    MatchCreateLeaf(tkOf);
    BuildCommonType; // Array �������ֻ���� Common Type����֧�� class ��
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildClassType;
begin

end;

procedure TCnPasAstGenerator.BuildConstExpression;
begin
  // �� BuildExpression ��ֻͬ�ǽڵ����Ͳ�ͬ
  MatchCreateLeafAndPush(tkNone, cntConstExpression);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ����� ConstExpression �ڵ�֮��

  try
    BuildSimpleExpression;
    while FLex.TokenID in RelOpTokens + [tkPoint, tkPointerSymbol, tkSquareOpen] do
    begin
      if FLex.TokenID in RelOpTokens then
      begin
        MatchCreateLeaf(FLex.TokenID);
        BuildSimpleExpression;
      end
      else if FLex.TokenID = tkPointerSymbol then // ע�⣬�� . ^ [] ����չ������ԭʼ�﷨��û��
        MatchCreateLeaf(FLex.TokenID)
      else if FLex.TokenID = tkPoint then
      begin
        MatchCreateLeaf(FLex.TokenID);
        BuildIdent;
      end
      else if FLex.TokenID = tkSquareOpen then
      begin
        MatchCreateLeafAndPush(FLex.TokenID);
        try
          BuildExpressionList;
        finally
          PopLeaf;
        end;
        MatchCreateLeaf(tkSquareClose);
      end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildDesignator;
begin
  MatchCreateLeafAndPush(tkNone, cntDesignator);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ����� Expression �ڵ�֮��

  try
    BuildQualId;
    while FLex.TokenID in [tkSquareOpen, tkRoundOpen, tkPoint, tkPointerSymbol] do
    begin
      case FLex.TokenID of
        tkSquareOpen: // �����±�
          begin
            MatchCreateLeafAndPush(tkSquareOpen);
            // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ�������Žڵ�֮��

            try
              BuildExpressionList;
            finally
              PopLeaf;
            end;
            MatchCreateLeaf(tkSquareClose); // �ӽڵ���������һ�㣬�ٷ������׵���������
          end;
        tkRoundOpen: // Function Call
          begin
            MatchCreateLeafAndPush(tkRoundOpen);
            // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ�������Žڵ�֮��

            try
              BuildExpressionList;
            finally
              PopLeaf;
            end;
            MatchCreateLeaf(tkRoundClose); // �ӽڵ���������һ�㣬�ٷ������׵���������
          end;
        tkPointerSymbol:
          begin
            MatchCreateLeaf(FLex.TokenID);
          end;
        tkPoint:
          begin
            MatchCreateLeaf(FLex.TokenID);
            BuildIdent;
          end;
      end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildEmumeratedIdent;
begin
  MatchCreateLeafAndPush(tkNone, cntEmumeratedIdent);

  try
    BuildIdent;
    if FLex.TokenID = tkEqual then
    begin
      MatchCreateLeaf(tkEqual);
      BuildConstExpression;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildEnumeratedList;
begin
  MatchCreateLeafAndPush(tkNone, cntEnumeratedList);

  try
    repeat
      BuildEmumeratedIdent;
      if FLex.TokenID = tkComma then
        MatchCreateLeaf(tkComma)
      else
        Break;
    until False;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildEnumeratedType;
begin
  MatchCreateLeafAndPush(tkRoundOpen);

  try
    BuildEnumeratedList;
  finally
    PopLeaf;
  end;
  MatchCreateLeaf(tkRoundClose);
end;

procedure TCnPasAstGenerator.BuildExpression;
begin
  MatchCreateLeafAndPush(tkNone, cntExpression);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ����� Expression �ڵ�֮��

  try
    BuildSimpleExpression;
    while FLex.TokenID in RelOpTokens + [tkPoint, tkPointerSymbol, tkSquareOpen] do
    begin
      if FLex.TokenID in RelOpTokens then
      begin
        MatchCreateLeaf(FLex.TokenID);
        BuildSimpleExpression;
      end
      else if FLex.TokenID = tkPointerSymbol then // ע�⣬�� . ^ [] ����չ������ԭʼ�﷨��û��
        MatchCreateLeaf(FLex.TokenID)
      else if FLex.TokenID = tkPoint then
      begin
        MatchCreateLeaf(FLex.TokenID);
        BuildIdent;
      end
      else if FLex.TokenID = tkSquareOpen then
      begin
        MatchCreateLeafAndPush(FLex.TokenID);
        try
          BuildExpressionList;
        finally
          PopLeaf;
        end;
        MatchCreateLeaf(tkSquareClose);
      end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildExpressionList;
begin
  MatchCreateLeafAndPush(tkNone, cntExpressionList);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ����� ExpressionList �ڵ�֮��

  try
    repeat
      BuildExpression;
      if FLex.TokenID = tkComma then
        MatchCreateLeaf(tkComma)
      else
        Break;
    until False;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildFactor;
begin
  MatchCreateLeafAndPush(tkNone, cntFactor);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ����� Factor �ڵ�֮��

  try
    case FLex.TokenID of
      tkAt:
        begin
          MatchCreateLeafAndPush(FLex.TokenID);
          // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ @ �ڵ�֮��

          try
            BuildDesignator;
          finally
            PopLeaf;
          end;
        end;
      tkIdentifier:
        begin
          BuildDesignator;
          if FLex.TokenID = tkRoundOpen then
          begin
            MatchCreateLeaf(tkRoundOpen);
            BuildExpressionList;
            MatchCreateLeaf(tkRoundClose)
          end;
        end;
      tkAsciiChar, tkString, tkNumber, tkInteger, tkFloat: // AsciiChar �� #12 ����
        MatchCreateLeaf(FLex.TokenID);
      tkNot:
        begin
          MatchCreateLeaf(FLex.TokenID);
          BuildFactor;
        end;
      tkSquareOpen:
        begin
          BuildSetConstructor;
        end;
      tkInherited:
        begin
          MatchCreateLeafAndPush(FLex.TokenID);
          // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ inherited �ڵ�֮��

          try
            BuildExpression;
          finally
            PopLeaf;
          end;
        end;
      tkRoundOpen:
        begin
          MatchCreateLeafAndPush(FLex.TokenID);
          // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ��С���Žڵ�֮��

          try
            BuildExpression;
          finally
            PopLeaf;
          end;
          MatchCreateLeaf(tkRoundClose); // �ӽڵ���������һ�㣬�ٷ������׵���С����

          while FLex.TokenID = tkPointerSymbol do
            MatchCreateLeaf(tkPointerSymbol)
        end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildFileType;
begin
  MatchCreateLeafAndPush(tkFile);

  try
    if FLex.TokenID = tkOf then
    begin
      MatchCreateLeaf(FLex.TokenID);
      BuildTypeID;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildIdent;
var
  T: TCnPasAstLeaf;
begin
  T := MatchCreateLeaf(tkIdentifier);

  while FLex.TokenID in [tkPoint, tkIdentifier] do
  begin
    if T <> nil then
      T.Text := T.Text + FLex.Token;
    NextToken;
  end;
end;

procedure TCnPasAstGenerator.BuildLabelId;
begin
  MatchCreateLeaf(tkIdentifier);
end;

procedure TCnPasAstGenerator.BuildOrdinalType;
var
  Bookmark: TCnGeneralLexBookmark;
  IsRange: Boolean;

  procedure SkipOrdinalPrefix;
  begin
    repeat
      FLex.NextNoJunk;
    until not (FLex.TokenID in [tkIdentifier, tkPoint, tkInteger, tkString, tkRoundOpen, tkSquareOpen,
      tkPlus, tkMinus, tkStar, tkSlash, tkDiv, tkMod]);
  end;

begin
  MatchCreateLeafAndPush(tkNone, cntOrdinalType);
  try
    if FLex.TokenID = tkRoundOpen then  // (a, b) ����
      BuildEnumeratedType
    else
    begin
      Lock;
      FLex.SaveToBookmark(Bookmark);

      try
        SkipOrdinalPrefix;
        IsRange := FLex.TokenID = tkDotDot;
      finally
        FLex.LoadFromBookmark(Bookmark);
        Unlock;
      end;

      if IsRange then
        BuildSubrangeType
      else
        BuildOrdIdentType;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildProcedureType;
begin
  MatchCreateLeafAndPush(tkNone, cntProcedureType);

  try
    if FLex.TokenID = tkProcedure then
    begin
      BuildProcedureHeading;
    end
    else if FLex.TokenID = tkFunction then
    begin
      BuildFunctionHeading;
    end;
    if FLex.TokenID = tkOf then
    begin
      MatchCreateLeaf(tkOf);
      MatchCreateLeaf(tkObject);
    end;

  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildQualId;
begin
  MatchCreateLeafAndPush(tkNone, cntQualId);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ����� QualId �ڵ�֮��

  try
    case FLex.TokenID of
      tkIdentifier:
        BuildIdent;
      tkRoundOpen:
        begin
          MatchCreateLeafAndPush(FLex.TokenID);
          // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ��С���Žڵ�֮��

          try
            BuildDesignator;
            if FLex.TokenID = tkAs then
            begin
              MatchCreateLeaf(tkAs);
              BuildIdent; // TypeId ���� Ident
            end;
          finally
            PopLeaf;
          end;
          MatchCreateLeaf(tkRoundClose); // �ӽڵ���������һ�㣬�ٷ������׵���С����
        end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildRecordType;
begin
  MatchCreateLeafAndPush(tkRecord);

  try
    if FLex.TokenID <> tkEnd then
      BuildFieldList;
    MatchCreateLeaf(tkEnd);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildSetConstructor;
begin
  MatchCreateLeafAndPush(tkNone, cntSetConstructor);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ����� SetConstructor �ڵ�֮��

  try
    MatchCreateLeafAndPush(tkSquareOpen);
   // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ�������Žڵ�֮��

    try
      while True do
      begin
        BuildSetElement;
        if FLex.TokenID = tkComma then
          MatchCreateLeaf(tkComma)
        else
          Break;
      end;
    finally
      PopLeaf;
    end;
    MatchCreateLeaf(tkSquareClose); // �ӽڵ���������һ�㣬�ٷ������׵���������
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildSetElement;
begin
  MatchCreateLeafAndPush(tkNone, cntSetElement);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ����� SetElement �ڵ�֮��

  try
    BuildExpression;
    if FLex.TokenID = tkDotDot then
    begin
      MatchCreateLeaf(tkDotDot);
      BuildExpression;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildSetType;
begin
  MatchCreateLeafAndPush(tkNone, cntSetType);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ����� SetType �ڵ�֮��

  try
    MatchCreateLeaf(tkSet);
    MatchCreateLeaf(tkOf);
    BuildOrdinalType;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildSimpleExpression;
begin
  MatchCreateLeafAndPush(tkNone, cntSimpleExpression);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ����� SimpleExpression �ڵ�֮��

  try
    if FLex.TokenID in [tkPlus, tkMinus, tkPointerSymbol] then
      MatchCreateLeaf(FLex.TokenID);

    BuildTerm;
    if FLex.TokenID in AddOpTokens then
    begin
      MatchCreateLeaf(FLex.TokenID);
      BuildTerm;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildSimpleStatement;
var
  Bookmark: TCnGeneralLexBookmark;
  IsDesignator: Boolean;
begin
  MatchCreateLeafAndPush(tkNone, cntSimpleStatement);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ����� SimpleStatement �ڵ�֮��

  try
    if FLex.TokenID = tkGoto then
    begin
      MatchCreateLeaf(FLex.TokenID);
      BuildLabelId;
    end
    else if FLex.TokenID = tkInherited then
    begin
      MatchCreateLeaf(FLex.TokenID);
      // �������û�ˣ�Ҳ��������һ�� SimpleStatement
      if not (FLex.TokenID in [tkSemicolon, tkEnd, tkElse]) then
        BuildSimpleStatement;
    end
    else if FLex.TokenID = tkRoundOpen then
    begin
      // ( Statement ) ���֣��������� Designator ���ֿ�������Ҫ����취����
      FLex.SaveToBookmark(Bookmark);
      Lock;
      try
        // ��ǰ�ж��Ƿ� Designator
        try
          BuildDesignator;
          // ���� Designator ������ϣ��жϺ�����ɶ

          IsDesignator := FLex.TokenID in [tkAssign, tkRoundOpen, tkSemicolon,
            tkElse, tkEnd];
          // TODO: Ŀǰֻ�뵽�⼸����Semicolon ���� Designator �Ѿ���Ϊ��䴦�����ˣ�
          // else/end ����������û�ֺŵ����ж�ʧ��
        except
          IsDesignator := False;
          // ������������� := �����Σ�BuildDesignator �����
          // ˵�������Ǵ�����Ƕ�׵� Simplestatement
        end;
      finally
        Unlock;
        FLex.LoadFromBookmark(Bookmark);
      end;

      if IsDesignator then // �� Designator�������������еĸ�ֵ
      begin
        BuildDesignator;
        if FLex.TokenID = tkAssign then
        begin
          MatchCreateLeaf(FLex.TokenID);
          BuildExpression;
        end;
      end
      else // �� ( Statement )
      begin
        MatchCreateLeafAndPush(tkRoundOpen);
        // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ��С���Žڵ�֮��

        try
          BuildSimpleStatement; // TODO: ��Ϊ Statement
        finally
          PopLeaf;
        end;
        MatchCreateLeaf(tkRoundClose);
      end;
    end
    else // �� ( ��ͷ��Ҳ�� Designator�������������еĸ�ֵ
    begin
      BuildDesignator;
      if FLex.TokenID = tkAssign then
      begin
        MatchCreateLeaf(FLex.TokenID);
        BuildExpression;
      end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildStringType;
begin
  MatchCreateLeafAndPush(tkNone, cntStringType);

  try
    if FLex.TokenID = tkString then
      MatchCreateLeaf(FLex.TokenID)
    else
      BuildIdent;

    if FLex.TokenID = tkRoundOpen then
    begin
      MatchCreateLeafAndPush(FLex.TokenID);
      try
        BuildExpression;
      finally
        PopLeaf;
      end;
      MatchCreateLeaf(tkRoundClose);
    end
    else if FLex.TokenID = tkSquareOpen then
    begin
      MatchCreateLeafAndPush(FLex.TokenID);
      try
        BuildConstExpression;
      finally
        PopLeaf;
      end;
      MatchCreateLeaf(tkSquareClose);
    end
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildStructType;
begin
  if FLex.TokenID = tkPacked then
    MatchCreateLeaf(tkPacked);

  case FLex.TokenID of
    tkArray:
      BuildArrayType;
    tkSet:
      BuildSetType;
    tkFile:
      BuildFileType;
    tkRecord:
      BuildRecordType;
  end;
end;

procedure TCnPasAstGenerator.BuildTerm;
begin
  MatchCreateLeafAndPush(tkNone, cntTerm);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ����� Term �ڵ�֮��

  try
    BuildFactor;
    if FLex.TokenID in MulOpTokens then
    begin
      MatchCreateLeaf(FLex.TokenID);
      BuildFactor;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildCommonType;
var
  Bookmark: TCnGeneralLexBookmark;
  IsRange: Boolean;
begin
  MatchCreateLeafAndPush(tkNone, cntCommonType);

  try
    case FLex.TokenID of
      tkRoundOpen:
        begin
          BuildEnumeratedType;
        end;
      tkPacked, tkArray, tkSet, tkFile, tkRecord:
        begin
          BuildStructType;
        end;
      tkProcedure, tkFunction:
        begin
          BuildProcedureType;
        end;
      tkPointerSymbol:
        begin
          BuildPointerType;
        end;
    else
      if (FLex.TokenID = tkString) or SameText(FLex.Token, 'String')
        or SameText(FLex.Token, 'AnsiString') or SameText(FLex.Token, 'WideString')
        or SameText(FLex.Token, 'UnicodeString') then
        BuildStringType
      else
      begin
        // TypeID? Խ��һ�� ConstExpr ���Ƿ��� ..
        Lock;
        FLex.SaveToBookmark(Bookmark);

        try
          BuildConstExpression;
          IsRange := FLex.TokenID = tkDotDot;
        finally
          FLex.LoadFromBookmark(Bookmark);
          UnLock;
        end;

        if IsRange then
          BuildSubrangeType
        else
          BuildTypeID;
      end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildTypeDecl;
begin
  MatchCreateLeafAndPush(tkNone, cntTypeDecl);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ TypeDecl �ڵ�֮��

  try
    BuildIdent;
    MatchCreateLeaf(tkEqual);
    if FLex.TokenID = tkType then
      MatchCreateLeaf(tkNone, cntTypeKeyword);

    // Ҫ�ֿ� RestrictType ����ͨ Type��ǰ�߰��� class/object/interface�����ֳ��ϲ��������
    if FLex.TokenID in [tkClass, tkObject, tkInterface] then
      BulidRestrictedType
    else
      BuildCommonType;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildTypeSection;
begin
  MatchCreateLeafAndPush(tkType);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ type �ڵ�֮��

  try
    while FLex.TokenID = tkIdentifier do
      BuildTypeDecl;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildUsesClause;
begin
  MatchCreateLeafAndPush(tkUses);
  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ Uses �ڵ�֮��

  try
    while True do
    begin
      BuildUsesDecl;
      if FLex.TokenID = tkComma then
        MatchCreateLeaf(tkComma)
      else
        Break;
    end;

    MatchCreateLeaf(tkSemiColon);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildUsesDecl;
begin
  BuildIdent;
end;

procedure TCnPasAstGenerator.BulidRestrictedType;
begin
  MatchCreateLeafAndPush(tkNone, cntRestrictedType);

  try
    case FLex.TokenID of
      tkClass:
        BuildClassType;
      tkObject:
        BuildObjectType;
      tkInterface:
        BuildInterfaceType;
    end;
  finally
    PopLeaf;
  end;
end;

constructor TCnPasASTGenerator.Create(const Source: string);
begin
  inherited Create;
  FLex := TCnGeneralPasLex.Create;
  FStack := TCnObjectStack.Create;
  FTree := TCnPasAstTree.Create(TCnPasAstLeaf);
  FCurrentRef := FTree.Root as TCnPasAstLeaf;

  FLex.Origin := PChar(Source);
end;

destructor TCnPasASTGenerator.Destroy;
begin
  FTree.Free;
  FStack.Free;
  FLex.Free;
  inherited;
end;

procedure TCnPasAstGenerator.Lock;
begin
  Inc(FLocked);
end;

function TCnPasAstGenerator.MatchCreateLeaf(AToken: TTokenKind;
  NodeType: TCnPasNodeType): TCnPasAstLeaf;
begin
  Result := nil;
  if (AToken <> tkNone) and (AToken <> FLex.TokenID) then
    raise ECnPascalAstException.Create(SCnErrorTokenNotMatch + ' '
      + GetEnumName(TypeInfo(TTokenKind), Ord(AToken)));

  if NodeType = cntInvalid then
    NodeType := NodeTypeFromToken(AToken);

  if FLocked = 0 then // δ���Ŵ����ڵ�
  begin
    if (FCurrentRef <> nil) and (FTree.Root <> FCurrentRef) then
      Result := FTree.AddChild(FCurrentRef) as TCnPasAstLeaf
    else
      Result := FTree.AddChild(FTree.Root) as TCnPasAstLeaf;

    Result.TokenKind := AToken;
    Result.NodeType := NodeType;
  end;

  if AToken <> tkNone then // �����ݵ�ʵ�ʽڵ㣬�Ų���һ��
  begin
    if FLocked = 0 then               // δ���Ŵ���
      Result.Text := FLex.Token;
    NextToken;                        // ��������Ҫǰ��
  end;
end;

procedure TCnPasAstGenerator.MatchCreateLeafAndPush(AToken: TTokenKind;
  NodeType: TCnPasNodeType);
var
  T: TCnPasAstLeaf;
begin
  T := MatchCreateLeaf(AToken, NodeType);
  if T <> nil then
  begin
    PushLeaf(FCurrentRef);
    FCurrentRef := T;  // Pop ֮ǰ���ڲ���ӵĽڵ��Ϊ�ýڵ�֮��
  end;
end;

procedure TCnPasAstGenerator.NextToken;
begin
  repeat
    FLex.Next;
  until not (FLex.TokenID in SpaceTokens + CommentTokens);
end;

function TCnPasAstGenerator.ForwardToken: TTokenKind;
var
  Bookmark: TCnGeneralLexBookmark;
begin
  FLex.SaveToBookmark(Bookmark);

  try
    NextToken;
    Result := FLex.TokenID;
  finally
    FLex.LoadFromBookmark(Bookmark);
  end;
end;

procedure TCnPasAstGenerator.PopLeaf;
begin
  if FLocked > 0 then // ����ʱ�� Pop����Ϊ Push Ҳ����
    Exit;

  if FStack.Count <= 0 then
    raise ECnPascalAstException.Create(SCnErrorStack);

  FCurrentRef := TCnPasAstLeaf(FStack.Pop);
end;

procedure TCnPasAstGenerator.PushLeaf(ALeaf: TCnPasAstLeaf);
begin
  if ALeaf <> nil then
    FStack.Push(ALeaf);
end;

procedure TCnPasAstGenerator.Unlock;
begin
  Dec(FLocked);
end;

procedure TCnPasAstGenerator.BuildInterfaceType;
begin

end;

procedure TCnPasAstGenerator.BuildObjectType;
begin

end;

procedure TCnPasAstGenerator.BuildOrdIdentType;
begin
  BuildIdent;
end;

procedure TCnPasAstGenerator.BuildSubrangeType;
begin
  MatchCreateLeafAndPush(tkNone, cntSubrangeType);

  try
    BuildConstExpression;
    MatchCreateLeaf(tkDotDot);
    BuildConstExpression;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildPointerType;
begin
  MatchCreateLeafAndPush(tkPointerSymbol, cntHat);

  try
    BuildTypeID;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildTypeID;
begin
  MatchCreateLeafAndPush(tkNone, cntTypeID);

  try
    if FLex.TokenID = tkString then // �� BuildIdent �ڲ����Ϲؼ���
      MatchCreateLeaf(FLex.TokenID)
    else
      BuildIdent;
    if FLex.TokenID = tkRoundOpen then
    begin
      MatchCreateLeaf(FLex.TokenID);
      BuildExpression;
      MatchCreateLeaf(tkRoundClose)
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildFieldList;
begin
  MatchCreateLeafAndPush(tkNone, cntFieldList);

  try
    while not (FLex.TokenID in [tkEnd, tkCase, tkRoundClose]) do
    begin
      if FLex.TokenID in VisibilityTokens then
        BuildClassVisibility;

      if FLex.TokenID = tkCase then
        Break
      else if FLex.TokenID in ProcedureTokens then
        BuildClassMethod
      else if FLex.TokenID = tkProperty then
        BuildClassProperty
      else if FLex.TokenID = tkType then
        BuildClassTypeSection
      else if FLex.TokenID = tkConst then
        BuildClassConstSection
      else if FLex.TokenID in [tkVar, tkThreadVar] then
        BuildVarSection
      else if FLex.TokenID <> tkEnd then
      begin
        BuildFieldDecl;
        if FLex.TokenID = tkSemiColon then
          MatchCreateLeaf(tkSemiColon);
      end;
    end;

    // ���� case �ɱ���
    if FLex.TokenID = tkCase then
      BuildVariantSection;

    if FLex.TokenID = tkSemiColon then
      MatchCreateLeaf(tkSemiColon);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildIdentList;
begin
  MatchCreateLeafAndPush(tkNone, cntIdentList);

  try
    repeat
      BuildIdent;
      if FLex.TokenID = tkComma then
        MatchCreateLeaf(tkComma)
      else
        Break;
    until False;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildFunctionHeading;
begin

end;

procedure TCnPasAstGenerator.BuildProcedureHeading;
begin

end;

procedure TCnPasAstGenerator.BuildClassConstSection;
begin

end;

procedure TCnPasAstGenerator.BuildClassMethod;
begin

end;

procedure TCnPasAstGenerator.BuildClassTypeSection;
begin

end;

procedure TCnPasAstGenerator.BuildClassVisibility;
begin

end;

procedure TCnPasAstGenerator.BuildVariantSection;
var
  Bookmark: TCnGeneralLexBookmark;
  HasColon: Boolean;
begin
  MatchCreateLeafAndPush(tkCase, cntVariantSection);

  try
    Lock;
    FLex.SaveToBookmark(Bookmark);

    try
      BuildIdent;
      HasColon := FLex.TokenID = tkColon;
    finally
      FLex.LoadFromBookmark(Bookmark);
      Unlock;
    end;

    if HasColon then
    begin
      BuildIdent;
      MatchCreateLeaf(tkColon);
      BuildTypeID;
    end
    else
      BuildTypeID;

    MatchCreateLeaf(tkOf);
    repeat
      BuildRecVariant;
      if FLex.TokenID = tkSemiColon then
      begin
        MatchCreateLeaf(FLex.TokenID);
        if FLex.TokenID in [tkEnd, tkRoundClose] then
          Break;
      end
      else
        Break;
    until False;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildVarSection;
begin

end;

procedure TCnPasAstGenerator.BuildFieldDecl;
begin
  MatchCreateLeafAndPush(tkNone, cntFieldDecl);

  try
    BuildIdentList;
    MatchCreateLeaf(tkColon);
    BuildCommonType;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildClassProperty;
begin
  MatchCreateLeafAndPush(tkProperty);

  try
    BuildIdent;
    if FLex.TokenID in [tkSquareOpen, tkColon] then
      BuildPropertyInterface;
    BuildPropertySpecifiers;
    MatchCreateLeaf(tkSemiColon);

    if FLex.TokenID = tkDefault then
    begin
      MatchCreateLeaf(FLex.TokenID);
      MatchCreateLeaf(tkSemiColon);
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildRecVariant;
begin
  MatchCreateLeafAndPush(tkNone, cntRecVariant);

  try
    repeat
      BuildConstExpression;
      if FLex.TokenID = tkComma then
        MatchCreateLeaf(tkComma)
      else
        Break;
    until False;

    MatchCreateLeaf(tkColon);
    if FLex.TokenID = tkRoundOpen then
    begin
      MatchCreateLeafAndPush(tkRoundOpen);

      try
        BuildFieldList;
      finally
        PopLeaf;
      end;
      MatchCreateLeaf(tkRoundClose);
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildPropertyInterface;
begin
  MatchCreateLeafAndPush(tkNone, cntPropertyInterface);

  try
    if FLex.TokenID <> tkColon then
      BuildPropertyParameterList;
    MatchCreateLeaf(tkColon);
    BuildCommonType;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildPropertySpecifiers;
var
  ID: TTokenKind;
begin
  MatchCreateLeafAndPush(tkNone, cntPropertySpecifiers);

  try
    while FLex.TokenID in PropertySpecifiersTokens do
    begin
      ID := FLex.TokenID;
      MatchCreateLeaf(FLex.TokenID);
      case ID of
        tkDispid:
          begin
            BuildExpression;
          end;
        tkIndex, tkStored, tkDefault:
          begin
            BuildConstExpression;
          end;
        tkRead, tkWrite:
          begin
            BuildDesignator;
          end;
        tkImplements:
          begin
            BuildTypeID;
          end;
        // tkNodefault, tkReadonly, tkWriteonly ֱ�� Match ��
      end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildPropertyParameterList;
begin
  MatchCreateLeafAndPush(tkNone, cntPropertyParameterList);

  try
    MatchCreateLeafAndPush(tkSquareOpen);

    repeat
      if FLex.TokenID in [tkVar, tkConst, tkOut] then
        MatchCreateLeaf(FLex.TokenID);

      BuildIdentList;
      MatchCreateLeaf(tkColon);
      BuildTypeID;

      if FLex.TokenID <> tkSemiColon then
        Break;
    until False;

    MatchCreateLeaf(tkSquareClose);
  finally
    PopLeaf;
  end;
end;

end.
