#include "postgres.h"
#include <string.h>
#include "fmgr.h"

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

extern void blep_(const char *foo, char **bar, int foolen, int *barlen);

#ifndef DEBUG_BUILD

void* _Dmodule_ref;

PG_FUNCTION_INFO_V1(stage19_blep);
Datum stage19_blep(PG_FUNCTION_ARGS) {

    text *foo = PG_GETARG_TEXT_P(0);
    int32 foolen = VARSIZE(foo) - VARHDRSZ;

    char *cfoo = malloc(foolen);
    memcpy(cfoo, VARDATA(foo), foolen);
    cfoo[foolen] = '\0';

    char *rv;
    int rvlen;
    blep_(cfoo, &rv, strlen(cfoo), &rvlen);

    int32 rvsize = rvlen + VARHDRSZ;
    text *prv = (text*)palloc(rvsize);
    SET_VARSIZE(prv, rvsize);
    memcpy(VARDATA(prv), rv, rvlen);
    PG_RETURN_TEXT_P(prv);
}

#endif//DEBUG_BUILD

int main(void) {
    const char *foo = "test";
    char *bar;
    int barlen;
    blep_(foo, &bar, strlen(foo), &barlen);
    printf("[from C] Result: %s\n", bar);
    return 0;
}

