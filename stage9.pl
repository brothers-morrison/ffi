use Inline C;
use Inline C => config => libs => '-lruby-2.1',
                          clean_after_build => 0,
                          inc => '-I/usr/include/ruby-2.1.0 -I/usr/include/x86_64-linux-gnu/ruby-2.1.0';

sub blep {
    my ($foo) = @_;
    print "Stage 9: ${foo}\n";

    my $bar = perl_do_the_thing("./stage10.rb", $foo);

    print "Return value[9]: ${bar}\n";
    return $bar;
}

__END__
__C__
#include <ruby.h>
#include <string.h>
#include <errno.h>

VALUE funcall_wrapper(VALUE actors) {
	return rb_funcall(rb_mKernel, rb_intern("blep"), 1, actors);
}

void print_rb_exc(void) {
	VALUE exception = rb_errinfo();
	rb_set_errinfo(Qnil);
	if (RTEST(exception)) {
        rb_warn("Ruby exception: %"PRIsVALUE"", exception);
    }
}

char *perl_do_the_thing(char *fname, char *arg1) {
    int state = 0;
    if (ruby_setup()) {
        return "Ruby setup failed.";
    }
    ruby_script("stage9");
    ruby_init_loadpath();
    rb_load_protect(rb_str_new_cstr(fname), 0, &state);
    if (state) {
        print_rb_exc();
        return "Ruby load_protect failed.";
    }
    VALUE rbrv = rb_protect(funcall_wrapper, rb_str_new_cstr(arg1), &state);
    if (state) {
        print_rb_exc();
        return "Ruby funcall failed.";
    }
    char *rv = strdup(StringValueCStr(rbrv));
    ruby_cleanup(0);
    return rv;
}
