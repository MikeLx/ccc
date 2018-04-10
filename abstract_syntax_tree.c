#include "abstract_syntax_tree.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

const char* token_to_string(int token_type)
{
  switch(token_type)
  {
  case INT:
    return "INT";
  case CHAR:
    return "CHAR";
  case ASTERISK:
    return "ASTERISK";
  case OPEN_PAREN:
    return "OPEN_PAREN";
  case CLOSE_PAREN:
    return "CLOSE_PAREN";
  case OPEN_BRACE:
    return "OPEN_BRACE";
  case CLOSE_BRACE:
    return "CLOSE_BRACE";
  case COMMA:
    return "COMMA";
  case RETURN:
    return "RETURN";
  case SEMICOLON:
    return "SEMICOLON";
  case PLUS:
    return "PLUS";
  case INTEGER_CONSTANT:
    return "INTEGER_CONSTANT";
  case IDENTIFIER:
    return "IDENTIFIER";
  case FUNCTION:
    return "FUNCTION";
  case ARGS_LIST:
    return "ARGS_LIST";
  case STATEMENTS:
    return "STATEMENTS";
  default:
    return "unknown token";
  }
}

abstract_syntax_tree* ast_alloc
(
  int token_type
)
{
  abstract_syntax_tree* ast = (abstract_syntax_tree*) malloc(sizeof(abstract_syntax_tree));
  ast->token_type           = token_type;
  ast->children             = 0;
  ast->s_val                = 0;
  return ast;
}

void ast_append_child(abstract_syntax_tree* ast, abstract_syntax_tree* child)
{
  ast_nodelist * list = (ast_nodelist*) malloc(sizeof(ast_nodelist));
  list->node = child;
  list->next = 0;
  if (ast->children)
  {
    ast_nodelist * tail = ast->children;
    while(tail->next)
    {
      tail = tail->next;
    }
    tail->next = list;
  }
  else
  {
    ast->children = list;
  }
}

abstract_syntax_tree* ast_nth_child(abstract_syntax_tree* ast, size_t n)
{
  ast_nodelist* list = ast->children;
  if (list)
  {
    size_t i = 0;
    while(i < n && list)
    {
      list = list->next;
      ++i;
    }
  }
  return list;
}

void ast_free(abstract_syntax_tree* ast)
{
  if (ast->children)
  {
    ast_nodelist * cur = ast->children;
    do 
    {
      ast_free(cur->node);
      ast_nodelist * next = cur->next;
      free(cur);
      cur = next;
    } while(cur);
  }
  ast->children = 0;
  free(ast);
}

char* _extra_stuff(abstract_syntax_tree* ast)
{
  char* ret;
  switch(ast->token_type)
  {
  case INTEGER_CONSTANT:
    ret = malloc(32);
    sprintf(ret, "(%d)", ast->i_val);
    break;
  case IDENTIFIER:
    ret = (char*) malloc(strlen(ast->s_val) + 3);
    sprintf(ret, "(%s)", ast->s_val);
    break;
  default:
    ret = (char*) calloc(1, 0);
  }
  return ret;
}

void _ast_print(abstract_syntax_tree* ast, int indent)
{
  char* padding = (char*) calloc(indent + 1, 0);
  for (int i = 0; i < indent; i++)
  {
    padding[i] = ' ';
  }
  const char* tok_str = token_to_string(ast->token_type);
  char* extra_stuff   = _extra_stuff(ast);
  printf("%s%s%s\n", padding, tok_str, extra_stuff);
  free(padding);
  free(extra_stuff);
  if (ast->children)
  {
    ast_nodelist * cur = ast->children;
    do
    {
      _ast_print(cur->node, indent + 2);
      cur = cur->next;
    } while(cur);
  }
}

void ast_print(abstract_syntax_tree* ast)
{
  _ast_print(ast, 0);
}
