#include "lexer.h"
#include "token.h"

YYSTYPE yylval;

int main(){
  int retval = yylex();
  while(retval != 0){
    debugtoken(yylval);
    retval = yylex();
  }
}
