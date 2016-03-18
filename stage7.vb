Imports System;
Imports System.Runtime.InteropServices;
Imports V8InterfaceThing

Public Class Stage7Runner
    Public Sub blep(foo as String) as String
        JX_InitializeOnce("stage7")
        JX_InitializeNewEngine
        JX_DefineMainFile("require('main.js');")
        JX_StartEngine
        JX_Loop
        IntPtr js_rv
        b
        JX_Loop
        JX_StopEngine
    End Sub
End Class

Public Class V8InterfaceThing
    <DllImport("jx")> Public Shared Function JX_InitializeOnce(String appname, IntPtr callback)
    End Function
    <DllImport("jx")> Public Shared Function JX_InitializeNewEngine()
    End Function
    <DllImport("jx")> Public Shared Function JX_DefineMainFile(String code)
    End Function
    <DllImport("jx")> Public Shared Function JX_StartEngine()
    End Function
    <DllImport("jx")> Public Shared Function JX_StopEngine()
    End Function
    <DllImport("jx")> Public Shared Function JX_Loop()
    End Function
End Class
