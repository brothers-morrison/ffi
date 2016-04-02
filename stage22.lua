
function blep (foo)
    io.write(string.format("Stage 22: %s\n", foo))

    bar = string.format("[Stage 22: %s]", foo)

    io.write(string.format("Return value [22]: %s\n", bar))
    return bar
end
