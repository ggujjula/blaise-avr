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
#include "token.h"

token yylval = NULL;
%}

LETTER    [a-zA-Z]
DIGIT     [0-9]

WORD_SYMBOL (and)|(array)|(begin)|(case)|(const)|(div)|(do)|(downto)|(else)|(end)|(file)|(for)|(function)|(goto)|(if)|(in)|(label)|(mod)|(nil)|(not)|(of)|(or)|(packed)|(procedure)|(program)|(record)|(repeat)|(set)|(then)|(to)|(type)|(until)|(var)|(while)|(with)

SPECIAL_SYMBOL [+\-*/=<>[\].,:;^()]|(<>)|(<=)|(>=)|(:=)|(\.\.)|{WORD_SYMBOL}

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
{COMMENT}           
{SPECIAL_SYMBOL}    {yylval = inittok(TYPE_SPEC, PLUS, 0, 0.0, NULL); return 1;}
{ID}                {yylval = inittok(TYPE_ID, PLUS, 0, 0.0, yytext); return 1;}
{CHAR_STR}          {yylval = inittok(TYPE_STR, PLUS, 0, 0.0, yytext); return 1;}
{SIGNED_NUM}        {yylval = inittok(TYPE_NUM, PLUS, 0, 0.0, NULL); return 1;}
%%

int yywrap() {
  return 1;
}

int main(){
  while(yylex() != 0){
    printf("Token:\n");
    printf("type: %d\n", yylval->type);
    printf("specval: %d\n", yylval->specval);
    printf("intval: %d\n", yylval->intval);
    printf("realval: %f\n", yylval->realval);
    printf("strval: %s\n", yylval->strval);
    printf("next: %p\n", yylval->next);
    printf("leaf: %p\n", yylval->leaf);
  }
}
