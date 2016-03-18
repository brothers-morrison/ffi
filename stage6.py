#!/usr/bin/env python3

from ctypes import *

mono = CDLL('./libmono.so')

mono.mono_jit_init.restype = c_void_p
mono.mono_domain_assembly_open.restype = c_void_p
mono.mono_assembly_get_image.restype = c_void_p
mono.mono_class_from_name.restype = c_void_p
mono.mono_class_get_method_from_name.restype = c_void_p
mono.mono_runtime_invoke.restype = c_void_p
mono.mono_object_to_string = c_void_p
mono.mono_string_new.restype = c_void_p
mono.mono_string_to_utf8.restype = c_char_p

def blep(foo):
	dom = mono.mono_jit_init(b"stage6");
	asm = mono.mono_domain_assembly_open(dom, b"stage7.exe");
	img = mono.mono_assembly_get_image(asm);
	cls = mono.mono_class_from_name(img, b"", b"Stage7Runner");
	met = mono.mono_class_get_method_from_name(cls, b"blep", 1);

	arg = c_void_p(mono.mono_string_new(dom, c_char_p(foo.encode())))
	mrv = mono.mono_runtime_invoke(met, None, byref(arg), None);
	prv = mono.mono_string_to_utf8(mono.mono_object_to_string(mrv)).decode()

	mono.mono_jit_cleanup(dom)
	return prv;

if __name__ == '__main__':
	print(blep('test'))
