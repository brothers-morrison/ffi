

all: Stage1.class stage2 stage3


Stage4.class: Stage4.java
	javac Stage4.java


libstage3.so: stage3.cpp stage3.hpp Stage4.class
	g++ -g -shared -fPIC -ljvm -L /usr/lib/jvm/java-8-openjdk/jre/lib/amd64/server -I /usr/lib/jvm/java-8-openjdk/include -I /usr/lib/jvm/java-8-openjdk/include/linux -o libstage3.so stage3.cpp


stage3: stage3.cpp stage3.hpp Stage4.class
	g++ -g -ljvm -L /usr/lib/jvm/java-8-openjdk/jre/lib/amd64/server -I /usr/lib/jvm/java-8-openjdk/include -I /usr/lib/jvm/java-8-openjdk/include/linux -o stage3 stage3.cpp


Stage2.class: Stage2.java
	javac Stage2.java


Stage2.h: Stage2.class
	javah Stage2


libStage2.so: Stage2.h Stage2.c libstage3.so
	gcc -g -shared -fPIC -ldl -I /usr/lib/jvm/java-8-openjdk/include -I /usr/lib/jvm/java-8-openjdk/include/linux -o libStage2.so Stage2.c


stage2: Stage2.h Stage2.c libstage3.so
	gcc -g -ldl -I /usr/lib/jvm/java-8-openjdk/include -I /usr/lib/jvm/java-8-openjdk/include/linux -o stage2 Stage2.c


Stage1.class: Stage1.java libStage2.so
	javac Stage1.java


.PHONY: clean
clean:
	rm -f *.so
	rm -f *.class
	rm -f stage2
