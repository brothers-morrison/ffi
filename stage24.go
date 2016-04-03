// package name: main
package main

import (
    "C"
    "fmt"
    "os"
)

//export stage24_blep
func stage24_blep(cfoo *C.char) *C.char {
    foo := C.GoString(cfoo)
    fmt.Fprintln(os.Stderr, "Stage 24:", foo);

    bar := fmt.Sprintf("[Stage 24: %v]", foo);

    fmt.Fprintln(os.Stderr, "Return value [24]:", bar);
    return C.CString(bar)
}

func main() {} // CGO FTW!
