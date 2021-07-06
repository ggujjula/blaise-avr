#!/usr/bin/sed
s/\#ifndef YYTOKENTYPE/&/;
T nomatch;
:match
p;
n;
s/\#endif/&/;
T match
:addinclude
a\
\n#include "token.h"
:nomatch
s/typedef int YYSTYPE/typedef token YYSTYPE/;
p;
