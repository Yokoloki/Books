#include <stdio.h>
#include <fcntl.h>

int main(){
    int fd;
    int newfd;
    char line[100];
    fgets(line, 100, stdin); printf("%s\n", line);
    fgets(line, 100, stdin); printf("%s\n", line);
    fgets(line, 100, stdin); printf("%s\n", line);
    fd = open("/etc/hosts", O_RDONLY);
    close(0);
    newfd = dup(fd);
    close(fd);
    if(newfd != 0){
        fprintf(stderr, "Cannot duplicate fd to 0\n");
        exit(1);
    }

    fgets(line, 100, stdin); printf("%s\n", line);
    fgets(line, 100, stdin); printf("%s\n", line);
    fgets(line, 100, stdin); printf("%s\n", line);
}
