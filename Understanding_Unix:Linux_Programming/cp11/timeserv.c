#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <time.h>
#include <string.h>

#define PORT 13000
#define HOSTLEN 256
#define oops(msg){ perror(msg); exit(1);}

int main(int ac, char *av[]){
    struct sockaddr_in saddr;
    struct hostent *hp;
    char hostname[HOSTLEN];
    int sock_id, sock_fd;
    FILE *sock_fp;
    char *ctime();
    time_t thetime;
    //Step 1.
    //    Ask the kernal for an available socket id
    sock_id = socket(PF_INET, SOCK_STREAM, 0);
    if(sock_id == -1) oops("socket");
    //init
    bzero((void*)&saddr, sizeof(saddr));
    gethostname(hostname, HOSTLEN);
    hp = gethostbyname("172.18.216.111");
    printf("addr = %d, len = %d\n", hp->h_addr_list[0], hp->h_length);
    bcopy((void*)hp->h_addr, (void*)&saddr.sin_addr, hp->h_length);
    saddr.sin_port = htons(PORT);
    saddr.sin_family = AF_INET;
    //Setp 2.
    //    Bind the socket id with addresses
    if(bind(sock_id, (struct sockaddr *)&saddr, sizeof(saddr)) != 0)
        oops("bind");
    //Step 3.
    //    Listen on that socket
    if(listen(sock_id, 1) != 0) oops("listen");

    while(1){
        //Step 4.
        //    Accept a connection
        sock_fd = accept(sock_id, NULL, NULL);
        printf("Got a connection\n");
        if(sock_fd == -1) oops("accept");
        sock_fp = fdopen(sock_fd, "w");
        if(sock_fp == NULL) oops("fdopen");
        thetime = time(NULL);
        fprintf(sock_fp, "The time here is %s", ctime(&thetime));
        fclose(sock_fp);
    }
}
