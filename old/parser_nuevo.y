%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

int yyerror(const char *s);
extern int yylex(void);
extern FILE *yyin;
extern int yylineno;
extern char *yytext;

typedef struct {
    char *name;
    char *class_name;
    int modifier; // Private 0, Public 1
} info;

char *actual_class = NULL;
info *var_and_methods = NULL;
int num_items = 0;

bool search_info(char *name, char *class_name) {
    int index = -1;
    for (int i = 0; i < num_items; i++) {
        if (strcmp(var_and_methods[i].name,name) == 0) {
            index = i;
        }
    }

    if (index == -1) {
        fprintf(stderr, "Error: variable or method not declared\n");
        exit(1);
    } else if (var_and_methods[index].modifier == 1 || var_and_methods[index].class_name == class_name) {
        return true;
    }
    return false;
}

void add_info(char *name, char * class_name, char *modifier) {
    num_items++;
    var_and_methods = realloc(var_and_methods, num_items*sizeof(info));
    info temp;
    temp.name = strdup(name);
    temp.class_name = strdup(class_name);
    temp.modifier = 0;
    if (strcmp(modifier, (char*)"public") == 0) {
        temp.modifier = 1;
    }
    var_and_methods[num_items - 1] = temp;
}

%}

%union {
    char* sval;
    int ival;
    double dval;
}

%token CLASS RETURN IF ELSE SWITCH CASE DEFAULT FOR WHILE DO NEW PRINT BREAK VOID
%token EQ NE AND OR PLUS MINUS STAR
%token SLASH ASSIGN GREATER LESS LBRACE RBRACE LPAREN RPAREN SEMICOLON COLON POINT COMMA

%token <sval> IDENTIFIER CAP_IDENTIFIER PUBLIC PRIVATE INT CHAR DOUBLE BOOLEAN STRING CHAR_LITERAL STRING_LITERAL
%token <dval> DOUBLE_LITERAL
%token <ival> BOOLEAN_LITERAL NUMBER

%type <sval> modifier data_type expression literal
%type <dval> compound_expression

%left '+' '-'
%left '*' '/'

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
    PUBLIC CLASS CAP_IDENTIFIER LBRACE attribute_declaration_list RBRACE { actual_class = strdup($3); }
    ;

attribute_declaration_list:
    attribute_declaration attribute_declaration_list
    | method_declaration_list
    ;

attribute_declaration:
    modifier data_type IDENTIFIER more_variables_declaration SEMICOLON { add_info($3,actual_class,$1); }
    | modifier data_type IDENTIFIER ASSIGN expression more_variables_declaration SEMICOLON {

        add_info($3,actual_class,$1);
    }
    | modifier CAP_IDENTIFIER IDENTIFIER ASSIGN NEW CAP_IDENTIFIER LPAREN RPAREN SEMICOLON { add_info($3,actual_class,$1); }
    ;

more_variables_declaration:
    /* empty */
    | COMMA IDENTIFIER ASSIGN expression more_variables_declaration
    | COMMA IDENTIFIER more_variables_declaration
    ;

method_declaration_list:
    /* empty */
    | method_declaration method_declaration_list
    | class_declaration_list
    ;

method_declaration:
    modifier data_type IDENTIFIER LPAREN parameter_list RPAREN LBRACE variable_declaration_list statement_list RBRACE { add_info($3,actual_class,$1); }
    | modifier VOID IDENTIFIER LPAREN parameter_list RPAREN LBRACE variable_declaration_list statement_list RBRACE { add_info($3,actual_class,$1); }
    ;

parameter_list:
    /* empty */
    | parameter
    | parameter_list COMMA parameter
    ;

parameter:
    data_type IDENTIFIER
    ;

variable_declaration_list:
    /* empty */
    | variable_declaration variable_declaration_list
    ;


variable_declaration:
    data_type IDENTIFIER COMMA ASSIGN more_variables_declaration SEMICOLON
    | data_type IDENTIFIER more_variables_declaration SEMICOLON
    | CAP_IDENTIFIER IDENTIFIER ASSIGN NEW CAP_IDENTIFIER LPAREN RPAREN SEMICOLON
    ;


modifier:
    PUBLIC
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
    | IDENTIFIER POINT IDENTIFIER { if(search_info($3,actual_class)==0) {fprintf(stderr, "Error: variable or method is private"); exit(1);}}
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
    expression PLUS expression // { $$ = $1 + $3; }
    | expression MINUS expression  // { $$ = $1 - $3; }
    | expression STAR expression  // { $$ = $1 * $3; }
    | expression SLASH expression  // { if ($3 != 0) $$ = $1 / $3; else { fprintf(stderr, "Error: division by 0\n"); exit(1); } }
    | LPAREN expression PLUS expression RPAREN  // { $$ = ($1 + $3); }
    | LPAREN expression MINUS expression RPAREN  // { $$ = ($1 - $3); }
    | LPAREN expression STAR expression RPAREN  // { $$ = ($1 * $3); }
    | LPAREN expression SLASH expression RPAREN  // { $$ = ($1 / $3); if ($3 != 0) $$ = $1 / $3    ; else { fprintf(stderr, "Error: division by 0\n"); exit(1); } }
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

more_variables:
    /* empty */
    | COMMA IDENTIFIER more_variables
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
    }
    else {
        fprintf(stderr, "The file that should be checked should be the first argument.\n");
        return 1;
    }

    if (yyparse() == 0) 
        printf("The code is completely correct!\n");
    else {
        printf("Parsing failed with errors.\n");
        return 1;
    }

    free(var_and_methods);

    return 0;
}

