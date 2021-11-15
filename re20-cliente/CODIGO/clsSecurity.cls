VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSecurity"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
#If AntiExternos Then
 
    Rem Desencriptador / Encriptador - Check de paquetes
    Rem @writer: MENDUZ - MENDUZ@NOICODER.COM
    Rem @date: 03122008
    Rem ###################################################
 
    Public Redundance As Byte 'CLIENTE
    
    Private Const R_DEFAULT As Byte = 13
    Private Const R_MULTIP_FACTOR As Byte = 3
 
Public Sub NAC_E_Byte(ByRef ByteArray() As Byte, ByVal code As Byte)
Rem Encriptador de ByteArrays
Rem @writer: MENDUZ - MENDUZ@NOICODER.COM
Rem @date: 03122008
    Dim i As Integer 'Ponemos integer porque no manejamos paquetes más grandes de 10KB
    For i = 0 To UBound(ByteArray)
        ByteArray(i) = code Xor ByteArray(i)
    Next
End Sub
 
Public Sub NAC_D_Byte(ByRef ByteArray() As Byte, ByVal code As Byte)
Rem Desencriptador de ByteArrays
Rem @writer: MENDUZ - MENDUZ@NOICODER.COM
Rem @date: 03122008
    Dim i As Integer 'Ponemos integer porque no manejamos paquetes más grandes de 10KB
    For i = 0 To UBound(ByteArray)
        ByteArray(i) = ByteArray(i) Xor code
    Next
End Sub
 
Public Function NAC_E_String(ByVal T As String, ByVal code As Byte) As String
Rem Encriptador de Strings
Rem CLIENT-SIDE
Rem @writer: MENDUZ - MENDUZ@NOICODER.COM
Rem @date: 03122008
    Dim Bytes() As Byte: Bytes = StrConv(T, vbFromUnicode)
    Call NAC_E_Byte(Bytes, code)
    NAC_E_String = StrConv(Bytes, vbUnicode)
End Function
 
Public Function NAC_D_String(ByVal T As String, ByVal code As Byte) As String
Rem Desencriptador de Strings
Rem CLIENT-SIDE
Rem @writer: MENDUZ - MENDUZ@NOICODER.COM
Rem @date: 03122008
    Dim Bytes() As Byte: Bytes = StrConv(T, vbFromUnicode)
    Call NAC_D_Byte(Bytes, code)
    NAC_D_String = StrConv(Bytes, vbUnicode)
End Function

Public Property Get MultiplicationFactor()
    MultiplicationFactor = R_MULTIP_FACTOR
End Property

Public Property Get DefaultRedundance()
    DefaultRedundance = R_DEFAULT
End Property

#End If
 
