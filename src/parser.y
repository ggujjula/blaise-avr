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
#include <stdlib.h>
#include "token.h"
#include "lexer.h"

//#define YYSTYPE token

static symtab top_symtab;
static token parsetree;

token parse_programheading(token prog, token id, token paramlist);

int yyerror(const char * err);
void init_symtab(void);
void init_parsetree(void);
%}

//%code requires {#include "token.h"}
%define api.value.type {token}
%define parse.trace

%token PLUS MINUS MULT DIVIDE EQ LT GT LBRACKET RBRACKET DOT COMMA COLON 
%token SEMICOLON POINT LPAREN RPAREN DIAMOND LTE GTE ASSIGN DOTDOT AND ARRAY 
%token PASBEGIN CASE CONST DIV DO DOWNTO ELSE END PASFILE FOR FUNC GOTO IF    
%token IN LABEL MOD NIL NOT OF OR PACKED PROC PROG RECORD REPEAT SET THEN TO
%token TYPE UNTIL VAR WHILE WITH

%token ID PASDIR SIGNED_REAL UNSIGNED_REAL SIGNED_INT UNSIGNED_INT LABELNUM STR

%start program

%%
/*
number: 
  signednumber
| unsignednumber
;

signednumber:
  SIGNED_REAL
| SIGNED_INT
;

unsignednumber:
  UNSIGNED_REAL
| UNSIGNED_INT
;

realnumber:
  SIGNED_REAL
| UNSIGNED_REAL
;

integralnumber:
  SIGNED_INT
| UNSIGNED_INT
;

label:
  UNSIGNED_INT
;

block:
  labeldeclarationpart constantdefinitionpart typedefinitionpart
  variabledeclarationpart procedureandfunctiondeclarationpart
  statementpart {printf("block");}
;
*/
//Temp block definition to allow for segmenting of development
block:
  {$$ = NULL; top_symtab = symtab_push(top_symtab);}
  statementpart {
    top_symtab = symtab_pop(top_symtab);
    $$ = $1;
  }
;
/*
labeldeclarationpart:
  LABEL label SEMICOLON
| LABEL label addlabel SEMICOLON
;

addlabel:
  COMMA label
| COMMA label addlabel
;

constantdefinitionpart:
  CONST constantdefinition
;

constantdefinition:
  ID EQ constant SEMICOLON
| ID EQ constant SEMICOLON constantdefinition
;

sign:
  PLUS
| MINUS
;

constant:
  sign number
| sign constantid
| number
| constantid
| STR
;

constantid:
  ID
;

typedefinitionpart:
  TYPE typedefinition
typedefinition:
  ID EQ typedenoter SEMICOLON
| ID EQ typedenoter SEMICOLON typedefinition
;

typedenoter:
  typeid
| newtype
;

newtype:
  newordinaltype
| newstructuredtype
| newpointertype
;

simpletypeid:
  typeid
;

structuredtypeid:
  typeid
;

pointertypeid:
  typeid
;

typeid:
  ID
;

simpletype:
  ordinaltype
| realtypeid
;

ordinaltype:
  newordinaltype
| ordinaltypeid
;

newordinaltype:
  enumeratedtype
| subrangetype
;

ordinaltypeid:
  typeid
;

realtypeid:
  typeid
;

enumeratedtype:
  LPAREN idlist RPAREN
;
*/
idlist:
  ID {$$ = $1;}
| idlist COMMA ID {
    $1->next = $3;
    free($2);
    $$ = $1;
  }
;
/*
subrangetype:
  constant DOTDOT constant
;

structuredtype:
  newstructuredtype
| structuredtypeid
;

newstructuredtype:
  PACKED unpackedstructuredtype
| unpackedstructuredtype
;

unpackedstructuredtype:
  arraytype
| recordtype
| settype
| filetype
;

arraytype:
  ARRAY LBRACKET indextype RBRACKET OF componenttype
indextype:
  ordinaltype
| ordinaltype COMMA indextype
;

componenttype:
  typedenoter
;

recordtype:
  RECORD fieldlist END
;

fieldlist:
  fixedpart SEMICOLON variantpart SEMICOLON
| fixedpart SEMICOLON variantpart
| fixedpart SEMICOLON
| fixedpart
| variantpart SEMICOLON
| variantpart
| %empty
;

fixedpart:
  recordsection
| recordsection SEMICOLON recordsection
recordsection:
  idlist COLON typedenoter
;

fieldid:
  ID
; 
variantpart:
  CASE variantselector OF variant
| CASE variantselector OF variant variantpartaddition
;

variantpartaddition:
  SEMICOLON variant
| SEMICOLON variant variantpartaddition
;

variantselector:
  tagfield COLON tagtype
;

tagfield:
  ID
;

variant:
  caseconstantlist COLON LPAREN fieldlist RPAREN
;

tagtype:
  ordinaltypeid
;

caseconstantlist:
  caseconstant
| caseconstant COMMA caseconstantlist
;

caseconstant:
  constant
;

settype:
  SET OF basetype
;

basetype:
  ordinaltype
;

filetype:
  PASFILE OF componenttype
;

pointertype:
  newpointertype
| pointertypeid
;

newpointertype:
  POINT domaintype
;

domaintype:
  typeid
;

variabledeclarationpart:
  VAR variabledeclaration SEMICOLON
| %empty
;

variabledeclaration:
  idlist COLON typedenoter
;

variableaccess:
  entirevariable
| componentvariable
| identifiedvariable
| buffervariable
; 
entirevariable:
  variableid
;

variableid:
  ID
;

componentvariable:
  indexedvariable
| fielddesignator
;

indexedvariable:
  arrayvariable LBRACKET indexexpression RBRACKET
;

indexexpression:
  expression
| expression COMMA indexexpression
;

arrayvariable:
  variableaccess
;

fielddesignator:
  recordvariable DOT fieldspecifier
| fielddesignatorid
;

recordvariable:
  variableaccess
;

fieldspecifier:
  fieldid
;

identifiedvariable:
  pointervariable POINT
;

pointervariable:
  variableaccess
;

buffervariable:
  filevariable POINT
;

filevariable:
  variableaccess
;

procedureandfunctiondeclarationpart:
  proceduredeclaration SEMICOLON
| functiondeclaration SEMICOLON
;

proceduredeclaration:
  procedureheading SEMICOLON directive
| procedureidentification SEMICOLON procedureblock
| procedureheading SEMICOLON procedureblock
;

directive:
  ID
;

procedureheading:
  PROC ID formalparameterlist
| PROC ID
;

procedureidentification:
  PROC ID
;

procedureid:
  ID
;

procedureblock:
  block
;

functiondeclaration:
  functionheading SEMICOLON directive
| functionidentification SEMICOLON functionblock
| functionheading SEMICOLON functionblock
functionheading:
  FUNC ID formalparameterlist COLON resulttype
| FUNC ID COLON resulttype
;

functionidentification:
  FUNC functionid
;

functionid:
  ID
;

resulttype:
  simpletypeid
| pointertypeid
;

functionblock:
  block
;

formalparameterlist:
  LPAREN formalparametersectionext RPAREN
;

formalparametersectionext:
  formalparametersection
| formalparametersectionext SEMICOLON formalparametersection
;

formalparametersection:
  valueparametersection
| variableparametersection
| proceduralparametersection
| functionalparametersection
;

valueparametersection:
  idlist COLON typeid
;

variableparametersection:
  VAR idlist COLON typeid
;

proceduralparametersection:
  procedureheading
;

functionalparametersection:
  functionheading
;

//skip conformant array section 6.6.3.7
expression:
  simpleexpression
| simpleexpression relationaloperator simpleexpression
;

relationaloperator:
  EQ | DIAMOND | LT | GT | LTE | GTE | IN
;

simpleexpression:
  sign term
| sign term addingoperatortermext
;

addingoperatortermext:
  addingoperator term
| addingoperator term addingoperatortermext
;

addingoperator:
  PLUS | MINUS | OR
;

term:
  factor
| factor multiplyingoperatortermext
;

multiplyingoperatortermext:
  multiplyingoperator term
| multiplyingoperator term multiplyingoperatortermext
;

multiplyingoperator:
  MULT | DIVIDE | DIV | MOD | AND
;

factor:
  variableaccess
| unsignedconstant
| functiondesignator
| setconstructor
| LPAREN expression RPAREN
| NOT factor
; 
unsignedconstant:
  unsignednumber
| STR
| constantid
| NIL
;

setconstructor:
  LBRACKET RBRACKET
| LBRACKET memberdesignatorext RBRACKET
;

memberdesignatorext:
  memberdesignator
| memberdesignator COMMA memberdesignatorext
;

memberdesignator:
  expression
| expression DOTDOT expression
;

booleanexpression:
  expression
;

functiondesignator:
  functionid
| functionid actualparameterlist
;

actualparameterlist:
  LPAREN actualparameterext RPAREN
;

actualparameterext:
  actualparameter
| actualparameter COMMA actualparameterext
;

actualparameter:
  expression
| variableaccess
| procedureid
| functionid
;
*/
statementpart:
  compoundstatement {$$ = $1;}
;
/*
statement:
  label COLON simplestatement
| label COLON structuredstatement
| simplestatement
| structuredstatement
;

simplestatement:
  emptystatement
| assignmentstatement
| procedurestatement
| gotostatement
;

emptystatement:
  %empty
;

assignmentstatement:
  variableaccess ASSIGN expression
| functionid ASSIGN expression
;

procedurestatement:
  procedureid actualparameterlist
| procedureid readparameterlist
| procedureid readlnparameterlist
| procedureid writeparameterlist
| procedureid writelnparameterlist
;

gotostatement:
  GOTO label
;

structuredstatement:
  compoundstatement
| conditionalstatement
| repetitivestatement
| withstatement
;

statementsequence:
  statement
| statement SEMICOLON statementsequence
;
*/
  //PASBEGIN statementsequence END
compoundstatement:
  PASBEGIN END {
    $$ = NULL;
    free($1);
    free($2);
  }
;
/*
conditionalstatement:
  ifstatement
| casestatement
;

ifstatement:
  IF booleanexpression THEN statement
| IF booleanexpression THEN statement elsepart
;

elsepart:
  ELSE statement
;

casestatement:
  CASE caseindex OF caselistelementext END 
| CASE caseindex OF caselistelementext SEMICOLON END 
caselistelementext:
  caselistelement
| caselistelement SEMICOLON caselistelementext
;

caselistelement:
  caseconstantlist COLON statement
;

caseindex:
  expression
;

repetitivestatement:
  repeatstatement
| whilestatement
| forstatement
;

repeatstatement:
  REPEAT statementsequence UNTIL booleanexpression
;


whilestatement:
  WHILE booleanexpression DO statement
;

forstatement:
  FOR controlvariable ASSIGN initialvalue TO finalvalue DO statement
| FOR controlvariable ASSIGN initialvalue DOWNTO finalvalue DO statement
;

controlvariable:
  entirevariable
;

initialvalue:
  expression
;

finalvalue:
  expression
;

withstatement:
  WITH recordvariablelist DO statement
;

recordvariablelist:
  recordvariable
| recordvariable COMMA recordvariablelist
;

fielddesignatorid:
  ID
;

readparameterlist:
  LPAREN variableaccessext RPAREN
| LPAREN filevariable COMMA variableaccessext RPAREN
;

variableaccessext:
  variableaccess
| variableaccess COMMA variableaccessext
;

readlnparameterlist:
  LPAREN filevariable RPAREN
| LPAREN variableaccess RPAREN
| LPAREN filevariable variableaccessext2 RPAREN
| LPAREN variableaccess variableaccessext2 RPAREN
| %empty
;

variableaccessext2:
  COMMA variableaccess
| COMMA variableaccess variableaccessext2
;

writeparameterlist:
  LPAREN writeparameterext RPAREN
| LPAREN filevariable COMMA writeparameterext RPAREN
writeparameterext:
  writeparameter
| writeparameter COMMA writeparameterext
;

writeparameter:
  expression
| expression COLON expression
| expression COLON expression COLON expression
;

writelnparameterlist:
  LPAREN filevariable RPAREN 
| LPAREN writeparameter RPAREN 
| LPAREN filevariable writeparameterext2 RPAREN 
| LPAREN writeparameter writeparameterext2 RPAREN 
| %empty
; 
writeparameterext2:
  COMMA writeparameter
| COMMA writeparameter writeparameterext2
;
*/
program:
  programheading SEMICOLON programblock DOT {
    $1->leaf = $3;
    parsetree = $1;
    free($2);
    free($4);
  }
;

programheading:
  PROG ID {
    $$ = parse_programheading($1, $2, NULL);
  }
| PROG ID LPAREN programparameterlist RPAREN {
    $$ = parse_programheading($1, $2, $4);
    free($3);
    free($5);
  }
;

programparameterlist:
  idlist {$$ = $1;}
;

programblock:
  block {$$ = $1;}
;
%%

token parse_programheading(token prog, token id, token paramlist){
  prog->next = id;
  if(paramlist){
    id->next = paramlist;
  }
  return prog;
}

int yyerror(const char * err){
  printf("%s\n", err);
  return -1;
}

int main(void){
  yydebug = 1;
  init_symtab(); 
  init_parsetree();
  yyparse();
  return 0;
}

void init_symtab(void){
  top_symtab = symtab_alloc();
}

void init_parsetree(void){
  parsetree = NULL;
}
