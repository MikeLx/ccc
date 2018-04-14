

%{
# include "c_language.tab.h"
# include "stdio.h"
%}

%%

"unsigned" { return UNSIGNED; }
"const" { return CONST; }

"long" { return LONG; }
"int" { return INT; }
"short" { return SHORT; }
"char" { return CHAR; }

"for" { return FOR; }
"while" { return WHILE; }
"do" { return DO; }
"if" { return IF; }
"else" { return ELSE; }
"switch" { return SWITCH; }
"case" { return CASE; }
"break" { return BREAK; }
"continue" { return CONTINUE; }
"return" { return RETURN; }

"(" { return OPEN_PAREN; }
")" { return CLOSE_PAREN; }
"{" { return OPEN_BRACE; }
"}" { return CLOSE_BRACE; }
"," { return COMMA; }
";" { return SEMICOLON; }

"*" { return ASTERISK; }
"+" { return PLUS; }
"-" { return MINUS; }
"/" { return DIVIDE; }
"==" { return DOUBLE_EQUALS; }
"=" { return EQUALS; }

[0-9]+  { yylval.i_val = atoi(yytext); return INTEGER_CONSTANT; }
'\\?.' { yylval.c_val = yytext[1]; return CHARACTER_CONSTANT; }
\".*\" {
  size_t len = strlen(yytext);
  size_t new_strlen = len - 2;
  char* contents = (char*) malloc(new_strlen + 1);
  contents[new_strlen] = '\0';
  yylval.s_val = strncpy(contents, yytext + 1, new_strlen);
  return STRING_CONSTANT;
}
[a-zA-Z_]+[a-zA-Z0-9_]* { yylval.s_val = strdup(yytext); return IDENTIFIER; }

"//".*\n?
[ \t\n\r]   { /* ignore white space */ }
. {
  char message[64];
  sprintf(message, "Mystery character %c\n", *yytext);
  yyerror(message);
}
%%
