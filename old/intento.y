%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yyerror(const char *s);
extern int yylex(void);
extern FILE *yyin;
extern int yylineno;
extern char *yytext;

typedef struct {
    char *name;
    char *class;
    int modifier; // 0 = Private, 1 = Public
} variable;

typedef struct {
    char *name;
    char *class;
    int modifier; // 0 = Private, 1 = Public
} method;

typedef struct {
    char *name;
    variable *variables;
    method *methods;
    int num_variables;
    int num_methods;
} class;


int actual_index = -1;
class *classes = NULL;
int num_classes = 0;

variable *scope_variables = NULL;
int num_scope_variables = 0;

int find_class(char *name) {
    for (int i = 0; i < num_classes; i++) {
        if (strcmp(classes[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

void add_class(char *name) {
    int index = find_class(name);
    if (index == -1) {
        actual_index++;
        num_classes++;
        classes = realloc(classes, num_classes * sizeof(class));

        if (classes == NULL) {
            fprintf(stderr, "Error: memory allocation failed\n");
            exit(1);
        }

        classes[num_classes - 1].name = strdup(name);
        classes[num_classes - 1].variables = NULL;
        classes[num_classes - 1].methods = NULL;
        classes[num_classes - 1].num_variables = 0;
        classes[num_classes - 1].num_methods = 0;
    
    } else {
        fprintf(stderr, "Error: class '%s' declared previously\n", name);
        exit(1);
    }
}

int find_attribute(int class_index, char *name) {
    for (int i = 0; i < classes[class_index].num_variables; i++) {
        if (strcmp(classes[class_index].variables[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

void add_attribute(char *class, char *name, char *modifier) {
    int class_index = find_class(class);
    int index = find_attribute(class_index, name);
    
    if (index == -1) {
        classes[class_index].num_variables++;
        classes[class_index].variables = realloc(classes[class_index].variables, classes[class_index].num_variables * sizeof(variable));
        
        if (classes[class_index].variables == NULL) {
            fprintf(stderr, "Error: memory allocation failed\n");
            exit(1);
        }

        classes[class_index].variables[classes[class_index].num_variables - 1].name = strdup(name);
        classes[class_index].variables[classes[class_index].num_variables - 1].class = strdup(class);
        classes[class_index].variables[classes[class_index].num_variables - 1].modifier = (strcmp(modifier, "private") == 0 ? 0 : 1);
    } else {
        fprintf(stderr, "Error: variable '%s' declared previously\n", name);
        exit(1);
    }
}


/*
double get_attribute_value(char *class, char *name) {
    int class_index = find_class(class);
    int index = find_attribute(class_index,name);
    if (index == -1) {
        fprintf(stderr, "Error: variable '%s' not declared\n", name);
        exit(1);
    }
    else if (classes[class_index].variables[index].inicialized == 0) {
        fprintf(stderr, "Error: variable '%s' not inicialized\n", name);
        exit(1);
    }

    return classes[class_index].variables[index].value;
}
*/

int get_attribute_modifier(char *class, char *name) {
    int class_index = find_class(class);
    int index = find_attribute(class_index,name);
    if (index == -1) {
        fprintf(stderr, "Error: variable '%s' not declared\n", name);
        exit(1);
    }

    return classes[class_index].variables[index].modifier;
}

/*
void set_attribute_value(char *class, char *name, double value) {
    int class_index = find_class(class);
    int index = find_attribute(class_index,name);
    
    if (index == -1) {
        fprintf(stderr, "Error: variable '%s' not declared\n", name);
        exit(1);
    }

    classes[class_index].variables[index].inicialized = 1;
    classes[class_index].variables[index].value = value;
    printf("Variable '%s' assigned value %f\n", name, value);
}
*/

int find_method(int class_index, char *name) {
    for (int i = 0; i < classes[class_index].num_methods; i++) {
        if (strcmp(classes[class_index].methods[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

void add_method(char *class, char *name, char *modifier) {
    int class_index = find_class(class);
    int index = find_method(class_index, name);

    if (index == -1) {
        classes[class_index].num_methods++;
        classes[class_index].methods = realloc(classes[class_index].methods, classes[class_index].num_methods * sizeof(method));
        classes[class_index].methods[classes[class_index].num_methods - 1].name = strdup(name);
        classes[class_index].methods[classes[class_index].num_methods - 1].modifier = (strcmp(modifier, "private") ? 0 : 1);
    } else {
        fprintf(stderr, "Error: method '%s' declared previously\n", name);
        exit(1);
    }
}

int get_method_modifier(char *class, char *name) {
    int class_index = find_class(class);
    int index = find_method(class_index, name);

    if (index == -1) {
        fprintf(stderr, "Error: method '%s' not declared\n", name);
        exit(1);
    }

    return classes[class_index].methods[index].modifier;
}

int find_variable(char *name) {
    for (int i = 0; i < num_scope_variables; i++) {
        if (strcmp(scope_variables[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

void add_variable(char *class, char *name, char *modifier) {
    int index = find_variable(name);
    if (index == -1) {
        num_scope_variables++;
        scope_variables = realloc(scope_variables, num_scope_variables * sizeof(variable));
        scope_variables[num_scope_variables - 1].name = strdup(name);
        scope_variables[num_scope_variables - 1].class = strdup(class);
        scope_variables[num_scope_variables - 1].modifier = (strcmp(modifier, "private") ? 0 : 1);
        // scope_variables[num_scope_variables - 1].inicialized = inicialized;
        // scope_variables[num_scope_variables - 1].value = value;
    } else {
        fprintf(stderr, "Error: variable '%s' declared previously\n", name);
        exit(1);
    }
}

/*
double get_variable_value(char *name) {
    int index = find_variable(name);
    if (index == -1) {
        fprintf(stderr, "Error: variable '%s' not declared\n", name);
        exit(1);
    }
    else if (scope_variables[index].inicialized == 0) {
        fprintf(stderr, "Error: variable '%s' not inicialized\n", name);
        exit(1);
    }

    return scope_variables[index].value;
}

void set_variable_value(char *name, double value) {
    int index = find_variable(name);
    
    if (index == -1) {
        fprintf(stderr, "Error: variable '%s' not declared\n", name);
        exit(1);
    }

    
    scope_variables[index].inicialized = 1;
    scope_variables[index].value = value;
    printf("Variable '%s' assigned value %f\n", name, value);
}
*/

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
    PUBLIC CLASS CAP_IDENTIFIER LBRACE attribute_declaration_list RBRACE { add_class($3); }
    ;

attribute_declaration_list:
    attribute_declaration attribute_declaration_list
    | method_declaration_list
    ;

attribute_declaration:
    modifier data_type IDENTIFIER more_variables_declaration SEMICOLON { add_attribute(classes[actual_index].name, $3, $1); }
    | modifier data_type IDENTIFIER ASSIGN expression more_variables_declaration SEMICOLON {
        /*
        if($2 == "int" || $2 == "double") {
            add_attribute(actual_class, $3, $1, 1, $5);
            printf("Variable '%s' assigned value %f\n", $3, $5);
        } else {
        */

        add_attribute(classes[actual_index].name, $3, $1);
    }
    | modifier CAP_IDENTIFIER IDENTIFIER ASSIGN NEW CAP_IDENTIFIER LPAREN RPAREN SEMICOLON { add_attribute(classes[actual_index].name, $3, $1); }
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
    modifier data_type IDENTIFIER LPAREN parameter_list RPAREN LBRACE variable_declaration_list statement_list RBRACE { /*add_method(actual_class, $3, $1);*/ }
    | modifier VOID IDENTIFIER LPAREN parameter_list RPAREN LBRACE variable_declaration_list statement_list RBRACE { /*add_method(actual_class, $3, $1);*/ }
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
    | IDENTIFIER POINT IDENTIFIER {
        
        int index = find_variable($1);
        if (index == -1) { fprintf(stderr, "Error: object not declared\n"); exit(1); }
        
        int class_index = find_class(scope_variables[index].class);
        if (index == -1) { fprintf(stderr, "Error: class not declared or primitive class\n"); exit(1); }

        int attribute_index = find_attribute(class_index, $3);
        if (attribute_index == -1) {
            fprintf(stderr, "Error: attribute not declared\n"); exit(1);
        }
        else if (get_attribute_modifier(scope_variables[index].class,$3) == 1 || classes[actual_index].name == scope_variables[index].class) {
            
        }
        else { fprintf(stderr, "Error: private_attribute\n"); exit(1); }

    }
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
    {
        int index = find_variable($1);
        if (index == -1) { fprintf(stderr, "Error: object not declared\n"); exit(1); }
        
        int class_index = find_class(scope_variables[index].class);
        if (index == -1) { fprintf(stderr, "Error: class not declared or primitive class\n"); exit(1); }

        int method_index = find_method(class_index, $3);
        if (method_index == -1) {
            fprintf(stderr, "Error: method not declared\n"); exit(1);
        }
        else if (get_method_modifier(scope_variables[index].class,$3) == 1 || classes[actual_index].name == scope_variables[index].class) {
            
        }
        else { fprintf(stderr, "Error: private method\n"); exit(1); }
    }
    | IDENTIFIER POINT IDENTIFIER LPAREN RPAREN
        {
            int index = find_variable($1);
            if (index == -1) { fprintf(stderr, "Error: object not declared\n"); exit(1); }
            
            int class_index = find_class(scope_variables[index].class);
            if (index == -1) { fprintf(stderr, "Error: class not declared or primitive class\n"); exit(1); }

            int method_index = find_method(class_index, $3);
            if (method_index == -1) {
                fprintf(stderr, "Error: method not declared\n"); exit(1);
            }
            else if (get_method_modifier(scope_variables[index].class,$3) == 1 || classes[actual_index].name == scope_variables[index].class) {
                
            }
            else { fprintf(stderr, "Error: private method\n"); exit(1); }
        }
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

    for (int i = 0; i < num_classes; i++) {
        free(classes[i].name);
        for (int j = 0; j < classes[i].num_variables; j++) {
            free(classes[i].variables[j].name);
            free(classes[i].variables[j].class);
        }
        for (int j = 0; j < classes[i].num_methods; j++) {
            free(classes[i].methods[j].name);
            free(classes[i].methods[j].class);
        }
        free(classes[i].variables);
        free(classes[i].methods);
    }

    free(classes);

    for (int i = 0; i < num_scope_variables; i++) {
        free(scope_variables[i].name);
        free(scope_variables[i].class);
    }

    free(scope_variables);

    return 0;
}


