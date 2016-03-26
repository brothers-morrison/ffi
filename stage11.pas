Library libtest;

Uses sysutils, Stage12Wrapper, CTypes;

Function blep(foo: PChar): PChar; cdecl;
var pfoo, baz: string;
begin
    pfoo := StrPas(foo);
    writeln('Stage 11: ', pfoo);
    baz := StrPas(PChar(Stage12Wrapper.stage12_blep(PCChar(PChar(pfoo)))));
    writeln('Return value[11]: ', baz);
    result := PChar(baz);
end;

exports
    blep;
end.
