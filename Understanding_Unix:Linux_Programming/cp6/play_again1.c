#include <stdio.h>
#include <termios.h>

#define QUESTION "Do you want another transaction?"
void tty_mode(int);
void set_crmode();
int get_response(char *);
int main(){
    int response;
    tty_mode(0);
    set_crmode();
    response = get_response(QUESTION);
    tty_mode(1);
    return response;
}
int get_response(char *question){
    printf("%s(y/n)", question);
    while(1){
        switch(getchar()){
            case 'y':
            case 'Y': return 0;
            case 'n':
            case 'N':
            case EOF: return 1;
            default:
                printf("\nUnknown input, please try again(y/n):");
        }
    }
}
void tty_mode(int i){
    static struct termios original_mode;
    if(i == 0)
        tcgetattr(0, &original_mode);
    else
        tcsetattr(0, TCSANOW, &original_mode);
}

void set_crmode(){
    struct termios state;
    tcgetattr(0, &state);
    state.c_lflag &= ~ICANON;
    state.c_cc[VMIN] = 1;
    tcsetattr(0, TCSANOW, &state);
}
