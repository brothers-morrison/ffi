#!/usr/bin/env python3

from ctypes import *

mono = CDLL('mono')

mono.mono_jit_init.restype = c_void_p

def blep(foo):
	return foo
	dom = mono.mono_jit_init("stage6");
	asm = mono.mono_domain_assembly_open(dom, "stage7.exe");
	MonoImage img = m.mono_assembly_get_image(asm);
	MonoClass cls = m.mono_class_from_name(img, "stage7", "Stage7Runner");
	MonoMethod met = m.mono_class_get_method_from_name(cls, "blep", 1);

	Memory mem = new Memory(Native.POINTER_SIZE);
	mem.setPointer(0, m.mono_string_new(dom, foo).object.getPointer());
	PointerByReference pargs =  new PointerByReference();
	pargs.setPointer(mem.share(0));
	MonoObject obj = m.mono_runtime_invoke(met, null, pargs, (PointerByReference)null);
	MonoString rv = new MonoString();
	rv.use(obj.getPointer());
	String jrv = m.mono_string_to_utf8(rv).getPointer().getString(0);

	m.mono_jit_cleanup(dom);
	return jrv;

if __name__ == '__main__':
	print(blep('test'))
