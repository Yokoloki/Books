#include <stdio.h>
#include <termios.h>

int main(){
    struct termios info;
    int rv = tcgetattr(0, &info);
    if(rv == -1){
        perror("tcgetattr");
        exit(1);
    }
    info.c_lflag &= ~ECHO;
    rv = tcsetattr(0, TCSANOW, &info);
    if(rv == -1){
        perror("tcsetattr");
        exit(1);
    }
    char str[100];
    printf("Please input the string: ");
    scanf("%s", str);
    printf("Already scaned.\n");
    printf("Your input is %s\n", str);
}
