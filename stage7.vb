Imports System
Imports System.Runtime.InteropServices
Imports V8InterfaceThing

Public Class Stage7Runner
    Public Shared Function blep(ByVal foo As String) As String
        System.Console.WriteLine ("Stage 7: "+foo)

        Dim jrv As IntPtr, glo As IntPtr, func As IntPtr, params As IntPtr, crv As IntPtr, vbrv As String
        Dim prog As String

        JX_InitializeOnce("stage7.exe")
        JX_InitializeNewEngine()
        JX_DefineMainFile("process.stage = require('./stage8.js');")
        JX_StartEngine()
        JX_Loop() ' startup

        params = Marshal.AllocCoTaskMem(40) ' sizeof(JXValue) == 40
        jrv    = Marshal.AllocCoTaskMem(40)
        func   = Marshal.AllocCoTaskMem(40)

        JX_Evaluate("process.stage.blep;", "eval", func)

        JX_New(params)
        JX_SetString(params, foo, Len(foo))

        JX_CallFunction(func, params, 1, jrv)

        crv  = JX_GetString(jrv)
        vbrv = Marshal.PtrToStringAuto(crv)
        ' free params, jrv, crv

        'JX_Loop() ' teardown

        System.Console.WriteLine ("Return value[7]: "+vbrv)
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
    <DllImport("jx")> Public Shared Function JX_IsUndefined(ByVal obj As IntPtr) As Boolean
    End Function
    <DllImport("jx")> Public Shared Function JX_InitializeOnce(ByVal homedir As String) As IntPtr
    End Function
    <DllImport("jx")> Public Shared Function JX_InitializeNewEngine() As Integer
    End Function
    <DllImport("jx")> Public Shared Function JX_Evaluate(ByVal code As String, ByVal scriptname As String, ByVal out As IntPtr) As Integer
    End Function
    <DllImport("jx")> Public Shared Function JX_DefineMainFile(ByVal code As String) As Integer
    End Function
    <DllImport("jx")> Public Shared Function JX_StartEngine() As Integer
    End Function
    <DllImport("jx")> Public Shared Function JX_Loop() As Integer
    End Function
    <DllImport("jx")> Public Shared Function JX_LoopOnce() As Integer
    End Function
    <DllImport("jx")> Public Shared Function JX_Free(ByVal ptr As IntPtr) As Integer
    End Function
    <DllImport("jx")> Public Shared Function JX_New(ByVal ptr As IntPtr) As Integer
    End Function
    <DllImport("jx")> Public Shared Function JX_SetString(ByVal s As IntPtr, ByVal v As String, ByVal l As Integer) _
            As Integer
    End Function
    <DllImport("jx")> Public Shared Function JX_GetGlobalObject(ByVal obj As IntPtr) As Integer
    End Function
    <DllImport("jx")> Public Shared Function JX_CallFunction(ByVal func As IntPtr, ByVal args As IntPtr, _
            ByVal argc As Integer, ByVal retval As IntPtr) As Integer
    End Function
    <DllImport("jx")> Public Shared Function JX_GetString(ByVal jxo As IntPtr) As IntPtr
    End Function
    <DllImport("jx")> Public Shared Function JX_GetNamedProperty(ByVal jxo As IntPtr, ByVal prop As String, _
            ByVal out As IntPtr) As IntPtr
    End Function
End Class
