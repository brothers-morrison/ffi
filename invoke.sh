#!/usr/bin/env sh
env LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk/jre/lib/amd64/server java -Djava.library.path=/home/jaseg/dev/toys/ffi Stage1 $@
