#!/usr/bin/env sh
#env PYTHONPATH=/home/jaseg/dev/toys/ffi MONO_PATH=/home/jaseg/dev/toys/ffi/mono/mcs/class/lib/net_4_x LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk/jre/lib/amd64/server:. java -Djava.library.path=/home/jaseg/dev/toys/ffi:/usr/lib -cp ./nativelibs4java/libraries/Mono/Mono.jar:. Stage1 $@

debug=""
cmd="java -Djava.library.path=/home/jaseg/ffi -cp ./nativelibs4java/libraries/Mono/Mono.jar:/usr/share/java/groovy.jar:/usr/share/java/asm3.jar:/usr/share/java/antlr.jar:. -Djava.compiler=NONE Stage1"

if [ $1 = "-d" ]; then
    debug="gdb -x gdb.init -ex run --args"
    shift
fi

if [ $1 = "-D" ]; then
    debug="gdb -x gdb.init --args"
    shift
fi

if [ $1 = "-x" ]; then
    cmd=""
    shift
fi

${debug} env LD_PRELOAD=/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server/libjsig.so PYTHONPATH=/home/jaseg/ffi LD_LIBRARY_PATH=.:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server:/home/jaseg/ffi:/usr/local/lib:/usr/lib/x86_64-linux-gnu:/usr/lib R_HOME=/usr/lib/R ${cmd} $@
