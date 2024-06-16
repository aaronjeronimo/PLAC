%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yyerror(const char *s);
extern int yylex(void);
extern FILE *yyin;
extern int yylineno; // Declaración para obtener el número de línea
extern char *yytext; // Declaración para obtener el texto actual
%}

%union {
    char* sval;
    int ival;
    double dval;
}

%token CLASS PUBLIC PRIVATE RETURN IF ELSE SWITCH CASE DEFAULT FOR WHILE DO NEW PRINT BREAK INT DOUBLE CHAR BOOLEAN STRING VOID
%token IDENTIFIER CAP_IDENTIFIER STRING_LITERAL CHAR_LITERAL DOUBLE_LITERAL NUMBER BOOLEAN_LITERAL EQ NE AND OR PLUS MINUS STAR
%token SLASH ASSIGN GREATER LESS LBRACE RBRACE LPAREN RPAREN SEMICOLON COLON POINT COMMA

%start program

%%
program:
    class_declaration_list
    ;

class_declaration_list:
    class_declaration
    | class_declaration class_declaration_list
    ;

class_declaration:
    PUBLIC CLASS CAP_IDENTIFIER LBRACE variable_declaration_list RBRACE
    ;

variable_declaration_list:
    variable_declaration variable_declaration_list
    | method_declaration_list
    ;

variable_declaration:
     modifier data_type IDENTIFIER variable_initialization more_variables SEMICOLON
    | modifier CAP_IDENTIFIER IDENTIFIER ASSIGN NEW CAP_IDENTIFIER LPAREN RPAREN SEMICOLON
    ;

variable_initialization:
    /* empty */
    | ASSIGN expression
    ;

more_variables:
    /* empty */
    | COMMA IDENTIFIER variable_initialization more_variables
    ;

method_declaration_list:
    /* empty */
    | method_declaration method_declaration_list
    | class_declaration_list
    ;

method_declaration:
    modifier data_type IDENTIFIER LPAREN parameter_list RPAREN LBRACE variable_declaration_list statement_list RBRACE
    | modifier VOID IDENTIFIER LPAREN parameter_list RPAREN LBRACE variable_declaration_list statement_list RBRACE
    ;

parameter_list:
    /* empty */
    | parameter
    | parameter_list COMMA parameter
    ;

parameter:
    data_type IDENTIFIER
    ;

modifier:
    /* empty */
    | PUBLIC
    | PRIVATE
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
    | statement statement_list
    ;

statement:
    assignment_statement
    | loop_statement
    | control_statement
    | print_statement
    | return_statement
    | method_call SEMICOLON
    ;

statement_list_for_loop:
    /* empty */
    | statement_for_loop statement_list_for_loop
    ;

statement_for_loop:
    assignment_statement
    | loop_statement
    | control_statement_for_loop
    | print_statement
    | return_statement
    | break_statement
    | method_call SEMICOLON
    ;


assignment_statement:
    IDENTIFIER ASSIGN expression SEMICOLON
    ;

expression:
    literal
    | IDENTIFIER
    | method_call
    | using_attribute
    | compound_expression

    ;

literal:
    NUMBER
    | CHAR_LITERAL
    | STRING_LITERAL
    | BOOLEAN_LITERAL
    | DOUBLE_LITERAL
    ;

compound_expression:
    expression aritmetic_operator expression
    | LPAREN expression aritmetic_operator expression RPAREN
    ;

aritmetic_operator:
    PLUS
    | MINUS
    | STAR
    | SLASH
    ;

using_attribute:
    IDENTIFIER POINT IDENTIFIER
    ;

method_call:
    IDENTIFIER POINT IDENTIFIER LPAREN argument_list RPAREN
    | IDENTIFIER POINT IDENTIFIER LPAREN RPAREN
    ;

argument_list:
    expression
    | argument_list COMMA expression
    ;

loop_statement:
    DO LBRACE statement_list_for_loop RBRACE WHILE LPAREN condition RPAREN SEMICOLON
    | FOR LPAREN data_type IDENTIFIER ASSIGN expression SEMICOLON condition SEMICOLON IDENTIFIER ASSIGN compound_expression RPAREN LBRACE statement_list_for_loop RBRACE
    ;

condition:
    expression logic_operator expression
    ;

logic_operator:
    GREATER 
    | LESS 
    | EQ 
    | NE 
    | AND 
    | OR 
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
    | case_clause case_clause_list
    ;

case_clause:
    CASE expression COLON statement_list
    ;

default_clause:
    /* empty */
    | DEFAULT COLON statement_list
    
control_statement_for_loop:
    IF LPAREN condition RPAREN LBRACE statement_list_for_loop RBRACE else_if_list_for_loop else_clause_for_loop
    | SWITCH LPAREN expression RPAREN LBRACE case_clause_list_for_loop default_clause_for_loop RBRACE
    ;

else_if_list_for_loop:
    /* empty */
    | else_if_list_for_loop ELSE IF LPAREN condition RPAREN LBRACE statement_list RBRACE
    ;

else_clause_for_loop:
    /* empty */
    | ELSE LBRACE statement_list_for_loop RBRACE
    ;

case_clause_list_for_loop:
    /* empty */
    | case_clause_for_loop case_clause_list_for_loop
    ;

case_clause_for_loop:
    CASE expression COLON statement_list_for_loop
    ;

default_clause_for_loop:
    /* empty */
    | DEFAULT COLON statement_list_for_loop
    ;

print_statement:
    PRINT LPAREN STRING_LITERAL more_variables RPAREN SEMICOLON
    ;

return_statement:
    RETURN expression SEMICOLON
    ;

break_statement:
    BREAK SEMICOLON
    ;

%%

int yyerror(const char *s) {
    fprintf(stderr, "%s at line %d at '%s'\n", s, yylineno, yytext);
    exit(1);
}

int main(int argc, char **argv) {
    
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "Could not open file %s\n", argv[1]);
            return 1;
        }

        int c;
        while ((c = fgetc(file)) != EOF) {
            putchar(c);
        }
        printf("\n\n");

        fclose(file);

        yyin = fopen(argv[1], "r"); // Establecer yyin para que Flex lea desde el archivo
        
        int ret = yyparse();

        fclose(yyin);

        if (ret == 0) 
            printf("The code is completely correct!\n");
        else {
            printf("Parsing failed with errors.\n");
            return 1;
        }
    }
    else {
        fprintf(stderr, "The file that should be checked should be the first argument.\n");
        return 1;
    }

    
    return 0;
}

