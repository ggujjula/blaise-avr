#include <stdlib.h>
#include "token.h"

token talloc(){
  token t = malloc(sizeof(struct tokenstruct));
  t->type = TYPE_SPEC;
  //t->specval = PLUS;
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
  //t->specval = specval;
  t->intval = intval;
  t->realval = realval;
  t->strval = strval;
  t->next = NULL;
  t->leaf = NULL;
  return t;
}
