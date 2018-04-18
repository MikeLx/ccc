
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
%token FUNCTION_DEFINITION FUNCTION_DECLARATION
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
  function_definition
  function_declaration
  paren_enclosed_args_list
  args_list
  typename
  basic_type
  pointer_type
  formal_parameter
  function_body
  statements
  statement
  conditional
  declaration
  expression

%%


compilation_unit: /* nothing */ { $$ = ast_alloc(COMPILATION_UNIT); root = $$; }
 | compilation_unit function_declaration { $$ = $1; ast_append_child($$, $2); }
 | compilation_unit function_definition { $$ = $1; ast_append_child($$, $2); }
 ;

function_declaration: typename IDENTIFIER paren_enclosed_args_list SEMICOLON {
    $$ = ast_alloc(FUNCTION_DECLARATION);
    ast_append_child($$, $1);
    ast_append_child($$, ast_alloc_s(IDENTIFIER, $2));
    ast_append_child($$, $3);
  }
 ;


function_definition: typename IDENTIFIER paren_enclosed_args_list function_body {
    $$   = ast_alloc(FUNCTION_DEFINITION);
    ast_append_child($$, $1);
    ast_append_child($$, ast_alloc_s(IDENTIFIER, $2));
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

formal_parameter: typename IDENTIFIER {
    $$ = ast_alloc(DECLARATION);
    ast_append_child($$,$1);
    ast_append_child($$, ast_alloc_s(IDENTIFIER, $2));
  }
 ;

function_body: OPEN_BRACE statements CLOSE_BRACE { $$ = $2; }
 ;

statements: /* nothing */ { $$ = ast_alloc(STATEMENTS); }
 | statements statement { $$ = $1; ast_append_child($$, $2); }
 ;

statement: RETURN expression SEMICOLON { $$ = ast_alloc(RETURN); ast_append_child($$,$2); }
 | declaration SEMICOLON { $$ = $1; }
 | expression SEMICOLON { $$ = $1; }
 | conditional { $$ = $1; }
 | OPEN_BRACE statements CLOSE_BRACE {
    $$ = ast_alloc(OPEN_BRACE);
    ast_append_child($$, $2);
    ast_append_child($$, ast_alloc(CLOSE_BRACE));
  }
 ;

conditional: IF OPEN_PAREN expression CLOSE_PAREN statement {
    $$ = ast_alloc(IF);
    ast_append_child($$, $3);
    ast_append_child($$, $5);
  }
 | IF OPEN_PAREN expression CLOSE_PAREN statement ELSE statement {
    $$ = ast_alloc(IF);
    ast_append_child($$, $3);
    ast_append_child($$, $5);
    abstract_syntax_tree* else_node = ast_alloc(ELSE);
    ast_append_child(else_node, $7);
    ast_append_child($$, else_node);
  }
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
 | IDENTIFIER EQUALS expression {
    $$ = ast_alloc(EQUALS);
    ast_append_child($$, ast_alloc_s(IDENTIFIER, $1));
    ast_append_child($$, $3);
  }
 ;

%%

// int validate_symbols(abstract_syntax_tree* ast, symbol_table* st)
// {
//   ast_nodelist* cur_child = 0;
//   switch(ast->token_type)
//   {
//     case IDENTIFIER:
//       if (st_is_in_scope())
//   }
// }

int build_symbol_table(abstract_syntax_tree* ast, symbol_table* st, int check_declared);

int error_if_undefined(symbol_table* st, const char* symbol)
{
  if (!st_find_symbol(st, symbol))
  {
    char* buf = (char*) malloc(strlen(symbol) + 64);
    sprintf(buf, "use of undefined symbol '%s'", symbol);
    yyerror(buf);
    free(buf);
    return 2;
  }
  return 0;
}

int error_if_defined(symbol_table* st, const char* symbol)
{
  if (st_is_in_scope(st, symbol))
  {
    char* buf = (char*) malloc(strlen(symbol) + 64);
    sprintf(buf, "duplicate declaration '%s'", symbol);
    yyerror(buf);
    free(buf);
    return 1;
  }
  return 0;
}

int handle_children(abstract_syntax_tree* ast, symbol_table* st, int check_declared)
{
  ast_nodelist* cur_child = 0;
  int error               = 0;
  cur_child = ast->children;
  while(cur_child && !error)
  {
    error     = build_symbol_table(cur_child->node, st, check_declared);
    cur_child = cur_child->next;
  }
  return error;
}

int build_symbol_table(abstract_syntax_tree* ast, symbol_table* st, int check_declared)
{
  int error = 0;
  switch(ast->token_type)
  {
  case OPEN_BRACE:
    st_enter_scope(st);
    handle_children(ast, st, check_declared);
    break;
  case CLOSE_BRACE:
    st_print(st);
    st_exit_scope(st);
    handle_children(ast, st, check_declared);
    break;
  case DECLARATION:
    ast = ast_nth_child(ast, 1);
    error = error_if_defined(st, ast->s_val);
    if (error) return error;

    error = build_symbol_table(ast, st, 0);
    if (error) return error;

    ast = ast_nth_child(ast, 2);
    if (ast) error = build_symbol_table(ast, st, 1);
    break;
  case IDENTIFIER:
    if (check_declared)
    {
      error = error_if_undefined(st, ast->s_val);
    }
    else
    {
      st_add_symbol(st, ast->s_val);
    }
    break;
  case FUNCTION_DEFINITION:
    //function name in current scope
    error = build_symbol_table(ast_nth_child(ast, 1), st, 0);
    if (error) return error;
    //enter function scope
    st_enter_scope(st);
    //handle args list
    error = build_symbol_table(ast_nth_child(ast, 2), st, 0);
    if (error) return error;
    //handle body
    error = build_symbol_table(ast_nth_child(ast, 3), st, 1);
    if (error) return error;
    st_print(st);
    //exit function scope
    st_exit_scope(st);
    break;
  default:
    handle_children(ast, st, check_declared);
    break;
  }
  return error;
}

int main(int argc, char** argv)
{
  if (yyparse() == 0)
  {
    ast_print(root);
    symbol_table* st = st_alloc();
    if (build_symbol_table(root, st, 1) == 0)
    {
      st_print(st);
    }
  }
}

int yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
}
