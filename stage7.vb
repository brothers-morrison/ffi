Imports System
Imports System.Runtime.InteropServices
Imports V8InterfaceThing

Public Class Stage7Runner
    Public Shared Function blep(ByVal foo As String) As String
        Dim ctx As IntPtr, js_rv As IntPtr, vb_rv As String
        ctx = duk_create_heap (Nothing, Nothing, Nothing, Nothing, Nothing)

        duk_push_string_file_raw (ctx, "stage8.js", 0)
        duk_push_string (ctx, "stage8.js")
        duk_eval_raw (ctx, Nothing, 0, 17)

        duk_get_global_string (ctx, "blep")
        duk_push_string (ctx, foo)
        duk_call (ctx, 1)
        js_rv = duk_to_string (ctx, -1)
        vb_rv = Marshal.PtrToStringAuto(js_rv)

        'duk_pop (ctx)
        'duk_destroy_heap (ctx)
        return vb_rv
    End Function
End Class

Module Main
    Sub Main()
        Dim args() As String = Environment.GetCommandLineArgs()
        System.Console.WriteLine (Stage7Runner.blep(args(1)))
    End Sub
End Module

Public Class V8InterfaceThing
    <DllImport("duktape")> Public Shared Function duk_create_heap(ByVal _a1 As IntPtr, ByVal _a1 As IntPtr, _
            ByVal _a1 As IntPtr, ByVal _a1 As IntPtr, ByVal _a1 As IntPtr) As IntPtr
    End Function
    <DllImport("duktape")> Public Shared Function duk_push_string_file_raw(ByVal ctx As IntPtr, ByVal path As String,
            ByVal flags As Integer) As IntPtr
    End Function
    <DllImport("duktape")> Public Shared Function duk_push_string(ByVal ctx As IntPtr, ByVal path As String) As IntPtr
    End Function
    <DllImport("duktape")> Public Shared Function duk_eval_raw(ByVal ctx As IntPtr, ByVal srcBuf As IntPtr, _
            ByVal src_len As Integer, ByVal flags As Integer) As Object
    End Function
    <DllImport("duktape")> Public Shared Function duk_get_global_string(ByVal ctx As IntPtr, ByVal id As String) As Boolean
    End Function
    <DllImport("duktape")> Public Shared Function duk_call(ByVal ctx As IntPtr, ByVal args As Integer) As Object
    End Function
    <DllImport("duktape")> Public Shared Function duk_to_string(ByVal ctx As IntPtr, ByVal idx As Integer) As IntPtr
    End Function
    <DllImport("duktape")> Public Shared Function duk_pop(ByVal ctx As IntPtr) As Object
    End Function
    <DllImport("duktape")> Public Shared Function duk_destroy_heap(ByVal ctx As IntPtr) As Object
    End Function
End Class
