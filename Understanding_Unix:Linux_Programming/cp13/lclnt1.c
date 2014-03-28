#include <stdio.h>
int main(int ac, char *av[]){
    setup();
    if(get_ticket() != 0) exit(0);
    do_regular_work();
    release_ticket();
    shut_down();
}

void do_regular_work(){
    printf("Sleeping for 10s\n");
    sleep(10);
}
