#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>

#define SOCKET "/tmp/logfilesock"
#define oops(m, x){ perror(m); exit(x);}

int main(int ac, char *av[]){
    if(ac != 2){
        fprintf(stderr, "usage: %s message\n", av[0]);
        exit(1);
    }
    int sock;
    struct sockaddr_un addr;
    socklen_t addrlen;
    char sockname[] = SOCKET;
    char *msg = av[1];
    sock = socket(PF_UNIX, SOCK_DGRAM, 0);
    if(sock == -1) oops("sock", 1);
    addr.sun_family = PF_UNIX;
    strcpy(addr.sun_path, sockname);
    addrlen = strlen(sockname) + sizeof(addr.sun_family);
    if(sendto(sock, msg, strlen(msg), 0, &addr, addrlen) == -1)
        oops("sendto", 3);
}
