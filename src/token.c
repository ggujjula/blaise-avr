#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "token.h"

token talloc(){
  token t = malloc(sizeof(struct tokenstruct));
  cleartok(t);
  return t;
}

token cleartok(token t){
  t->type = TYPE_CLEAR;
  t->specval = -1;
  t->intval = 0;
  t->realval = 0.0;
  t->strval = NULL;
  t->next = NULL;
  t->leaf = NULL;
  return t;
}

token inittok(toktype type, enum yytokentype specval, int intval, double realval, char* strval){
  token t = malloc(sizeof(struct tokenstruct));
  t->type = type;
  t->specval = specval;
  t->intval = intval;
  t->realval = realval;
  size_t strsize = strlen(strval);
  //TODO: Take care of mem leaks from this malloc
  t->strval = malloc(strsize * sizeof(char));
  strncpy(t->strval, strval, strsize);
  t->next = NULL;
  t->leaf = NULL;
  return t;
}

void debugtoken(token tok){
  printf("\n-----DEBUG TOKEN-----\n");
  printf("Type: %x\n", tok->type);
  printf("intval: %x\n", tok->intval);
  printf("realval: %f\n", tok->realval);
  printf("strval: %s\n", tok->strval);
  printf("entry: %p\n", tok->entry);
  printf("type_sym: %p\n", tok->type_sym);
  printf("leaf: %p\n", tok->leaf);
  printf("next: %p\n", tok->next);
  printf("-----END DEBUG TOKEN-----\n");
}

void tokentest(token tok){
  union debugunion{
    double input;
    unsigned long output;
  };
  union debugunion dbu;
  dbu.input = tok->realval;
  printf("Type: %x\n", tok->type);
  printf("intval: %x\n", tok->intval);
  printf("realval: %lx\n", dbu.output);
  printf("strval: %s\n", tok->strval);
  printf("entry: %p\n", tok->entry);
  printf("type_sym: %p\n", tok->type_sym);
  printf("leaf: %p\n", tok->leaf);
  printf("next: %p\n", tok->next);
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
