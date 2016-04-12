/*
 * invoke like this: env LD_LIBRARY_PATH=. ./fromctogo test
 */
#include <stdio.h>

extern char *blep(char *foo);

int main(int argc, char **argv) {
    if (argc != 2)
        return 2;
    char *foo = argv[1];

    printf("C starting: %s\n", foo);
    char *bar = blep(foo);
    printf("C done: %s\n", bar);
    return 0;
}
