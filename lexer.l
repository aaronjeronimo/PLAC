%{
#include "parser.tab.h"
#include <string.h>

%}

digit          [0-9]
letter         [a-zA-Z]
cap_letter     [A-Z]
identifier     {letter}({letter}|{digit})*
cap_identifier {cap_letter}({letter}|{digit})*
string_lit     \"[^\"]*\"
char_lit       \'[^\']\'
comment        "//".*|"/*"(.|\n)*?"*/"

%%
\n           	 { yylineno++; } // Incrementa el número de línea en cada nueva línea
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
"print"          { return PRINT; }
"out"            { return OUT; }
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

{comment}        { /* ignore comments */ yylineno++; }

"+"              { return '+'; }
"-"              { return '-'; }
"*"              { return '*'; }
"/"              { return '/'; }
"="              { return '='; }
"=="             { return EQ; }
"!="             { return NE; }
">"              { return '>'; }
"<"              { return '<'; }
"&&"             { return AND; }
"||"             { return OR; }
"{"              { return LBRACE; }
"}"              { return RBRACE; }
"("              { return LPAREN; }
")"              { return RPAREN; }
";"              { return ';'; yylineno++; }
"."              { return '.'; }
","              { return ','; }

[ \t\n]+         { /* ignore whitespace */ }


.                { printf("Unexpected character: %s\n", yytext); }

%%

int yywrap() {
    return 1;
}

