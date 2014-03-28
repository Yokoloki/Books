#include <stdio.h>

int main(int ac, char *av[]){
    if(ac != 3){
        fprintf(stderr, "Usage: %s source dest", *av);
        exit(1);
    }
    int thepipe[2], newfd, pid;
    if(pipe(thepipe) == -1){
        fprintf(stderr, "Cannot open a pipe");
        exit(1);
    }
    if((pid = fork()) == -1){
        fprintf(stderr, "fork");
        exit(1);
    }
    if(pid == 0){
        close(thepipe[0]);
        if(dup2(thepipe[1], 1) == -1){
            fprintf(stderr, "child dup2");
            exit(1);
        }
        close(thepipe[1]);
        fprintf(stderr, "parent exec %s\n", av[1]);
        execlp(av[1], av[1], NULL);
        fprintf(stderr, "child execlp");
        exit(1);
    }
    else{
        close(thepipe[1]);
        if(dup2(thepipe[0], 0) == -1){
            fprintf(stderr, "parent dup2");
            exit(1);
        }
        close(thepipe[0]);
        fprintf(stderr, "child exec %s\n", av[2]);
        execlp(av[2], av[2], NULL);
        fprintf(stderr, "parent execlp");
        exit(1);
    }
}
