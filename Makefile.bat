bison -dy hack_assembler.y
flex hack_assembler.lex
gcc y.tab.c lex.yy.c -o hack_assembler