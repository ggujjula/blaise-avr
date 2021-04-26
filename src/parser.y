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
#include <stdio.h>
#include "token.h"
#include "lexer.h"

//#define YYSTYPE token

int yyerror(const char * err);
%}

%define api.value.type {token}

%token PLUS MINUS MULT DIVIDE EQ LT GT LBRACKET RBRACKET DOT COMMA COLON 
%token SEMICOLON POINT LPAREN RPAREN DIAMOND LTE GTE ASSIGN DOTDOT AND ARRAY 
%token PASBEGIN CASE CONST DIV DO DOWNTO ELSE END PASFILE FOR FUNC GOTO IF    
%token IN LABEL MOD NIL NOT OF OR PACKED PROC PROG RECORD REPEAT SET THEN TO
%token TYPE UNTIL VAR WHILE WITH

%token ID PASDIR NUM LABELNUM STR

%%
  block: labeldeclarationpart constantdefinitionpart typedefinitionpart
          variabledeclarationpart procedureandfunctiondeclarationpart
          statementpart
        ;
  labeldeclarationpart: LABEL NUM SEMICOLON
                      | LABEL NUM addlabel SEMICOLON
                      ;
  addlabel: COMMA LABEL
          ;
  constantdefinitionpart: CONST constantdefinition
                        ;
  constantdefinition: ID EQ constant SEMICOLON
                    | ID EQ constant SEMICOLON constantdefinition
                    ;
  sign: PLUS
      | MINUS
      ;
  constant: sign NUM
          | sign constantid
          | NUM
          | constantid
          | STR
          ;
  constantid: ID
            ;
  typedefinitionpart: TYPE typedefinition
  typedefinition: ID EQ typedenoter SEMICOLON
                | ID EQ typedenoter SEMICOLON typedefinition
                ;
  typedenoter: typeid
             | newtype
             ;
  newtype: newordinaltype
        | newstructuredtype
        | newpointertype
        ;
  simpletypeid: typeid
              ;
  structuredtypeid: typeid
                  ;
  pointertypeid: typeid
                ;
  typeid: ID
  simpletype: ordinaltype
            | realtypeid
            ;
  ordinaltype: newordinaltype
             | ordinaltypeid
             ;
  newordinaltype: enumeratedtype
                | subrangetype
                ;
  ordinaltypeid: typeid
               ;
  realtypeid: typeid
            ;
  enumeratedtype: LPAREN idlist RPAREN
                ;
  idlist: ID
        | idlist COMMA ID
        ;
  structuredtype: newstructuredtype
                | structuredtypeid
                ;
  newstructuredtype: PACKED unpackedstructuredtype
                   | unpackedstructuredtype
                   ;
  unpackedstructuredtype: arraytype
                        | recordtype
                        | settype
                        | filetype
                        ;
  arraytype: ARRAY LBRACKET indextype RBRACKET OF componenttype
  indextype: ordinaltype
           | ordinaltype COMMA indextype
           ;
  componenttype: typedenoter
               ;
  recordtype: RECORD fieldlist END
            ;
  fieldlist: fixedpart SEMICOLON variantpart SEMICOLON
           | fixedpart SEMICOLON variantpart
           | fixedpart SEMICOLON
           | fixedpart
           | variantpart SEMICOLON
           | variantpart
           |
           ;
  fixedpart: recordsection
           | recordsection SEMICOLON recordsection
  recordsection: idlist COLON typedenoter
               ;
  fieldid: ID
         ; 
  variantpart: CASE variantselector OF variant
             | CASE variantselector OF variant variantpartaddition
             ;
  variantpartaddition: SEMICOLON variant
                     | SEMICOLON variant variantpartaddition
                     ;
  variantselector: tagfield COLON tagtype
                 ;
  tagfield: ID
          ;
  variant: caseconstantlist COLON LPAREN fieldlist RPAREN
         ;
  tagtype: ordinaltypeid
         ;
  caseconstantlist: caseconstant
                  | caseconstant COMMA caseconstantlist
                  ;
  caseconstant: constant
              ;
  settype: SET OF basetype
         ;
  basetype: ordinaltype
          ;
  filetype: FILE OF componenttype
          ;
  pointertype: newpointertype
             | pointertypeid
             ;
  newpointertype: POINT domaintype
                ;
  domaintype: typeid
            ;
  variabledeclarationpart:
  procedureandfunctiondeclarationpart:
  statementpart:
%%

int yyerror(const char * err){
  return -1;
}

int main(){
  yyparse();
  return 0;
}
