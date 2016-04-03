// package name: main
package main

/*
#include <stdio.h>
extern const char *stage25_blep(char *foo);
extern void hs_init(int *argc, char ***foo);
extern void hs_exit();
#cgo LDFLAGS: -L. -lstage25 -L/home/jaseg/ffi -L/home/jaseg/ffi/haskell-libs -lstage25 -L/usr/lib/ghc -lHSrts-ghc7.6.3 -lHSrts_thr_debug-ghc7.6.3 -lHSrts_debug-ghc7.6.3 -lHSrts_thr-ghc7.6.3 -lHStransformers-0.5.2.0-ghc7.6.3 -lHStext-1.2.2.1-ghc7.6.3 -lHSmtl-2.2.1-ghc7.6.3 -lHSparsec-3.1.9-ghc7.6.3
*/
import "C"
import "fmt"
import "os"

//export stage24_blep
func stage24_blep(cfoo *C.char) *C.char {
    foo := C.GoString(cfoo)
    fmt.Fprintln(os.Stderr, "Stage 24:", foo);

    C.hs_init(nil, nil);

    bar := C.GoString(C.stage25_blep(C.CString(foo)))

    C.hs_exit();

    fmt.Fprintln(os.Stderr, "Return value [24]:", bar);
    return C.CString(bar)
}

func main() {} // CGO FTW!
