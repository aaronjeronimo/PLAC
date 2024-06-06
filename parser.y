%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
extern int yylex(void);
extern FILE *yyin;
extern int yylineno; // Declaración para obtener el número de línea
extern char *yytext; // Declaración para obtener el texto actual
%}

%union {
    char* sval;
    int ival;
}

%token CLASS PUBLIC PRIVATE RETURN IF ELSE SWITCH CASE DEFAULT
%token FOR WHILE DO NEW PRINT OUT BREAK INT DOUBLE CHAR BOOLEAN STRING VOID
%token IDENTIFIER CAP_IDENTIFIER STRING_LITERAL CHAR_LITERAL
%token NUMBER BOOLEAN_LITERAL
%token EQ NE AND OR LBRACE RBRACE LPAREN RPAREN

%type class_declaration class_body method_declaration parameter_list parameter variable_declaration
%type statement assignment_statement expression literal compound_expression object_creation method_call argument_list
%type condition control_statement loop_statement print_statement return_statement break_statement

%%
program:
    class_declaration_list
    ;

class_declaration_list:
    class_declaration
    | class_declaration_list class_declaration
    ;

class_declaration:
    PUBLIC CLASS CAP_IDENTIFIER LBRACE class_body RBRACE
    ;

class_body:
    variable_declaration_list method_declaration_list
    ;

variable_declaration_list:
    /* empty */
    | variable_declaration_list variable_declaration
    ;

method_declaration_list:
    /* empty */
    | method_declaration_list method_declaration
    ;

method_declaration:
    modifier return_type IDENTIFIER LPAREN parameter_list RPAREN LBRACE variable_declaration_list statement_list RBRACE
    | return_type IDENTIFIER LPAREN parameter_list RPAREN LBRACE variable_declaration_list statement_list RBRACE
    ;

parameter_list:
    /* empty */
    | parameter
    | parameter_list ',' parameter
    ;

parameter:
    data_type IDENTIFIER
    ;

variable_declaration:
    modifier data_type IDENTIFIER ';'
    | data_type IDENTIFIER ';'
    ;

modifier:
    PUBLIC
    | PRIVATE
    ;

return_type:
    VOID
    | data_type
    ;

data_type:
    INT
    | CHAR
    | DOUBLE
    | BOOLEAN
    | STRING
    ;

statement_list:
    /* empty */
    | statement_list statement
    ;

statement:
    assignment_statement
    | loop_statement
    | control_statement
    | print_statement
    | return_statement
    | break_statement
    ;

assignment_statement:
    IDENTIFIER '=' expression ';'
    ;

expression:
    literal
    | IDENTIFIER
    | method_call
    | object_creation
    | compound_expression
    ;

literal:
    NUMBER
    | CHAR_LITERAL
    | STRING_LITERAL
    | BOOLEAN_LITERAL
    ;

compound_expression:
    expression '+' expression
    | expression '-' expression
    | expression '*' expression
    | expression '/' expression
    ;

object_creation:
    NEW IDENTIFIER LPAREN RPAREN
    ;

method_call:
    IDENTIFIER '.' IDENTIFIER LPAREN argument_list RPAREN
    | IDENTIFIER '.' IDENTIFIER LPAREN RPAREN
    ;

argument_list:
    expression
    | argument_list ',' expression
    ;

loop_statement:
    DO LBRACE statement_list RBRACE WHILE LPAREN condition RPAREN ';'
    | FOR LPAREN data_type IDENTIFIER '=' expression ';' condition ';' assignment_statement RPAREN LBRACE statement_list RBRACE
    ;

condition:
    expression '>' expression
    | expression '<' expression
    | expression EQ expression
    | expression NE expression
    | expression AND expression
    | expression OR expression
    ;

control_statement:
    IF LPAREN condition RPAREN LBRACE statement_list RBRACE else_if_list else_clause
    | SWITCH LPAREN expression RPAREN LBRACE case_clause_list default_clause RBRACE
    ;

else_if_list:
    /* empty */
    | else_if_list ELSE IF LPAREN condition RPAREN LBRACE statement_list RBRACE
    ;

else_clause:
    /* empty */
    | ELSE LBRACE statement_list RBRACE
    ;

case_clause_list:
    /* empty */
    | case_clause_list case_clause
    ;

case_clause:
    CASE expression ':' statement_list
    ;

default_clause:
    /* empty */
    | DEFAULT ':' statement_list
    ;

print_statement:
    OUT '.' PRINT LPAREN STRING_LITERAL RPAREN
    | OUT '.' PRINT LPAREN STRING_LITERAL ',' IDENTIFIER RPAREN
    ;

return_statement:
    RETURN expression ';'
    ;

break_statement:
    BREAK ';'
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s at '%s'\n", yylineno, s, yytext);
}

int main(int argc, char **argv) {
    yylineno = 1; // Initialize line number
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "Could not open file %s\n", argv[1]);
            return 1;
        }
        yyin = file;
    }
    return yyparse();
}

