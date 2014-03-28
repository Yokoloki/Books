#include <stdio.h>
#include <termios.h>
#include <fcntl.h>
#include <string.h>

#define ASK "Do you want another transaction?"
#define TRIES 100
#define SLEEPTIME 100000
#define BEEP putchar('\a')

void tty_mode(int);
void set_cr_noecho_mode();
void set_nodelay_mode();
int get_response(char *, int);
char get_ok_char();
int main(){
    int response;
    tty_mode(0);
    set_cr_noecho_mode();
    set_nodelay_mode();
    response = get_response(ASK, TRIES);
    tty_mode(1);
    return response;
}
int get_response(char *question, int maxtries){
    int input;
    printf("%s(y/n)", question);
    fflush(stdout);
    while(1){
        usleep(SLEEPTIME);
        input = tolower(get_ok_char());
        if(input == 'y') return 0;
        if(input == 'n') return 1;
        if(maxtries-- == 0)
            return 2;
        BEEP;
    }
}
char get_ok_char(){
    int c;
    while((c = getchar()) != EOF && strchr("yYnN", c) == NULL);
    return c;
}

void tty_mode(int i){
    static struct termios original_mode;
    static int termflags;
    if(i == 0){
        tcgetattr(0, &original_mode);
        termflags = fcntl(0, F_GETFL);
    }
    else{
        tcsetattr(0, TCSANOW, &original_mode);
        fcntl(0, F_SETFL, termflags);
    }
}

void set_cr_noecho_mode(){
    struct termios state;
    tcgetattr(0, &state);
    state.c_lflag &= ~ICANON;
    state.c_lflag &= ~ECHO;
    state.c_cc[VMIN] = 1;
    tcsetattr(0, TCSANOW, &state);
}

void set_nodelay_mode(){
    int termflags;
    termflags = fcntl(0, F_GETFL);
    termflags |= O_NDELAY;
    fcntl(0, F_SETFL, termflags);
}
