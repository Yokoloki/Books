#include <stdio.h>
extern char **environ;
int main(){
    char *table[3];
    table[0] = "TERM1=111";
    table[1] = "HOME1=/test/test";
    table[2] = 0;
    environ = table;
    execlp("env", "env", NULL);
}
