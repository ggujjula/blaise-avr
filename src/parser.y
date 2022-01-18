/*
  parser.y - Parser for Unextended Pascal programs

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
%}
%require "3.7.6"

%code requires {
    #include "token.h"
}

%token-table
%defines
%define api.pure full
%define api.value.type {token}
%define api.header.include {"parser.h"}
%define parse.trace

%code {

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lexer.h"

#define MAXINT 2147483647 //2^31-1 (integer is 32-bits)
#define MAXCHAR 255 //2^8-1 (char is 8-bit unsigned)

static symtab top_symtab;
static token parsetree;

token lookup(token id);//, entrytype t);
token parse_programheading(token prog, token id, token paramlist);
void parse_label(token label);
token parse_constant(token sign, token constant);
void parse_constantdefinition(token id, token constant);
void parse_typedefinition(token id, token def);
token parse_enumeratedtype(token idlist);
token parse_subrangetype(token filltok, token lowbound, token highbound);
token parse_newstructuredtype(token typetok, token packed);
token parse_arraytype(token indicies, token typetok);
token parse_recordtype(token fieldlist);
token parse_fieldlist(token fixed, token variant);
token parse_recordsection(token idlist, token typedenoter);
token parse_settype(token basetype, token fill);
token parse_pointertype(token domaintype);

int yyerror(const char * err);
void init_symtab(void);
void init_parsetree(void);

}

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

/*
realnumber:
  SIGNED_REAL
| UNSIGNED_REAL
;

integralnumber:
  SIGNED_INT
| UNSIGNED_INT
;
*/

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
  {top_symtab = symtab_push(top_symtab);}
  labeldeclarationpart constantdefinitionpart typedefinitionpart
  statementpart {
    debugsymtabtree(top_symtab);
    top_symtab = symtab_pop(top_symtab);
    token tokholder = talloc();
    if($2)
      token_append(tokholder, $2);
    if($3)
      token_append(tokholder, $3);
    if($4)
      token_append(tokholder, $4);
    if($5)
      token_append(tokholder, $5);
    $$ = tokholder->next;
    tfree(tokholder);
  }
;
labeldeclarationpart:
  LABEL addlabel SEMICOLON {
    tfree($1);
    tfree($3);
    $$ = NULL;
  }
| %empty {$$ = NULL;}
;

addlabel:
  label {
    parse_label($1);
    tfree($1);
    $$ = NULL;
  }
| addlabel COMMA label {
    parse_label($3); 
    tfree($1);
    tfree($2);
    tfree($3);
    $$ = NULL;
  }
;

constantdefinitionpart:
  CONST constantdefinition {
    tfree($1);
    $$ = NULL;
  }
| {$$ = NULL;}
;

constantdefinition:
  ID EQ constant SEMICOLON {
    parse_constantdefinition($1, $3);
    tfree($1);
    tfree($2);
    tfree($3);
    tfree($4);
    $$ = NULL;
  }
| constantdefinition ID EQ constant SEMICOLON {
    parse_constantdefinition($2, $4);
    tfree($2);
    tfree($3);
    tfree($4);
    tfree($5);
    $$ = NULL;
  }
;

sign:
  PLUS
| MINUS
;

constant:
  sign number {$$ = parse_constant($1, $2); tfree($1);}
| sign constantid {$$ = parse_constant($1, $2); tfree($1);}
| number
| constantid
| STR
;

constantid:
  ID {$$ = lookup($1);}//, CONST_ENTRY);}
;

typedefinitionpart:
  TYPE typedefinition {
    tfree($1);
    $$ = NULL;
  }
| {$$ = NULL;}
;

typedefinition:
  ID EQ typedenoter SEMICOLON {
    parse_typedefinition($1, $3);
    tfree($2);
    tfree($4);
    $$ = NULL;
  }
| typedefinition ID EQ typedenoter SEMICOLON {
    parse_typedefinition($2, $4);
    tfree($3);
    tfree($5);
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
  ID {$$ = lookup($1);}//, INVALID_ENTRY);}
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
    $$ = parse_enumeratedtype($2);
    tfree($1);
    tfree($3);
  }
;

idlist:
  ID
| idlist COMMA ID {
    token_append($1, $3);
    tfree($2);
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
  PACKED unpackedstructuredtype {$$ = parse_newstructuredtype($1, $2);}
| unpackedstructuredtype {$$ = parse_newstructuredtype($1, NULL);}
;

unpackedstructuredtype:
  arraytype
| recordtype
| settype
| filetype
;

arraytype:
  ARRAY LBRACKET indextype RBRACKET OF componenttype {
    tfree($1);
    tfree($2);
    tfree($4);
    tfree($5);
    $$ = parse_arraytype($3, $6);
  }
;

indextype:
  ordinaltype
| indextype COMMA ordinaltype {
    tfree($2);
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
    tfree($1);
    tfree($3);
    parse_recordtype($2);
    $$ = NULL;
  }
;

fieldlist:
  fixedpart SEMICOLON variantpart SEMICOLON {
    tfree($2);
    tfree($4);
    $$ = parse_fieldlist($1, $3);
  }
| fixedpart SEMICOLON variantpart {
    tfree($2);
    $$ = parse_fieldlist($1, $3);
  }
| fixedpart SEMICOLON {
    tfree($2);
    $$ = parse_fieldlist($1, NULL);
  }
| fixedpart {
    $$ = parse_fieldlist($1, NULL);
  }
| variantpart SEMICOLON {
    tfree($2);
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
    tfree($2);
    token_append($1, $3);
    $$ = $1; 
  }
;

recordsection:
  idlist COLON typedenoter {
    tfree($2);
    $$ = parse_recordsection($1, $3);
  }
;

fieldid:
  ID
; 

variantpart:
  CASE variantselector OF variantext {
    tfree($1);
    tfree($3);
    $2->leaf = $4;
    $$ = $2;
  }
;

variantext:
  variant
| variantext SEMICOLON variant {
    tfree($2);
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
    tfree($2);
    $1->type_sym = $3->entry;
    tfree($3);
    $$ = $1;
  }
| tagtype {
    printf("I don't know how to handle this use case. Sorry.\n");
    exit(1);
  }
;

tagfield:
  ID
;

variant:
  caseconstantlist COLON LPAREN fieldlist RPAREN {
    tfree($2);
    tfree($3);
    tfree($5);
    $1->leaf = $4;
    $$ = $1;
  }
;

tagtype:
  ordinaltypeid {$$ = lookup($1);}//, INVALID_ENTRY);}
;

caseconstantlist:
  caseconstant
| caseconstantlist COMMA caseconstant {
    tfree($2);
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
  SET OF basetype{
    tfree($1);
    $$ = parse_settype($3, $2);
  }
;

basetype:
  ordinaltype
;

filetype:
  PASFILE OF componenttype {
    tfree($1);
    tfree($2);
    $$ = $3;
  }
;

pointertype:
  newpointertype {
    $$ = parse_pointertype($1);
  }
| pointertypeid {
    $$ = parse_pointertype($1);
  }
;

newpointertype:
  POINT domaintype {
    tfree($1);
    $$ = $2;
  }
;

domaintype:
  typeid
;

/*
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
    tfree($1);
    tfree($2);
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
    //printf("%p\n", $3);
    //debugtokentree($3);
    $1->leaf = $3;
    tfree($2);
    tfree($4);
    parsetree = $1;
  }
;

programheading:
  PROG ID {
    $$ = parse_programheading($1, $2, NULL);
  }
| PROG ID LPAREN programparameterlist RPAREN {
    $$ = parse_programheading($1, $2, $4);
    tfree($3);
    tfree($5);
  }
;

programparameterlist:
  idlist
;

programblock:
  block
;
%%

token parse_pointertype(token basetype){
  symentry pointentry = symentry_alloc();
  pointentry->etype = POINT_ENTRY;
  pointentry->size = 8;
  pointentry->type = basetype->type_sym;
  basetype= cleartok(basetype);
  basetype->type_sym = pointentry;
  return basetype;
}

token parse_enumeratedtype(token idlist){
  int i = 0;
  for(; idlist; i++){
    symentry backing = symentry_alloc();
    symentry entry = symentry_alloc();
    entry->name = malloc(strlen(idlist->strval) + 1);
    strcpy(entry->name, idlist->strval);
    entry->etype = ID_ENTRY;
    entry->type = backing;
    backing->etype = CONST_ENTRY;
    backing->intval = i;
    backing->type = symtab_get(top_symtab, "integer");
    symtab_add(top_symtab, entry);
    token temp = idlist->next;
    tfree(idlist);
    idlist = temp;
  }
  token retval = talloc();
  symentry enumentry = symentry_alloc();
  enumentry->etype = ENUM_ENTRY;
  enumentry->size = i;
  retval->entry = enumentry;
  //TODO: Consider adding enumentry->next = <the first CONST> and link the CONSTs with ->next
  return retval; 
}

token parse_subrangetype(token filltok, token lowbound, token highbound){
  //TODO: Type checking of constants to ensure they are ordinal
  symentry entry = symentry_alloc();
  entry->etype = SUBRANGE_ENTRY;
  entry->low = lowbound->intval;
  debugtoken(highbound);
  entry->high = highbound->intval;
  entry->size = symtab_get(top_symtab, "integer")->type->size;
  cleartok(filltok);
  filltok->entry = entry;
  tfree(lowbound);
  tfree(highbound);
  return filltok;
}

token parse_newstructuredtype(token typetok, token packed){
  if(packed){
    tfree(packed);
  }
  return typetok;
}

token parse_arraytype(token indicies, token typetok){
  token retval = talloc();
  if(!indicies->next){
    //Process typtok
    symentry entry = symentry_alloc();
    entry->etype = ARRAY_ENTRY;
    entry->size = (indicies->entry->high - indicies->entry->low + 1) * typetok->type_sym->size;
    entry->low = indicies->entry->low;
    entry->high = indicies->entry->high;
    entry->type = typetok->entry;
    retval->entry = entry;
    retval->type_sym = entry->type;
  }
  else{
    token recursereturn = parse_arraytype(indicies->next, typetok);
    symentry entry = symentry_alloc();
    entry->etype = ARRAY_ENTRY;
    entry->size = (indicies->entry->high - indicies->entry->low + 1) * recursereturn->entry->size;
    entry->low = indicies->entry->low;
    entry->high = indicies->entry->high;
    entry->type = recursereturn->entry;
    retval->entry = entry;
    retval->type_sym = entry->type;
  }
  return retval;
}

//Returns the next offset x such that
//      x >= cur_offset
//      x % boundary == 0
int find_next_offset(int cur_offset, int boundary){
  if(cur_offset % boundary == 0){
    return cur_offset;
  }
  return cur_offset + (boundary - (cur_offset % boundary));
}

token parse_recordtype(token fieldlist){

}

token parse_fieldlist(token fixed, token variant){
  if(variant){
    printf("Bye!\n");
    exit(1);
  }
  token recorditer = fixed;
  symentry prevend = NULL;
  while(recorditer){
    symentry entryiter = recorditer->entry;
    symentry entryend = entryiter
    while(entryend->next){
      entryend = entryend->next;
    }
    if(prevend){
      prevend->next = entryiter;
    }
    prevend = entryend;
    recorditer = recorditer->next;
  }
  symentry liststart = fixed->entry;
  cleartok(fixed);
  fixed->entry = liststart
  return fixed;
}

token parse_recordsection(token idlist, token typedenoter){
  symentry arglist = NULL;
  symentry arglistend = NULL;
  while(idlist){
    if(arglist){
      arglistend->next = symentry_alloc();
      arglistend = arglistend->next;
    }
    else{
      arglist = arglistend = symentry_alloc();
    }
    arglistend->name = malloc(strlen(idlist->strval) + 1);
    strcpy(arglistend->name, idlist->strval);
    arglistend->size = typedenoter->entry->size;
    arglistend->type = typedenoter->entry; //TODO:type_sym
    token tmp = idlist->next;
    tfree(idlist);
    idlist = tmp;
  }
  cleartok(typedenoter);
  typedenoter->entry = arglist;
  return typedenoter;
}

token parse_settype(token basetype, token fill){
  symentry setentry = symentry_alloc();
  setentry->etype = SET_ENTRY;
  setentry->size = basetype->entry->size;
  setentry->type = basetype->entry;
  cleartok(fill);
  fill->entry = setentry;
  fill->type_sym = setentry->type;
  return fill;
}


void parse_typedefinition(token id, token def){
  symentry typeentry = symentry_alloc();
  typeentry->etype = ID_ENTRY;
  typeentry->name = malloc(strlen(id->strval) + 1);
  strcpy(typeentry->name, id->strval);
  typeentry->type = def->entry;
  symtab_add(top_symtab, typeentry);
}


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
  return constant;
}

void parse_constantdefinition(token id, token constant){
  //printf("Adding constant %s to symtab\n", id->strval);
  symentry constentry = symentry_alloc();
  constentry->name = malloc(strlen(id->strval) + 1);
  strcpy(constentry->name, id->strval);
  constentry->etype = ID_ENTRY;
  constentry->type = constant->type_sym;
  symtab_add(top_symtab, constentry);
}

token lookup(token id){//, entrytype t){
  //printf("id is %s\n", id->strval);
  symentry entry = symtab_get(top_symtab, id->strval);
  if(!entry){
    printf("No entry %s declared\n", id->strval);
    exit(1);
  }
  /*
  if(entry->etype != t){
    printf("%s is not the desired type of entry %d\n", id->strval, t);
    exit(1);
  }
  */
  id->intval = entry->intval;
  id->realval = entry->realval;
  if(entry->strval){
    id->strval = malloc(strlen(entry->strval) + 1);
    strcpy(id->strval, entry->strval);
  }
  id->entry = entry;
  id->type_sym = entry->type;
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
  //printf("label_name:%s\n", label_name);
  if(symtab_get(top_symtab, label_name)){
    printf("Repeated label number: %s\n", label_name);
    exit(1);
  }
  symentry label_entry = symentry_alloc();
  //symentry label_backing = symentry_alloc();
  label_entry->etype = ID_ENTRY;
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
  if(!yyparse()){
    debugtokentree(parsetree);
  }
  return 0;
}

void init_symtab(void){
  top_symtab = symtab_alloc();
  symentry intentry = symentry_alloc();
  symentry realentry = symentry_alloc();
  symentry boolentry = symentry_alloc();
  symentry charentry = symentry_alloc();
  symentry intbacking = symentry_alloc();
  symentry realbacking = symentry_alloc();
  symentry boolbacking = symentry_alloc();
  symentry charbacking = symentry_alloc();
  intentry->etype = ID_ENTRY;
  realentry->etype = ID_ENTRY;
  boolentry->etype = ID_ENTRY;
  charentry->etype = ID_ENTRY;
  intentry->type = intbacking;
  realentry->type = realbacking;
  boolentry->type = boolbacking;
  charentry->type = charbacking;
  intentry->name = "integer";
  realentry->name = "real";
  boolentry->name = "Boolean";
  charentry->name = "char";
  intbacking->etype = INT_ENTRY;
  realbacking->etype = REAL_ENTRY;
  boolbacking->etype = BOOL_ENTRY;
  charbacking->etype = CHAR_ENTRY;
  intbacking->size = 4;
  realbacking->size = 8;
  boolbacking->size = 1;
  charbacking->size = 1;
  intbacking->low = -MAXINT;
  intbacking->high = MAXINT;
  boolbacking->low = 0;
  boolbacking->high = 1;
  charbacking->low = 0;
  charbacking->high = MAXCHAR;
  symtab_add(top_symtab, intentry);
  symtab_add(top_symtab, realentry);
  symtab_add(top_symtab, boolentry);
  symtab_add(top_symtab, charentry);
  symentry boolfalse = symentry_alloc();
  symentry booltrue = symentry_alloc();
  symentry boolfalsebacking = symentry_alloc();
  symentry booltruebacking = symentry_alloc();
  boolfalse->etype = ID_ENTRY;
  booltrue->etype = ID_ENTRY;
  boolfalse->type = boolfalsebacking;
  booltrue->type = booltruebacking;
  boolfalse->name = "false";
  booltrue->name = "true";
  boolfalsebacking->etype = CONST_ENTRY;
  booltruebacking->etype = CONST_ENTRY;
  boolfalsebacking->size = symtab_get(top_symtab, "Boolean")->type->size;
  booltruebacking->size = symtab_get(top_symtab, "Boolean")->type->size;
  boolfalsebacking->intval = 0;
  booltruebacking->intval = 1;
  boolfalsebacking->type = symtab_get(top_symtab, "Boolean")->type;
  booltruebacking->type = symtab_get(top_symtab, "Boolean")->type;
  symtab_add(top_symtab, boolfalse);
  symtab_add(top_symtab, booltrue);
  debugsymtab(top_symtab);
}

void init_parsetree(void){
  parsetree = NULL;
}
