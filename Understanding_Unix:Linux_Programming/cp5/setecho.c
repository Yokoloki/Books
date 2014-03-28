#include <stdio.h>
#include <termios.h>

void oops(char *, int);
int main(int ac, char *av[]){
    struct termios info;
    if(ac == 1) exit(0);
    if(tcgetattr(0, &info) == -1)
        oops("tcgetattr", 1);
    if(av[1][0] == 'y')
        info.c_lflag |= ECHO;
    else
        info.c_lflag &= ~ECHO;
    if(tcsetattr(0, TCSANOW, &info) == -1)
        oops("tcsetattr", 2);
}

void oops(char *str, int i){
    fprintf(stderr, "%s return %d", str, i);
    exit(1);
}
