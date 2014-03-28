#include <stdio.h>
#include <signal.h>
#define DELAY 9
void childexit(int);
int main(){
    int newpid;
    void child_code(int, int), parent_code(int);
    regsig();
    printf("Parent pid = %d\n", getpid());
    newpid = fork();
    if(newpid  == -1)
        perror("fork");
    else if(newpid == 0)
        child_code(DELAY, 10);
    else
        parent_code(newpid);
}

void regsig(){
    signal(SIGCHLD, childexit);
}
void childexit(int signum){
    printf("Sad, one of your children die.\n");
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
    int child_staus;
    wait_rv = wait(&child_staus);
    printf("done waiting for %d. Return: %d\n", childpid, wait_rv);
    
    int high_8, low_7, bit_7;
    high_8 = child_staus >> 8;
    low_7 = child_staus & ((1<<6)-1);
    bit_7 = child_staus & (1<<6);
    printf("status: exit=%d, sig=%d, core=%d\n", high_8, low_7, bit_7);
}
