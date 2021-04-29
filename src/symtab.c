#include "symtab.h"

symtab symtab_alloc(void){
  symtab = malloc(sizeof(symboltable));
  symtab->entrylist = NULL;
  symtab->prev = NULL;
}

symentry symentry_alloc(void){
  symentry = malloc(sizeof(tableentry));
  symentry->name = NULL;
  symentry->size = -1;
  symentry->type = NULL;
  symentry->next = NULL;
}
