#include <stdio.h>
#include <signal.h>

int main(){
    void f(int);
    int i;
    signal(SIGINT, f);
    for(i=0; i<5; i++){
        printf("hello %d\n", i);
        sleep(2);
    }
}
void f(int signum){
    printf("OUCH! ..%d..\n", signum);
}
