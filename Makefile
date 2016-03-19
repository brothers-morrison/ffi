

all: Stage1.class stage2 stage3

stage7.exe: stage7.vb
	vbnc $<

stage5.exe: stage5.cs stage7.exe
	mcs $<

stage5: stage5.exe stage7.exe
	mkbundle --keeptemp stage5.exe -o stage5
	#FIXME make this portable
	gcc -ggdb -o stage5 -Wall -D_REENTRANT -I/usr/lib/pkgconfig/../../include/mono-2.0 -L/usr/lib/pkgconfig/../../lib -lmonosgen-2.0 -lm -lrt -ldl -lpthread temp.c temp.o

Stage4.class: Stage4.java stage5.exe stage5
	javac -cp ./nativelibs4java/libraries/Mono/Mono.jar $<


libstage3.so: stage3.cpp stage3.hpp Stage4.class
	g++ -g -shared -fPIC -ljvm -L /usr/lib/jvm/java-8-openjdk/jre/lib/amd64/server -I /usr/lib/jvm/java-8-openjdk/include -I /usr/lib/jvm/java-8-openjdk/include/linux -o libstage3.so $<


stage3: stage3.cpp stage3.hpp Stage4.class
	g++ -g -ljvm -L /usr/lib/jvm/java-8-openjdk/jre/lib/amd64/server -I /usr/lib/jvm/java-8-openjdk/include -I /usr/lib/jvm/java-8-openjdk/include/linux -o stage3 $<


Stage2.class: Stage2.java
	javac $<


Stage2.h: Stage2.class
	javah Stage2


libStage2.so: Stage2.c Stage2.h libstage3.so
	gcc -g -shared -fPIC -ldl -I /usr/lib/jvm/java-8-openjdk/include -I /usr/lib/jvm/java-8-openjdk/include/linux -o libStage2.so $<


stage2: Stage2.c Stage2.h libstage3.so
	gcc -g -ldl -I /usr/lib/jvm/java-8-openjdk/include -I /usr/lib/jvm/java-8-openjdk/include/linux -o stage2 $<


Stage1.class: Stage1.java libStage2.so
	javac $<


.PHONY: clean
clean:
	rm -f libStage2.so libstage3.so
	rm -f Stage1.class Stage2.class Stage4.class
	rm -f stage2 stage3 stage5
	rm -f stage5.exe stage7.exe
	rm -f temp.c temp.o temp.s
