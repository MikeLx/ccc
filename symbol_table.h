#include <string.h>

typedef struct symbol
{
  const char* identifier;
} symbol;

typedef struct scope
{
  symbol* symbols;
  size_t  n_symbols;
  size_t  symbols_capacity;
} scope;

typedef struct scope_node
{
  struct scope_node* prev;
  struct scope_node* next;
  scope*             val;
} scope_node;

typedef struct symbol_table
{
  scope_node* scopes;
  scope_node* current_scope;
} symbol_table;

symbol_table* st_alloc      ();
void          st_free       (symbol_table* st);
void          st_enter_scope(symbol_table* st);
void          st_exit_scope (symbol_table* st);
int           st_is_in_scope(symbol_table* st, const char* id);
symbol*       st_find_symbol(symbol_table* st, const char* id);
void          st_add_symbol (symbol_table* st, const char* id);
void          st_print      (symbol_table* st);
