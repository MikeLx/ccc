#include "c_language.tab.h"

typedef struct abstract_syntax_tree abstract_syntax_tree;
typedef struct ast_nodelist         ast_nodelist;
struct ast_nodelist
{
  abstract_syntax_tree * node;
  ast_nodelist * next;
};

struct abstract_syntax_tree
{
  int           token_type;
  char*         s_val;
  int           i_val;
  ast_nodelist* children;
};


abstract_syntax_tree* ast_alloc(int token_type);

void ast_append_child(abstract_syntax_tree* ast, abstract_syntax_tree* child);

abstract_syntax_tree* ast_nth_child(abstract_syntax_tree* ast, size_t n);

void ast_free(abstract_syntax_tree* ast);
void ast_print(abstract_syntax_tree* ast);
