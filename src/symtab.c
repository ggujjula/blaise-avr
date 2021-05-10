#include "symtab.h"
#include <stdlib.h>

symtab symtab_alloc(void){
  symtab retval = malloc(sizeof(symboltable));
  retval->entrylist = NULL;
  retval->prev = NULL;
  return retval;
}

symentry symentry_alloc(void){
  symentry retval = malloc(sizeof(tableentry));
  retval->name = NULL;
  retval->size = -1;
  retval->type = NULL;
  retval->next = NULL;
  return retval;
}
