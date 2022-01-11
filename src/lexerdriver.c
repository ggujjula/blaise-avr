#include "lexer.h"
#include "token.h"

int main(){
  YYSTYPE yylval;
  int retval = yylex(&yylval);
  while(retval != 0){
    debugtoken(yylval);
    retval = yylex(&yylval);
  }
}
