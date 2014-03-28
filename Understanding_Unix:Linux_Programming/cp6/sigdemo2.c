#include <stdio.h>
#include <signal.h>

int main(){
    int i;
    signal(SIGINT, SIG_IGN);
    for(i=0; i<5; i++){
        printf("hello %d\n", i);
        sleep(2);
    }
}
