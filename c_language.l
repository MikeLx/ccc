

%{
# include "c_language.tab.h"
%}

%%

"int" { return INT; }
"char" { return CHAR; }
"*" { return ASTERISK; }
"(" { return OPEN_PAREN; }
")" { return CLOSE_PAREN; }
"{" { return OPEN_BRACE; }
"}" { return CLOSE_BRACE; }
"," { return COMMA; }
"return" { return RETURN; }
";" { return SEMICOLON; }
"+" { return PLUS; }
[0-9]+  { return INTEGER_CONSTANT; }
[a-zA-Z_]+[a-zA-Z0-9_]* { return IDENTIFIER; }

"//".*\n?
[ \t\n\r]   { /* ignore white space */ }
. {
  char message[64];
  sprintf(message, "Mystery character %c\n", *yytext);
  yyerror(message);
}
%%
