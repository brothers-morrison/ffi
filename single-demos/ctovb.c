/*
 * Invoke like: env LD_LIBRARY_PATH=. ./fromctovb test
 * This needs a fairyly recent libmonosgen.
 */
#include <mono/jit/jit.h>
#include <mono/metadata/assembly.h>
#include <stdio.h>

int main(int argc, char **argv) {
    if (argc != 2)
        return 2;
    char *foo = argv[1];
    printf("C started with <%s>\n", foo);
    
    MonoDomain      *dom = mono_jit_init("Paul");
    MonoAssembly    *asy = mono_domain_assembly_open(dom, "ctovb.exe");
    MonoImage       *img = mono_assembly_get_image(asy);
    MonoClass       *cls = mono_class_from_name(img, "", "CToVB");
    MonoMethod      *met = mono_class_get_method_from_name(cls, "blep", 1);

    MonoString      *arg = mono_string_new(dom, foo);
    MonoObject      *mrv = mono_runtime_invoke(met, NULL, (void **)&arg, NULL);
    char            *bar = mono_string_to_utf8(mono_object_to_string(mrv, NULL));
    printf("Return value from mono <%s>\n", bar);
}

