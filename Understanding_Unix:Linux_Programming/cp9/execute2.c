#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>

int execute(char *argv[]){
    int pid;
    int child_info = -1;
    if(argv[0] == NULL) return 0;
    pid = fork();
    if(pid == -1){
        perror("fork");
    }
    else if(pid == 0){
        environ = VLtable2environ();
        signal(SIGINT, SIG_DFL);
        signal(SIGQUIT, SIG_DFL);
        execvp(argv[0], argv);
        fprintf(stderr, "cannot execute command %s\n", argv[0]);
        exit(1);
    }
    else{
        if(wait(&child_info) == -1)
            perror("wait");
        return child_info;
    }
}
