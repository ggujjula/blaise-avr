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
#ifndef BLAISE_AVR_TOKEN_H
#define BLAISE_AVR_TOKEN_H

#include "symtab.h"

typedef char toktype;

struct tokenstruct {
  toktype type;
  int specval;
  int intval;
  double realval;
  char* strval;
  symentry entry;
  symentry type_sym;
  struct tokenstruct* leaf;
  struct tokenstruct* next;
};
typedef struct tokenstruct* token;


#define TYPE_CLEAR  0
#define TYPE_SPEC   1
#define TYPE_ID     2
#define TYPE_DIR    3
#define TYPE_NUM    4
#define TYPE_LABEL  5
#define TYPE_STR    6

#define NUM_SPEC    57

token talloc();
token cleartok(token t);
token inittok(toktype type, int specval, int intval, double realval, char* strval);
void debugtoken(token tok);
void debugtokentree(token tok);
void tokentest(token tok);
void token_append(token tok1, token tok2);

#endif
