#include <stdio.h>

int main(){
    printf("Mypid = %d\n", getpid());
    fork();
    fork();
    printf("Now my pid = %d\n", getpid());
}
