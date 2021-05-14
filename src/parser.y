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
#include <string.h>
#include "token.h"
#include "lexer.h"

//#define YYSTYPE token

static symtab top_symtab;
static token parsetree;

token parse_constant(token sign, token constant);
void parse_constantdefinition(token id, token constant);
token const_lookup(token id);
token parse_programheading(token prog, token id, token paramlist);
void parse_label(token label);

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

/*
block:
  labeldeclarationpart constantdefinitionpart typedefinitionpart
  variabledeclarationpart procedureandfunctiondeclarationpart
  statementpart {printf("block");}
;
*/
//Temp block definition to allow for segmenting of development
block:
  {$$ = NULL; top_symtab = symtab_push(top_symtab);}
  labeldeclarationpart constantdefinitionpart typedefinitionpart
  statementpart {
    top_symtab = symtab_pop(top_symtab);
    $$ = $1;
  }
;
labeldeclarationpart:
  LABEL addlabel SEMICOLON {
    free($1);
    free($3);
    $$ = NULL;
  }
;

addlabel:
  label {
    parse_label($1);
    $$ = NULL;
  }
| addlabel COMMA label {
    parse_label($3); 
    free($2);
    $$ = NULL;
  }
;

constantdefinitionpart:
  CONST constantdefinition {
    free($1);
    $$ = NULL;
  }
;

constantdefinition:
  ID EQ constant SEMICOLON {
    parse_constantdefinition($1, $3);
    free($2);
    free($4);
    $$ = NULL;
  }
| constantdefinition ID EQ constant SEMICOLON {
    parse_constantdefinition($2, $4);
    free($3);
    free($5);
    $$ = NULL;
  }
;

sign:
  PLUS
| MINUS
;

constant:
  sign number {$$ = parse_constant($1, $2);}
| sign constantid {$$ = parse_constant($1, $2);}
| number
| constantid
| STR
;

constantid:
  ID {$$ = const_lookup($1);}
;

typedefinitionpart:
  TYPE typedefinition {
    free($1);
    $$ = NULL;
  }
;

typedefinition:
  ID EQ typedenoter SEMICOLON {
    parse_typedefinition($1, $3);
    free($2);
    free($4);
    $$ = NULL;
  }
| typedefinition ID EQ typedenoter SEMICOLON {
    parse_typedefinition($2, $4);
    free($3);
    free($5);
    $$ = NULL;
  }
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
  ID {$$ = type_lookup($1);}
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
  LPAREN idlist RPAREN{
    free($1);
    free($3);
    $$ = $2;
  }
;

idlist:
  ID
| idlist COMMA ID {
    $1->next = $3;
    free($2);
    $$ = $1;
  }
;

subrangetype:
  constant DOTDOT constant {$$ = parse_subrangetype($2, $1, $3);}
;

structuredtype:
  newstructuredtype
| structuredtypeid
;

newstructuredtype:
  PACKED unpackedstructuredtype {$$ = parse_newstructuredtype($1, true);}
| unpackedstructuredtype {$$ = parse_newstructuredtype($1, false);}
;

unpackedstructuredtype:
  arraytype
| recordtype
| settype
| filetype
;

arraytype:
  ARRAY LBRACKET indextype RBRACKET OF componenttype {
    free($1);
    free($2);
    free($4);
    free($5);
    $$ = parse_arraytype($3, $6);
  }
;

indextype:
  ordinaltype
| indextype COMMA ordinaltype {
    free($2);
    token index = $1;
    token end = NULL;
    while(index){
      end = index;
      index = index->next;
    }
    end->next = $3;
    $$ = $1; 
  }
;

componenttype:
  typedenoter
;

recordtype:
  RECORD fieldlist END {
    free($1);
    free($1);
    $$ = $2;
  }
;

fieldlist:
  fixedpart SEMICOLON variantpart SEMICOLON {
    free($2);
    free($4);
    $$ = parse_fieldlist($1, $3);
  }
| fixedpart SEMICOLON variantpart {
    free($2);
    $$ = parse_fieldlist($1, $3);
  }
| fixedpart SEMICOLON {
    free($2);
    $$ = parse_fieldlist($1, NULL);
  }
| fixedpart {
    $$ = parse_fieldlist($1, NULL);
  }
| variantpart SEMICOLON {
    free($2);
    $$ = parse_fieldlist(NULL, $1);
  }
| variantpart {
    $$ = parse_fieldlist(NULL, $1);
  }
| %empty {$$ = NULL;}
;

fixedpart:
  recordsection
| recordsection SEMICOLON recordsection {
    free($2);
    token index = $1;
    token end = NULL;
    while(index){
      end = index;
      index = index->next;
    }
    end->next = $3;
    $$ = $1; 
  }
;

recordsection:
  idlist COLON typedenoter {
    free($2);
    $$ = parse_recordsection($1, $3);
  }
;

fieldid:
  ID
; 

variantpart:
  CASE variantselector OF variantext {
    free($1);
    free($3);
    $2->leaf = $4;
    $$ = $2;
  }
;

variantext:
  variant
| variantext SEMICOLON variant {
    free($2);
    token index = $1;
    token end = NULL;
    while(index){
      end = index;
      index = index->next;
    }
    end->next = $3;
    $$ = $1; 
  }
;

variantselector:
  tagfield COLON tagtype {
    free($2);
    $1->type_sym = $3->symentry;
    free($3);
    $$ = $1;
  }
;

tagfield:
  ID
;

variant:
  caseconstantlist COLON LPAREN fieldlist RPAREN {
    free($2);
    free($3);
    free($5);
    $1->leaf = $4;
    $$ = $1;
  }
;

tagtype:
  ordinaltypeid {$$ = type_lookup($1);}
;

caseconstantlist:
  caseconstant
| caseconstantlist COMMA caseconstant {
    free($2);
    token index = $1;
    token end = NULL;
    while(index){
      end = index;
      index = index->next;
    }
    end->next = $3;
    $$ = $1; 
  }
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

/*
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
| indexexpression COMMA expression
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
| addingoperatortermext term addingoperator
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
| multiplyingoperatortermext term multiplyingoperator
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
| memberdesignatorext COMMA memberdesignator
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
| actualparameterext COMMA actualparameter
;

actualparameter:
  expression
| variableaccess
| procedureid
| functionid
;
*/
statementpart:
  compoundstatement
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
| statementsequence SEMICOLON statement
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
;

caselistelementext:
  caselistelement
| caselistelementext SEMICOLON caselistelement
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
| variableaccessext COMMA variableaccess
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
| variableaccessext2 COMMA variableaccess
;

writeparameterlist:
  LPAREN writeparameterext RPAREN
| LPAREN filevariable COMMA writeparameterext RPAREN
;

writeparameterext:
  writeparameter
| writeparameterext COMMA writeparameter
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
| writeparameterext2 COMMA writeparameter
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
  idlist
;

programblock:
  block
;
%%

token parse_constant(token sign, token constant){
  if(!sign){
    return constant;
  }
  if(constant->type_sym != symtab_get(top_symtab, "integer") ||
      constant->type_sym != symtab_get(top_symtab, "real")){
    printf("Sign can't be applied to non integer or real constant\n");
    exit(1);
  }
  if(!strcmp(sign->strval, "-")){
    constant->intval *= -1;
    constant->realval *= -1;
    constant->entry = NULL;
  }
  free(sign);
  return constant;
}

void parse_constantdefinition(token id, token constant){
  printf("Adding constant %s to symtab\n", id->strval);
  symentry constentry = symentry_alloc();
  constentry->name = id->strval;
  constentry->etype = CONST_TYPE;
  constentry->intval = constant->intval;
  constentry->realval = constant->realval;
  constentry->strval = constant->strval;
  constentry->type = constant->type_sym;
  symtab_add(top_symtab, constentry);
  free(id);
  free(constant);
}

token const_lookup(token id){
  printf("id is %s\n", id->strval);
  symentry constentry = symtab_get(top_symtab, id->strval);
  if(!constentry){
    printf("No id %s declared\n", id->strval);
    exit(1);
  }
  if(constentry->etype != CONST_TYPE){
    printf("%s is not a constant\n", id->strval);
    exit(1);
  }
  id->intval = constentry->intval;
  id->realval = constentry->realval;
  id->strval = constentry->strval;
  id->entry = constentry;
  id->type_sym = constentry->type;
  return id;
}

void parse_label(token label){
  if(label->intval < 0 || label->intval > 9999){
    printf("Invalid label number: %d\n", label->intval);
    exit(1);
  }
  char *label_name =  malloc(5 * sizeof(char));//Max possible string is 9999\0
  snprintf(label_name, 5 * sizeof(char), "%d", label->intval);
  //TODO: This prob doesn't follow scope rules
  if(symtab_get(top_symtab, label_name)){
    printf("Repeated label number: %s\n", label_name);
    exit(1);
  }
  free(label);
  symentry label_entry = symentry_alloc();
  label_entry->etype = LABEL_TYPE;
  label_entry->name = label_name;
  symtab_add(top_symtab, label_entry);
}

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
  symentry intentry = symentry_alloc();
  symentry realentry = symentry_alloc();
  symentry boolentry = symentry_alloc();
  symentry charentry = symentry_alloc();
  intentry->name = "integer";
  realentry->name = "real";
  boolentry->name = "Boolean";
  charentry->name = "char";
  symtab_add(top_symtab, intentry);
  symtab_add(top_symtab, realentry);
  symtab_add(top_symtab, boolentry);
  symtab_add(top_symtab, charentry);
}

void init_parsetree(void){
  parsetree = NULL;
}
