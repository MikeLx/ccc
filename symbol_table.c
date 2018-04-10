#include "symbol_table.h"

#include <stdlib.h>
#include <stdio.h>

scope* scope_alloc()
{
  scope* ret            = (scope*) malloc(sizeof(scope));
  ret->symbols          = (symbol*) malloc(sizeof(symbol));
  ret->n_symbols        = 0;
  ret->symbols_capacity = 1;
  return ret;
}

void scope_free(scope* s)
{
  free(s->symbols);
  free(s);
}

void scope_reserve(scope* s, size_t n)
{
  if (s->symbols_capacity >= n)
  {
    return;
  }
  else
  {
    s->symbols = realloc(s->symbols, sizeof(symbol) * n);
  }
}

void scope_append(scope* s, symbol sym)
{
  if (s->symbols_capacity <= s->n_symbols)
  {
    scope_reserve(s, s->n_symbols + 1);
  }
  s->symbols[s->n_symbols++] = sym;
}

scope_node* scope_node_alloc()
{
  scope_node* ret = (scope_node*) malloc(sizeof(scope_node));
  ret->val         = scope_alloc();
  ret->next        = 0;
  ret->prev        = 0;
  return ret;
}

void scope_node_free(scope_node* sn)
{
  scope_free(sn->val);
  free(sn);
}

symbol_table* st_alloc()
{
  symbol_table* ret = (symbol_table*) malloc(sizeof(symbol_table));
  ret->scopes        = scope_node_alloc();
  ret->current_scope = ret->scopes;
  return ret;
}

void st_free(symbol_table* st)
{

}

void st_enter_scope(symbol_table* st)
{
  scope_node* new_scope = scope_node_alloc();
  new_scope->prev = st->current_scope;
  new_scope->prev->next = new_scope;
  st->current_scope = new_scope;
}

void st_exit_scope (symbol_table* st)
{
  scope_node* old_scope = st->current_scope->prev;
  old_scope->next = 0;
  scope_node_free(st->current_scope);
  st->current_scope = old_scope;
}

int st_is_in_scope(symbol_table* st, const char* id)
{
  scope* cur = st->current_scope->val;
  for (size_t i = 0; i < cur->n_symbols; i++)
  {
    if (strcmp(cur->symbols[i].identifier, id) == 0)
    {
      return 1;
    }
  }
  return 0;
}

symbol* st_find_symbol(symbol_table* st, const char* id)
{
  scope_node* cur_node = st->current_scope;
  while (cur_node)
  {
    scope* cur_scope = cur_node->val;
    for (size_t i = 0; i < cur_scope->n_symbols; i++)
    {
      if (strcmp(cur_scope->symbols[i].identifier, id) == 0)
      {
        return cur_scope->symbols + i;
      }
    }
    cur_node = cur_node->prev;
  }
  return 0;
}

void st_add_symbol(symbol_table* st, const char* id)
{
  symbol sym;
  sym.identifier = id;
  scope_append(st->current_scope->val, sym);
}

void scope_print(scope* s)
{
  for (size_t i = 0; i < s->n_symbols; i++)
  {
    printf("%s\n", s->symbols[i].identifier);
  }
}

void st_print(symbol_table* st)
{
  scope_node* cur_node = st->current_scope;
  while(cur_node)
  {
    scope_print(cur_node->val);
    printf("\n");
    cur_node = cur_node->prev;
  }
}
