#include <stdio.h>
#include <signal.h>
int main(){
    void wakeup(int);
    printf("sleep for 4s\n");
    signal(SIGALRM, wakeup);
    alarm(4);
    pause();
    printf("= =...\n");
}

void wakeup(int signum){
    printf("Receive alarm from kernel!\n");
}
