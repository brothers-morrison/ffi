#include <string.h>
#include <stdio.h>

extern void blep_(const char *foo, char **bar, int foolen, int *barlen);

#ifndef DEBUG_BUILD
#include "postgres.h"
#include "fmgr.h"

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

void* _Dmodule_ref;

PG_FUNCTION_INFO_V1(stage19_blep);
Datum stage19_blep(PG_FUNCTION_ARGS) {

    text *foo = PG_GETARG_TEXT_P(0);
    int32 foolen = VARSIZE(foo) - VARHDRSZ;

    char *cfoo = malloc(foolen);
    memcpy(cfoo, VARDATA(foo), foolen);
    cfoo[foolen] = '\0';

    char *orv;
    int rvlen;
    //fprintf(stderr, "Stage 18.5: %s\n", cfoo);
    blep_(cfoo, &orv, strlen(cfoo), &rvlen);
    //crv[rvlen] = 0;
    //fprintf(stderr, "Return value [18.5]: %s\n", crv);
    //char *rv = malloc(128);
    //rvlen = snprintf(rv, 128, "rv: <%d | %p> %s", rvlen, orv, strndup(orv, rvlen));
    munmap(orv, rvlen);

    int32 rvsize = rvlen + VARHDRSZ;
    text *prv = (text*)palloc(rvsize);
    SET_VARSIZE(prv, rvsize);
    memcpy(VARDATA(prv), orv, rvlen);
    PG_RETURN_TEXT_P(prv);
}

#endif//DEBUG_BUILD

int main(void) {
    const char *foo = "test";
    char *bar;
    int barlen;
    blep_(foo, &bar, strlen(foo), &barlen);
    printf("fortran res: %p %zu\n", bar, barlen);
    char *out = strndup(bar, barlen);
    munmap(bar, barlen);
    printf("[from C] Result (%d): \"%s\"\n", barlen, bar);
    return 0;
}

