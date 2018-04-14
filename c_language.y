
%{
#  include <stdio.h>
#  include "abstract_syntax_tree.h"
#  include "symbol_table.h"
abstract_syntax_tree* root;

%}

/* declare tokens */
%token UNSIGNED CONST
%token CHAR SHORT INT LONG
%token FOR WHILE DO IF ELSE SWITCH CASE BREAK CONTINUE RETURN
%token OPEN_PAREN CLOSE_PAREN OPEN_BRACE CLOSE_BRACE COMMA SEMICOLON
%token ASTERISK PLUS MINUS DIVIDE DOUBLE_EQUALS EQUALS
%token <i_val> INTEGER_CONSTANT
%token <c_val> CHARACTER_CONSTANT
%token <s_val> STRING_CONSTANT
%token <s_val> IDENTIFIER
%token COMPILATION_UNIT
%token FUNCTION
%token DECLARATION
%token ARGS_LIST
%token STATEMENTS

%union {
  struct abstract_syntax_tree * p_ast;
  int                           i_val;
  char                          c_val;
  char*                         s_val;
}

%type <p_ast>
  compilation_unit
  function
  paren_enclosed_args_list
  args_list
  typename
  basic_type
  pointer_type
  formal_parameter
  function_body
  statements
  statement
  declaration
  expression

%%


compilation_unit: /* nothing */ { $$ = ast_alloc(COMPILATION_UNIT); root = $$; }
 | compilation_unit function { $$ = $1; ast_append_child($$, $2); }
 ;

function: typename IDENTIFIER paren_enclosed_args_list function_body {
    $$   = ast_alloc(FUNCTION);
    ast_append_child($$, $1);
    abstract_syntax_tree * ident = ast_alloc(IDENTIFIER);
    ident->s_val = $2;
    ast_append_child($$, ident);
    ast_append_child($$, $3);
    ast_append_child($$, $4);
  }
 ;

paren_enclosed_args_list: OPEN_PAREN args_list CLOSE_PAREN { $$ = $2; }

args_list: /* nothing */ { $$ = ast_alloc(ARGS_LIST); }
 | formal_parameter { $$ = ast_alloc(ARGS_LIST); ast_append_child($$,$1); }
 | args_list COMMA formal_parameter { $$ = $1; ast_append_child($$,$3); }
 ;

typename: basic_type { $$ = $1; }
 | pointer_type { $$ = $1; }
 ;

basic_type: INT { $$ = ast_alloc(INT); }
 | CHAR { $$ = ast_alloc(CHAR); }
 ;

pointer_type: basic_type ASTERISK { $$ = ast_alloc(ASTERISK); ast_append_child($$, $1); }
 | pointer_type ASTERISK { $$ = ast_alloc(ASTERISK); ast_append_child($$, $1); }
 ;

formal_parameter: typename IDENTIFIER { $$ = ast_alloc(IDENTIFIER); $$->s_val = $2; ast_append_child($$,$1); }
 | pointer_type IDENTIFIER { $$ = ast_alloc(IDENTIFIER); $$->s_val = $2; ast_append_child($$,$1); }
 ;

function_body: OPEN_BRACE statements CLOSE_BRACE { $$ = $2; }
 ;

statements: /* nothing */ { $$ = ast_alloc(STATEMENTS); }
 | statements statement { $$ = $1; ast_append_child($$, $2); }
 ;

statement: RETURN expression SEMICOLON { $$ = ast_alloc(RETURN); ast_append_child($$,$2); }
 | declaration SEMICOLON { $$ = $1; }
 | expression SEMICOLON { $$ = $1; }
 ;

declaration: typename IDENTIFIER {
    $$ = ast_alloc(DECLARATION);
    ast_append_child($$, $1);
    ast_append_child($$, ast_alloc_s(IDENTIFIER, $2));
  }
 | typename IDENTIFIER EQUALS expression {
    $$ = ast_alloc(DECLARATION);
    ast_append_child($$, $1);
    ast_append_child($$, ast_alloc_s(IDENTIFIER, $2));
    ast_append_child($$, $4);
 }
 ;

expression: IDENTIFIER { $$ = ast_alloc_s(IDENTIFIER, $1); }
 | INTEGER_CONSTANT { $$ = ast_alloc_i(INTEGER_CONSTANT, $1); }
 | STRING_CONSTANT { $$ = ast_alloc_s(STRING_CONSTANT, $1); }
 | CHARACTER_CONSTANT { $$ = ast_alloc_c(CHARACTER_CONSTANT, $1); }
 | expression PLUS expression {
    $$ = ast_alloc(PLUS);
    ast_append_child($$,$1);
    ast_append_child($$,$3);
  }
 ;

%%
int main(int argc, char** argv)
{
  if (yyparse() == 0)
  {
    ast_print(root);
    //symbol_table* st = st_alloc();
    //root is always a function
    //abstract_syntax_tree* ident = ast_nth_child(root, 2);
    //st_add_symbol(st, ident->s_val);
    //st_enter_scope(st);
  }
}

int yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
}
