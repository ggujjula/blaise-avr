#include "symtab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

symtab symtab_alloc(void){
  symtab retval = calloc(1, sizeof(symboltable));
  return retval;
}

symentry symentry_alloc(void){
  symentry retval = calloc(1, sizeof(tableentry));
  retval->size = -1;
  retval->offset = -1;
  retval->low = -1;
  retval->high = -1;
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
  //TODO: symbol entries of child are probably leaking
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
      printf("Comparing %s to %s\n", curlist->name, name);
      if(!strcmp(curlist->name, name)){
        return curlist;
      }
      curlist = curlist->next;
    }
    curtab = curtab->prev;
  }
  return NULL;
}
