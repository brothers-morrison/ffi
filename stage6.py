#!/usr/bin/env python3

from ctypes import *

def blep(foo):
	print('Stage 6:', foo)

	mono = CDLL('libmonosgen-2.0.so.1')

	mono.mono_jit_init.restype = c_void_p
	mono.mono_domain_assembly_open.restype = c_void_p
	mono.mono_assembly_get_image.restype = c_void_p
	mono.mono_class_from_name.restype = c_void_p
	mono.mono_class_get_method_from_name.restype = c_void_p
	mono.mono_runtime_invoke.restype = c_void_p
	mono.mono_object_to_string = c_void_p
	mono.mono_string_new.restype = c_void_p
	mono.mono_string_to_utf8.restype = c_char_p
	mono.mono_get_root_domain.restype = c_void_p

	dom = c_void_p(mono.mono_get_root_domain())
	asm = c_void_p(mono.mono_domain_assembly_open(dom, b"stage7.exe"))
	img = c_void_p(mono.mono_assembly_get_image(asm))
	cls = c_void_p(mono.mono_class_from_name(img, b"", b"Stage7Runner"))
	met = c_void_p(mono.mono_class_get_method_from_name(cls, b"blep", 1))

	arg = c_void_p(mono.mono_string_new(dom, c_char_p(foo.encode())))
	mrv = mono.mono_runtime_invoke(met, None, byref(arg), None)
	prv = mono.mono_string_to_utf8(mono.mono_object_to_string(mrv)).decode()

	print('Return value[6]:', prv)
	return prv

if __name__ == '__main__':
	print(blep('test'))
