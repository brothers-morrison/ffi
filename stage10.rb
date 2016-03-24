
require 'ffi'

module Stage11Lib
    extend FFI::Library
    ffi_lib './libstage11.so'
    attach_function :blep, [ :string ], :string
end

def blep(foo)
    puts "Stage 10: #{foo}\n"
    bar = Stage11Lib.blep(foo)
    puts "Return value[10]: #{bar}\n"
    return bar
end

