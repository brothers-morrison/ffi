#include <iostream>
#include <octave/oct.h>
#include <octave/octave.h>
#include <octave/parse.h>
#include <octave/toplev.h>

void much_improved_octave_exit_func(int ec) {
    /* ignore hard. */
}

extern "C" const char * stage16_5_blep (const char *foo) {
    string_vector argv(2);
    argv(0) = "embedded";
    argv(1) = "-q";
    octave_main(2, argv.c_str_vec(), 1);
    octave_exit = much_improved_octave_exit_func;

    int st=0;
    eval_string("source(\"stage17.m\")", true, st);

    octave_value_list args(1);
    args(octave_idx_type(0)) = octave_value(foo);
    octave_value_list out = feval("blep", args, 1);
    std::string orv = out(0).string_value();
    const char *rv = strdup(orv.c_str());

    clean_up_and_exit(0);
    return rv;
}

int main(void) {
    printf("Return value: %s\n", stage16_5_blep("fnord"));
}
