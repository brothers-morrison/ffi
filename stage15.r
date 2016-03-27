
print("Stage 15 R source file loaded")

blep <- function(foo) {
    cat("Stage 15:", foo, "\n")
    rv <- paste("[ Stage 15: ", foo, "]", sep="")
    cat("Return value [15]:", foo, "\n")
    return(rv)
}

