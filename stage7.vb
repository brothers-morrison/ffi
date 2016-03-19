Imports System
Imports System.Runtime.InteropServices
Imports V8InterfaceThing

Public Class Stage7Runner
    Public Shared Function blep(ByVal foo As String) As String
        Dim jrv As IntPtr, glo As IntPtr, func As IntPtr, params As IntPtr, crv As IntPtr, vbrv As String

        JX_InitializeOnce(".")
        JX_InitializeNewEngine()
        JX_DefineMainFile("require('stage8.js')")
        JX_StartEngine()
        JX_Loop() ' startup

        params = Marshal.AllocCoTaskMem(40) ' sizeof(JXValue) == 40
        jrv    = Marshal.AllocCoTaskMem(40)
        glo    = Marshal.AllocCoTaskMem(40)
        func   = Marshal.AllocCoTaskMem(40)

        JX_GetGlobalObject(glo)
        JX_GetNamedProperty(glo, "blep", func)

        JX_New(params)
        JX_SetString(params, foo, Len(foo))

        JX_CallFunction(func, params, 1, jrv)

        crv  = JX_GetString(jrv)
        vbrv = Marshal.PtrToStringAuto(crv)
        ' free params, jrv, crv

        'JX_Loop() ' teardown

        return vbrv
    End Function
End Class

Module Main
    Sub Main()
        Dim args() As String = Environment.GetCommandLineArgs()
        System.Console.WriteLine (Stage7Runner.blep(args(1)))
    End Sub
End Module

Public Class V8InterfaceThing
    <DllImport("jx")> Public Shared Function JX_InitializeOnce(ByVal homedir As String) As Object
    End Function
    <DllImport("jx")> Public Shared Function JX_InitializeNewEngine() As Object
    End Function
    <DllImport("jx")> Public Shared Function JX_DefineMainFile(ByVal code As String) As Object
    End Function
    <DllImport("jx")> Public Shared Function JX_StartEngine() As Object
    End Function
    <DllImport("jx")> Public Shared Function JX_Loop() As Object
    End Function
    <DllImport("jx")> Public Shared Function JX_Free(ByRef ptr As IntPtr) As Object
    End Function
    <DllImport("jx")> Public Shared Function JX_New(ByRef ptr As IntPtr) As Object
    End Function
    <DllImport("jx")> Public Shared Function JX_SetString(ByRef s As IntPtr, ByVal v As String, ByVal l As Integer) _
            As Object
    End Function
    <DllImport("jx")> Public Shared Function JX_GetGlobalObject(ByRef obj As IntPtr) As Object
    End Function
    <DllImport("jx")> Public Shared Function JX_CallFunction(ByRef func As IntPtr, ByRef args As IntPtr, _
            ByVal argc As Integer, ByRef retval As IntPtr) As Object
    End Function
    <DllImport("jx")> Public Shared Function JX_GetString(ByRef jxo As IntPtr) As IntPtr
    End Function
    <DllImport("jx")> Public Shared Function JX_GetNamedProperty(ByRef jxo As IntPtr, ByVal prop As String, _
            ByRef out As IntPtr) As IntPtr
    End Function
End Class
