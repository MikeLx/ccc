
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

symbol_table* build_symbol_table(abstract_syntax_tree* ast, symbol_table* st)
{
  ast_nodelist* cur_child = 0;
  switch(ast->token_type)
  {
  case IDENTIFIER:
    st_add_symbol(st, ast->s_val);
    break;
  case ARGS_LIST:
  case STATEMENTS:
    cur_child = ast->children;
    while(cur_child)
    {
      build_symbol_table(cur_child->node, st);
      cur_child = cur_child->next;
    }
    break;
  case FUNCTION:
    //function name in current scope
    build_symbol_table(ast_nth_child(ast, 1), st);
    //enter function scope
    st_enter_scope(st);
    //handle args list
    build_symbol_table(ast_nth_child(ast, 2), st);
    //handle body
    build_symbol_table(ast_nth_child(ast, 3), st);
    st_print(st);
    //exit function scope
    st_exit_scope(st);
    break;
  }  
}

int main(int argc, char** argv)
{
  yyparse();
  ast_print(root);
  symbol_table* st = st_alloc();
  build_symbol_table(root, st);
  st_print(st);
}

int yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
}
