#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "parser.h"
#include "token.h"

static int debugtreeindent = 0;
static token debugtreeroot = NULL;
static const int debugtableoffset = (int)(PLUS);
//static const int debugtablesize = (int)(STR) - (int)(PLUS);
static const char* debugtable[] = {
  "+", "-", "*", "/", "=", "<", ">", "{", "}", ".", ",", ":", ";", "^", "(", ")",
  "<>", "<=", ">=", ":=", "..", "AND", "ARRAY", "PASBEGIN", "CASE", "CONST", "DIV",
  "DO", "DOWNTO", "ELSE", "END", "PASFILE", "FOR", "FUNC", "GOTO", "IF", "IN",
  "LABEL", "MOD", "NIL", "NOT", "OF", "OR", "PACKED", "PROC", "PROG", "RECORD",
  "REPEAT", "SET", "THEN", "TO", "TYPE", "UNTIL", "VAR", "WHILE", "WITH", "ID",
  "PASDIR", "SIGNED_REAL", "UNSIGNED_REAL", "SIGNED_INT", "UNSIGNED_INT",
  "LABELNUM", "STR" };

token talloc(){
  token t = malloc(sizeof(struct tokenstruct));
  cleartok(t);
  return t;
}

token cleartok(token t){
  memset(t, 0, sizeof(struct tokenstruct));
  t->specval = -1; //tokentype of 0 is YYEOF
  return t;
}

token inittok(toktype type, int specval, int intval, double realval, char* strval){
  token t = talloc();
  t->type = type;
  t->specval = specval;
  t->intval = intval;
  t->realval = realval;
  t->strval = malloc(strlen(strval) + 1);
  strcpy(t->strval, strval);
  return t;
}

void tfree(token t){
  if(t->strval){
    free(t->strval);
  }
  free(t);
}

void debugtokentree(token tok){
  if(!tok){
    return;
  }
  if(tok->specval < PLUS ||
      tok->specval > STR ||
      tok->type < TYPE_SPEC ||
      tok->type > TYPE_STR){
    printf("INVALID ");
    return;
  }
  if(!debugtreeroot){
    debugtreeroot = tok;
  }
  printf("\n");
  for(int i = 0; i < debugtreeindent; i++){
    printf(" ");
  }
  printf("{ %s", debugtable[(int)(tok->specval) - debugtableoffset]);
  switch(tok->type){
    case TYPE_ID:
      printf(":%s ", tok->strval);
      break;
    case TYPE_STR:
      printf(":\"%s \"", tok->strval);
      break;
    case TYPE_NUM:
    case TYPE_LABEL:
      printf(":%x ", tok->intval);
      break;
    default:
      printf(" ");
      break;
  }
  if(tok->leaf){
    debugtreeindent++;
    debugtokentree(tok->leaf); 
    debugtreeindent--;
  }
  printf("}");
  debugtokentree(tok->next); 
  if(debugtreeroot == tok){
    printf("\n");
    debugtreeroot = NULL;
  }
}

void debugtoken(token tok){
  union debugunion{
    double input;
    unsigned long output;
  };
  union debugunion dbu;
  dbu.input = tok->realval;
  printf("\n--------DEBUG TOKEN--------\n");
  printf("%12s%p\n", "Address: ", tok);
  if(!tok ||
      tok->specval < PLUS ||
      tok->specval > STR ||
      tok->type < TYPE_SPEC ||
      tok->type > TYPE_STR){
    printf("INVALID\n");
  }
  else{
    printf("%12s%x\n", "Type: ", tok->type);
    printf("%12s%s(%d)\n", "specval: ", debugtable[(int)(tok->specval) - debugtableoffset], tok->specval);
    printf("%12s%x\n", "intval: ", tok->intval);
    printf("%12s%lx\n", "realval: ", dbu.output);
    printf("%12s%s\n", "strval: ", tok->strval);
    printf("%12s%p\n", "entry: ", tok->entry);
    printf("%12s%p\n", "type_sym: ", tok->type_sym);
    printf("%12s%p\n", "leaf: ", tok->leaf);
    printf("%12s%p\n", "next: ", tok->next);
  }
    printf("------END DEBUG TOKEN------\n");
}

void token_append(token tok1, token tok2){
  if(!tok1){
    return;
  }
  token index = tok1;
  token end = NULL;
  while(index){
    end = index;
    index = index->next;
  }
  end->next = tok2;
}
