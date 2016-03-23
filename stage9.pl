use Inline C;
use Inline C => config => libs => '-L/usr/local/lib -lmruby',
                          clean_after_build => 0;

sub blep {
    my ($foo) = @_;
    print "Stage 9: ${foo}\n";

    my $mrb = perl_mrb_init("stage10.rb");
    my $bar = perl_mrb_call_s_s($mrb, "Stage10Runner", "blep", $foo);
    perl_mrb_deinit($mrb);

    print "Return value[9]: ${bar}\n";
    return $bar;
}

blep('test')

__END__
__C__
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/irep.h>
#include <mruby/string.h>
#include <string.h>
#include <errno.h>

char *perl_do_the_thing(char *fname, void *_mrb, char *cname, char *mname, char *arg1) {
    FILE *fp = fopen(fname, "rb");

    mrb_state *mrb = mrb_open();
    mrb_value inst;
    inst = mrb_load_irep_file_cxt(mrb, fp, NULL);

    mrb_value argv[1];
    argv[0] = mrb_str_new(mrb, arg1, strlen(arg1));
    mrb_value rbrv = mrb_funcall_argv(mrb, inst, mrb_intern(mrb, mname, strlen(mname)), 1, argv);

    char *rv = strdup(RSTRING_PTR(rbrv));

    mrb_close(mrb);
    fclose(fp);

    return rv;
}
