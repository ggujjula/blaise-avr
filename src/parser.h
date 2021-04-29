/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
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
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

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

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_SRC_PARSER_H_INCLUDED
# define YY_YY_SRC_PARSER_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    PLUS = 258,
    MINUS = 259,
    MULT = 260,
    DIVIDE = 261,
    EQ = 262,
    LT = 263,
    GT = 264,
    LBRACKET = 265,
    RBRACKET = 266,
    DOT = 267,
    COMMA = 268,
    COLON = 269,
    SEMICOLON = 270,
    POINT = 271,
    LPAREN = 272,
    RPAREN = 273,
    DIAMOND = 274,
    LTE = 275,
    GTE = 276,
    ASSIGN = 277,
    DOTDOT = 278,
    AND = 279,
    ARRAY = 280,
    PASBEGIN = 281,
    CASE = 282,
    CONST = 283,
    DIV = 284,
    DO = 285,
    DOWNTO = 286,
    ELSE = 287,
    END = 288,
    PASFILE = 289,
    FOR = 290,
    FUNC = 291,
    GOTO = 292,
    IF = 293,
    IN = 294,
    LABEL = 295,
    MOD = 296,
    NIL = 297,
    NOT = 298,
    OF = 299,
    OR = 300,
    PACKED = 301,
    PROC = 302,
    PROG = 303,
    RECORD = 304,
    REPEAT = 305,
    SET = 306,
    THEN = 307,
    TO = 308,
    TYPE = 309,
    UNTIL = 310,
    VAR = 311,
    WHILE = 312,
    WITH = 313,
    ID = 314,
    PASDIR = 315,
    NUM = 316,
    LABELNUM = 317,
    STR = 318
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef token YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_SRC_PARSER_H_INCLUDED  */
