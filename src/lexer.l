/*
<desc>

  Copyright (C) 2021 <name> 

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

%{
#include <math.h> 
#include "token.h"
%}

%option nounput
%option noinput

LETTER    [a-zA-Z]
DIGIT     [0-9]

PLUS_SYM            \+
MINUS_SYM           \-
MULT_SYM            \*
DIVIDE_SYM          \/
EQ_SYM              =
LT_SYM              <
GT_SYM              >
LBRACKET_SYM        \[
RBRACKET_SYM        \]
DOT_SYM             \.
COMMA_SYM           ,
COLON_SYM           :
SEMICOLON_SYM       ;
POINT_SYM           \^
LPAREN_SYM          \(
RPAREN_SYM          \)
DIAMOND_SYM         (<>)
LTE_SYM             (<=)
GTE_SYM             (>=)
ASSIGN_SYM          (:=)
DOTDOT_SYM          (\.\.)
AND_SYM             (and)
ARRAY_SYM           (array)
BEGIN_SYM           (begin)
CASE_SYM            (case)
CONST_SYM           (const)
DIV_SYM             (div)
DO_SYM              (do)
DOWNTO_SYM          (downto)
ELSE_SYM            (else)
END_SYM             (end)
FILE_SYM            (file)
FOR_SYM             (for)
FUNC_SYM            (function)
GOTO_SYM            (goto)
IF_SYM              (if)
IN_SYM              (in)
LABEL_SYM           (label)
MOD_SYM             (mod)
NIL_SYM             (nil)
NOT_SYM             (not)
OF_SYM              (of)
OR_SYM              (or)
PACKED_SYM          (packed)
PROC_SYM            (procedure)
PROG_SYM            (program)
RECORD_SYM          (record)
REPEAT_SYM          (repeat)
SET_SYM             (set)
THEN_SYM            (then)
TO_SYM              (to)
TYPE_SYM            (type)
UNTIL_SYM           (until)
VAR_SYM             (var)
WHILE_SYM           (while)
WITH_SYM            (with)

WORD_SYMBOL {AND_SYM}|{ARRAY_SYM}|{BEGIN_SYM}|{CASE_SYM}|{CONST_SYM}|{DIV_SYM}|{DO_SYM}|{DOWNTO_SYM}|{ELSE_SYM}|{END_SYM}|{FILE_SYM}|{FOR_SYM}|{FUNC_SYM}|{GOTO_SYM}|{IF_SYM}|{IN_SYM}|{LABEL_SYM}|{MOD_SYM}|{NIL_SYM}|{NOT_SYM}|{OF_SYM}|{OR_SYM}|{PACKED_SYM}|{PROC_SYM}|{PROG_SYM}|{RECORD_SYM}|{REPEAT_SYM}|{SET_SYM}|{THEN_SYM}|{TO_SYM}|{TYPE_SYM}|{UNTIL_SYM}|{VAR_SYM}|{WHILE_SYM}|{WITH_SYM}

SPECIAL_SYMBOL [{PLUS_SYM}{MINUS_SYM}{MULT_SYM}{DIVIDE_SYM}{EQ_SYM}{LT_SYM}{GT_SYM}{LBRACKET_SYM}{RBRACKET_SYM}{DOT_SYM}{COMMA_SYM}{COLON_SYM}{SEMICOLON_SYM}{POINT_SYM}{LPAREN_SYM}{RPAREN_SYM}]|{DIAMOND_SYM}|{LTE_SYM}|{GTE_SYM}|{ASSIGN_SYM}|{DOTDOT_SYM}|{WORD_SYMBOL}

ID {LETTER}({LETTER}|{DIGIT})*

DIRECTIVE {LETTER}({LETTER}|{DIGIT})*

SIGNED_NUM {SIGNED_INT}|{SIGNED_REAL}.

SIGNED_REAL {SIGN}?{UNSIGNED_REAL}

SIGNED_INT {SIGN}?{UNSIGNED_INT}

UNSIGNED_NUM {UNSIGNED_INT}|{UNSIGNED_REAL}.

SIGN [\+|\-] 

UNSIGNED_REAL ({DIGIT_SEQ}\.{FRAC_PART}(e{SCALE_FACTOR})?)|({DIGIT_SEQ}e{SCALE_FACTOR})

UNSIGNED_INT {DIGIT_SEQ}
 
FRAC_PART {DIGIT_SEQ}

SCALE_FACTOR {SIGN}?{DIGIT_SEQ}
 
DIGIT_SEQ {DIGIT}{DIGIT}*

LABEL {DIGIT_SEQ}

CHAR_STR '{STR_ELEM}{STR_ELEM}*'

STR_ELEM {APOSTROPHE_IMG}|{STR_CHAR}

APOSTROPHE_IMG \"

STR_CHAR .

COMMENT ((\{)|(\(\*))([^}*]|(\*[^)]))*((\})|(\*\)))
%%
{COMMENT}|[\n\r\t\x20]        {}//printf("Comment or whitespace: %s\n", yytext);}
{PLUS_SYM}          {yylval = inittok(TYPE_SPEC, PLUS, 0, 0.0, yytext); debugtoken(yylval); return PLUS;}
{MINUS_SYM}         {yylval = inittok(TYPE_SPEC, MINUS, 0, 0.0, yytext); debugtoken(yylval); return MINUS;}
{MULT_SYM}          {yylval = inittok(TYPE_SPEC, MULT, 0, 0.0, yytext); debugtoken(yylval); return MULT;}
{DIVIDE_SYM}        {yylval = inittok(TYPE_SPEC, DIVIDE, 0, 0.0, yytext); debugtoken(yylval); return DIVIDE;}
{EQ_SYM}            {yylval = inittok(TYPE_SPEC, EQ, 0, 0.0, yytext); debugtoken(yylval); return EQ;}
{LT_SYM}            {yylval = inittok(TYPE_SPEC, LT, 0, 0.0, yytext); debugtoken(yylval); return LT;}
{GT_SYM}            {yylval = inittok(TYPE_SPEC, GT, 0, 0.0, yytext); debugtoken(yylval); return GT;}
{LBRACKET_SYM}      {yylval = inittok(TYPE_SPEC, LBRACKET, 0, 0.0, yytext); debugtoken(yylval); return LBRACKET;}
{RBRACKET_SYM}      {yylval = inittok(TYPE_SPEC, RBRACKET, 0, 0.0, yytext); debugtoken(yylval); return RBRACKET;}
{DOT_SYM}           {yylval = inittok(TYPE_SPEC, DOT, 0, 0.0, yytext); debugtoken(yylval); return DOT;}
{COMMA_SYM}         {yylval = inittok(TYPE_SPEC, COMMA, 0, 0.0, yytext); debugtoken(yylval); return COMMA;}
{COLON_SYM}         {yylval = inittok(TYPE_SPEC, COLON, 0, 0.0, yytext); debugtoken(yylval); return COLON;}
{SEMICOLON_SYM}     {yylval = inittok(TYPE_SPEC, SEMICOLON, 0, 0.0, yytext); debugtoken(yylval); return SEMICOLON;}
{POINT_SYM}         {yylval = inittok(TYPE_SPEC, POINT, 0, 0.0, yytext); debugtoken(yylval); return POINT;}
{LPAREN_SYM}        {yylval = inittok(TYPE_SPEC, LPAREN, 0, 0.0, yytext); debugtoken(yylval); return LPAREN;}
{RPAREN_SYM}        {yylval = inittok(TYPE_SPEC, RPAREN, 0, 0.0, yytext); debugtoken(yylval); return RPAREN;}
{DIAMOND_SYM}       {yylval = inittok(TYPE_SPEC, DIAMOND, 0, 0.0, yytext); debugtoken(yylval); return DIAMOND;}
{LTE_SYM}           {yylval = inittok(TYPE_SPEC, LTE, 0, 0.0, yytext); debugtoken(yylval); return LTE;}
{GTE_SYM}           {yylval = inittok(TYPE_SPEC, GTE, 0, 0.0, yytext); debugtoken(yylval); return GTE;}
{ASSIGN_SYM}        {yylval = inittok(TYPE_SPEC, ASSIGN, 0, 0.0, yytext); debugtoken(yylval); return ASSIGN;}
{DOTDOT_SYM}        {yylval = inittok(TYPE_SPEC, DOTDOT, 0, 0.0, yytext); debugtoken(yylval); return DOTDOT;}
{AND_SYM}           {yylval = inittok(TYPE_SPEC, AND, 0, 0.0, yytext); debugtoken(yylval); return AND;}
{ARRAY_SYM}         {yylval = inittok(TYPE_SPEC, ARRAY, 0, 0.0, yytext); debugtoken(yylval); return ARRAY;}
{BEGIN_SYM}         {yylval = inittok(TYPE_SPEC, PASBEGIN, 0, 0.0, yytext); debugtoken(yylval); return PASBEGIN;}
{CASE_SYM}          {yylval = inittok(TYPE_SPEC, CASE, 0, 0.0, yytext); debugtoken(yylval); return CASE;}
{CONST_SYM}         {yylval = inittok(TYPE_SPEC, CONST, 0, 0.0, yytext); debugtoken(yylval); return CONST;}
{DIV_SYM}           {yylval = inittok(TYPE_SPEC, DIV, 0, 0.0, yytext); debugtoken(yylval); return DIV;}
{DO_SYM}            {yylval = inittok(TYPE_SPEC, DO, 0, 0.0, yytext); debugtoken(yylval); return DO;}
{DOWNTO_SYM}        {yylval = inittok(TYPE_SPEC, DOWNTO, 0, 0.0, yytext); debugtoken(yylval); return DOWNTO;}
{ELSE_SYM}          {yylval = inittok(TYPE_SPEC, ELSE, 0, 0.0, yytext); debugtoken(yylval); return ELSE;}
{END_SYM}           {yylval = inittok(TYPE_SPEC, END, 0, 0.0, yytext); debugtoken(yylval); return END;}
{FILE_SYM}          {yylval = inittok(TYPE_SPEC, PASFILE, 0, 0.0, yytext); debugtoken(yylval); return PASFILE;}
{FOR_SYM}           {yylval = inittok(TYPE_SPEC, FOR, 0, 0.0, yytext); debugtoken(yylval); return FOR;}
{FUNC_SYM}          {yylval = inittok(TYPE_SPEC, FUNC, 0, 0.0, yytext); debugtoken(yylval); return FUNC;}
{GOTO_SYM}          {yylval = inittok(TYPE_SPEC, GOTO, 0, 0.0, yytext); debugtoken(yylval); return GOTO;}
{IF_SYM}            {yylval = inittok(TYPE_SPEC, IF, 0, 0.0, yytext); debugtoken(yylval); return IF;}
{IN_SYM}            {yylval = inittok(TYPE_SPEC, IN, 0, 0.0, yytext); debugtoken(yylval); return IN;}
{LABEL_SYM}         {yylval = inittok(TYPE_SPEC, LABEL, 0, 0.0, yytext); debugtoken(yylval); return LABEL;}
{MOD_SYM}           {yylval = inittok(TYPE_SPEC, MOD, 0, 0.0, yytext); debugtoken(yylval); return MOD;}
{NIL_SYM}           {yylval = inittok(TYPE_SPEC, NIL, 0, 0.0, yytext); debugtoken(yylval); return NIL;}
{NOT_SYM}           {yylval = inittok(TYPE_SPEC, NOT, 0, 0.0, yytext); debugtoken(yylval); return NOT;}
{OF_SYM}            {yylval = inittok(TYPE_SPEC, OF, 0, 0.0, yytext); debugtoken(yylval); return OF;}
{OR_SYM}            {yylval = inittok(TYPE_SPEC, OR, 0, 0.0, yytext); debugtoken(yylval); return OR;}
{PACKED_SYM}        {yylval = inittok(TYPE_SPEC, PACKED, 0, 0.0, yytext); debugtoken(yylval); return PACKED;}
{PROC_SYM}          {yylval = inittok(TYPE_SPEC, PROC, 0, 0.0, yytext); debugtoken(yylval); return PROC;}
{PROG_SYM}          {yylval = inittok(TYPE_SPEC, PROG, 0, 0.0, yytext); debugtoken(yylval); return PROG;}
{RECORD_SYM}        {yylval = inittok(TYPE_SPEC, RECORD, 0, 0.0, yytext); debugtoken(yylval); return RECORD;}
{REPEAT_SYM}        {yylval = inittok(TYPE_SPEC, REPEAT, 0, 0.0, yytext); debugtoken(yylval); return REPEAT;}
{SET_SYM}           {yylval = inittok(TYPE_SPEC, SET, 0, 0.0, yytext); debugtoken(yylval); return SET;}
{THEN_SYM}          {yylval = inittok(TYPE_SPEC, THEN, 0, 0.0, yytext); debugtoken(yylval); return THEN;}
{TO_SYM}            {yylval = inittok(TYPE_SPEC, TO, 0, 0.0, yytext); debugtoken(yylval); return TO;}
{TYPE_SYM}          {yylval = inittok(TYPE_SPEC, TYPE, 0, 0.0, yytext); debugtoken(yylval); return TYPE;}
{UNTIL_SYM}         {yylval = inittok(TYPE_SPEC, UNTIL, 0, 0.0, yytext); debugtoken(yylval); return UNTIL;}
{VAR_SYM}           {yylval = inittok(TYPE_SPEC, VAR, 0, 0.0, yytext); debugtoken(yylval); return VAR;}
{WHILE_SYM}         {yylval = inittok(TYPE_SPEC, WHILE, 0, 0.0, yytext); debugtoken(yylval); return WHILE;}
{WITH_SYM}          {yylval = inittok(TYPE_SPEC, WITH, 0, 0.0, yytext); debugtoken(yylval); return WITH;}
{ID}                {yylval = inittok(TYPE_ID, ID, 0, 0.0, yytext); debugtoken(yylval); return ID;}
{CHAR_STR}          {yylval = inittok(TYPE_STR, STR, 0, 0.0, yytext); debugtoken(yylval); return STR;}
{UNSIGNED_REAL}     {yylval = inittok(TYPE_NUM, UNSIGNED_REAL, 0, atof(yytext), yytext); debugtoken(yylval); return UNSIGNED_REAL;}
{UNSIGNED_INT}      {yylval = inittok(TYPE_NUM, UNSIGNED_INT, atoi(yytext), 0.0, yytext); debugtoken(yylval); return UNSIGNED_INT;}
{SIGNED_REAL}       {yylval = inittok(TYPE_NUM, SIGNED_REAL, 0, atof(yytext), yytext); debugtoken(yylval); return SIGNED_REAL;}
{SIGNED_INT}        {yylval = inittok(TYPE_NUM, SIGNED_INT, atoi(yytext), 0.0, yytext); debugtoken(yylval); return SIGNED_INT;}
[\x00-\xFF]         {printf("Syntax error: invalid character %d %c\n", yytext[0], yytext[0]); return 1;}
%%

int yywrap() {
  return 1;
}
