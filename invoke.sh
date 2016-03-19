#!/usr/bin/env sh
#env PYTHONPATH=/home/jaseg/dev/toys/ffi MONO_PATH=/home/jaseg/dev/toys/ffi/mono/mcs/class/lib/net_4_x LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk/jre/lib/amd64/server:. java -Djava.library.path=/home/jaseg/dev/toys/ffi:/usr/lib -cp ./nativelibs4java/libraries/Mono/Mono.jar:. Stage1 $@

DEBUG=""

if [ $1 = "-d" ]; then
    DEBUG="gdb -x gdb.init -ex run --args"
    shift
fi

if [ $1 = "-D" ]; then
    DEBUG="gdb -x gdb.init --args"
    shift
fi
${DEBUG} env LD_PRELOAD=/usr/lib/jvm/java-8-openjdk/jre/lib/amd64/server/libjsig.so PYTHONPATH=/home/jaseg/dev/toys/ffi MONO_PATH=/home/jaseg/dev/toys/ffi/mono/mcs/class/lib/net_4_x LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk/jre/lib/amd64/server:. java -Djava.library.path=/home/jaseg/dev/toys/ffi -cp ./nativelibs4java/libraries/Mono/Mono.jar:. -Djava.compiler=NONE Stage1 $@
