
#include <EXTERN.h>
#include <perl.h>

static char *do_call(PerlInterpreter *my_perl, char *foo) {
    dSP;                            /* initialize stack pointer */
    ENTER;                          /* everything created after here */
    SAVETMPS;                       /* ...is a temporary variable. */
    PUSHMARK(SP);                   /* remember the stack pointer */
    XPUSHs(sv_2mortal(Perl_newSVpv(my_perl, foo, strlen(foo)))); /* push foo onto the stack  */
    PUTBACK;                        /* make local stack pointer global */
    call_pv("blep", G_SCALAR);      /* call blep */
    SPAGAIN;                        /* refresh stack pointer */
    SV  *svp = POPs;                /* pop the return value from stack */
    char *rv = strdup(SvPVx_nolen(svp));
    PUTBACK;
    FREETMPS;                       /* free that return value */
    LEAVE;                          /* ...and the XPUSHed "mortal" args. */
    return rv;
}

/* see https://www.xav.com/perl/lib/Pod/perlembed.html */
EXTERN_C void boot_DynaLoader (pTHX_ CV* cv);
static void xs_init(pTHX) {
    char *file = __FILE__;
    /* DynaLoader is a special case */
    newXS("DynaLoader::boot_DynaLoader", boot_DynaLoader, file);
}

char *stage8h_blep(char *foo) {
    printf("Stage 8.5: %s\n", foo);
    PerlInterpreter *my_perl; /* NOTE: Due to shitty programming, this variable *must* have this name. Fuck Perl. */

     int   argc1   =  0;
    char **argv1   =  NULL;
    char  *argv2[] = {(char*)"", (char*)"stage9.pl"}; /* peeeerl */

    PERL_SYS_INIT(&argc1, &argv1);
    my_perl = perl_alloc();
    perl_construct(my_perl);

    perl_parse(my_perl, xs_init, 2, argv2, (char **)NULL);
    PL_exit_flags |= PERL_EXIT_DESTRUCT_END;
    perl_run(my_perl);

    char *rv = do_call(my_perl, foo);

    perl_destruct(my_perl);
    perl_free(my_perl);
    PERL_SYS_TERM();

    printf("Return value[8.5]: %s\n", rv);
    return rv;
}

int main(int argc, char **argv) {
    if (argc < 2)
        return 1;
    printf("%s\n", stage8h_blep(argv[1]));
    return 0;
}
