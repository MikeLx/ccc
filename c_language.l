

%{
# include "c_language.tab.h"
# include "stdio.h"
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
[0-9]+  { yylval.i_val = atoi(yytext); return INTEGER_CONSTANT; }
[0-9]*\.[0-9]+ { yylval.d_val = atof(yytext); return DOUBLE_CONSTANT; }
[0-9]+\.[0-9]* { yylval.d_val = atof(yytext); return DOUBLE_CONSTANT; }

[a-zA-Z_]+[a-zA-Z0-9_]* { yylval.s_val = strdup(yytext); return IDENTIFIER; }

"//".*\n?
[ \t\n\r]   { /* ignore white space */ }
. {
  char message[64];
  sprintf(message, "Mystery character %c\n", *yytext);
  yyerror(message);
}
%%
