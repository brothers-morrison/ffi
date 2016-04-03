#!/usr/bin/env luajit

local ffi = require("ffi")
stage23 = ffi.load("stage23")
ffi.cdef[[
    const char *blep(const char *foo);
]]

function blep (foo)
    io.stderr:write(string.format("Stage 22: %s\n", foo))

    bar = ffi.string(stage23.blep(foo))

    io.stderr:write(string.format("Return value [22]: %s\n", bar))
    return bar
end

