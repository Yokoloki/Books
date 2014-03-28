#include <stdio.h>

int main(){
    int ret_from_fork;
    printf("Before fork, pid = %d\n", getpid());
    ret_from_fork = fork();
    sleep(1);
    printf("After fork, my pid = %d, return from fork = %d\n", getpid(), ret_from_fork);
    return 0;
}
