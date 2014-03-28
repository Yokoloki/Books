#include <stdio.h>
#include <unistd.h>

int main(){
    int len, i, apipe[2];
    char buf[BUFSIZ];
    if(pipe(apipe) == -1){
        perror("cannot make pipe");
        exit(1);
    }
    printf("Got a pipe, [%d] -> [%d]\n", apipe[1], apipe[0]);
    while(fgets(buf, BUFSIZ, stdin)){
        len = strlen(buf);
        if(write(apipe[1], buf, len) != len){
            perror("writing to pipe");
            exit(1);
        }
        for(i=0; i<len; i++) buf[i] = 'X';
        len = read(apipe[0], buf, BUFSIZ);
        if(len == -1){
            perror("Reading from pipe");
            exit(1);
        }
        if(write(1, buf, len) != len){
            perror("Writing to stdout");
            exit(1);
        }
    }
}
