# Note: This is an octave script file, not obj-c.

1;

function rv = blep(foo)
    printf("Stage 17: %s\n", foo);
#    bar = ["[Stage 17: " foo "]"];
    bar = stage17_makecall("blep", foo);
    printf("Return value [17]: %s\n", bar);
    rv = bar;
endfunction
