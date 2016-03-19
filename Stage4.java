
import java.io.File;
import java.io.FileNotFoundException;
import java.nio.IntBuffer;

import com.nativelibs4java.mono.*;
import com.nativelibs4java.mono.MonoLibrary.*;

import com.sun.jna.Memory;
import com.sun.jna.Native;
import com.sun.jna.ptr.PointerByReference;

public class Stage4 {
	public static String blep(String foo) {
		final MonoLibrary m = MonoLibrary.INSTANCE;
		final MonoDomain dom = m.mono_jit_init("stage4");
		final MonoAssembly asm = m.mono_domain_assembly_open(dom, "stage5.exe");
		MonoImage img = m.mono_assembly_get_image(asm);
		MonoClass cls = m.mono_class_from_name(img, "stage5", "Stage5Runner");
		MonoMethod met = m.mono_class_get_method_from_name(cls, "blep", 1);

		Memory mem = new Memory(Native.POINTER_SIZE);
		mem.setPointer(0, m.mono_string_new(dom, foo).object.getPointer());
		PointerByReference pargs =  new PointerByReference();
		pargs.setPointer(mem.share(0));
		MonoObject obj = m.mono_runtime_invoke(met, null, pargs, (PointerByReference)null);
		/*MonoString rv = new MonoString();
		rv.use(obj.getPointer());
		String jrv = m.mono_string_to_utf8(rv).getPointer().getString(0);

		m.mono_jit_cleanup(dom);*/
		return foo; //jrv
	}

	public static void main(String args[]) {
		System.out.println(blep(args[0]));
	}
}
