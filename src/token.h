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
#include "symtab.h"

typedef char toktype;

struct tokenstruct {
  toktype type;
  //YYTOKENTYPE specval;
  int intval;
  double realval;
  char* strval;
  symentry entry;
  symtype type_sym;
  struct tokenstruct* leaf;
  struct tokenstruct* next;
};

typedef struct tokenstruct* token;

#include "parser.h"

#define TYPE_SPEC   0
#define TYPE_ID     1
#define TYPE_DIR    2
#define TYPE_NUM    3
#define TYPE_LABEL  4
#define TYPE_STR    5

#define NUM_SPEC    57
/*
#define PLUS        1
#define MINUS       2
#define MULT        3
#define DIVIDE      4
#define EQ          5
#define LT          6
#define GT          7
#define LBRACKET    8
#define RBRACKET    9
#define DOT         10
#define COMMA       11
#define COLON       12
#define SEMICOLON   13
#define POINT       14
#define LPAREN      15
#define RPAREN      16
#define DIAMOND     17
#define LTE         18
#define GTE         19
#define ASSIGN      20
#define DOTDOT      21
#define AND         22
#define ARRAY       23
#define PASBEGIN    24
#define CASE        25
#define CONST       26
#define DIV         27
#define DO          28
#define DOWNTO      29
#define ELSE        30
#define END         31
//Avoid conflict with stdio FILE
#define PASFILE     32
#define FOR         33
#define FUNC        34
#define GOTO        36
#define IF          37
#define IN          38
#define LABEL       39
#define MOD         40
#define NIL         41
#define NOT         42
#define OF          43
#define OR          44
#define PACKED      45
#define PROC        46
#define PROG        47
#define RECORD      48
#define REPEAT      49
#define SET         50
#define THEN        51
#define TO          52
#define TYPE        53
#define UNTIL       54
#define VAR         55
#define WHILE       56
#define WITH        57  
                    
#define ID          58
#define PASDIR      59
#define NUM         60
#define LABELNUM    61
#define STR         62 
*/

token talloc();
token inittok(toktype type, enum yytokentype specval, int intval, double realval, char* strval);
