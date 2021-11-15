VERSION 5.00
Begin VB.Form FrmActivarCuenta 
   Appearance      =   0  'Flat
   BackColor       =   &H00000000&
   BorderStyle     =   0  'None
   ClientHeight    =   3870
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   3540
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3870
   ScaleMode       =   0  'User
   ScaleWidth      =   3540
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox NombreDeCuenta 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00E0E0E0&
      Height          =   195
      Left            =   480
      TabIndex        =   0
      Top             =   1480
      Width           =   2535
   End
   Begin VB.TextBox texVer 
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty DataFormat 
         Type            =   1
         Format          =   "0"
         HaveTrueFalseNull=   0
         FirstDayOfWeek  =   0
         FirstWeekOfYear =   0
         LCID            =   11274
         SubFormatType   =   1
      EndProperty
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00E0E0E0&
      Height          =   255
      IMEMode         =   3  'DISABLE
      Left            =   600
      MaxLength       =   5
      TabIndex        =   2
      Top             =   2800
      Width           =   855
   End
   Begin VB.TextBox Validacion 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00E0E0E0&
      Height          =   195
      Left            =   480
      TabIndex        =   1
      Top             =   2120
      Width           =   2535
   End
   Begin VB.Label refuerzo 
      BackStyle       =   0  'Transparent
      Caption         =   "Label1"
      Height          =   375
      Left            =   1560
      TabIndex        =   4
      Top             =   2760
      Width           =   735
   End
   Begin VB.Image Image1 
      Height          =   375
      Left            =   400
      Tag             =   "0"
      Top             =   3360
      Width           =   1080
   End
   Begin VB.Image Image2 
      Height          =   375
      Left            =   2030
      Tag             =   "0"
      Top             =   3340
      Width           =   1080
   End
   Begin VB.Label valcar 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "12345"
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   9
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H000040C0&
      Height          =   255
      Left            =   2160
      TabIndex        =   3
      Top             =   2800
      Width           =   855
   End
End
Attribute VB_Name = "FrmActivarCuenta"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Dim ValidacionNumber As Long

'Declaración del Api SetLayeredWindowAttributes que establece _
 la transparencia al form
  
Private Declare Function SetLayeredWindowAttributes Lib "user32" (ByVal hwnd As Long, ByVal crKey As Long, ByVal bAlpha As Byte, ByVal dwFlags As Long) As Long
  
'Recupera el estilo de la ventana
Private Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long) As Long
  
'Declaración del Api SetWindowLong necesaria para aplicar un estilo _
 al form antes de usar el Api SetLayeredWindowAttributes
  
Private Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
  
Private Const GWL_EXSTYLE = (-20)

Private Const LWA_ALPHA = &H2

Private Const WS_EX_LAYERED = &H80000

'Función para saber si formulario ya es transparente. _
 Se le pasa el Hwnd del formulario en cuestión
  
Public Function Is_Transparent(ByVal hwnd As Long) As Boolean
    
    On Error GoTo Is_Transparent_Err
    

    
  
    Dim msg As Long
  
    msg = GetWindowLong(hwnd, GWL_EXSTYLE)
         
    If (msg And WS_EX_LAYERED) = WS_EX_LAYERED Then
        Is_Transparent = True
    Else
        Is_Transparent = False

    End If
  
    If Err Then
        Is_Transparent = False

    End If
  
    
    Exit Function

Is_Transparent_Err:
    Call RegistrarError(Err.number, Err.Description, "FrmActivarCuenta.Is_Transparent", Erl)
    Resume Next
    
End Function
  
'Función que aplica la transparencia, se le pasa el hwnd del form y un valor de 0 a 255
Public Function Aplicar_Transparencia(ByVal hwnd As Long, Valor As Integer) As Long
    
    On Error GoTo Aplicar_Transparencia_Err
    
  
    Dim msg As Long
  
    
  
    If Valor < 0 Or Valor > 255 Then
        Aplicar_Transparencia = 1
    Else
        msg = GetWindowLong(hwnd, GWL_EXSTYLE)
        msg = msg Or WS_EX_LAYERED
     
        SetWindowLong hwnd, GWL_EXSTYLE, msg
     
        'Establece la transparencia
        SetLayeredWindowAttributes hwnd, 0, Valor, LWA_ALPHA
  
        Aplicar_Transparencia = 0
  
    End If
  
    If Err Then
        Aplicar_Transparencia = 2

    End If
  
    
    Exit Function

Aplicar_Transparencia_Err:
    Call RegistrarError(Err.number, Err.Description, "FrmActivarCuenta.Aplicar_Transparencia", Erl)
    Resume Next
    
End Function

Private Sub Form_Load()
    
    On Error GoTo Form_Load_Err
    
    Call FormParser.Parse_Form(Me)
    Call Aplicar_Transparencia(Me.hwnd, 240)
    Me.Picture = LoadInterface("validar.bmp")

    'Cargamos Interface
    If CuentaEmail <> "" Then
        NombreDeCuenta = CuentaEmail

    End If

    ValidacionNumber = RandomNumber(10000, 90000)
    valcar = ValidacionNumber

    
    Exit Sub

Form_Load_Err:
    Call RegistrarError(Err.number, Err.Description, "FrmActivarCuenta.Form_Load", Erl)
    Resume Next
    
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
    
    On Error GoTo Form_MouseMove_Err
    

    If Image2.Tag = "1" Then
        Image2.Picture = Nothing
        Image2.Tag = "0"

    End If

    If Image1.Tag = "1" Then
        Image1.Picture = Nothing
        Image1.Tag = "0"

    End If

    
    Exit Sub

Form_MouseMove_Err:
    Call RegistrarError(Err.number, Err.Description, "FrmActivarCuenta.Form_MouseMove", Erl)
    Resume Next
    
End Sub

Private Sub Image1_Click()
    
    On Error GoTo Image1_Click_Err
    
    Call Sound.Sound_Play(SND_CLICK)
    Unload Me
    frmMasOpciones.Show , frmConnect
    frmMasOpciones.Top = frmMasOpciones.Top + 3000

    
    Exit Sub

Image1_Click_Err:
    Call RegistrarError(Err.number, Err.Description, "FrmActivarCuenta.Image1_Click", Erl)
    Resume Next
    
End Sub

Private Sub Image1_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)

    'Image1.Picture = LoadInterface("validar_volver.bmp")
    ' Image1.Tag = "1"
End Sub

Private Sub Image1_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
    
    On Error GoTo Image1_MouseMove_Err
    

    If Image1.Tag = "0" Then
        Image1.Picture = LoadInterface("validar_volver.bmp")
        Image1.Tag = "1"

    End If

    
    Exit Sub

Image1_MouseMove_Err:
    Call RegistrarError(Err.number, Err.Description, "FrmActivarCuenta.Image1_MouseMove", Erl)
    Resume Next
    
End Sub

Private Sub Image2_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
    
    On Error GoTo Image2_MouseMove_Err
    

    If Image2.Tag = "0" Then
        Image2.Picture = LoadInterface("validar_enviar.bmp")
        Image2.Tag = "1"

    End If

    
    Exit Sub

Image2_MouseMove_Err:
    Call RegistrarError(Err.number, Err.Description, "FrmActivarCuenta.Image2_MouseMove", Erl)
    Resume Next
    
End Sub

Private Sub Image2_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)

    ' Image2.Picture = LoadInterface("validar_enviar.bmp")
End Sub

Private Sub Image2_Click()
    
    On Error GoTo Image2_Click_Err
    

    Call Sound.Sound_Play(SND_CLICK)
    CuentaEmail = NombreDeCuenta.Text
    
    If Len(Validacion.Text) = 6 Then
        If IsNumeric(texVer) Then
            If ValidacionNumber <> texVer Then
                Call MensajeAdvertencia("Codigo de seguridad erroneo.")
                Exit Sub

            End If

        Else
            Call MensajeAdvertencia("Codigo de seguridad invalido.")
            Exit Sub

        End If

    Else
        Call MensajeAdvertencia("Codigo de validación invalido.")
        Exit Sub

    End If

    ValidacionCode = Validacion.Text
                        
    ValidacionNumber = RandomNumber(100000, 900000)
    valcar = ValidacionNumber
    texVer.Text = ""
    
    EstadoLogin = E_MODO.ActivandoCuenta
    
    If frmMain.Socket1.Connected Then
        frmMain.Socket1.Disconnect
        frmMain.Socket1.Cleanup
        DoEvents

    End If

    frmMain.Socket1.HostName = IPdelServidor
    frmMain.Socket1.RemotePort = PuertoDelServidor
    frmMain.Socket1.Connect
    Unload Me

    
    Exit Sub

Image2_Click_Err:
    Call RegistrarError(Err.number, Err.Description, "FrmActivarCuenta.Image2_Click", Erl)
    Resume Next
    
End Sub

Private Sub refuerzo_Click()
    
    On Error GoTo refuerzo_Click_Err
    
    texVer.SetFocus

    
    Exit Sub

refuerzo_Click_Err:
    Call RegistrarError(Err.number, Err.Description, "FrmActivarCuenta.refuerzo_Click", Erl)
    Resume Next
    
End Sub

Private Sub valcar_Click()
    
    On Error GoTo valcar_Click_Err
    
    texVer.SetFocus

    
    Exit Sub

valcar_Click_Err:
    Call RegistrarError(Err.number, Err.Description, "FrmActivarCuenta.valcar_Click", Erl)
    Resume Next
    
End Sub