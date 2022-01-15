/*
  symtab.h - Symbol table definitions

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
#ifndef BLAISE_AVR_SYMTAB_H
#define BLAISE_AVR_SYMTAB_H

typedef enum entrytype{
  INVALID_ENTRY = 0,
  ID_ENTRY,     //NOTE: ID_ENTRY is used for label symbols as well, since Pascal defines ids and labels in different
                // namespaces (IDs must start with a letter, labels must start with a digit)
  LABEL_ENTRY,
  CONST_ENTRY,
  REAL_ENTRY,
  INT_ENTRY,
  BOOL_ENTRY,
  CHAR_ENTRY,
  ENUM_ENTRY,
  SUBRANGE_ENTRY,
  ARRAY_ENTRY,
  RECORD_ENTRY,
  SET_ENTRY,
  FILE_ENTRY,
  POINT_ENTRY
} entrytype;

typedef struct tableentry{
  entrytype etype;
  char *name;
  int size;
  int offset;
  //TODO: Use a union for intval, realval, and strval
  int intval;
  double realval;
  char* strval;
  int low;
  int high;
  struct tableentry *type;
  struct tableentry *next;
} tableentry;

typedef struct tableentry* symentry;

typedef struct symboltable{
  symentry entrylist;
  struct symboltable *prev;
} symboltable;

typedef struct symboltable* symtab;

symtab symtab_alloc(void);
symentry symentry_alloc(void);
symtab symtab_push(symtab parent);
symtab symtab_pop(symtab child);
void symtab_add(symtab tab, symentry entry);
symentry symtab_get(symtab tab, char *name);
void debugsymentry(symentry entry);
void debugsymtab(symtab tab);
void debugsymtabtree(symtab tab);

#endif
