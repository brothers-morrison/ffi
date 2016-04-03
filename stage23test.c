#include <stdio.h>

extern const char *stage24_blep(char *foo);

int main(int argc, char **argv) {
    if (argc != 2)
        return 1;
    char *foo = argv[1];
    printf("Stage 23(test): %s\n", foo);
    const char *bar = stage24_blep(foo);
    printf("Return value [23(test)]: %s\n", bar);
    return 0;
}
