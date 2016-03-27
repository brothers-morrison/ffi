
library(inline)

settings <- getPlugin("Rcpp")

blep <- function(foo) {
    cat("Stage 15:", foo, "\n")
    rv <- paste("[ Stage 15: ", foo, "]", sep="")

    stage16_wrapper = cfunction(signature(foo="character"), 
                                cppargs=c("-I/usr/lib/jvm/java-7-openjdk-amd64/include", "-I/usr/lib/jvm/java-7-openjdk-amd64/include/linux"),
                                libargs=c("-L/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server", "-ljvm"),
                                language="C",
                                includes=("#include <jni.h>"),
                                body='
        const char *cfoo = CHAR(asChar(foo));
        JavaVM *jvm = NULL;
        JNIEnv *env = NULL;

        printf("Stage 15.5: %s\\n", cfoo);

        JNI_GetCreatedJavaVMs(&jvm, 1, NULL);
        (*jvm)->AttachCurrentThread(jvm, (void **)&env, NULL);


        jclass      gshellc     = (*env)->FindClass         (env, "groovy/lang/GroovyShell");
        //__asm__("int $3");
        jmethodID   cons_id     = (*env)->GetMethodID       (env, gshellc, "<init>", "()V");
        jobject     gshell      = (*env)->NewObject         (env, gshellc, cons_id);

        jmethodID   parse_id    = (*env)->GetMethodID       (env, gshellc, "parse", "(Ljava/io/File;)Lgroovy/lang/Script;");
        jclass      filec       = (*env)->FindClass         (env, "java/io/File");
        jmethodID   fcons_id    = (*env)->GetMethodID       (env, filec, "<init>", "(Ljava/lang/String;)V");
        jstring     fpaths      = (*env)->NewStringUTF      (env, "./stage16.groovy");
        jobject     lefile      = (*env)->NewObject         (env, filec, fcons_id, fpaths);
        jobject     script      = (*env)->CallObjectMethod  (env, gshell, parse_id, lefile);

        jstring     bleps       = (*env)->NewStringUTF      (env, "blep");
        jobject     objectc     = (*env)->FindClass         (env, "java/lang/Object");
        jobject     jfoo        = (*env)->NewStringUTF      (env, cfoo);
        jobject     bleparga    = (*env)->NewObjectArray    (env, 1, objectc, jfoo);
        jclass      scriptc     = (*env)->FindClass         (env, "groovy/lang/Script");
        jmethodID   invMet_id   = (*env)->GetMethodID       (env, scriptc, "invokeMethod", "(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/Object;");
        jthrowable  ex          = (*env)->ExceptionOccurred (env);
        if (ex) {
            (*env)->ExceptionDescribe(env);
            (*env)->ExceptionClear(env);
        }
        jobject     jrv         = (*env)->CallObjectMethod  (env, script, invMet_id, bleps, bleparga);
        ex          = (*env)->ExceptionOccurred (env);
        if (ex) {
            (*env)->ExceptionDescribe(env);
            (*env)->ExceptionClear(env);
        }

        const char *crv         = (*env)->GetStringUTFChars (env, jrv, 0);
        const char *rv          = strdup(crv);

        (*jvm)->DetachCurrentThread(jvm);
        printf("Return value[15.5]: %s\\n", rv);
        return mkString(rv);
    ')
    rv = stage16_wrapper(foo)

    cat("Return value [15]:", foo, "\n")
    return(rv)
}

