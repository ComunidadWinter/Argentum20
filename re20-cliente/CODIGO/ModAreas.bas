Attribute VB_Name = "ModAreas"
Option Explicit

'LAS GUARDAMOS PARA PROCESAR LOS MPs y sabes si borrar personajes
Public MinLimiteX      As Integer

Public MaxLimiteX      As Integer

Public MinLimiteY      As Integer

Public MaxLimiteY      As Integer

Private Const AREA_DIM As Byte = 12

Public Sub CambioDeArea(ByVal x As Byte, ByVal y As Byte)
    
    On Error GoTo CambioDeArea_Err
    

    Dim loopX As Long, loopY As Long
    
    MinLimiteX = (x \ AREA_DIM - 1) * AREA_DIM
    MaxLimiteX = MinLimiteX + (AREA_DIM * 3) - 1
    
    MinLimiteY = (y \ AREA_DIM - 1) * AREA_DIM
    MaxLimiteY = MinLimiteY + (AREA_DIM * 3) - 1
    
    For loopX = 1 To 100
        For loopY = 1 To 100
            
            If (loopY < MinLimiteY) Or (loopY > MaxLimiteY) Or (loopX < MinLimiteX) Or (loopX > MaxLimiteX) Then
                'Erase NPCs
                
                With MapData(loopX, loopY)
                
                    If .charindex > 0 Then
                        If .charindex <> UserCharIndex Then
                            Call EraseChar(.charindex)
    
                        End If
                    End If
                    
                    'Erase OBJs
                    If Not EsObjetoFijo(loopX, loopY) Then
                        .ObjGrh.GrhIndex = 0
                        .OBJInfo.OBJIndex = 0
                    End If

                End With
                
            End If
        
        Next loopY
    Next loopX
    
    Call RefreshAllChars

    
    Exit Sub

CambioDeArea_Err:
    Call RegistrarError(Err.Number, Err.Description, "ModAreas.CambioDeArea", Erl)
    Resume Next
    
End Sub
