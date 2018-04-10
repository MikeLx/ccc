
%{
#  include <stdio.h>
#  include "abstract_syntax_tree.h"
#  include "symbol_table.h"
abstract_syntax_tree* root;

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
%token <i_val> INTEGER_CONSTANT
%token <s_val> IDENTIFIER
%token FUNCTION
%token ARGS_LIST
%token STATEMENTS

%union {
  struct abstract_syntax_tree * p_ast;
  int                           i_val;
  char*                         s_val;
}

%type <p_ast>
  function
  paren_enclosed_args_list
  args_list
  type
  pointer
  formal_parameter
  function_body
  statements
  statement
  expression
%%

function: INT IDENTIFIER paren_enclosed_args_list function_body {
    $$   = ast_alloc(FUNCTION);
    ast_append_child($$, ast_alloc(INT));
    abstract_syntax_tree * ident = ast_alloc(IDENTIFIER);
    ident->s_val = $2;
    ast_append_child($$, ident);
    ast_append_child($$, $3);
    ast_append_child($$, $4);
    root = $$;
  }
 ;

paren_enclosed_args_list: OPEN_PAREN args_list CLOSE_PAREN { $$ = $2; }

args_list: /* nothing */ { $$ = ast_alloc(ARGS_LIST); }
 | formal_parameter { $$ = ast_alloc(ARGS_LIST); ast_append_child($$,$1); }
 | args_list COMMA formal_parameter { $$ = $1; ast_append_child($$,$3); }
 ;

type: INT { $$ = ast_alloc(INT); }
 | CHAR { $$ = ast_alloc(CHAR); }
 ;

pointer: type ASTERISK { $$ = ast_alloc(ASTERISK); ast_append_child($$, $1); }
 | pointer ASTERISK { $$ = ast_alloc(ASTERISK); ast_append_child($$, $1); }
 ;

formal_parameter: type IDENTIFIER { $$ = ast_alloc(IDENTIFIER); $$->s_val = $2; ast_append_child($$,$1); }
 | pointer IDENTIFIER { $$ = ast_alloc(IDENTIFIER); $$->s_val = $2; ast_append_child($$,$1); }
 ;

function_body: OPEN_BRACE statements CLOSE_BRACE { $$ = $2; }
 ;

statements: /* nothing */ { $$ = ast_alloc(STATEMENTS); }
 | statement statements { $$ = $2; ast_append_child($$, $1); }
 ;

statement: RETURN expression SEMICOLON { $$ = ast_alloc(RETURN); ast_append_child($$,$2); }
 | expression SEMICOLON { $$ = $1; }
 ;

expression: IDENTIFIER { $$ = ast_alloc(IDENTIFIER); $$->s_val = $1; }
 | INTEGER_CONSTANT { $$ = ast_alloc(INTEGER_CONSTANT); $$->i_val = $1; }
 | expression PLUS expression {
    $$ = ast_alloc(PLUS);
    ast_append_child($$,$1);
    ast_append_child($$,$3);
  }
 ;
 
%%
int main(int argc, char** argv)
{
  yyparse();
  ast_print(root);
  symbol_table* st = st_alloc();
  //root is always a function
  abstract_syntax_tree* ident = ast_nth_child(root, 2);
  st->append_symbol(st, ident->s_val);
  st_enter_scope(st);

}

int yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
}
