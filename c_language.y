
%{
#  include <stdio.h>
%}

/* declare tokens */
%token INT CHAR
%token ASTERISK
%token OPEN_PAREN CLOSE_PAREN
%token OPEN_BRACE CLOSE_BRACE
%token COMMA
%token RETURN
%token SEMICOLON
%token PLUS
%token INTEGER_CONSTANT
%token IDENTIFIER

%%

function: INT IDENTIFIER OPEN_PAREN args_list CLOSE_PAREN function_body { printf("function ..."); }
 ;


args_list: /* nothing */
 | formal_parameter { printf("formal_parameter"); }
 | args_list COMMA formal_parameter { printf("args_list, formal_parameter"); }
 ;

type: INT { printf("INT"); }
 | CHAR { printf("CHAR"); }
 ;

pointer: type ASTERISK { printf("type ASTERISK"); }
 | pointer ASTERISK { printf("pointer ASTERISK"); }
 ;

formal_parameter: type IDENTIFIER { printf("type ID"); }
 | pointer IDENTIFIER { printf("pointer ID"); }
 ;

function_body: OPEN_BRACE CLOSE_BRACE { printf("EMPTY FUNCTION BODY"); }
 | OPEN_BRACE statements CLOSE_BRACE { printf("FUNCTION BODY WITH STATEMENTS!"); }
 ;

statements: /* nothing */
 | statement statements { printf("recursive statements"); }
 ;

statement: RETURN expression SEMICOLON { printf("RETURN expression;"); }
 | expression SEMICOLON { printf("expression;"); }
 ;

expression: IDENTIFIER { printf("IDENTIFIER"); }
 | INTEGER_CONSTANT { printf("INTEGER_CONSTANT"); }
 | expression PLUS expression { printf("expr + expr"); }
 ;
 
%%
int main(int argc, char** argv)
{
  printf("> "); 
  yyparse();
}

yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
}
