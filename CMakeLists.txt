cmake_minimum_required(VERSION 2.8)

project(ccc)

add_custom_command(
  OUTPUT "c_language.tab.c" "c_language.tab.h"
  COMMAND bison -d c_language.y
  DEPENDS "c_language.y"
  COMMENT "Generating parser with bison..."
)

add_custom_command(
  OUTPUT "lex.yy.c"
  COMMAND flex -B c_language.l
  DEPENDS "c_language.tab.h" "c_language.l"
  COMMENT "Generating lexer with flex..."
)

set_source_files_properties(
  "lex.yy.c" "c_language.tab.c"
  PROPERTIES GENERATED TRUE
)

add_executable(ccc "abstract_syntax_tree.c" "symbol_table.c" "c_language.tab.c" "lex.yy.c")

target_link_libraries(ccc  "fl")
