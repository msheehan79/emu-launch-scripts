Option Compare Database

Public Function GenerateExport(System As String)
    Dim dbObj As DAO.Database
    Dim qdf As DAO.QueryDef
    Dim rstObj As DAO.Recordset
    Dim myFile As String
    Dim fld
       
    On Error GoTo ErrorHandler
    
Start:
    Set dbObj = CurrentDb()
    
    'Get the parameter query
    Set qdf = dbObj.QueryDefs("Metadata")
    
    'Supply the parameter value
    qdf.Parameters("System") = System
    
    'Open a Recordset based on the parameter query
    Set rstObj = qdf.OpenRecordset()
    
    ' Create directories if they don't exist
    If Len(Dir("C:\Emulation\metadata\" & System, vbDirectory)) = 0 Then
        MkDir "C:\Emulation\metadata\" & System
    End If
    
    myFile = "C:\Emulation\metadata\" & System & "\metadata.txt"

    If rstObj.RecordCount = 0 Then
        Set rstObj = Nothing
        Exit Function
    End If

    Open myFile For Output As #1

    Do While Not rstObj.EOF
        For Each fld In rstObj.Fields
            Print #1, fld.Name & ": " & fld.Value
        Next
        Print #1,
        rstObj.MoveNext
    Loop

CleanUp:
    Close #1
    Set rstObj = Nothing
    Exit Function
    
ErrorHandler:
    GoTo CleanUp
End Function

