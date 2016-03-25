
# NOTE: Additionally to all of this shit, the perl script may compile some things at runtime.


all: allstages

.PHONY: allstages
allstages: Stage1.class stage2 libStage2.so stage3 libstage3.so Stage4.class stage5 stage7.exe libstage8.5.so libstage11.so


libstage11.so: stage11.pas
	fpc -Mdelphi -Tlinux -Xc -Cg -gw $<

libstage8.5.so: stage8.5.c
	gcc -g -shared -fPIC $(shell perl -MExtUtils::Embed -e ccopts -e ldopts) -o libstage8.5.so $<
	gcc -g $(shell perl -MExtUtils::Embed -e ccopts -e ldopts) -o stage8.5 $<

stage7.exe: stage7.vb
	vbnc $<

stage5.exe: stage5.cs
	mcs $<

stage5: stage5.exe
	mkbundle --keeptemp stage5.exe -o stage5
	#FIXME make this portable
	gcc -ggdb -o stage5 -Wall -D_REENTRANT -I/usr/local/lib/pkgconfig/../../include/mono-2.0 -L/usr/local/lib/pkgconfig/../../lib -lmono-2.0 -lm -lrt -ldl -lpthread temp.c temp.o

Stage4.class: Stage4.java
	javac -cp ./nativelibs4java/libraries/Mono/Mono.jar $<


libstage3.so: stage3.cpp stage3.hpp
	g++ -g -shared -fPIC -ljvm -L /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server -I /usr/lib/jvm/java-7-openjdk-amd64/include -I /usr/lib/jvm/java-7-openjdk-amd64/include/linux -o libstage3.so $<


stage3: stage3.cpp stage3.hpp Stage4.class
	g++ -g -ljvm -L /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server -I /usr/lib/jvm/java-7-openjdk-amd64/include -I /usr/lib/jvm/java-7-openjdk-amd64/include/linux -o stage3 $<


Stage2.class: Stage2.java
	javac $<


Stage2.h: Stage2.class
	javah Stage2


libStage2.so: Stage2.c Stage2.h
	gcc -g -shared -fPIC -ldl -I /usr/lib/jvm/java-7-openjdk-amd64/include -I /usr/lib/jvm/java-7-openjdk-amd64/include/linux -o libStage2.so $<


stage2: Stage2.c Stage2.h
	gcc -g -ldl -I /usr/lib/jvm/java-7-openjdk-amd64/include -I /usr/lib/jvm/java-7-openjdk-amd64/include/linux -o stage2 $<


Stage1.class: Stage1.java
	javac $<


.PHONY: sync
sync:
	rsync -avP . ffivm:ffi/ --exclude=jxcore --exclude=levm.qcow2 --exclude=mono --exclude=node_modules --exclude=mruby

.PHONY: clean
clean:
	rm -f libStage2.so libstage3.so libstage8.5.so libstage11.so
	rm -f Stage1.class Stage2.class Stage4.class
	rm -f stage2 stage3 stage5 stage8.5
	rm -f stage5.exe stage7.exe
	rm -f temp.c temp.o temp.s
	rm -rf _Inline __pycache__
