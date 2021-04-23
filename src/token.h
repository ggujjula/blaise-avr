/*
  token.h - Definitions of token struct and constants

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

typedef char toktype;

struct tokenstruct {
  toktype type;
  char specval;
  int intval;
  double realval;
  char * strval;
  struct tokenstruct * leaf;
  struct tokenstruct * next;
};

typedef struct tokenstruct * token;

#define TYPE_SPEC   0
#define TYPE_ID     1
#define TYPE_DIR    2
#define TYPE_NUM    3
#define TYPE_LABEL  4
#define TYPE_STR    5

#define NUM_SPEC    57
#define PLUS        0
#define MINUS       1
#define MULT        2
#define DIVIDE      3
#define EQ          4
#define LT          5
#define GT          6
#define LBRACKET    7
#define RBRACKET    8
#define DOT         9
#define COMMA       10
#define COLON       11
#define SEMICOLON   12
#define POINT       13
#define LPAREN      14
#define RPAREN      15
#define DIAMOND     16
#define LTE         17
#define GTE         18
#define ASSIGN      19
#define DOTDOT      20
#define AND         21
#define ARRAY       22
#define PASBEGIN    23
#define CASE        24
#define CONST       25
#define DIV         26
#define DO          27
#define DOWNTO      28
#define ELSE        29
#define END         30
//Avoid conflict with stdio FILE
#define PASFILE     31
#define FOR         32
#define FUNCTION    33
#define GOTO        34
#define IF          36
#define IN          37
#define LABEL       38
#define MOD         39
#define NIL         40
#define NOT         41
#define OF          42
#define OR          43
#define PACKED      44
#define PROCEDURE   45
#define PROGRAM     46
#define RECORD      47
#define REPEAT      48
#define SET         49
#define THEN        50
#define TO          51
#define TYPE        52
#define UNTIL       53
#define VAR         54
#define WHILE       55
#define WITH        56

token talloc(){
  token t = malloc(sizeof(struct tokenstruct));
  t->type = TYPE_SPEC;
  t->specval = PLUS;
  t->intval = 0;
  t->realval = 0.0;
  t->strval = NULL;
  t->next = NULL;
  t->leaf = NULL;
  return t;
}

token inittok(toktype type, char specval, int intval, double realval, char * strval){
  token t = malloc(sizeof(struct tokenstruct));
  t->type = type;
  t->specval = specval;
  t->intval = intval;
  t->realval = realval;
  t->strval = strval;
  t->next = NULL;
  t->leaf = NULL;
  return t;
}

