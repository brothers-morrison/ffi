
# NOTE: Additionally to all of this shit, the perl script may compile some things at runtime.


all: allstages

.PHONY: allstages
allstages: Stage1.class stage2 libStage2.so stage3 libstage3.so Stage4.class stage5 stage7.exe libstage8.5.so stage8.5\
           libstage11.so libstage16.5.so stage16.5 stage17_makecall.oct stage18_load libstage19.so


stage18helper.o: stage18helper.c
	gcc -g -c -fPIC -Ipostgresql/src/interfaces/libpq -Ipostgresql/src/include -o $@ $<

stage19.o: stage19.d
	gdc -g -c -shared -defaultlib=phobos2 -fPIC -o$@ $<

libstage19.so: stage18helper.o stage19.o
	gdc -g -fPIC -shared -o$@ -defaultlib=phobos2 $^
	#-Xlinker -L/usr/lib/x86_64-linux-gnu 

/tmp/testdb:
	/usr/local/pgsql/bin/initdb -D /tmp/testdb

.PHONY:
stage18_load: stage18.sql /tmp/testdb libstage19.so
	./stage18_load.sh

libpostgres.so: postgresql
	@echo "[Postgres: making common]"
	make -j 4 -C postgresql/src/common  CFLAGS="-g -fPIC -msse4.2 -shared" LD_FLAGS="-shared" clean
	make -j 4 -C postgresql/src/common  CFLAGS="-g -fPIC -msse4.2 -shared" LD_FLAGS="-shared" all
	@echo "[Postgres: making port]"
	make -j 4 -C postgresql/src/port    CFLAGS="-g -fPIC -msse4.2 -shared" LD_FLAGS="-shared" clean
	make -j 4 -C postgresql/src/port    CFLAGS="-g -fPIC -msse4.2 -shared" LD_FLAGS="-shared" all
	@echo "[Postgres: cleaning backend]"
	make -j 4 -C postgresql/src/backend clean
	@echo "[Postgres: making backend]"
	make -j 4 -C postgresql/src/backend CFLAGS="-g -fPIC -msse4.2 -shared" LD_FLAGS="-shared" ||\
		make -j 4 -C postgresql/src/backend CFLAGS="-g -fPIC -msse4.2 -shared" LD_FLAGS="-shared"
	@echo "[Postgres: copying build output]"
	cp postgresql/src/backend/postgres ./libpostgres.so

stage17_makecall.oct: stage17helper.cpp libpostgres.so
	CXXFLAGS="-Ipostgresql/src/interfaces/libpq -Ipostgresql/src/include" mkoctfile -g -o $@ $<

libstage16.5.so: stage16.5.cpp
	g++ -g -shared -fPIC -I/usr/local/include/octave-4.0.1 -I/usr/local/include/octave-4.0.1/octave -I/usr/include/hdf5/serial -I/usr/include/mpi -pthread -fopenmp -L/usr/local/lib/octave/4.0.1 -L/usr/local/lib -loctinterp -loctave -o $@ $<
#	env CFLAGS="-shared -fPIC" mkoctfile -v --link-stand-alone $< -o $@

stage16.5: stage16.5.cpp
	mkoctfile -v --link-stand-alone $< -o $@

rinside/src/RInsideAutoloads.h rinside/src/RInsideEnvVars.h:
	env R_HOME=/usr make -C rinside/src -f Makevars headers
	#because we're pros
	sed -i '/^WARNING/d' rinside/src/RInsideEnvVars.h rinside/src/RInsideAutoloads.h

libstage14.so: stage14.mm rinside/src/RInsideAutoloads.h rinside/src/RInsideEnvVars.h
	# please excuse this abomination
	clang -Wall -g -shared -fPIC -I/usr/include/GNUstep -Irinside/inst/include -I/usr/lib/R/site-library/Rcpp/include -I/usr/share/R/include -Xlinker -lgnustep-base -lR -fvisibility=hidden -I./rfix -O0 -o $@ $< rinside/src/RInside.cpp rinside/src/MemBuf.cpp /usr/lib/R/site-library/Rcpp/libs/Rcpp.so

libstage13.so: stage13.m libstage14.so
	clang -Wall -g -shared -fPIC -lobjc -o $@ -I /usr/include/GNUstep -Xlinker -lgnustep-base -fconstant-string-class=NSConstantString -L. -lstage14 $<

libstage12.so: stage12.S libstage13.so
	gcc -g -shared -fPIC -ldl -lc -o $@ $<

libstage11.so: stage11.pas Stage12Wrapper.pas libstage12.so
	fpc -Mdelphi -Tlinux -Xc -Cg -gw $<

libstage8.5.so: stage8.5.c
	gcc -g -shared -fPIC $(shell perl -MExtUtils::Embed -e ccopts -e ldopts) -o $@ $<

stage8.5: stage8.5.c
	gcc -g $(shell perl -MExtUtils::Embed -e ccopts -e ldopts) -o $@ $<

stage7.exe: stage7.vb
	vbnc $<

stage5.exe: stage5.cs
	mcs $<

stage5: stage5.exe
	mkbundle --keeptemp $< -o $@
	#FIXME make this portable
	gcc -ggdb -o $@ -Wall -D_REENTRANT -I/usr/local/lib/pkgconfig/../../include/mono-2.0 -L/usr/local/lib/pkgconfig/../../lib -lmono-2.0 -lm -lrt -ldl -lpthread temp.c temp.o

Stage4.class: Stage4.java
	javac -cp ./nativelibs4java/libraries/Mono/Mono.jar $<


libstage3.so: stage3.cpp stage3.hpp
	g++ -g -shared -fPIC -ljvm -L /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server -I /usr/lib/jvm/java-7-openjdk-amd64/include -I /usr/lib/jvm/java-7-openjdk-amd64/include/linux -o $@ $<


stage3: stage3.cpp stage3.hpp Stage4.class
	g++ -g -ljvm -L /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server -I /usr/lib/jvm/java-7-openjdk-amd64/include -I /usr/lib/jvm/java-7-openjdk-amd64/include/linux -o $@ $<


Stage2.class: Stage2.java
	javac $<


Stage2.h: Stage2.class
	javah $(basename $<)


libStage2.so: Stage2.c Stage2.h
	gcc -g -shared -fPIC -ldl -I /usr/lib/jvm/java-7-openjdk-amd64/include -I /usr/lib/jvm/java-7-openjdk-amd64/include/linux -o $@ $<


stage2: Stage2.c Stage2.h
	gcc -g -ldl -I /usr/lib/jvm/java-7-openjdk-amd64/include -I /usr/lib/jvm/java-7-openjdk-amd64/include/linux -o stage2 $<


Stage1.class: Stage1.java
	javac $<


.PHONY: sync
sync:
	rsync -avP . ffivm:ffi/ --exclude=jxcore --exclude=levm.qcow2 --exclude=mono --exclude=node_modules --exclude=mruby

.PHONY: clean
clean:
	rm -f libStage2.so libstage3.so libstage8.5.so libstage11.so libstage12.so libstage13.so libstage14.so libstage16.5.so
	rm -f Stage1.class Stage2.class Stage4.class
	rm -f stage2 stage3 stage5 stage8.5 stage16.5
	rm -f stage5.exe stage7.exe
	rm -f temp.c temp.o temp.s
	rm -f stage18helper.o stage19.o libstage19.so
	rm -f stage17_makecall.oct
	rm -f rinside/src/RInsideAutoloads.h rinside/src/RInsideEnvVars.h
	rm -rf _Inline __pycache__

.PHONY: mrproper
mrproper: clean
	rm -f libpostgres.so
	rm -rf /tmp/testdb
