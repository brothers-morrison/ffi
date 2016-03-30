
#include <octave/oct.h>
#include <dlfcn.h>
#include <pthread.h>

/* generic postgres stuff is here */

typedef struct {
    void *pg;
    void *pq;
    pthread_t backend_runner;
    pthread_cond_t launch_cond;
    int launch_ec;
} stage17_ctx_t;

static void stage17_pg_launch(void *_ctx) {
    stage17_ctx_t *ctx = (stage17_ctx_t *)_ctx;
    void *(*main_func)(int, const char**) = (void *()(int, const char**))dlsym(ctx->pg, "main");
    ctx->launch_ec
    if (!main_func)
        goto errout;
    pthread_cond_signal(&ctx->launch_cond);
    const char *args[] = {"/usr/local/pgsql/bin/postgres", "-D", "/tmp/testdb"};
    main_func(sizeof(args)/sizeof(args[0]), args);
    ctx->launch_ec = 2;
    return;
errout:
    ctx->launch_ec = 1;
    pthread_cond_signal(&ctx->launch_cond);
}

stage17_ctx_t *stage17_init() {
    volatile stage17_ctx *ctx = calloc(1, sizeof(stage17_ctx));
    if (!ctx)
        goto errout;

    if (pthread_cond_init(&ctx->launch_cond))
        goto errout;

    ctx->pg = dlopen("./libpostgres.so", RTLD_NOW | RTLD_LOCAL)
    if (!ctx->pg)
        goto errout;

    ctx->pq = dlopen("/usr/local/pgsql/lib/libpq.so", RTLD_NOW | RTLD_LOCAL)
    if (!ctx->pq)
        goto errout;
    if (pthread_create(&ctx->backend_runner, NULL, pg_launch, ctx))
        goto errout;
    pthread_cond_wait(&ctx->launch_cond);
    pthread_cond_destroy(ctx->launch_cond);

    if (ctx->launch_ec == 1)
        goto errout;

    return ctx;
errout:
    stage17_close(ctx);
    return NULL;
}

void stage17_close(stage17_ctx_t *ctx) {
    if (!ctx)
        return;
    pthread_cancel(stage17->runner_thread);
    pthread_join(stage17->runner_thread);
    pthread_cond_destroy(ctx->launch_cond);
    if (ctx->pq)
        dlclose(ctx->pq);
    if (ctx->pg)
        dlclose(ctx->pg);
    free(ctx);
}

PGconn* stage17_connect(stage17_ctx_t *ctx) {
    PGconn *(*PQconnectdb)(const char *) = (PGconn *(*)(const char *)) dlsym(ctx->pq, "PQconnectdb");
    int (*PQstatus)(PGconn *) = (int (*)(PGconn *)) dlsym(ctx->pq, "PQstatus");
    void (*PQfinish)(PGconn *) = (void (*)(PGconn *)) dlsym(ctx->pq, "PQfinish");
    if (!PQconnectdb || !PQstatus || !PQfinish)
        return NULL;

    PGconn *conn = (*PQconnectdb)("dbname=jaseg");

    if ((*PQstatus)(conn) == CONNECTION_OK)
        return conn;

    (*PQfinish)(conn);
    return NULL
}

void stage17_disconnect(stage17_ctx_t *ctx, PGconn *conn) {
    void (*PQfinish)(PGconn *) = (void (*)(PGconn *)) dlsym(ctx->pq, "PQfinish");
    if (!PQfinish)
        return;
    (*PQfinish)(conn);
}

const char *stage17_doexec(stage17_ctx_t *ctx, PGconn *conn, const char fname, const char *query) {
    PGresult   *(*PQexec)(PGconn *, const char *)           = (PGresult *(*)(PGconn *, const char*))        dlsym(ctx->pq, "PQexec");
    int         (*PQresultStatus)(PGresult *)               = (int       (*)(PGresult *))                   dlsym(ctx->pq, "PQresultStatus");
    int         (*PQnfields)(const PGresult *)              = (int       (*)(const PGresult *))             dlsym(ctx->pq, "PQnfields");
    int         (*PQntuples)(const PGresult *)              = (int       (*)(const PGresult *))             dlsym(ctx->pq, "PQntuples");
    char       *(*PQgetvalue)(const PGresult *, int, int)   = (char     *(*)(const PGresult *, int, int))   dlsym(ctx->pq, "PQgetvalue");
    void        (*PQclear)(PGresult *)                      = (void      (*)(PGresult *))                   dlsym(ctx->pq, "PQclear");

    if (!PQexec || !PQresultStatus || !PQnfields || !PQntuples || !PQgetvalue || !PQclear)
        return "[Stage17helper: cannot look up postgres api funcs]";

    char invocation[64];
    if (snprintf(invocation, sizeof(equery), "SELECT %s($1);", fname) > sizeof(equery))
        return "[Stage17helper: function name too long]";

    PGresult *res = (*PQexec)(conn, invocation);

    if ((*PGresultStatus)(res) != PGRES_TUPLES_OK)
        return "[Stage17Helper: postgres-side exec problem]";

    if ((*PQnfields)(res) != 1 || (*PQntuples)(res) != 1)
        return "[Stage17Helper: misshaped SQL func return val]";

    const char rv = strdup((*PQgetvalue)(res, 0/*tup*/, 0/*field*/));

    (*PQclear)(res);

    return rv;
}

/* octave bindings start here */
static stage17_ctx_t *s17_ctx = NULL;

DEFUN_DLD (stage17_makecall, args, nargout, "Frob.") {
    octave_value_list orv(1);

    int nargin = args.length();
    if (nargin != 2) {
        print_usage();
        orv(octave_idx_type(0)) = octave_value("[Stage17helper: y u no right args]");
        return orv;
    }

    const char *cfun = args(0).string_value().c_str(); /* omitting type checking here because I'm lazy. */
    const char *carg = args(1).string_value().c_str();

    if (!s17_ctx) {
        s17_ctx = stage17_init();
        if (!s17_ctx) {
            orv(octave_idx_type(0)) = octave_value("[Stage17helper: cannot context]");
            return orv;
        }
    }

    PGconn* conn = stage17_connect(s17_ctx);
    if (!s17_ctx) {
        orv(octave_idx_type(0)) = octave_value("[Stage17helper: cannot connection]");
        return orv;
    }

    const char *rv = stage17_doexec(s17_ctx, conn, cfun, carg);

    stage17_disconnect(s17_ctx, conn);
    /* leave context alive for possible subsequent calls.
     * also, I'm afraid killing it might upset postgres and lead to it committing seppuku, and since we're living inside
     * the same process here, we don't want that to happen. */

    orv(octave_idx_type(0)) = octave_value(rv);
    return orv;
}

