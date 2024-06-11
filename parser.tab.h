/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    CLASS = 258,                   /* CLASS  */
    PUBLIC = 259,                  /* PUBLIC  */
    PRIVATE = 260,                 /* PRIVATE  */
    RETURN = 261,                  /* RETURN  */
    IF = 262,                      /* IF  */
    ELSE = 263,                    /* ELSE  */
    SWITCH = 264,                  /* SWITCH  */
    CASE = 265,                    /* CASE  */
    DEFAULT = 266,                 /* DEFAULT  */
    FOR = 267,                     /* FOR  */
    WHILE = 268,                   /* WHILE  */
    DO = 269,                      /* DO  */
    NEW = 270,                     /* NEW  */
    PRINT = 271,                   /* PRINT  */
    BREAK = 272,                   /* BREAK  */
    INT = 273,                     /* INT  */
    DOUBLE = 274,                  /* DOUBLE  */
    CHAR = 275,                    /* CHAR  */
    BOOLEAN = 276,                 /* BOOLEAN  */
    STRING = 277,                  /* STRING  */
    VOID = 278,                    /* VOID  */
    IDENTIFIER = 279,              /* IDENTIFIER  */
    CAP_IDENTIFIER = 280,          /* CAP_IDENTIFIER  */
    STRING_LITERAL = 281,          /* STRING_LITERAL  */
    CHAR_LITERAL = 282,            /* CHAR_LITERAL  */
    DOUBLE_LITERAL = 283,          /* DOUBLE_LITERAL  */
    NUMBER = 284,                  /* NUMBER  */
    BOOLEAN_LITERAL = 285,         /* BOOLEAN_LITERAL  */
    EQ = 286,                      /* EQ  */
    NE = 287,                      /* NE  */
    AND = 288,                     /* AND  */
    OR = 289,                      /* OR  */
    PLUS = 290,                    /* PLUS  */
    MINUS = 291,                   /* MINUS  */
    STAR = 292,                    /* STAR  */
    SLASH = 293,                   /* SLASH  */
    ASSIGN = 294,                  /* ASSIGN  */
    GREATER = 295,                 /* GREATER  */
    LESS = 296,                    /* LESS  */
    LBRACE = 297,                  /* LBRACE  */
    RBRACE = 298,                  /* RBRACE  */
    LPAREN = 299,                  /* LPAREN  */
    RPAREN = 300,                  /* RPAREN  */
    SEMICOLON = 301,               /* SEMICOLON  */
    COLON = 302,                   /* COLON  */
    POINT = 303,                   /* POINT  */
    COMMA = 304                    /* COMMA  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 13 "parser.y"

    char* sval;
    int ival;
    double dval;

#line 119 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
