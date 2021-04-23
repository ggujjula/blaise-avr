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
{COMMENT}           printf("Comment: %s\n", yytext);
{SPECIAL_SYMBOL}    printf("Special symbol: %s\n", yytext);
{ID}                printf("ID: %s\n", yytext);
{SIGNED_NUM}        printf("Signed num: %s\n", yytext);
{CHAR_STR}          printf("String: %s\n", yytext);
%%

int yywrap() {
  return 1;
}

int main(){
  yylex();
}
