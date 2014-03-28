#include <stdio.h>

int main(){
    int fork_rv;
    printf("Before fork, pid = %d\n", getpid());
    fork_rv = fork();
    if(fork_rv == -1)
        perror("fork");
    else if(fork_rv == 0)
        printf("I'm the child, pid = %d\n", getpid());
    else
        printf("I'm the father, pid = %d\n", getpid());
}
