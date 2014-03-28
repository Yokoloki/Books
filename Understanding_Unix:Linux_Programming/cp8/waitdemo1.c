#include <stdio.h>
#define DELAY 2
int main(){
    int newpid;
    void child_code(int, int), parent_code(int);
    printf("Parent pid = %d\n", getpid());
    newpid = fork();
    if(newpid  == -1)
        perror("fork");
    else if(newpid == 0)
        child_code(DELAY, 10);
    else
        parent_code(newpid);
}

void child_code(int delay, int exitcode){
    printf("child %d here, sleep for %dseconds.\n", getpid(), delay);
    sleep(delay);
    printf("exit child node\n");
    exit(exitcode);
}

void parent_code(int childpid){
    sleep(1);
    int wait_rv;
    wait_rv = wait(NULL);
    printf("done waiting for %d. Return: %d\n", childpid, wait_rv);
}
