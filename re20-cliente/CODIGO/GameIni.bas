Attribute VB_Name = "GameIni"
'RevolucionAo 1.0
'Pablo Mercavides
Option Explicit

Public Type tCabecera 'Cabecera de los con

    desc As String * 255
    CRC As Long
    MagicWord As Long

End Type

Public MiCabecera As tCabecera

Public Sub IniciarCabecera(ByRef Cabecera As tCabecera)
    
    On Error GoTo IniciarCabecera_Err
    
    Cabecera.desc = "Argentum Online by Noland Studios. Copyright Noland-Studios 2001, pablomarquez@noland-studios.com.ar"
    Cabecera.CRC = Rnd * 100
    Cabecera.MagicWord = Rnd * 10

    
    Exit Sub

IniciarCabecera_Err:
    Call RegistrarError(Err.number, Err.Description, "GameIni.IniciarCabecera", Erl)
    Resume Next
    
End Sub

