using System;
using System.Runtime.InteropServices;
using static stage5.PythonInterfaceThing;

namespace stage5 {
    public class Stage5Runner
    {
        static public string blep(string foo)
        {
            Console.WriteLine("Stage 5: "+foo);
            Py_Initialize();
            IntPtr mod  = PyImport_ImportModule("stage6");
            IntPtr func = PyObject_GetAttrString(mod, "blep");
            IntPtr args = PyTuple_New(1);
            IntPtr pfoo = PyUnicode_FromString(foo);
            PyTuple_SetItem(args, 0, pfoo);
            IntPtr pres = PyObject_CallObject(func, args);
            IntPtr bres = PyUnicode_AsUTF16String(pres);
            /* doing utf-16 on an utf-8 system? why not! */
            long size = PyBytes_Size(bres);
            IntPtr sres = PyBytes_AsString(bres);
            string s = Marshal.PtrToStringUni(sres, (int)size/2);
            Py_Finalize();

            Console.WriteLine("Return value[5]: "+s);
            return s;
        }

        static public void Main()
        {
            Console.WriteLine(blep("test"));
        }
    }

    public class PythonInterfaceThing
    {
        [DllImport("python3.5m")]
            public static extern void Py_Initialize();
        [DllImport("python3.5m")]
            public static extern IntPtr PyImport_ImportModule(string name);
        [DllImport("python3.5m")]
            public static extern IntPtr PyObject_GetAttrString(IntPtr obj, string name);
        [DllImport("python3.5m")]
            public static extern IntPtr PyTuple_New(int len);
        [DllImport("python3.5m")]
            public static extern IntPtr PyObject_CallObject(IntPtr func, IntPtr args);
        [DllImport("python3.5m")]
            public static extern void PyTuple_SetItem(IntPtr tup, int idx, IntPtr val);
        [DllImport("python3.5m")]
            public static extern IntPtr PyUnicode_FromString(string str);
        [DllImport("python3.5m")]
            public static extern IntPtr PyUnicode_AsUTF16String(IntPtr pstr);
        [DllImport("python3.5m")]
            public static extern IntPtr PyBytes_AsString(IntPtr pstr);
        [DllImport("python3.5m")]
            public static extern long PyBytes_Size(IntPtr pstr);
        [DllImport("python3.5m")]
            public static extern IntPtr PyUnicode_AsUnicode(IntPtr pstr);
        [DllImport("python3.5m")]
            public static extern IntPtr PyObject_Str(IntPtr pstr);
        [DllImport("python3.5m")]
            public static extern int PyUnicode_Check(IntPtr pstr);
        [DllImport("python3.5m")]
            public static extern void Py_Finalize();
        [DllImport("python3.5m")]
            public static extern void PyErr_Print();
    }
}
