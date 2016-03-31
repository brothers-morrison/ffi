
import std.string;
import std.stdio;
import std.conv;

extern (C) immutable(char) *stage19_dblep(immutable(char) *foo) {
    string dfoo = to!string(foo);
    writefln("Stage 19: %s", dfoo);

    auto bar = format("[Stage 19: %s]", dfoo);

    writefln("Return value [19]: %s", bar);
    return bar.toStringz();
}

extern (C) extern void c_main();
void main() {
    return c_main();
//    printf("[from D] Result: %s\n", stage19_dblep("test".toStringz()));
}
