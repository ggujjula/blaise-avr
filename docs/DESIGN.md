DESIGN DOC
------------
(Subject to change as development continues)

Host architecture: x86-64
Target architecture: avr (Currently only ATmega328P)
Language used: C

Tools and dependencies:
  bash
  flex
  bison
  make
  gcc
  glibc

Component separation:
  Lexer:
    lexer.lex
      Input to flex, containing regular language and token generation functions
    lexer.h
      If needed, any functions that will need to be called by the parser/codegen
    lexer.c
      Output of flex
  Parser:
    parser.yacc
      Input to bison, containing grammar and code tree construction functions
    parser.h
      If needed, any functions that will need to be called by lexer/codegen
    parser.c
      Output of bison
  Code Generator:
    codegen.h
      If needed, any functions that will need to be called by lexer/parser
    codegen.c
      Code generation driver, which will call the appropriate handler functions
      for the given target device for each construct in the code tree.
    avrgeneric.h
      Defines the code generation functions in the case of a full instruction set.
    atmega328p.h
      Defines the code generation functions appropriate for an ATmega328P.

Interface between components:
  Tokens:
    token.h
      Defines the different token classes.
  Code Tree:
    All interface definitions should be handled in token.h.
  Symbol Table:
    symtab.h
      Defines the structure of the symbol table and functions to manipulate one.

Testing:
  /tests/test\_\* (Tests)
  /tests/test.sh  (Starting Script)
  'make check' to run script

Considerations for expansion:
  Allow for target device to be specified
    Workarounds may be needed since not all devices support all instructions

Potential issues and mitigating actions:
  Space restrictions on target device:
    Code generator can keep track of size of output, terminate if exceeds target
    device limits. avrdude probably already does this
  Incomplete instruction set implementation:
    Use alternate code sequences as a workaround, or terminate if not possible
  flex output not thread safe by default
    Don't make this compiler multithreaded
