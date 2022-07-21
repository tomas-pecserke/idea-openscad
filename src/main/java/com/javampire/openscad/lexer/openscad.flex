package com.javampire.openscad.lexer;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;
import com.intellij.psi.TokenType;
import com.javampire.openscad.psi.OpenSCADTypes;

%%

%class OpenSCADLexer
%implements FlexLexer
%unicode
%function advance
%type IElementType
%eof{  return;
%eof}

CRLF=\R
BLANK=[ \t\f]
WHITE_SPACE={CRLF} | {BLANK}

IMPORT_COND={WHITE_SPACE}*"<"
IMPORT_PATH=[^<>]+

C_STYLE_COMMENT=("/*"[^"*"]{COMMENT_TAIL})|"/*"
DOC_COMMENT="/*""*"+("/"|([^"/""*"]{COMMENT_TAIL}))?
COMMENT_TAIL=([^"*"]*("*"+[^"*""/"])?)*("*"+"/")?
END_OF_LINE_COMMENT="/""/"[^\r\n]*
BLOCK_COMMENT_BODY={BLANK}*{END_OF_LINE_COMMENT}(\R{BLANK}*{END_OF_LINE_COMMENT})*
BLOCK_COMMENT_END=\R{BLANK}*("module"|"function"|{IDENTIFIER}{WHITE_SPACE}*"=")

IDENTIFIER = [a-zA-Z0-9_$]*

DIGIT = [0-9]
DECIMAL = {DIGIT}+ "."? | {DIGIT}* "." {DIGIT}+
NUMBER_LITERAL = {DECIMAL} ([Ee] [+-]? {DIGIT}+)?

ESCAPE_SEQUENCE = \\[^]
STRING_LITERAL = \"  ([^\\\"] | {ESCAPE_SEQUENCE})* \"?

%state IMPORT_PATH

%%

<YYINITIAL> {

    "false"                     { return OpenSCADTypes.FALSE_KEYWORD; }
    "true"                      { return OpenSCADTypes.TRUE_KEYWORD; }
    "undef"                     { return OpenSCADTypes.UNDEF_KEYWORD; }

    "function"	                { return OpenSCADTypes.FUNCTION_KEYWORD; }
    "module"	                { return OpenSCADTypes.MODULE_KEYWORD; }

    "else"                      { return OpenSCADTypes.ELSE_KEYWORD; }
    "for"                       { return OpenSCADTypes.FOR_KEYWORD; }
    "if"                        { return OpenSCADTypes.IF_KEYWORD; }
    "let"                       { return OpenSCADTypes.LET_KEYWORD; }
    "assign"                    { return OpenSCADTypes.ASSIGN_KEYWORD; }
    "each"                      { return OpenSCADTypes.EACH_KEYWORD; }

    "include"
     / {IMPORT_COND}           { yybegin(IMPORT_PATH); return OpenSCADTypes.INCLUDE_KEYWORD; }
    "use"
     / {IMPORT_COND}           { yybegin(IMPORT_PATH); return OpenSCADTypes.USE_KEYWORD; }

    "."                         { return OpenSCADTypes.DOT; }
    "="                         { return OpenSCADTypes.EQUALS; }
    ";"                         { return OpenSCADTypes.SEMICOLON; }
    ","                         { return OpenSCADTypes.COMMA; }
    "-"                         { return OpenSCADTypes.MINUS; }
    "+"                         { return OpenSCADTypes.PLUS; }
    "/"                         { return OpenSCADTypes.DIV; }
    "*"                         { return OpenSCADTypes.MUL; }
    "%"                         { return OpenSCADTypes.PERC; }
    "?"                         { return OpenSCADTypes.QUERY; }
    ":"                         { return OpenSCADTypes.COLON; }
    "("                         { return OpenSCADTypes.LPARENTH; }
    ")"                         { return OpenSCADTypes.RPARENTH; }
    "{"                         { return OpenSCADTypes.LBRACE; }
    "}"                         { return OpenSCADTypes.RBRACE; }
    "["                         { return OpenSCADTypes.LBRACKET; }
    "]"                         { return OpenSCADTypes.RBRACKET; }
    "#"                         { return OpenSCADTypes.HASH; }

    "<"                         { return OpenSCADTypes.LT; }
    "<="                        { return OpenSCADTypes.LE; }
    ">"                         { return OpenSCADTypes.GT; }
    ">="                        { return OpenSCADTypes.GE; }
    "=="                        { return OpenSCADTypes.EQ; }
    "!="                        { return OpenSCADTypes.NE; }

    "&&"                        { return OpenSCADTypes.AND; }
    "||"                        { return OpenSCADTypes.OR; }
    "!"                         { return OpenSCADTypes.EXCL; }

    ^{BLOCK_COMMENT_BODY}
    / {BLOCK_COMMENT_END}       { return OpenSCADTypes.BLOCK_COMMENT; }
    {C_STYLE_COMMENT}           { return OpenSCADTypes.C_STYLE_COMMENT; }
    {DOC_COMMENT}               { return OpenSCADTypes.DOC_COMMENT; }
    {END_OF_LINE_COMMENT}       { return OpenSCADTypes.END_OF_LINE_COMMENT; }

    {NUMBER_LITERAL}            { return OpenSCADTypes.NUMBER_LITERAL; }
    {IDENTIFIER}                { return OpenSCADTypes.IDENTIFIER; }
    {STRING_LITERAL}            { return OpenSCADTypes.STRING_LITERAL; }

}

{WHITE_SPACE}+                  { return TokenType.WHITE_SPACE; }

<IMPORT_PATH> {
    "<"                         { return OpenSCADTypes.IMPORT_START; }
    {IMPORT_PATH}              { return OpenSCADTypes.IMPORT_PATH; }
    ">"                         { yybegin(YYINITIAL); return OpenSCADTypes.IMPORT_END; }
}

[^]                             { return TokenType.BAD_CHARACTER; }
