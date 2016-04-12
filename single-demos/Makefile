
# NOTE: Additionally to all of this shit, the perl script may compile some things at runtime.


all: allstages

.PHONY: allstages
allstages: fromctogo fromrusttohaskell FromPythonToJava.class fromctovb

########################################################################################################################

fromctogo: fromctogo.c libfromctogo.so
	gcc -L. -lfromctogo -Wall -Wpedantic -Wstrict-aliasing -Wextra -o $@ $<

libfromctogo.so: fromcto.go
	go build -o $@ -buildmode c-shared $<

########################################################################################################################

fromrusttohaskell: fromrusttohaskell.rs libfromrusttohaskell.so
	rustc -g -L. $(patsubst %,-L%,$(shell find /usr/lib/ghc-* -type d)) $(patsubst lib%.so,-l%,$(shell find /usr/lib/ghc-* -name "*.so" -printf "%f\n")) -o $@ $<

libfromrusttohaskell.so: fromrusttohaskell.hs
	ghc --make -dynamic -shared -fPIC -o $@ $<

########################################################################################################################

FromPythonToJava.class: FromPythonToJava.java
	javac $<

########################################################################################################################

fromctovb: ctovb.c ctovb.exe
	gcc $(shell pkg-config --cflags --libs monosgen-2) -o $@ $<

ctovb.exe: ctovb.vb
	vbnc $<

########################################################################################################################

.PHONY: clean
clean:
	rm -f libfromctogo.so fromctogo
	rm -f libfromrusttohaskell.so fromrusttohaskell
	rm -f fromctovb ctovb.exe

