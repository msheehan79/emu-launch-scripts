Option Compare Database

Public Function UpdateDescriptions()
    ' Update the description memo field table before any export
    DoCmd.OpenQuery "ClearDescriptions"
    DoCmd.OpenQuery "AddDescriptions"
    DoCmd.OpenQuery "FormatDescriptionsCRLF"
    DoCmd.OpenQuery "FormatDescriptionsPass1"
    DoCmd.OpenQuery "FormatDescriptionsPass2"
    DoCmd.OpenQuery "FormatDescriptionsPass3"
End Function

Public Function ExportAllSystems()
    Dim dbObj As DAO.Database
    Dim rstObj As DAO.Recordset
    
    Set dbObj = CurrentDb()
    Set rstObj = dbObj.OpenRecordset("SystemCollections")
    
    If rstObj.RecordCount = 0 Then
        GoTo Cleanup
    End If

    Do While Not rstObj.EOF
        SystemCollectionExport (rstObj.Fields("SystemName"))
        rstObj.MoveNext
    Loop

Cleanup:
    Set rstObj = Nothing
    Set dbObj = Nothing
    Exit Function

ErrorHandler:
    GoTo Cleanup
End Function

Public Function ExportAllCustomCollections()
    Dim dbObj As DAO.Database
    Dim rstObj As DAO.Recordset

    Set dbObj = CurrentDb()
    Set rstObj = dbObj.OpenRecordset("Collections")
    
    If rstObj.RecordCount = 0 Then
        GoTo Cleanup
    End If

    Do While Not rstObj.EOF
        CustomCollectionExport (rstObj.Fields("Collection"))
        rstObj.MoveNext
    Loop

Cleanup:
    Set rstObj = Nothing
    Set dbObj = Nothing
    Exit Function

ErrorHandler:
    GoTo Cleanup
End Function

Public Function CustomCollectionExport(Collection As String)
    Dim exportDir As String
    Dim dbObj As DAO.Database
    Dim qdf As DAO.QueryDef
    Dim rstObj As DAO.Recordset
    Dim tagRst As DAO.Recordset
    Dim myFile As String
    Dim fld
       
    exportDir = "C:\Emulation\metadata\"

    On Error GoTo ErrorHandler
    
Start:
    ' Create directories if they don't exist
    If Len(Dir(exportDir, vbDirectory)) = 0 Then
        MkDir exportDir
    End If
    
    Set dbObj = CurrentDb()
        
    'Get the parameter query for Collection
    Set qdf = dbObj.QueryDefs("CustomCollections - Name")

    'Supply the parameter value
    qdf.Parameters("CollectionName") = Collection
    
    'Open a Recordset based on the parameter query
    Set rstObj = qdf.OpenRecordset()
    
    If rstObj.RecordCount = 0 Then
        Set rstObj = Nothing
        Exit Function
    End If

    myFile = exportDir & "custom-" & rstObj.Fields("ShortName") & ".metadata.txt"
    
    Open myFile For Output As #1

    Do While Not rstObj.EOF
        For Each fld In rstObj.Fields
            Print #1, fld.Name & ": " & fld.Value
        Next
        Print #1,
        rstObj.MoveNext
    Loop

    'Get the parameter query for Game Files
    Set qdf = dbObj.QueryDefs("CustomCollections - Files")
    
    'Supply the parameter value
    qdf.Parameters("CollectionName") = Collection
    
    'Open a Recordset based on the parameter query
    Set rstObj = qdf.OpenRecordset()
    
    If rstObj.RecordCount = 0 Then
        Set rstObj = Nothing
    Else
        Do While Not rstObj.EOF
            For Each fld In rstObj.Fields
                Print #1, fld.Name & ": " & fld.Value
            Next
            rstObj.MoveNext
        Loop
        Print #1,
    End If
 
    'Get the parameter query for Metadata
    Set qdf = dbObj.QueryDefs("CustomCollections - GameMetadata")

    'Supply the parameter value
    qdf.Parameters("CollectionName") = Collection
    
    'Open a Recordset based on the parameter query
    Set rstObj = qdf.OpenRecordset()
    
    If rstObj.RecordCount = 0 Then
        GoTo Cleanup
    End If

    ' Open Tags query
    Set tagRst = dbObj.OpenRecordset("CustomSortByCollection")

    Do While Not rstObj.EOF
        For Each fld In rstObj.Fields
            If InStr(1, fld.Name, "assets-") Then
                Print #1, Replace(fld.Name, "-", ".") & ": " & fld.Value
            Else
                Print #1, fld.Name & ": " & fld.Value
            End If
        Next
        addCustomSortTags rstObj.Fields("x-gameID"), tagRst
        Print #1,
        rstObj.MoveNext
    Loop

Cleanup:
    Close #1
    Set rstObj = Nothing
    Set tagRst = Nothing
    Set dbObj = Nothing
    Exit Function

ErrorHandler:
    GoTo Cleanup
End Function

Public Function SystemCollectionExport(System As String)
    Dim exportDir As String
    Dim dbObj As DAO.Database
    Dim qdf As DAO.QueryDef
    Dim rstObj As DAO.Recordset
    Dim tagRst As DAO.Recordset
    Dim myFile As String
    Dim fld
       
    exportDir = "C:\Emulation\metadata\"

    On Error GoTo ErrorHandler
    
Start:
    ' Create directories if they don't exist
    If Len(Dir(exportDir, vbDirectory)) = 0 Then
        MkDir exportDir
    End If
    
    Set dbObj = CurrentDb()
        
    'Get the parameter query for Collection
    Set qdf = dbObj.QueryDefs("Collection-System")
    
    'Supply the parameter value
    qdf.Parameters("System") = System
    
    'Open a Recordset based on the parameter query
    Set rstObj = qdf.OpenRecordset()
    
    If rstObj.RecordCount = 0 Then
        Set rstObj = Nothing
        Exit Function
    End If

    myFile = exportDir & "system-" & rstObj.Fields("x-shortname") & ".metadata.txt"
    
    Open myFile For Output As #1

    Do While Not rstObj.EOF
        For Each fld In rstObj.Fields
            Print #1, fld.Name & ": " & fld.Value
        Next
        Print #1,
        rstObj.MoveNext
    Loop

    'Get the parameter query for Game Files
    Set qdf = dbObj.QueryDefs("SystemCollections - Files")
    
    'Supply the parameter value
    qdf.Parameters("System") = System
    
    'Open a Recordset based on the parameter query
    Set rstObj = qdf.OpenRecordset()
    
    If rstObj.RecordCount = 0 Then
        Set rstObj = Nothing
    Else
        Do While Not rstObj.EOF
            For Each fld In rstObj.Fields
                Print #1, fld.Name & ": " & fld.Value
            Next
            rstObj.MoveNext
        Loop
        Print #1,
    End If
 
    'Get the parameter query for Metadata
    Set qdf = dbObj.QueryDefs("Metadata")

    'Supply the parameter value
    qdf.Parameters("System") = System
    
    'Open a Recordset based on the parameter query
    Set rstObj = qdf.OpenRecordset()
    
    If rstObj.RecordCount = 0 Then
        GoTo Cleanup
    End If

    ' Open Tags query
    Set tagRst = dbObj.OpenRecordset("CustomSortByCollection")

    Do While Not rstObj.EOF
        For Each fld In rstObj.Fields
            If InStr(1, fld.Name, "assets-") Then
                Print #1, Replace(fld.Name, "-", ".") & ": " & fld.Value
            Else
                Print #1, fld.Name & ": " & fld.Value
            End If
        Next
        addCustomSortTags rstObj.Fields("x-gameID"), tagRst
        Print #1,
        rstObj.MoveNext
    Loop

Cleanup:
    Close #1
    Set rstObj = Nothing
    Set tagRst = Nothing
    Set dbObj = Nothing
    Exit Function
    
ErrorHandler:
    GoTo Cleanup
End Function

Private Sub addCustomSortTags(gameId As Integer, tagRst As DAO.Recordset)
    'Search for the first matching tag record
    tagRst.FindFirst "[ID] = " & gameId

    'Check the result
    If tagRst.NoMatch Then
        Exit Sub
    Else
        Do While Not tagRst.NoMatch
            Print #1, "tag: " & tagRst!Tag
            tagRst.FindNext "[ID] = " & gameId
        Loop

        'Search for the next matching record
        tagRst.FindNext "[ID] = " & gameId
    End If
End Sub

Public Function GenerateExport(System As String)
    Dim exportDir As String
    Dim dbObj As DAO.Database
    Dim qdf As DAO.QueryDef
    Dim rstObj As DAO.Recordset
    Dim myFile As String
    Dim fld
       
    exportDir = "C:\Emulation\metadata\"

    On Error GoTo ErrorHandler
    
Start:
    ' Create directories if they don't exist
    If Len(Dir(exportDir, vbDirectory)) = 0 Then
        MkDir exportDir
    End If
    
    Set dbObj = CurrentDb()
        
    'Get the parameter query for Collection
    Set qdf = dbObj.QueryDefs("Collection")
    
    'Supply the parameter value
    qdf.Parameters("System") = System
    
    'Open a Recordset based on the parameter query
    Set rstObj = qdf.OpenRecordset()
    
    If rstObj.RecordCount = 0 Then
        Set rstObj = Nothing
        Exit Function
    End If

    myFile = exportDir & rstObj.Fields("x-shortname") & ".metadata.txt"
    
    Open myFile For Output As #1

    Do While Not rstObj.EOF
        For Each fld In rstObj.Fields
            Print #1, fld.Name & ": " & fld.Value
        Next
        Print #1,
        rstObj.MoveNext
    Loop

    'Get the parameter query for Ignore Files
    Set qdf = dbObj.QueryDefs("Ignore-Files")
    
    'Supply the parameter value
    qdf.Parameters("System") = System
    
    'Open a Recordset based on the parameter query
    Set rstObj = qdf.OpenRecordset()
    
    If rstObj.RecordCount = 0 Then
        Set rstObj = Nothing
    Else
        Do While Not rstObj.EOF
            For Each fld In rstObj.Fields
                Print #1, fld.Name & ": " & fld.Value
            Next
            Print #1,
            rstObj.MoveNext
        Loop
    End If
 
    'Get the parameter query for Metadata
    Set qdf = dbObj.QueryDefs("Metadata")

    'Supply the parameter value
    qdf.Parameters("System") = System
    
    'Open a Recordset based on the parameter query
    Set rstObj = qdf.OpenRecordset()
    
    If rstObj.RecordCount = 0 Then
        GoTo Cleanup
    End If

    Do While Not rstObj.EOF
        For Each fld In rstObj.Fields
            If InStr(1, fld.Name, "assets-") Then
                Print #1, Replace(fld.Name, "-", ".") & ": " & fld.Value
            Else
                Print #1, fld.Name & ": " & fld.Value
            End If
        Next
        Print #1,
        rstObj.MoveNext
    Loop

Cleanup:
    Close #1
    Set rstObj = Nothing
    Exit Function
    
ErrorHandler:
    GoTo Cleanup
End Function


Public Function ExportMameResolutionFiles()
    Dim exportDir As String
    Dim dbObj As DAO.Database
    Dim qdf As DAO.QueryDef
    Dim rstObj As DAO.Recordset
    Dim myFile As String
       
    exportDir = "C:\Emulation\metadata\configfiles\"

    On Error GoTo ErrorHandler
    
Start:
    ' Create directories if they don't exist
    If Len(Dir(exportDir, vbDirectory)) = 0 Then
        MkDir exportDir
    End If
    
    Set dbObj = CurrentDb()
        
    'Get the parameter query for the data
    Set qdf = dbObj.QueryDefs("ResolutionsMAMEGames")

    'Open a Recordset based on the parameter query
    Set rstObj = qdf.OpenRecordset()
    
    If rstObj.RecordCount = 0 Then
        Set rstObj = Nothing
        Exit Function
    End If

    Do While Not rstObj.EOF

        ' Create directories if they don't exist
        If Len(Dir(exportDir & rstObj.Fields("x-system"), vbDirectory)) = 0 Then
            MkDir exportDir & rstObj.Fields("x-system")
        End If
    
        myFile = exportDir & rstObj.Fields("x-system") & "\" & rstObj.Fields("cfgfile")
        Open myFile For Output As #1

        If ((rstObj.Fields("Vector") = False) And (rstObj.Fields("4K Max Resolution") <> "3840x2160")) Then
            Print #1, "video_fullscreen_x = " & rstObj.Fields("value X")
            Print #1, "video_fullscreen_y = " & rstObj.Fields("value Y")
        End If
        
        If (rstObj.Fields("Video Layout") = True) Then
            Print #1, "video_driver = gl"
            Print #1, "video_layout_enable = true"
            Print #1, "video_layout_path = ""../configs/arcade-mame/layouts/" & rstObj.Fields("File") & """"
            Print #1, "video_layout_selected_view = " & rstObj.Fields("Layout Default View")
        End If

        If (rstObj.Fields("4-Way") = True) Then
            Print #1, "input_player1_analog_dpad_mode = """ & 0 & """"
            Print #1, "input_player2_analog_dpad_mode = """ & 0 & """"

            Print #1, "input_player1_up_axis = """ & 99 & """"
            Print #1, "input_player1_up_btn = """ & 99 & """"
            Print #1, "input_player1_up_mbtn = """ & 99 & """"
            
            Print #1, "input_player1_down_axis = """ & 99 & """"
            Print #1, "input_player1_down_btn = """ & 99 & """"
            Print #1, "input_player1_down_mbtn = """ & 99 & """"
            
            Print #1, "input_player1_left_axis = """ & 99 & """"
            Print #1, "input_player1_left_btn = """ & 99 & """"
            Print #1, "input_player1_left_mbtn = """ & 99 & """"
            
            Print #1, "input_player1_right_axis = """ & 99 & """"
            Print #1, "input_player1_right_btn = """ & 99 & """"
            Print #1, "input_player1_right_mbtn = """ & 99 & """"
            
            Print #1, "input_player2_up_axis = """ & 99 & """"
            Print #1, "input_player2_up_btn = """ & 99 & """"
            Print #1, "input_player2_up_mbtn = """ & 99 & """"
            
            Print #1, "input_player2_down_axis = """ & 99 & """"
            Print #1, "input_player2_down_btn = """ & 99 & """"
            Print #1, "input_player2_down_mbtn = """ & 99 & """"
            
            Print #1, "input_player2_left_axis = """ & 99 & """"
            Print #1, "input_player2_left_btn = """ & 99 & """"
            Print #1, "input_player2_left_mbtn = """ & 99 & """"
            
            Print #1, "input_player2_right_axis = """ & 99 & """"
            Print #1, "input_player2_right_btn = """ & 99 & """"
            Print #1, "input_player2_right_mbtn = """ & 99 & """"
            
            Print #1, "input_player1_l_x_minus_axis = ""-" & 9 & """"
            Print #1, "input_player1_l_x_plus_axis = ""+" & 9 & """"
            Print #1, "input_player1_l_y_minus_axis = ""+" & 9 & """"
            Print #1, "input_player1_l_y_plus_axis = ""-" & 9 & """"
            
            Print #1, "input_player2_l_x_minus_axis = ""-" & 9 & """"
            Print #1, "input_player2_l_x_plus_axis = ""+" & 9 & """"
            Print #1, "input_player2_l_y_minus_axis = ""+" & 9 & """"
            Print #1, "input_player2_l_y_plus_axis = ""-" & 9 & """"
        End If
        
        rstObj.MoveNext
        Close #1
    Loop

Cleanup:
    Set rstObj = Nothing
    Exit Function
    
ErrorHandler:
    GoTo Cleanup
End Function
