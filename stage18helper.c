
#include <dlfcn.h>
#include <pthread.h>

typedef struct {
    void *pg;
    void *pq;
    pthread_t backend_runner;
    pthread_cond_t launch_cond;
    int launch_ec;
} stage18_ctx_t;

static void stage18_pg_launch(void *_ctx) {
    stage18_ctx_t *ctx = (stage18_ctx_t *)_ctx;
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

stage18_ctx_t *stage18_init() {
    volatile stage18_ctx *ctx = calloc(1, sizeof(stage18_ctx));
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
    stage18_close(ctx);
    return NULL;
}

void stage18_close(stage18_ctx_t *ctx) {
    if (!ctx)
        return;
    pthread_cancel(stage18->runner_thread);
    pthread_join(stage18->runner_thread);
    pthread_cond_destroy(ctx->launch_cond);
    if (ctx->pq)
        dlclose(ctx->pq);
    if (ctx->pg)
        dlclose(ctx->pg);
    free(ctx);
}

PGconn* stage18_connect(stage18_ctx_t *ctx) {
    PGconn *(*PQconnectdb)(const char *) = (PGconn *(*)(const char *)) dlsym(ctx->pq, "PQconnectdb");
    int (*PQstatus)(PGconn *) = (int (*)(PGconn *)) dlsym(ctx->pq, "PQstatus");
    void (*PQfinish)(PGconn *) = (void (*)(PGconn *)) dlsym(ctx->pq, "PQfinish");
    if (!PQconnectdb || !PQstatus || !PQfinish)
        return NULL;

    PGconn *conn = PQconnectdb("dbname=jaseg");

    if (PQstatus(conn) == CONNECTION_OK)
        return conn;

    PQfinish(conn);
    return NULL
}

void stage18_disconnect(stage18_ctx_t *ctx, PGconn *conn) {
    void (*PQfinish)(PGconn *) = (void (*)(PGconn *)) dlsym(ctx->pq, "PQfinish");
    if (!PQfinish)
        return;
    PQfinish(conn);
}

	def exec_tuples(self, cmd):
		res = pq.PQexec(self.conn, cmd)
		assert pq.PQresultStatus(res) == 2 # PGRES_TUPLES_OK
		nf = pq.PQnfields(res)
		nt = pq.PQntuples(res)
		fields = tuple( pq.PQfname(res, i) for i in range(nf) )
		tuples = [ tuple( pq.PQgetvalue(res, tn, fn) for fn in range(nf) ) for tn in range(nt) ]
		pq.PQclear(res)
		return fields, tuples

