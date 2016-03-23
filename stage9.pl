use Inline C;
use Inline C => config => libs => '-L/usr/local/lib -lmruby',
                          clean_after_build => 0;

sub blep {
    my ($foo) = @_;
    print "Stage 9: ${foo}\n";

    my $mr = perl_mrb_open();
    my $rbf = perl_mrb_load_file($mr, 'stage10.rb');

#    my $mod = perl_mrb_module_get_under($mr, $rbf, 'Stage10');
#    my $cls = perl_mrb_class_get_under($mr, $mod, 'Stage10Runner');
    my $ins = perl_mrb_obj_new($mr, $rbf);

    my $bar = perl_mrb_call_wrapper_s_s($mr, $ins, "blep", foo);

    perl_mrb_close($mr);

    print "Return value[9]: ${bar}\n";
    return $bar;
}

blep('test')

__END__
__C__
#include <mruby.h>
#include <mruby/compile.h>
#include <string.h>
#include <errno.h>

void * perl_mrb_open() {
    return mrb_open();
}

void perl_mrb_close(void * mr) {
    return mrb_close((mrb_state*)mr);
}

void * perl_mrb_module_get_under(void * mr, void * ins, char * name) {
    printf("Looking up module \"%s\" in ctx %p\n", name, mr);
    return mrb_module_get_under((mrb_state*)mr, (struct RClass *)ins, name);
}

void * perl_mrb_class_get_under(void * mr, void * obj, char* name) {
    return mrb_class_get_under((mrb_state*)mr, (struct RClass*)obj, name);
}

void * perl_mrb_obj_new(void * mr, void * cls) {
    mrb_value *val = malloc(sizeof(mrb_value));
    *val = mrb_obj_new((mrb_state*)mr, (struct RClass*)cls, 0, NULL);
    return val;
}

void * perl_mrb_load_file(void * mr, char * fn) {
    mrb_value *val = malloc(sizeof(mrb_value));
    FILE *fp = fopen(fn, "r");
    mrbc_context* ctx = mrbc_context_new((mrb_state*)mr);
    mrbc_filename((mrb_state*)mr, ctx, fn);
    *val = mrb_load_file_cxt((mrb_state*)mr, fp, ctx);
    printf("loading: %p %p %p\n", ctx, fp, val);
    fclose(fp);
    return val;
}

char *perl_mrb_call_wrapper_s_s(void * _mr, void * ins, char* name, char* arg) {
    mrb_state *mr = (mrb_state*)_mr;
    mrb_value rarg = mrb_str_new(mr, arg, strlen(arg));
    mrb_value rv = mrb_funcall(mr, *((mrb_value*)ins), name, 1, &rarg);
    if (mr->exc) {
        mrb_print_error(mr);
        return "ERROR[Stage 9]";
    }
    char *crv = mrb_str_to_cstr(mr, rv);
    if (mr->exc) {
        mrb_print_error(mr);
        return "ERROR[Stage 9]";
    }
    return crv;
}
