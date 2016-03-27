
println "Stage 16 loading..."

@Grapes([
    @Grab(group='com.github.jnr', module='jnr-ffi', version='0.6.0'),
    @Grab(group='com.github.jnr', module='jnr-x86asm', version='1.0.1'),
    @Grab(group='com.github.jnr', module='jffi', version='1.0.11'),
])

import jnr.ffi.Library

interface Blepr {
    String stage16_5_blep(String foo)
}

println "Stage 16 loaded."

def blep(foo) {
    println "Stage 16: "+foo
    Library.addLibraryPath("stage16.5", new File("/home/jaseg/ffi"));
    Blepr blpr = Library.loadLibrary("stage16.5", Blepr.class)
    bar = blpr.stage16_5_blep(foo)

    println "Return value [16]: "+bar
    return bar
}

println 'Stage 16 invoke: '+blep("test")
