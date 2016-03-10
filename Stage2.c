
#include <stdio.h>
#include <dlfcn.h>
#include "Stage2.h"

typedef void *Stage3_t;

const char *stage2_blep(const char *foo) {
    void *handle = dlopen("./libstage3.so", RTLD_LAZY | RTLD_LOCAL);

    if (!handle)
        printf("Stage 3 dlopen error: %s\n", dlerror());

    Stage3_t *(*stage3_create)();
    void (*stage3_delete)(Stage3_t *);
    const char *(*stage3_blep)(Stage3_t *, const char *);

    stage3_create = (Stage3_t *(*)()) dlsym(handle, "stage3_create");
    stage3_delete = (void (*)(Stage3_t *)) dlsym(handle, "stage3_delete");
    stage3_blep = (const char *(*)(Stage3_t *, const char *)) dlsym(handle, "stage3_blep");

    Stage3_t *st = stage3_create();
    const char *cres = stage3_blep(st, foo);
    stage3_delete(st);

    return cres;
}

int main(int argc, char **argv) {
    if (argc < 2)
        return 1;
    printf("%s\n", stage2_blep(argv[1]));
    return 0;
}

JNIEXPORT jstring JNICALL Java_Stage2_blep (JNIEnv *env, jobject obj, jstring foo)
{
    const char *cfoo = (*env)->GetStringUTFChars(env, foo, 0);

    
    jstring res = (*env)->NewStringUTF(env, stage2_blep(cfoo));

    (*env)->ReleaseStringUTFChars(env, foo, cfoo);
    return res;
}

