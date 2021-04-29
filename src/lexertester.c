#include "lexer.h"
#include "token.h"

int main(){
  int retval = yylex();
  while(retval != 0){
    tokentest(yylval);
    retval = yylex();
  }
}
