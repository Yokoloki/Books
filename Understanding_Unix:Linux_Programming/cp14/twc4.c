#include <stdio.h>
#include <pthread.h>
#include <ctype.h>

struct arg_set{
    char *fname;
    int count;
};

struct arg_set *mail_box;
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t flag = PTHREAD_COND_INITIALIZER;

int main(int ac, char *av[]){
    pthread_t t1, t2;
    struct arg_set args1, args2;
    void *count_word(void*);
    int reports_in = 0;
    int total_words = 0;
    if(ac != 3){
        fprintf(stderr, "usage: %s file1 file2\n", av[0]);
        exit(1);
    }
    pthread_mutex_lock(&lock);
    args1.fname = av[1];
    args1.count = 0;
    pthread_create(&t1, NULL, count_word, (void*)&args1);
    args2.fname = av[2];
    args2.count = 0;
    pthread_create(&t2, NULL, count_word, (void*)&args2);
    while(reports_in < 2){
        printf("MAIN: waiting for flag to go up\n");
        pthread_cond_wait(&flag, &lock);
        printf("MAIN: got the lock\n");
        printf("%7d %s\n", mail_box->count, mail_box->fname);
        total_words += mail_box->count;
        if(mail_box == &args1)
            pthread_join(t1, NULL);
        if(mail_box == &args2)
            pthread_join(t2, NULL);
        mail_box = NULL;
        pthread_cond_signal(&flag);
        reports_in++;
    }
    printf("%7d total words\n", total_words);
}

void *count_word(void *m){
    struct arg_set *args = (struct arg_set *)m;
    FILE *fp;
    int c, prevc = '\0';
    if((fp = fopen(args->fname, "r")) != NULL){
        while((c = getc(fp)) != EOF){
            if(!isalnum(c) && isalnum(prevc))
                args->count++;
            prevc = c;
        }
        fclose(fp);
    }else
        perror(args->fname);
    printf("COUNT %s: waiting to get lock\n", args->fname);
    pthread_mutex_lock(&lock);
    printf("COUNT %s: got the lock\n", args->fname);
    mail_box = args;
    printf("COUNT %s: raise the flag\n", args->fname);
    pthread_cond_signal(&flag);
    printf("COUNT %s: unlocking box\n", args->fname);
    pthread_mutex_unlock(&lock);
    return NULL;
}
