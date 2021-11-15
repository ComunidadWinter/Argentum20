VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "TVidaUtil"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Declare Function GetTickCount _
                Lib "kernel32" () As Long

Private Const Item_MaxList   As Integer = 10000
Private Const Item_TimeClear As Long = 1800000 '900000 / 60 = 15 minutos

Private Type tItem
    Item_Pos As WorldPos 'Pos of item to clear
    Item_Time As Long 'Item 'Time of item to clear
    Item_Enable As Boolean

End Type

Dim Item_List()      As tItem
Dim Item_ListIndex() As Integer
Dim Item_LastIndex   As Integer

Public Sub Class_Initialize()
    Dim Maps As Integer

    Maps = val(GetVar(DatPath & "Map.dat", "INIT", "NumMaps"))
    ReDim Item_ListIndex(1 To Maps, 1 To 100, 1 To 100) As Integer
 
    Item_LastIndex = 0

End Sub

Public Sub Class_Terminate()
    Erase Item_List()
    Erase Item_ListIndex()
    Item_LastIndex = 0

End Sub

Private Function Item_FindSlot() As Integer

    On Error GoTo hErr

    Dim LoopC As Long

    If Item_LastIndex = 0 Then
        Item_FindSlot = 1
        Exit Function

    End If

    LoopC = 1

    Do Until Item_List(LoopC).Item_Enable = False

        If LoopC = Item_LastIndex Then
            Item_FindSlot = Item_LastIndex + 1
            Exit Function

        End If

        LoopC = LoopC + 1
    Loop
   
    Item_FindSlot = LoopC
    Exit Function
   
hErr:
    LogError "Error al renovar recursos"

End Function

Public Sub Item_ListAdd(ByVal Map As Integer, _
                        ByVal X As Byte, _
                        ByVal Y As Byte)
On Error GoTo hErr
    If Item_ListIndex(Map, X, Y) = 0 Then
   
        Dim Item_Index As Integer
        Item_Index = Item_FindSlot
   
        'Apuntamos al ultimo Char
        If Item_Index > Item_LastIndex Then
            Item_LastIndex = Item_Index
            ReDim Preserve Item_List(1 To Item_LastIndex)

        End If
       
        With Item_List(Item_Index)
            .Item_Enable = True
            .Item_Time = GetTickCount

            With .Item_Pos
                .Map = Map
                .X = X
                .Y = Y

            End With

        End With

        Item_ListIndex(Map, X, Y) = Item_Index
    Else
        Item_List(Item_ListIndex(Map, X, Y)).Item_Time = GetTickCount

    End If
hErr:
    LogError "Error al renovar recursos"
End Sub

Public Sub Item_ListErase(ByVal Map As Integer, _
                          ByVal X As Byte, _
                          ByVal Y As Byte)
                          On Error Resume Next
On Error GoTo hErr
    Dim Item_Index As Integer
    Item_Index = Item_ListIndex(Map, X, Y)
       
    If Item_Index > 0 Then
   
        Dim Item_Data As tItem
        Item_List(Item_Index) = Item_Data
       
        'Update array size
        If Item_Index = Item_LastIndex Then

            Do Until Item_List(Item_LastIndex).Item_Enable
                Item_LastIndex = Item_LastIndex - 1

                If Item_LastIndex = 0 Then
                
                    Exit Sub

                End If

            Loop
            ReDim Preserve Item_List(1 To Item_LastIndex)

        End If
       
        Item_ListIndex(Map, X, Y) = 0

    End If
hErr:
    LogError "Error al renovar recursos"
End Sub

Public Sub Item_CheckTime()
On Error GoTo hErr
    Dim LoopC     As Long
    Dim TimeClear As Long
   
    TimeClear = GetTickCount

    For LoopC = 1 To Item_LastIndex

        With Item_List(LoopC)

            If .Item_Pos.Map > 0 Then
                If Abs(.Item_Time - TimeClear) >= Item_TimeClear Then
                    MapData(.Item_Pos.Map, .Item_Pos.X, .Item_Pos.Y).ObjInfo.VidaUtil = ObjData(MapData(.Item_Pos.Map, .Item_Pos.X, .Item_Pos.Y).ObjInfo.ObjIndex).VidaUtil
                    Item_ListErase .Item_Pos.Map, .Item_Pos.X, .Item_Pos.Y
                End If

            End If

        End With

    Next LoopC
hErr:
    LogError "Error al renovar recursos"
End Sub
Public Sub LimpiezaForzada()
On Error GoTo hErr
    Dim LoopC     As Long
    Dim TimeClear As Long
   
    TimeClear = GetTickCount

    For LoopC = 1 To Item_LastIndex

        With Item_List(LoopC)

            If .Item_Pos.Map > 0 Then
                    MapData(.Item_Pos.Map, .Item_Pos.X, .Item_Pos.Y).ObjInfo.VidaUtil = ObjData(MapData(.Item_Pos.Map, .Item_Pos.X, .Item_Pos.Y).ObjInfo.ObjIndex).VidaUtil
                    Item_ListErase .Item_Pos.Map, .Item_Pos.X, .Item_Pos.Y
            End If

        End With

    Next LoopC
hErr:
    LogError "Error al renovar recursos"
End Sub



