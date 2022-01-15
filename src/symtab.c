#include "symtab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char *etype_debug[] = {
  "INVALID_ENTRY",
  "ID_ENTRY",
  "LABEL_ENTRY",
  "CONST_ENTRY",
  "REAL_ENTRY",
  "INT_ENTRY",
  "BOOL_ENTRY",
  "CHAR_ENTRY",
  "ENUM_ENTRY",
  "SUBRANGE_ENTRY",
  "ARRAY_ENTRY",
  "RECORD_ENTRY",
  "SET_ENTRY",
  "FILE_ENTRY",
  "POINT_ENTRY"
};

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

void debugsymentry(symentry entry){
  printf("\n--------DEBUG SYMBOL ENTRY--------\n");
  printf("%12s%p\n", "Address: ", entry);
  if(!entry ||
      entry->etype == INVALID_ENTRY){
    printf("INVALID\n");
  }
  else{
    printf("%12s%s(%d)\n", "etype: ", etype_debug[(int)(entry->etype)], entry->etype);
    printf("%12s%s\n", "Name: ", entry->name);
    printf("%12s%d\n", "size: ", entry->size);
    printf("%12s%d\n", "offset: ", entry->offset);
    union debugunion{
      double input;
      unsigned long output;
    };
    //union debugunion dbu;
    //dbu.input = entry->realval;
    printf("%12s%d\n", "intval: ", entry->intval);
    printf("%12s%f\n", "realval: ", entry->realval);
    printf("%12s%s\n", "strval: ", entry->strval);
    printf("%12s%x\n", "low: ", entry->low);
    printf("%12s%x\n", "high: ", entry->high);
    printf("%12s%p\n", "type: ", entry->type);
    printf("%12s%p\n", "next: ", entry->next);
  }
    printf("------END DEBUG SYMBOL ENTRY------\n");
}

void debugsymtab(symtab tab){
  printf("\n--------DEBUG SYMBOL TABLE--------\n");
  symentry entry = tab->entrylist;
  while(entry){
    debugsymentry(entry);
    entry = entry->next;
  }
  printf("\n--------END DEBUG SYMBOL TABLE--------\n");
}

void debugsymtabtree(symtab tab){
  printf("\n--------DEBUG SYMBOL TABLE TREE--------\n");
  while(tab){
    debugsymtab(tab);
    tab = tab->prev;
  }
  printf("\n--------END DEBUG SYMBOL TABLE TREE--------\n");
}
