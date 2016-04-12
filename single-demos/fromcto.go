// package name: main
package main

import "C"
import "fmt"
import "os"

//export blep
func blep(cfoo *C.char) *C.char {
    foo := C.GoString(cfoo)
    fmt.Fprintln(os.Stderr, "Something something go... ", foo);
    bar := fmt.Sprintf("This is go speaking, <%v> over and out.", foo)
    return C.CString(bar)
}

func main() {} // CGO FTW!
