// package name: stage24
package stage24

import (
    "C"
    "fmt"
)

//export stage24_blep
func stage24_blep(cfoo *C.char) *C.char {
    foo := C.GoString(cfoo)
    fmt.Println("Stage 24: %v", foo);

    bar := fmt.Sprintf("[Stage 24: %v]", foo);

    fmt.Println("Return value [24]: %v", bar);
    return C.CString(bar)
}

func main() {} // CGO FTW!
