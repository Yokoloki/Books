#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define oops(m, x){ perror(m); exit(x);}
int make_dgram_client_socket();
int make_internet_address(char *, int, struct sockaddr_in *);

int main(int ac, char *av[]){
    int sock;
    char *msg;
    struct sockaddr_in saddr;
    char buf[BUFSIZ];
    int saddrlen, msglen;
    if(ac != 4){
        fprintf(stderr, "usage: %s host port 'message'\n", av[0]);
        exit(1);
    }
    msg = av[3];
    if((sock = make_dgram_client_socket()) == -1)
        oops("cannot make socket", 2);
    make_internet_address(av[1], atoi(av[2]), &saddr);
    if(sendto(sock, msg, strlen(msg), 0, &saddr, sizeof(saddr)) == -1)
        oops("sendto failed", 3);
    if((msglen = recvfrom(sock, buf, BUFSIZ, 0, &saddr, &saddrlen)) > 0){
        buf[msglen] = '\0';
        printf("dgsend: got a message %s\n", buf);
        say_who_called(&saddr);
    }
    return 0;
}

void say_who_called(struct sockaddr_in *addrp){
    char host[BUFSIZ];
    int port;
    get_internet_address(host, BUFSIZ, &port, addrp);
    printf(" from: %s:%d\n", host, port);
}
