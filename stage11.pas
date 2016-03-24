Library libtest;

Uses sysutils;

Function blep(foo: PChar): PChar; cdecl;
var pfoo, baz: string;
begin
    pfoo := StrPas(foo);
    writeln('Stage 11: ', pfoo);
    baz := Format('[Stage11: %s]', [pfoo]);
    writeln('Return value[11]: ', baz);
    result := PChar(baz);
end;

exports
    blep;
end.
