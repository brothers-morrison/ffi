
Unit Stage12Wrapper;
{$link ./libstage12.so}
{$linklib c}
Interface
Uses Ctypes;
Function stage12_blep(foo: PCChar): PCChar; cdecl; external;
Implementation
end.

