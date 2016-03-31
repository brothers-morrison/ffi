
#include <octave/oct.h>
#include <dlfcn.h>
#include <signal.h>
#include <libpq-fe.h>
#include <unistd.h>

/* generic postgres stuff is here */

typedef struct {
    void *pq;
} stage17_ctx_t;

static int pgpid = 0;

void kill_pgpid() {
    if (pgpid) {
        int pid = pgpid;
        pgpid = 0;
        kill(pid, SIGINT);
    }
}

void stage17_close(stage17_ctx_t *ctx) {
    if (!ctx)
        return;
    kill_pgpid();
    if (ctx->pq)
        dlclose(ctx->pq);
    free(ctx);
}

stage17_ctx_t *stage17_init() {
    stage17_ctx_t *ctx = (stage17_ctx_t *)calloc(1, sizeof(stage17_ctx_t));
    if (!ctx)
        goto errout;

    if (!pgpid) {
        pgpid = fork();
        atexit(kill_pgpid);
        if (!pgpid) {
            execl("/usr/local/pgsql/bin/postgres", "/usr/local/pgsql/bin/postgres", "-D", "/tmp/testdb", "-c", "log_min_messages=PANIC", (char *)NULL);
        }
    }

    ctx->pq = dlopen("/usr/local/pgsql/lib/libpq.so", RTLD_NOW | RTLD_LOCAL);
    if (!ctx->pq)
        goto errout;

    return ctx;
errout:
    stage17_close(ctx);
    return NULL;
}

#define CONNECT_TIMEOUT     10000000u /* us */
#define CONNECT_POLL_IVL    500000 /* us */

PGconn* stage17_connect(stage17_ctx_t *ctx) {
    typedef PGPing  (*PQpingParams_t)   (const char **, const char **, int);
    typedef PGconn *(*PQconnectParams_t)(const char **, const char **, int);
    PQpingParams_t      PQpingParams        = (PQpingParams_t)              dlsym(ctx->pq, "PQpingParams");
    PQconnectParams_t   PQconnectParams     = (PQconnectParams_t)           dlsym(ctx->pq, "PQconnectdb");
    int     (*PQstatus)     (PGconn *)      = (int (*)(PGconn *))           dlsym(ctx->pq, "PQstatus");
    void    (*PQfinish)     (PGconn *)      = (void (*)(PGconn *))          dlsym(ctx->pq, "PQfinish");
    if (!PQpingParams || !PQconnectParams || !PQstatus || !PQfinish)
        return NULL;

    const char *kwds[] = { NULL };
    const char *vals[] = { NULL};
    for (unsigned int i=0; i < CONNECT_TIMEOUT/CONNECT_POLL_IVL; i++) {
        usleep(CONNECT_POLL_IVL);
        if ((*PQpingParams)(kwds, vals, 0) == PQPING_OK)
            break;
    }

    PGconn *conn = (*PQconnectParams)(kwds, vals, 0);

    if ((*PQstatus)(conn) == CONNECTION_OK)
        return conn;

    (*PQfinish)(conn);
    return NULL;
}

void stage17_disconnect(stage17_ctx_t *ctx, PGconn *conn) {
    void (*PQfinish)(PGconn *) = (void (*)(PGconn *)) dlsym(ctx->pq, "PQfinish");
    if (!PQfinish)
        return;
    (*PQfinish)(conn);
}

const char *stage17_doexec(stage17_ctx_t *ctx, PGconn *conn, const char *fname, const char *arg) {
    typedef PGresult *(*PQexecParams_t)(PGconn *, const char*, int, const Oid *, const char * const *, const int *, const int *, int);
    PQexecParams_t PQexecParams                             =               (PQexecParams_t)              dlsym(ctx->pq, "PQexecParams");
    int         (*PQresultStatus)(PGresult *)               = (int       (*)(PGresult *))                   dlsym(ctx->pq, "PQresultStatus");
    int         (*PQnfields)(const PGresult *)              = (int       (*)(const PGresult *))             dlsym(ctx->pq, "PQnfields");
    int         (*PQntuples)(const PGresult *)              = (int       (*)(const PGresult *))             dlsym(ctx->pq, "PQntuples");
    char       *(*PQgetvalue)(const PGresult *, int, int)   = (char     *(*)(const PGresult *, int, int))   dlsym(ctx->pq, "PQgetvalue");
    void        (*PQclear)(PGresult *)                      = (void      (*)(PGresult *))                   dlsym(ctx->pq, "PQclear");
    char       *(*PQresultErrorField)(const PGresult *, int)= (char     *(*)(const PGresult *, int))        dlsym(ctx->pq, "PQresultErrorField");

    if (!PQexecParams || !PQresultStatus || !PQnfields || !PQntuples || !PQgetvalue || !PQclear || !PQresultErrorMessage)
        return "[Stage17helper: cannot look up postgres api funcs]";

    char invocation[64];
    if (snprintf(invocation, sizeof(invocation), "SELECT %s($1::text);", fname) > sizeof(invocation))
        return "[Stage17helper: function name too long]";
/*    printf("Stage17helper: Sending query \"%s\"\n", invocation); */

    const char * const vals[] = { arg };
    const int          lens[] = { 0 /* ignored for 'text' posgres type */ };
    const int          fmts[] = { 0 };
    PGresult *res = (*PQexecParams)(conn, invocation, 1, NULL, vals, lens, fmts, 0/*binary result format*/);

    int status = (*PQresultStatus)(res);
    if (status != PGRES_TUPLES_OK) {
        printf("Stage17Helper: postgres-side exec problem: %s (%d)\n", PQresultErrorField(res, PG_DIAG_MESSAGE_PRIMARY), status);
        return "[Stage17Helper: postgres-side exec problem]";
    }

    if ((*PQnfields)(res) != 1 || (*PQntuples)(res) != 1)
        return "[Stage17Helper: misshaped SQL func return val]";

    const char *rv = strdup((*PQgetvalue)(res, 0/*tup*/, 0/*field*/));

    (*PQclear)(res);

    return rv;
}

/* octave bindings start here */
/* note that this makes some older octaves (read: the one that comes with debian) loose shit and start fucking up the
 * heap. thus, I run this with an octave build and installed from-source on the demo system. */
static stage17_ctx_t *s17_ctx = NULL;

/* test stuff
int main(void) {

    s17_ctx = stage17_init();
    PGconn* conn = stage17_connect(s17_ctx);
    const char *rv = stage17_doexec(s17_ctx, conn, "blep", "test");
    printf("result: %s\n", rv);
    stage17_disconnect(s17_ctx, conn);
    return 0;
}
*/

DEFUN_DLD (stage17_makecall, args, nargout, "Frob.") {
    octave_value_list orv(1);

    int nargin = args.length();
    if (nargin != 2) {
        print_usage();
        orv(octave_idx_type(0)) = octave_value("[Stage17helper: y u no right args]");
        return orv;
    }

    char *cfun = strdup(args(0).string_value().c_str()); /* omitting type checking here because I'm lazy. */
    char *carg = strdup(args(1).string_value().c_str()); /* btw, the strdup'ing is actually necessary. some parts of
                                                            octave's api aren't that great. */

    if (!s17_ctx) {
        s17_ctx = stage17_init();
        if (!s17_ctx) {
            orv(octave_idx_type(0)) = octave_value("[Stage17helper: cannot context]");
            return orv;
        }
    }

    PGconn* conn = stage17_connect(s17_ctx);
    if (!conn) {
        orv(octave_idx_type(0)) = octave_value("[Stage17helper: cannot connection]");
        return orv;
    }

    const char *rv = stage17_doexec(s17_ctx, conn, cfun, carg);

    stage17_disconnect(s17_ctx, conn);

    /*
    char diag[128];
    snprintf(diag, sizeof(diag), "calling %s(%s).", cfun, carg);
    orv(octave_idx_type(0)) = octave_value(strdup(diag));
    */
    /* leave context alive for possible subsequent calls.
     * also, I'm afraid killing it might upset postgres and lead to it committing seppuku, and since we're living inside
     * the same process here, we don't want that to happen. */

    orv(octave_idx_type(0)) = octave_value(rv);
    return orv;
}

