#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <time.h>
#include <string.h>

#define PORT 15000
#define HOSTLEN 256
#define oops(msg){ perror(msg); exit(1);}

int main(int ac, char *av[]){
    struct sockaddr_in saddr;
    struct hostent *hp;
    char hostname[HOSTLEN];
    int sock_id, sock_fd;
    FILE *sock_fpi, *sock_fpo;
    FILE *pipe_fp;
    char dirname[BUFSIZ];
    char cmd[BUFSIZ];
    int dirlen, c;

    sock_id = socket(PF_INET, SOCK_STREAM, 0);
    if(sock_id == -1) oops("socket");

    bzero((void*)&saddr, sizeof(saddr));
    gethostname(hostname, HOSTLEN);
    hp = gethostbyname("172.18.216.111");
    bcopy((void*)hp->h_addr, (struct sockaddr *)&saddr, hp->h_length);
    saddr.sin_port = htons(PORT);
    saddr.sin_family = AF_INET;
    if(bind(sock_id, (struct sockaddr *)&saddr, sizeof(saddr)) != 0) oops("bind");
    if(listen(sock_id, 1) != 0) oops("listen");
    while(1){
        sock_fd = accept(sock_id, NULL, NULL);
        if(sock_fd == -1) oops("accept");
        if((sock_fpi = fdopen(sock_fd, "r")) == NULL) oops("fdopen reading");
        if((sock_fpo = fdopen(sock_fd, "w")) == NULL) oops("fdopen writing");
        if(fgets(dirname, BUFSIZ-5, sock_fpi) == NULL) oops("reading dirname");
        sanitize(dirname);
        sprintf(cmd, "ls %s", dirname);
        if((pipe_fp = popen(cmd, "r")) == NULL) oops("popen");
        while((c = getc(pipe_fp)) != EOF)
            putc(c, sock_fpo);
        pclose(pipe_fp);
        fclose(sock_fpo);
        fclose(sock_fpi);
    }
}

void sanitize(char *str){
    while(*str == '/' || isalnum(*str))
            str++;
    *str = '\0';
}
