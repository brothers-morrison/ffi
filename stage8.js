var ffi = require('ffi');
var ref = require('ref');

var perl = ffi.Library('/usr/lib/perl5/core_perl/CORE/libperl', {
    'Perl_sys_init': ['void', ['int', 'char **']],
    'perl_alloc': ['void *', []],
    'perl_construct': ['void', ['void*']],
    'perl_parse': ['int', ['void *', 'void *', 'int', 'char **', 'char **']],
    'perl_run': ['int', ['void*']],
    'perl_destruct': ['void', ['void*']],
    'perl_free': ['void', ['void*']],
    'Perl_sys_term': ['void', []],
    'Perl_call_argv': ['int', ['char *', 'int', 'char **']]
});

module.exports = {
    blep: function (foo) {
        console.log('Stage 8: '+foo);
        perl.Perl_sys_init(0, null);
        purl = perl.perl_alloc();
        perl.perl_construct(purl);
        // cannot PL_exit_flags (to PERL_EXIT_DESTRUCT_END) since it seems "ffi" does not support variables.
        
        args = ref.byref(ref.byref('stage9.pl'))
        perl.perl_parse(purl, null, 1, args, null);
        perl.perl_run(perl);

        { 'Perl_push_scope': ['void', []],
        }
        var sp = perl.PL_stack_sp; // FIXME this is an exported var!
        perl.push_scope();
        Perl_save_strlen((STRLEN *)&perl.PL_tmps_floor),
        perl.PL_tmps_floor = perl.PL_tmps_ix
        PUSHMARK(SP);                   /* remember the stack pointer    */
        XPUSHs(sv_2mortal(newSViv(a))); /* push the base onto the stack  */
        XPUSHs(sv_2mortal(newSViv(b))); /* push the exponent onto stack  */
        PUTBACK;                      /* make local stack pointer global */
        call_pv("expo", G_SCALAR);      /* call the function             */
        SPAGAIN;                        /* refresh stack pointer         */
        /* pop the return value from stack */
        printf ("%d to the %dth power is %d.\n", a, b, POPi);
        PUTBACK;
        FREETMPS;                       /* free that return value        */
        LEAVE;                       /* ...and the XPUSHed "mortal" args.*/


        perl.perl_destruct(purl);
        perl.perl_free(purl);
        Perl_sys_term();

        console.log('Return value[8]: '+foo);
        return '[Stage8 '+foo+']';
    }
};
