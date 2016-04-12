Imports System
Imports System.Text
Imports System.Runtime.InteropServices
Imports V8InterfaceThing

Public Class CToVB
    Public Shared Function blep(ByVal foo As String) As String
        System.Console.WriteLine ("VisualBasic greetings, "+foo)
        return "Frob <"+foo+">"
    End Function
End Class

Module Main
    Sub Main()
        Dim args() As String = Environment.GetCommandLineArgs()
        System.Console.WriteLine (CToVB.blep(args(1)))
    End Sub
End Module

