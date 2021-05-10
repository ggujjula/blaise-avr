#include "symtab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

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

symtab symtab_push(symtab parent){
  printf("symtab push\n");
  symtab child = symtab_alloc();
  child->prev = parent;
  return child;
}

symtab symtab_pop(symtab child){
  printf("symtab pop\n");
  symtab parent = child->prev;
  free(child);
  return parent;
}

void symtab_add(symtab tab, symentry entry){
  entry->next = tab->entrylist;
  tab->entrylist = entry;
}

symentry symtab_get(symtab tab, char *name){
  symtab curtab = tab;
  while(curtab){
    symentry curlist = curtab->entrylist;
    while(curlist){
      if(!strcmp(curlist->name, name)){
        return curlist;
      }
      curlist = curlist->next;
    }
    curtab = curtab->prev;
  }
  return NULL;
}
