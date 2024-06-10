%{
#include "parser.tab.h"
#include <string.h>

%}

%option yylineno

underscore     "_"
digit          [0-9]
letter         [a-zA-Z]
cap_letter     [A-Z]
identifier     ({letter}|{underscore})({letter}|{digit}|{underscore})*
cap_identifier {cap_letter}({letter}|{digit}|{underscore})*
string_lit     \"[^\"]*\"
char_lit       \'[^\']\'
comment        "//".*|"/*"(.|\n)*"*/"

%%
"public"         { return PUBLIC; }
"class"          { return CLASS; }
"private"        { return PRIVATE; }
"return"         { return RETURN; }
"if"             { return IF; }
"else"           { return ELSE; }
"switch"         { return SWITCH; }
"case"           { return CASE; }
"default"        { return DEFAULT; }
"for"            { return FOR; }
"while"          { return WHILE; }
"do"             { return DO; }
"new"            { return NEW; }
"out.print"      { return PRINT; }
"break"          { return BREAK; }

"int"		 { return INT; }
"char"		 { return CHAR; }
"String"     { return STRING; }
"double"	 { return DOUBLE; }
"boolean"	 { return BOOLEAN; }
"void"	 	 { return VOID; }

"true"           { yylval.ival = 1; return BOOLEAN_LITERAL; }
"false"          { yylval.ival = 0; return BOOLEAN_LITERAL; }

{cap_identifier} { yylval.sval = strdup(yytext); return CAP_IDENTIFIER; }
{identifier}     { yylval.sval = strdup(yytext); return IDENTIFIER; }
{string_lit}     { yylval.sval = strdup(yytext); return STRING_LITERAL; }
{char_lit}       { yylval.sval = strdup(yytext); return CHAR_LITERAL; }
{digit}+         { yylval.ival = atoi(yytext); return NUMBER; }

{comment}        { /* ignore comments */ }

"+"              { return PLUS; }
"-"              { return MINUS; }
"*"              { return STAR; }
"/"              { return SLASH; }
"="              { return ASSIGN; }
"=="             { return EQ; }
"!="             { return NE; }
">"              { return GREATER; }
"<"              { return LESS; }
"&&"             { return AND; }
"||"             { return OR; }
"{"              { return LBRACE; }
"}"              { return RBRACE; }
"("              { return LPAREN; }
")"              { return RPAREN; }
";"              { return SEMICOLON; }
":"              { return COLON; }
"."              { return POINT; }
","              { return COMMA; }

[ \t\n]+         { /* ignore whitespace */ }


.               { printf("Unexpected character: %s\n", yytext); }

%%

int yywrap() {
    return 1;
}

