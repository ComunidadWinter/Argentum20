Attribute VB_Name = "Extra"
'Argentum Online 0.11.6
'Copyright (C) 2002 Márquez Pablo Ignacio
'
'This program is free software; you can redistribute it and/or modify
'it under the terms of the Affero General Public License;
'either version 1 of the License, or any later version.
'
'This program is distributed in the hope that it will be useful,
'but WITHOUT ANY WARRANTY; without even the implied warranty of
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'Affero General Public License for more details.
'
'You should have received a copy of the Affero General Public License
'along with this program; if not, you can find it at http://www.affero.org/oagpl.html
'
'Argentum Online is based on Baronsoft's VB6 Online RPG
'You can contact the original creator of ORE at aaron@baronsoft.com
'for more information about ORE please visit http://www.baronsoft.com/
'
'
'You can contact me at:
'morgolock@speedy.com.ar
'www.geocities.com/gmorgolock
'Calle 3 número 983 piso 7 dto A
'La Plata - Pcia, Buenos Aires - Republica Argentina
'Código Postal 1900
'Pablo Ignacio Márquez

Option Explicit

Public Sub FindLegalPos(ByVal UserIndex As Integer, ByVal Map As Integer, ByRef X As Byte, ByRef Y As Byte)
        '***************************************************
        'Autor: ZaMa
        'Last Modification: 26/03/2009
        'Search for a Legal pos for the user who is being teleported.
        '***************************************************
        
        On Error GoTo FindLegalPos_Err
        

100     If MapData(Map, X, Y).UserIndex <> 0 Or MapData(Map, X, Y).NpcIndex <> 0 Then
                    
            ' Se teletransporta a la misma pos a la que estaba
102         If MapData(Map, X, Y).UserIndex = UserIndex Then Exit Sub
                            
            Dim FoundPlace     As Boolean

            Dim tX             As Long

            Dim tY             As Long

            Dim Rango          As Long

            Dim OtherUserIndex As Integer
    
104         For Rango = 0 To 5
106             For tY = Y - Rango To Y + Rango
108                 For tX = X - Rango To X + Rango

                        'Reviso que no haya User ni NPC
110                     If MapData(Map, tX, tY).UserIndex = 0 And MapData(Map, tX, tY).NpcIndex = 0 Then
                        
112                         If InMapBounds(Map, tX, tY) Then FoundPlace = True
                        
                            Exit For

                        End If

114                 Next tX
        
116                 If FoundPlace Then Exit For
118             Next tY
            
120             If FoundPlace Then Exit For
122         Next Rango
    
124         If FoundPlace Then 'Si encontramos un lugar, listo, nos quedamos ahi
126             X = tX
128             Y = tY
            Else
                'Muy poco probable, pero..
                'Si no encontramos un lugar, sacamos al usuario que tenemos abajo, y si es un NPC, lo pisamos.
130             OtherUserIndex = MapData(Map, X, Y).UserIndex

132             If OtherUserIndex <> 0 Then

                    'Si no encontramos lugar, y abajo teniamos a un usuario, lo pisamos y cerramos su comercio seguro
134                 If UserList(OtherUserIndex).ComUsu.DestUsu > 0 Then

                        'Le avisamos al que estaba comerciando que se tuvo que ir.
136                     If UserList(UserList(OtherUserIndex).ComUsu.DestUsu).flags.UserLogged Then
138                         Call FinComerciarUsu(UserList(OtherUserIndex).ComUsu.DestUsu)
140                         Call WriteConsoleMsg(UserList(OtherUserIndex).ComUsu.DestUsu, "Comercio cancelado. El otro usuario se ha desconectado.", FontTypeNames.FONTTYPE_TALK)
                        

                        End If

                        'Lo sacamos.
142                     If UserList(OtherUserIndex).flags.UserLogged Then
144                         Call FinComerciarUsu(OtherUserIndex)
146                         Call WriteShowMessageBox(OtherUserIndex, "Alguien se ha conectado donde te encontrabas, por favor reconéctate...")
                        

                        End If

                    End If
            
148                 Call CloseSocket(OtherUserIndex)

                End If

            End If

        End If

        
        Exit Sub

FindLegalPos_Err:
150     Call RegistrarError(Err.Number, Err.Description, "Extra.FindLegalPos", Erl)
152     Resume Next
        
End Sub

Public Function EsNewbie(ByVal UserIndex As Integer) As Boolean
        
        On Error GoTo EsNewbie_Err
        
100     EsNewbie = UserList(UserIndex).Stats.ELV <= LimiteNewbie

        
        Exit Function

EsNewbie_Err:
102     Call RegistrarError(Err.Number, Err.Description, "Extra.EsNewbie", Erl)
104     Resume Next
        
End Function

Public Function esArmada(ByVal UserIndex As Integer) As Boolean
        '***************************************************
        'Autor: Pablo (ToxicWaste)
        'Last Modification: 23/01/2007
        '***************************************************
        
        On Error GoTo esArmada_Err
        
100     esArmada = (UserList(UserIndex).Faccion.ArmadaReal = 1)

        
        Exit Function

esArmada_Err:
102     Call RegistrarError(Err.Number, Err.Description, "Extra.esArmada", Erl)
104     Resume Next
        
End Function

Public Function esCaos(ByVal UserIndex As Integer) As Boolean
        '***************************************************
        'Autor: Pablo (ToxicWaste)
        'Last Modification: 23/01/2007
        '***************************************************
        
        On Error GoTo esCaos_Err
        
100     esCaos = (UserList(UserIndex).Faccion.FuerzasCaos = 1)

        
        Exit Function

esCaos_Err:
102     Call RegistrarError(Err.Number, Err.Description, "Extra.esCaos", Erl)
104     Resume Next
        
End Function

Public Function EsGM(ByVal UserIndex As Integer) As Boolean
        '***************************************************
        'Autor: Pablo (ToxicWaste)
        'Last Modification: 23/01/2007
        '***************************************************
        
        On Error GoTo EsGM_Err
        
100     If UserIndex = 0 Then
102         EsGM = False
            Exit Function
        End If
        
104     EsGM = (UserList(UserIndex).flags.Privilegios And (PlayerType.Admin Or PlayerType.Dios Or PlayerType.SemiDios Or PlayerType.Consejero)) <> 0

        
        Exit Function

EsGM_Err:
106     Call RegistrarError(Err.Number, Err.Description, "Extra.EsGM", Erl)
108     Resume Next
        
End Function

Private Function CheckMapRestrictions(ByVal UserIndex As Integer, ByVal Map As Integer) As Boolean

100     With UserList(UserIndex)

102         If EsGM(UserIndex) Then
104             CheckMapRestrictions = True
                Exit Function
            End If

106         If MapInfo(Map).Newbie And Not EsNewbie(UserIndex) Then
108             If .flags.UltimoMensaje <> 101 Then
110                 Call WriteConsoleMsg(UserIndex, "Sólo los newbies pueden entrar a este mapa.", FontTypeNames.FONTTYPE_INFO)
112                 .flags.UltimoMensaje = 101
                End If
                Exit Function
            End If

114         If MapInfo(Map).NoPKs And (Status(UserIndex) = 0 Or Status(UserIndex) = 2) Then
116             If .flags.UltimoMensaje <> 102 Then
118                 Call WriteConsoleMsg(UserIndex, "Sólo los ciudadanos pueden entrar a este mapa.", FontTypeNames.FONTTYPE_INFO)
120                 .flags.UltimoMensaje = 102
                End If
                Exit Function
            End If

122         If MapInfo(Map).NoCiudadanos And (Status(UserIndex) = 1 Or Status(UserIndex) = 3) Then
124             If .flags.UltimoMensaje <> 103 Then
126                 Call WriteConsoleMsg(UserIndex, "Sólo los criminales pueden entrar a este mapa.", FontTypeNames.FONTTYPE_INFO)
128                 .flags.UltimoMensaje = 103
                End If
                Exit Function
            End If

130         If MapInfo(Map).SoloClanes And .GuildIndex <= 0 Then
132             If .flags.UltimoMensaje <> 104 Then
134                 Call WriteConsoleMsg(UserIndex, "Necesitas pertenecer a un clan para entrar a este mapa.", FontTypeNames.FONTTYPE_INFO)
136                 .flags.UltimoMensaje = 104
                End If
                Exit Function
            End If

138         If MapInfo(Map).MinLevel <> 0 And .Stats.ELV < MapInfo(Map).MinLevel Then
140             If .flags.UltimoMensaje <> 105 Then
142                 Call WriteConsoleMsg(UserIndex, "Necesitas ser al menos nivel " & MapInfo(Map).MinLevel & " para entrar a este mapa.", FontTypeNames.FONTTYPE_INFO)
144                 .flags.UltimoMensaje = 105
                End If
                Exit Function
            End If

146         If MapInfo(Map).MaxLevel <> 0 And .Stats.ELV >= MapInfo(Map).MaxLevel Then
148             If .flags.UltimoMensaje <> 106 Then
150                 Call WriteConsoleMsg(UserIndex, "Sólo los personajes inferiores a nivel " & MapInfo(Map).MaxLevel & " pueden entrar a este mapa.", FontTypeNames.FONTTYPE_INFO)
152                 .flags.UltimoMensaje = 106
                End If
                Exit Function
            End If

154         CheckMapRestrictions = True

        End With

End Function

Public Sub DoTileEvents(ByVal UserIndex As Integer, ByVal Map As Integer, ByVal X As Integer, ByVal Y As Integer)

        '***************************************************
        'Autor: Pablo (ToxicWaste) & Unknown (orginal version)
        'Last Modification: 23/01/2007
        'Handles the Map passage of Users. Allows the existance
        'of exclusive maps for Newbies, Royal Army and Caos Legion members
        'and enables GMs to enter every map without restriction.
        'Uses: Mapinfo(map).Restringir = "NEWBIE" (newbies), "ARMADA", "CAOS", "FACCION" or "NO".
        '***************************************************
        On Error GoTo ErrHandler

        Dim nPos   As WorldPos

        Dim EsTeleport As Boolean

        'Controla las salidas
100     If InMapBounds(Map, X, Y) Then
    
102         If MapData(Map, X, Y).ObjInfo.ObjIndex > 0 Then
104             EsTeleport = ObjData(MapData(Map, X, Y).ObjInfo.ObjIndex).OBJType = eOBJType.otTeleport
            End If

106         If (MapData(Map, X, Y).TileExit.Map > 0) And (MapData(Map, X, Y).TileExit.Map <= NumMaps) Then

                ' WyroX: Restricciones de mapas
108             If CheckMapRestrictions(UserIndex, MapData(Map, X, Y).TileExit.Map) Then
110                 If LegalPos(MapData(Map, X, Y).TileExit.Map, MapData(Map, X, Y).TileExit.X, MapData(Map, X, Y).TileExit.Y, UserList(UserIndex).flags.Navegando = 1, , , False) Then
112                     Call WarpUserChar(UserIndex, MapData(Map, X, Y).TileExit.Map, MapData(Map, X, Y).TileExit.X, MapData(Map, X, Y).TileExit.Y, EsTeleport)
            
                    Else
114                     Call ClosestLegalPos(MapData(Map, X, Y).TileExit, nPos)

116                     If nPos.X <> 0 And nPos.Y <> 0 Then
118                         Call WarpUserChar(UserIndex, nPos.Map, nPos.X, nPos.Y, EsTeleport)
                        End If

                    End If
            
                ' Si hay un teleport: movemos al usuario para que no se quede bloqueándolo
120             ElseIf EsTeleport Then
122                 Call ClosestLegalPos(UserList(UserIndex).Pos, nPos)

124                  If nPos.X <> 0 And nPos.Y <> 0 Then
126                      Call WarpUserChar(UserIndex, nPos.Map, nPos.X, nPos.Y, EsTeleport)
                    End If
                End If

                'Te fusite del mapa. La criatura ya no es más tuya ni te reconoce como que vos la atacaste.
                Dim aN As Integer
    
128             aN = UserList(UserIndex).flags.AtacadoPorNpc

130             If aN > 0 Then
132                 NpcList(aN).Movement = NpcList(aN).flags.OldMovement
134                 NpcList(aN).Hostile = NpcList(aN).flags.OldHostil
136                 NpcList(aN).flags.AttackedBy = vbNullString

                End If
    
138             aN = UserList(UserIndex).flags.NPCAtacado

140             If aN > 0 Then
142                 If NpcList(aN).flags.AttackedFirstBy = UserList(UserIndex).name Then
144                     NpcList(aN).flags.AttackedFirstBy = vbNullString

                    End If

                End If

146             UserList(UserIndex).flags.AtacadoPorNpc = 0
148             UserList(UserIndex).flags.NPCAtacado = 0

            End If
    
        End If

        Exit Sub

ErrHandler:
150     Call LogError("Error en DotileEvents. Error: " & Err.Number & " - Desc: " & Err.Description)

End Sub

Function InRangoVision(ByVal UserIndex As Integer, ByVal X As Integer, ByVal Y As Integer) As Boolean
        
        On Error GoTo InRangoVision_Err
        

100     If X > UserList(UserIndex).Pos.X - MinXBorder And X < UserList(UserIndex).Pos.X + MinXBorder Then
102         If Y > UserList(UserIndex).Pos.Y - MinYBorder And Y < UserList(UserIndex).Pos.Y + MinYBorder Then
104             InRangoVision = True
                Exit Function

            End If

        End If

106     InRangoVision = False

        
        Exit Function

InRangoVision_Err:
108     Call RegistrarError(Err.Number, Err.Description, "Extra.InRangoVision", Erl)
110     Resume Next
        
End Function

Function InRangoVisionNPC(ByVal NpcIndex As Integer, X As Integer, Y As Integer) As Boolean
        
        On Error GoTo InRangoVisionNPC_Err
        

100     If X > NpcList(NpcIndex).Pos.X - MinXBorder And X < NpcList(NpcIndex).Pos.X + MinXBorder Then
102         If Y > NpcList(NpcIndex).Pos.Y - MinYBorder And Y < NpcList(NpcIndex).Pos.Y + MinYBorder Then
104             InRangoVisionNPC = True
                Exit Function

            End If

        End If

106     InRangoVisionNPC = False

        
        Exit Function

InRangoVisionNPC_Err:
108     Call RegistrarError(Err.Number, Err.Description, "Extra.InRangoVisionNPC", Erl)
110     Resume Next
        
End Function

Function InMapBounds(ByVal Map As Integer, ByVal X As Integer, ByVal Y As Integer) As Boolean
        
        On Error GoTo InMapBounds_Err
        
            
100     If (Map <= 0 Or Map > NumMaps) Or X < MinXBorder Or X > MaxXBorder Or Y < MinYBorder Or Y > MaxYBorder Then
102         InMapBounds = False
        Else
104         InMapBounds = True

        End If

        
        Exit Function

InMapBounds_Err:
106     Call RegistrarError(Err.Number, Err.Description, "Extra.InMapBounds", Erl)
108     Resume Next
        
End Function

Sub ClosestLegalPos(Pos As WorldPos, ByRef nPos As WorldPos, Optional ByVal PuedeAgua As Boolean = False, Optional ByVal PuedeTierra As Boolean = True)
        '*****************************************************************
        'Author: Unknown (original version)
        'Last Modification: 24/01/2007 (ToxicWaste)
        'Encuentra la posicion legal mas cercana y la guarda en nPos
        '*****************************************************************
        
        On Error GoTo ClosestLegalPos_Err
        

        Dim Notfound As Boolean

        Dim LoopC    As Integer

        Dim tX       As Integer

        Dim tY       As Integer

100     nPos.Map = Pos.Map

102     Do While Not LegalPos(Pos.Map, nPos.X, nPos.Y, PuedeAgua, PuedeTierra, , False)

104         If LoopC > 12 Then
106             Notfound = True
                Exit Do

            End If
    
108         For tY = Pos.Y - LoopC To Pos.Y + LoopC
110             For tX = Pos.X - LoopC To Pos.X + LoopC
            
112                 If LegalPos(nPos.Map, tX, tY, PuedeAgua, PuedeTierra, , False) Then
114                     nPos.X = tX
116                     nPos.Y = tY
                        '¿Hay objeto?
                
118                     tX = Pos.X + LoopC
120                     tY = Pos.Y + LoopC
  
                    End If
        
122             Next tX
124         Next tY
    
126         LoopC = LoopC + 1
    
        Loop

128     If Notfound = True Then
130         nPos.X = 0
132         nPos.Y = 0

        End If

        
        Exit Sub

ClosestLegalPos_Err:
134     Call RegistrarError(Err.Number, Err.Description, "Extra.ClosestLegalPos", Erl)
136     Resume Next
        
End Sub

Sub ClosestStablePos(Pos As WorldPos, ByRef nPos As WorldPos)
        '*****************************************************************
        'Encuentra la posicion legal mas cercana que no sea un portal y la guarda en nPos
        '*****************************************************************
        
        On Error GoTo ClosestStablePos_Err
        

        Dim Notfound As Boolean

        Dim LoopC    As Integer

        Dim tX       As Integer

        Dim tY       As Integer

100     nPos.Map = Pos.Map

102     Do While Not LegalPos(Pos.Map, nPos.X, nPos.Y)

104         If LoopC > 12 Then
106             Notfound = True
                Exit Do

            End If
    
108         For tY = Pos.Y - LoopC To Pos.Y + LoopC
110             For tX = Pos.X - LoopC To Pos.X + LoopC
            
112                 If LegalPos(nPos.Map, tX, tY) And MapData(nPos.Map, tX, tY).TileExit.Map = 0 Then
114                     nPos.X = tX
116                     nPos.Y = tY
                        '¿Hay objeto?
                
118                     tX = Pos.X + LoopC
120                     tY = Pos.Y + LoopC
  
                    End If
        
122             Next tX
124         Next tY
    
126         LoopC = LoopC + 1
    
        Loop

128     If Notfound = True Then
130         nPos.X = 0
132         nPos.Y = 0

        End If

        
        Exit Sub

ClosestStablePos_Err:
134     Call RegistrarError(Err.Number, Err.Description, "Extra.ClosestStablePos", Erl)
136     Resume Next
        
End Sub

Function NameIndex(ByVal name As String) As Integer
        
        On Error GoTo NameIndex_Err
        

        Dim UserIndex As Integer

        '¿Nombre valido?
100     If LenB(name) = 0 Then
102         NameIndex = 0
            Exit Function

        End If

104     If InStrB(name, "+") <> 0 Then
106         name = UCase$(Replace(name, "+", " "))

        End If

108     UserIndex = 1

110     Do Until UCase$(UserList(UserIndex).name) = UCase$(name)
    
112         UserIndex = UserIndex + 1
    
114         If UserIndex > MaxUsers Then
116             NameIndex = 0
                Exit Function

            End If
    
        Loop
 
118     NameIndex = UserIndex
 
        
        Exit Function

NameIndex_Err:
120     Call RegistrarError(Err.Number, Err.Description, "Extra.NameIndex", Erl)
122     Resume Next
        
End Function

Function IP_Index(ByVal inIP As String) As Integer
        
        On Error GoTo IP_Index_Err
        
 
        Dim UserIndex As Integer

        '¿Nombre valido?
100     If LenB(inIP) = 0 Then
102         IP_Index = 0
            Exit Function

        End If
  
104     UserIndex = 1

106     Do Until UserList(UserIndex).ip = inIP
    
108         UserIndex = UserIndex + 1
    
110         If UserIndex > MaxUsers Then
112             IP_Index = 0
                Exit Function

            End If
    
        Loop
 
114     IP_Index = UserIndex

        Exit Function

        
        Exit Function

IP_Index_Err:
116     Call RegistrarError(Err.Number, Err.Description, "Extra.IP_Index", Erl)
118     Resume Next
        
End Function

Function ContarMismaIP(ByVal UserIndex As Integer, ByVal UserIP As String) As Integer
        
        On Error GoTo CheckForSameIP_Err
        

        Dim LoopC As Integer

100     For LoopC = 1 To MaxUsers

102         If UserList(LoopC).flags.UserLogged = True Then
104             If UserList(LoopC).ip = UserIP And UserIndex <> LoopC Then
106                 ContarMismaIP = ContarMismaIP + 1
                End If

            End If

108     Next LoopC

        
        Exit Function

CheckForSameIP_Err:
110     Call RegistrarError(Err.Number, Err.Description, "Extra.MaxConexionesIP", Erl)
112     Resume Next
        
End Function

Sub HeadtoPos(ByVal Head As eHeading, ByRef Pos As WorldPos)
        
        On Error GoTo HeadtoPos_Err
        

        '*****************************************************************
        'Toma una posicion y se mueve hacia donde esta perfilado
        '*****************************************************************
        Dim X  As Integer

        Dim Y  As Integer

        Dim nX As Integer

        Dim nY As Integer

100     X = Pos.X
102     Y = Pos.Y

104     If Head = eHeading.NORTH Then
106         nX = X
108         nY = Y - 1

        End If

110     If Head = eHeading.SOUTH Then
112         nX = X
114         nY = Y + 1

        End If

116     If Head = eHeading.EAST Then
118         nX = X + 1
120         nY = Y

        End If

122     If Head = eHeading.WEST Then
124         nX = X - 1
126         nY = Y

        End If

        'Devuelve valores
128     Pos.X = nX
130     Pos.Y = nY

        
        Exit Sub

HeadtoPos_Err:
132     Call RegistrarError(Err.Number, Err.Description, "Extra.HeadtoPos", Erl)
134     Resume Next
        
End Sub

' Autor: WyroX - 20/01/2021
' Retorna el heading recibo como parámetro pero rotado, según el valor R.
' Si R es 1, rota en sentido horario. Si R es -1, en sentido antihorario.
Function RotateHeading(ByVal Heading As eHeading, ByVal R As Integer) As eHeading
    
    RotateHeading = (Heading + R + 3) Mod 4 + 1
    
End Function

Function LegalPos(ByVal Map As Integer, ByVal X As Integer, ByVal Y As Integer, Optional ByVal PuedeAgua As Boolean = False, Optional ByVal PuedeTierra As Boolean = True, Optional ByVal Montado As Boolean = False, Optional ByVal PuedeTraslado As Boolean = True) As Boolean
        '***************************************************
        'Autor: Pablo (ToxicWaste) & Unknown (orginal version)
        'Last Modification: 23/01/2007
        'Checks if the position is Legal.
        '***************************************************
        '¿Es un mapa valido?
        
        On Error GoTo LegalPos_Err
        
100     If Map <= 0 Or Map > NumMaps Then Exit Function
        
102     If X < MinXBorder Or X > MaxXBorder Then Exit Function
        
104     If Y < MinYBorder Or Y > MaxYBorder Then Exit Function
        
106     With MapData(Map, X, Y)
        
108         If .NpcIndex <> 0 Then Exit Function

110         If .UserIndex <> 0 Then Exit Function
            
112         If Not PuedeTraslado Then
114             If .TileExit.Map > 0 Then Exit Function
            End If
            
116         If Not PuedeAgua Then
118             If (.Blocked And FLAG_AGUA) <> 0 Then Exit Function
            End If
            
120         If Not PuedeTierra Then
122             If (.Blocked And FLAG_AGUA) = 0 Then Exit Function
            End If
            
124         If (.Blocked And eBlock.ALL_SIDES) = eBlock.ALL_SIDES Then Exit Function
        
        End With
        
126     LegalPos = True

        Exit Function

LegalPos_Err:
128     Call RegistrarError(Err.Number, Err.Description, "Extra.LegalPos", Erl)
        
End Function

Function LegalWalk(ByVal Map As Integer, ByVal X As Integer, ByVal Y As Integer, ByVal Heading As eHeading, Optional ByVal PuedeAgua As Boolean = False, Optional ByVal PuedeTierra As Boolean = True, Optional ByVal Montado As Boolean = False, Optional ByVal PuedeTraslado As Boolean = True) As Boolean
        On Error GoTo LegalWalk_Err
        

100     If Map <= 0 Or Map > NumMaps Then Exit Function
        
102     If X < MinXBorder Or X > MaxXBorder Then Exit Function
        
104     If Y < MinYBorder Or Y > MaxYBorder Then Exit Function
        
106     With MapData(Map, X, Y)
        
108         If .NpcIndex <> 0 Then Exit Function

110         If .UserIndex <> 0 Then
112             If UserList(.UserIndex).flags.AdminInvisible = 0 And UserList(.UserIndex).flags.Muerto = 0 Then
                    Exit Function
                End If
            End If
            
114         If Not PuedeTraslado Then
116             If .TileExit.Map > 0 Then Exit Function
            End If
            
118         If Not PuedeAgua Then
120             If (.Blocked And FLAG_AGUA) <> 0 Then Exit Function
            End If
            
122         If Not PuedeTierra Then
124             If (.Blocked And FLAG_AGUA) = 0 Then Exit Function
            End If
            
126         If (.Blocked And 2 ^ (Heading - 1)) <> 0 Then Exit Function
        
        End With
        
128     LegalWalk = True

        
        Exit Function

LegalWalk_Err:
130     Call RegistrarError(Err.Number, Err.Description, "Extra.LegalWalk", Erl)
132     Resume Next
        
End Function

Function LegalPosNPC(ByVal Map As Integer, ByVal X As Integer, ByVal Y As Integer, ByVal AguaValida As Byte, Optional ByVal IsPet As Boolean = False) As Boolean
        
        On Error GoTo LegalPosNPC_Err
        

100     If (Map <= 0 Or Map > NumMaps) Or (X < MinXBorder Or X > MaxXBorder Or Y < MinYBorder Or Y > MaxYBorder) Then
102         LegalPosNPC = False
        
104     ElseIf MapData(Map, X, Y).TileExit.Map > 0 Then
106         LegalPosNPC = False
        
        Else

108         If AguaValida = 0 Then
110             LegalPosNPC = (MapData(Map, X, Y).Blocked And eBlock.ALL_SIDES) <> eBlock.ALL_SIDES And (MapData(Map, X, Y).UserIndex = 0) And (MapData(Map, X, Y).NpcIndex = 0) And (MapData(Map, X, Y).trigger <> eTrigger.POSINVALIDA Or IsPet) And (MapData(Map, X, Y).Blocked And FLAG_AGUA) = 0
            Else
112             LegalPosNPC = (MapData(Map, X, Y).Blocked And eBlock.ALL_SIDES) <> eBlock.ALL_SIDES And (MapData(Map, X, Y).UserIndex = 0) And (MapData(Map, X, Y).NpcIndex = 0) And (MapData(Map, X, Y).trigger <> eTrigger.POSINVALIDA Or IsPet)
            End If
 
        End If

        
        Exit Function

LegalPosNPC_Err:
114     Call RegistrarError(Err.Number, Err.Description, "Extra.LegalPosNPC", Erl)
116     Resume Next
        
End Function

Function LegalWalkNPC(ByVal Map As Integer, ByVal X As Integer, ByVal Y As Integer, ByVal Heading As eHeading, Optional ByVal PuedeAgua As Boolean = False, Optional ByVal PuedeTierra As Boolean = True, Optional ByVal IgnoraInvalida As Boolean = False, Optional ByVal PuedePisar As Boolean) As Boolean
    ' Reescrito por WyroX

    On Error GoTo LegalWalkNPC_Err

    If (Map <= 0 Or Map > NumMaps) Or (X < MinXBorder Or X > MaxXBorder Or Y < MinYBorder Or Y > MaxYBorder) Then
        Exit Function
    End If

    With MapData(Map, X, Y)

        If .TileExit.Map Then Exit Function

        If Not PuedeAgua Then
            If .Blocked And FLAG_AGUA Then
                Exit Function
            End If
        End If

        If Not PuedeTierra Then
            If (.Blocked And FLAG_AGUA) = 0 Then
                Exit Function
            End If
        End If

        If Not PuedePisar Then
            If .UserIndex Then
                If UserList(.UserIndex).flags.AdminInvisible = 0 And UserList(.UserIndex).flags.Muerto = 0 Then
                    Exit Function
                End If
            ElseIf .NpcIndex Then
                Exit Function
            End If
        End If
        
        If Not IgnoraInvalida Then
            If .trigger = eTrigger.POSINVALIDA Then
                Exit Function
            End If
        End If
        
        If .Blocked And 2 ^ (Heading - 1) Then
            Exit Function
        End If

    End With
    
    LegalWalkNPC = True
    
    Exit Function

LegalWalkNPC_Err:
118     Call RegistrarError(Err.Number, Err.Description, "Extra.LegalWalkNPC", Erl)
120     Resume Next
        
End Function

Sub SendHelp(ByVal index As Integer)
        
        On Error GoTo SendHelp_Err
        

        Dim NumHelpLines As Integer

        Dim LoopC        As Integer

100     NumHelpLines = val(GetVar(DatPath & "Help.dat", "INIT", "NumLines"))

102     For LoopC = 1 To NumHelpLines
104         Call WriteConsoleMsg(index, GetVar(DatPath & "Help.dat", "Help", "Line" & LoopC), FontTypeNames.FONTTYPE_INFO)
106     Next LoopC

        
        Exit Sub

SendHelp_Err:
108     Call RegistrarError(Err.Number, Err.Description, "Extra.SendHelp", Erl)
110     Resume Next
        
End Sub

Public Sub Expresar(ByVal NpcIndex As Integer, ByVal UserIndex As Integer)
        
        On Error GoTo Expresar_Err
        

100     If NpcList(NpcIndex).NroExpresiones > 0 Then

            Dim randomi

102         randomi = RandomNumber(1, NpcList(NpcIndex).NroExpresiones)
104         Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessageChatOverHead(NpcList(NpcIndex).Expresiones(randomi), NpcList(NpcIndex).Char.CharIndex, vbWhite))

        End If

        
        Exit Sub

Expresar_Err:
106     Call RegistrarError(Err.Number, Err.Description, "Extra.Expresar", Erl)
108     Resume Next
        
End Sub

Sub LookatTile(ByVal UserIndex As Integer, ByVal Map As Integer, ByVal X As Integer, ByVal Y As Integer)
        
        On Error GoTo LookatTile_Err
        

        'Responde al click del usuario sobre el mapa
        Dim FoundChar      As Byte

        Dim FoundSomething As Byte

        Dim TempCharIndex  As Integer

        Dim Stat           As String

        Dim ft             As FontTypeNames

        '¿Rango Visión? (ToxicWaste)
100     If (Abs(UserList(UserIndex).Pos.Y - Y) > RANGO_VISION_Y) Or (Abs(UserList(UserIndex).Pos.X - X) > RANGO_VISION_X) Then
            Exit Sub

        End If

        '¿Posicion valida?
102     If InMapBounds(Map, X, Y) Then
104         UserList(UserIndex).flags.TargetMap = Map
106         UserList(UserIndex).flags.TargetX = X
108         UserList(UserIndex).flags.TargetY = Y

            '¿Es un obj?
110         If MapData(Map, X, Y).ObjInfo.ObjIndex > 0 Then
                'Informa el nombre
112             UserList(UserIndex).flags.TargetObjMap = Map
114             UserList(UserIndex).flags.TargetObjX = X
116             UserList(UserIndex).flags.TargetObjY = Y
118             FoundSomething = 1
120         ElseIf MapData(Map, X + 1, Y).ObjInfo.ObjIndex > 0 Then

                'Informa el nombre
122             If ObjData(MapData(Map, X + 1, Y).ObjInfo.ObjIndex).OBJType = eOBJType.otPuertas Then
124                 UserList(UserIndex).flags.TargetObjMap = Map
126                 UserList(UserIndex).flags.TargetObjX = X + 1
128                 UserList(UserIndex).flags.TargetObjY = Y
130                 FoundSomething = 1

                End If

132         ElseIf MapData(Map, X + 1, Y + 1).ObjInfo.ObjIndex > 0 Then

134             If ObjData(MapData(Map, X + 1, Y + 1).ObjInfo.ObjIndex).OBJType = eOBJType.otPuertas Then
                    'Informa el nombre
136                 UserList(UserIndex).flags.TargetObjMap = Map
138                 UserList(UserIndex).flags.TargetObjX = X + 1
140                 UserList(UserIndex).flags.TargetObjY = Y + 1
142                 FoundSomething = 1

                End If

144         ElseIf MapData(Map, X, Y + 1).ObjInfo.ObjIndex > 0 Then

146             If ObjData(MapData(Map, X, Y + 1).ObjInfo.ObjIndex).OBJType = eOBJType.otPuertas Then
                    'Informa el nombre
148                 UserList(UserIndex).flags.TargetObjMap = Map
150                 UserList(UserIndex).flags.TargetObjX = X
152                 UserList(UserIndex).flags.TargetObjY = Y + 1
154                 FoundSomething = 1

                End If

            End If
    
156         If FoundSomething = 1 Then
158             UserList(UserIndex).flags.TargetObj = MapData(Map, UserList(UserIndex).flags.TargetObjX, UserList(UserIndex).flags.TargetObjY).ObjInfo.ObjIndex

160             If MostrarCantidad(UserList(UserIndex).flags.TargetObj) Then

162                 Call WriteConsoleMsg(UserIndex, "O*" & UserList(UserIndex).flags.TargetObj & "* - " & MapData(UserList(UserIndex).flags.TargetObjMap, UserList(UserIndex).flags.TargetObjX, UserList(UserIndex).flags.TargetObjY).ObjInfo.Amount & "", FontTypeNames.FONTTYPE_INFO)
            
                Else

164                 If ObjData(UserList(UserIndex).flags.TargetObj).OBJType = eOBJType.otYacimiento Then
166                     Call ActualizarRecurso(Map, UserList(UserIndex).flags.TargetObjX, UserList(UserIndex).flags.TargetObjY)
168                     Call WriteConsoleMsg(UserIndex, ObjData(UserList(UserIndex).flags.TargetObj).name & " - (Minerales disponibles: " & MapData(Map, UserList(UserIndex).flags.TargetObjX, UserList(UserIndex).flags.TargetObjY).ObjInfo.Amount & ")", FontTypeNames.FONTTYPE_INFO)

170                 ElseIf ObjData(UserList(UserIndex).flags.TargetObj).OBJType = eOBJType.otArboles Then
172                     Call ActualizarRecurso(Map, UserList(UserIndex).flags.TargetObjX, UserList(UserIndex).flags.TargetObjY)
174                     Call WriteConsoleMsg(UserIndex, ObjData(UserList(UserIndex).flags.TargetObj).name & " - (Recursos disponibles: " & MapData(Map, UserList(UserIndex).flags.TargetObjX, UserList(UserIndex).flags.TargetObjY).ObjInfo.Amount & ")", FontTypeNames.FONTTYPE_INFO)
                    
176                 ElseIf ObjData(UserList(UserIndex).flags.TargetObj).OBJType = eOBJType.otTeleport Then
178                     If MapData(Map, X, Y).TileExit.Map > 0 Then
180                         If LenB(MapInfo(MapData(Map, X, Y).TileExit.Map).map_name) <> 0 Then
182                             Call WriteConsoleMsg(UserIndex, "Portal a " & MapInfo(MapData(Map, X, Y).TileExit.Map).map_name, FontTypeNames.FONTTYPE_INFO)
                            Else
184                             Call WriteConsoleMsg(UserIndex, "Portal a un mapa desconocido...", FontTypeNames.FONTTYPE_INFO)
                            End If
                        Else
186                         Call WriteConsoleMsg(UserIndex, "Portal hacia la quinta dimensión", FontTypeNames.FONTTYPE_INFO)
                        End If
                    Else
188                     Call WriteConsoleMsg(UserIndex, "O*" & UserList(UserIndex).flags.TargetObj & "*", FontTypeNames.FONTTYPE_INFO)

                    End If

                End If
    
            End If

            '¿Es un personaje?
190         If Y + 1 <= YMaxMapSize Then
192             If MapData(Map, X, Y + 1).UserIndex > 0 Then
194                 TempCharIndex = MapData(Map, X, Y + 1).UserIndex
196                 FoundChar = 1

                End If

198             If MapData(Map, X, Y + 1).NpcIndex > 0 Then
200                 TempCharIndex = MapData(Map, X, Y + 1).NpcIndex
202                 FoundChar = 2

                End If

            End If

            '¿Es un personaje?
204         If FoundChar = 0 Then
206             If MapData(Map, X, Y).UserIndex > 0 Then
208                 TempCharIndex = MapData(Map, X, Y).UserIndex
210                 FoundChar = 1

                End If

212             If MapData(Map, X, Y).NpcIndex > 0 Then
214                 TempCharIndex = MapData(Map, X, Y).NpcIndex
216                 FoundChar = 2

                End If

            End If
    
            'Reaccion al personaje
218         If FoundChar = 1 Then '  ¿Encontro un Usuario?
            
220             If UserList(TempCharIndex).flags.AdminInvisible = 0 Or CompararPrivilegios(UserIndex, TempCharIndex) >= 0 Then
            
                    'If LenB(UserList(TempCharIndex).DescRM) = 0 Then 'No tiene descRM y quiere que se vea su nombre.
                    
222                 If UserList(TempCharIndex).showName Or CompararPrivilegios(UserIndex, TempCharIndex) >= 0 Then
                
224                     If UserList(TempCharIndex).flags.Privilegios = user Then
                    
                            Dim Fragsnick As String
    
226                         If EsGM(UserIndex) Then
228                             Stat = Stat & " <" & ListaClases(UserList(TempCharIndex).clase) & " " & ListaRazas(UserList(TempCharIndex).raza) & " Nivel: " & UserList(TempCharIndex).Stats.ELV & ">"
                            End If
    
                            'End If
230                         If EsNewbie(TempCharIndex) Then
232                             Stat = Stat & " <Newbie>"
                            End If
    
234                         If UserList(UserIndex).Stats.UserSkills(eSkill.Supervivencia) > 49 Then
236                             If UserList(TempCharIndex).flags.Envenenado > 0 Then
238                                 Fragsnick = " | Envenenado"
                                End If
    
240                             If UserList(TempCharIndex).flags.Ceguera = 1 Then
242                                 Fragsnick = Fragsnick & " | Ciego"
                                End If
    
244                             If UserList(TempCharIndex).flags.Incinerado = 1 Then
246                                 Fragsnick = Fragsnick & " | Incinerado"
                                End If
    
248                             If UserList(TempCharIndex).flags.Paralizado = 1 Then
250                                 Fragsnick = Fragsnick & " | Paralizado"
                                End If
    
252                             If UserList(TempCharIndex).flags.Inmovilizado = 1 Then
254                                 Fragsnick = Fragsnick & " | Inmovilizado"
                                End If
    
256                             If UserList(TempCharIndex).Counters.Trabajando > 0 Then
258                                 Fragsnick = Fragsnick & " | Trabajando"
                                End If
    
260                             If UserList(TempCharIndex).flags.invisible = 1 Then
262                                 Fragsnick = Fragsnick & " | Invisible"
                                End If
    
264                             If UserList(TempCharIndex).flags.Oculto = 1 Then
266                                 Fragsnick = Fragsnick & " | Oculto"
                                End If
    
268                             If UserList(TempCharIndex).flags.Estupidez = 1 Then
270                                 Fragsnick = Fragsnick & " | Estupido"
                                End If
    
272                             If UserList(TempCharIndex).flags.Maldicion = 1 Then
274                                 Fragsnick = Fragsnick & " | Maldito"
                                End If
    
276                             If UserList(TempCharIndex).flags.Silenciado = 1 Then
278                                 Fragsnick = Fragsnick & " | Silenciado"
                                End If
    
280                             If UserList(TempCharIndex).flags.Comerciando = True Then
282                                 Fragsnick = Fragsnick & " | Comerciando"
                                End If
    
284                             If UserList(TempCharIndex).flags.Descansar = 1 Then
286                                 Fragsnick = Fragsnick & " | Descansando"
                                End If
    
288                             If UserList(TempCharIndex).flags.Meditando = True Then
290                                 Fragsnick = Fragsnick & " | Concentrado"
                                End If
    
292                             If UserList(TempCharIndex).flags.BattleModo = 1 Then
294                                 Fragsnick = Fragsnick & " | Modo Battle"
                                End If
                            
296                             If UserList(TempCharIndex).Stats.MinHp = 0 Then
298                                 Stat = Stat & " <Muerto>"
300                             ElseIf UserList(TempCharIndex).Stats.MinHp < (UserList(TempCharIndex).Stats.MaxHp * 0.1) Then
302                                 Stat = Stat & " <Casi muerto" & Fragsnick & ">"
304                             ElseIf UserList(TempCharIndex).Stats.MinHp < (UserList(TempCharIndex).Stats.MaxHp * 0.5) Then
306                                 Stat = Stat & " <Malherido" & Fragsnick & ">"
308                             ElseIf UserList(TempCharIndex).Stats.MinHp < (UserList(TempCharIndex).Stats.MaxHp * 0.75) Then
310                                 Stat = Stat & " <Herido" & Fragsnick & ">"
312                             ElseIf UserList(TempCharIndex).Stats.MinHp < (UserList(TempCharIndex).Stats.MaxHp * 0.99) Then
314                                 Stat = Stat & " <Levemente herido" & Fragsnick & ">"
                                Else
316                                 Stat = Stat & " <Intacto" & Fragsnick & ">"
                                End If
    
                            End If
                    
318                         If UserList(TempCharIndex).Faccion.ArmadaReal = 1 Then
320                             Stat = Stat & " <" & TituloReal(TempCharIndex) & ">"
322                             ft = FontTypeNames.FONTTYPE_CONSEJOVesA
324                         ElseIf UserList(TempCharIndex).Faccion.FuerzasCaos = 1 Then
326                             Stat = Stat & " <" & TituloCaos(TempCharIndex) & ">"
328                             ft = FontTypeNames.FONTTYPE_CONSEJOCAOSVesA
                            End If
                    
330                         If UserList(TempCharIndex).GuildIndex > 0 Then
332                             Stat = Stat & " <" & modGuilds.GuildName(UserList(TempCharIndex).GuildIndex) & ">"
                            End If
    
                        End If ' If user > 0 then
                                
334                     If Not UserList(TempCharIndex).flags.Privilegios And PlayerType.user Then
336                         If UserList(TempCharIndex).flags.Privilegios = Consejero Then
338                             Stat = Stat & " <Game Desing>"
340                             ft = FontTypeNames.FONTTYPE_GM
    
                            End If
    
342                         If UserList(TempCharIndex).flags.Privilegios = SemiDios Then
344                             Stat = Stat & " <Game Master>"
346                             ft = FontTypeNames.FONTTYPE_GM
    
                            End If
    
348                         If UserList(TempCharIndex).flags.Privilegios = Dios Then
350                             Stat = Stat & " <Administrador>"
352                             ft = FontTypeNames.FONTTYPE_DIOS
    
                            End If
                            
354                         If UserList(TempCharIndex).flags.Privilegios = PlayerType.Admin Then
356                             Stat = Stat & " <Administrador>"
358                             ft = FontTypeNames.FONTTYPE_DIOS
    
                            End If
                        
360                     ElseIf UserList(TempCharIndex).Faccion.Status = 0 Then
362                         ft = FontTypeNames.FONTTYPE_CRIMINAL
364                     ElseIf UserList(TempCharIndex).Faccion.Status = 1 Then
366                         ft = FontTypeNames.FONTTYPE_CITIZEN
                        End If
                        
368                     If UserList(TempCharIndex).flags.Casado = 1 Then
370                         Stat = Stat & " <Pareja de " & UserList(TempCharIndex).flags.Pareja & ">"
    
                        End If
                        
372                     If Len(UserList(TempCharIndex).Desc) > 0 Then
374                         Stat = "Ves a " & UserList(TempCharIndex).name & Stat & " - " & UserList(TempCharIndex).Desc
                        Else
376                         Stat = "Ves a " & UserList(TempCharIndex).name & Stat
    
                        End If
                     
                        ' Else  'Si tiene descRM la muestro siempre.
                        '   Stat = UserList(TempCharIndex).DescRM
                        '   ft = FontTypeNames.FONTTYPE_INFOBOLD
                        ' End If
                
378                     If LenB(Stat) > 0 Then
380                         Call WriteConsoleMsg(UserIndex, Stat, ft)
                        End If
                
382                     FoundSomething = 1
384                     UserList(UserIndex).flags.TargetUser = TempCharIndex
386                     UserList(UserIndex).flags.TargetNPC = 0
388                     UserList(UserIndex).flags.TargetNpcTipo = eNPCType.Comun

                    Else
390                     Call WriteConsoleMsg(UserIndex, "Ves a ??? <Game Master>", FontTypeNames.FONTTYPE_GM)
    
392                     UserList(UserIndex).flags.TargetUser = TempCharIndex
394                     UserList(UserIndex).flags.TargetNPC = 0
396                     UserList(UserIndex).flags.TargetNpcTipo = eNPCType.Comun
    
                    End If
                End If
            End If

398         If FoundChar = 2 Then '¿Encontro un NPC?

                Dim estatus As String

400             If EsGM(UserIndex) Or UserList(UserIndex).Stats.UserSkills(eSkill.Supervivencia) >= 75 Then
402                 estatus = "<" & NpcList(TempCharIndex).Stats.MinHp & "/" & NpcList(TempCharIndex).Stats.MaxHp
                    
404             ElseIf UserList(UserIndex).Stats.UserSkills(eSkill.Supervivencia) >= 50 Then
406                 If NpcList(TempCharIndex).Stats.MaxHp <> 0 Then
408                     estatus = "<" & Round((NpcList(TempCharIndex).Stats.MinHp / NpcList(TempCharIndex).Stats.MaxHp) * 100#, 0) & "%"
                    End If
 
410             ElseIf UserList(UserIndex).Stats.UserSkills(eSkill.Supervivencia) >= 25 Then
                
412                 If NpcList(TempCharIndex).Stats.MinHp < (NpcList(TempCharIndex).Stats.MaxHp * 0.1) Then
414                     estatus = "<Agonizando"
416                 ElseIf NpcList(TempCharIndex).Stats.MinHp < (NpcList(TempCharIndex).Stats.MaxHp * 0.2) Then
418                     estatus = "<Casi muerto"
420                 ElseIf NpcList(TempCharIndex).Stats.MinHp < (NpcList(TempCharIndex).Stats.MaxHp * 0.5) Then
422                     estatus = "<Malherido"
424                 ElseIf NpcList(TempCharIndex).Stats.MinHp < (NpcList(TempCharIndex).Stats.MaxHp * 0.7) Then
426                     estatus = "<Herido"
428                 ElseIf NpcList(TempCharIndex).Stats.MinHp < (NpcList(TempCharIndex).Stats.MaxHp * 0.95) Then
430                     estatus = "<Levemente herido"
                    Else
432                     estatus = "<Intacto"
                    End If
                    
                Else
434                 If NpcList(TempCharIndex).Stats.MinHp < NpcList(TempCharIndex).Stats.MaxHp Then
436                     estatus = "<Herido"
                    Else
438                     estatus = "<Intacto"
                    End If
                        
                End If
                        
440             If NpcList(TempCharIndex).flags.Envenenado > 0 Then
442                 estatus = estatus & " | Envenenado"
                End If
                        
444             If NpcList(TempCharIndex).flags.Paralizado = 1 Then
446                 If UserList(UserIndex).Stats.UserSkills(eSkill.Supervivencia) >= 100 Then
448                     estatus = estatus & " | Paralizado (" & CInt(NpcList(TempCharIndex).Contadores.Paralisis / 6.5) & "s)"
                    Else
450                     estatus = estatus & " | Paralizado"
                    End If
                End If
                        
452             If NpcList(TempCharIndex).flags.Inmovilizado = 1 Then
454                 If UserList(UserIndex).Stats.UserSkills(eSkill.Supervivencia) >= 100 Then
456                     estatus = estatus & " | Inmovilizado (" & CInt(NpcList(TempCharIndex).Contadores.Paralisis / 6.5) & "s)"
                    Else
458                     estatus = estatus & " | Inmovilizado"

                    End If

                End If
                        
460             estatus = estatus & ">"
    
                'End If
            
462             If Len(NpcList(TempCharIndex).Desc) > 1 Then
                    ' WyroX: Hacemos que se detenga a hablar un momento :P
                    If NpcList(TempCharIndex).Movement = Caminata Then
                        NpcList(TempCharIndex).Contadores.IntervaloMovimiento = GetTickCount + 5000 - NpcList(TempCharIndex).IntervaloMovimiento ' 5 segundos
                    End If

                    'Optimizacion de protocolo por Ladder
464                 Call WriteChatOverHead(UserIndex, "NPCDESC*" & NpcList(TempCharIndex).Numero, NpcList(TempCharIndex).Char.CharIndex, vbWhite)
466             ElseIf TempCharIndex = CentinelaNPCIndex Then
                    'Enviamos nuevamente el texto del centinela según quien pregunta
468                 Call modCentinela.CentinelaSendClave(UserIndex)
                
470             ElseIf NpcList(TempCharIndex).MaestroUser > 0 Then
472                 Call WriteConsoleMsg(UserIndex, "NPCNAME*" & NpcList(TempCharIndex).Numero & "* es mascota de " & UserList(NpcList(TempCharIndex).MaestroUser).name & " " & estatus, FontTypeNames.FONTTYPE_INFO)
                
                Else
                
474                 Call WriteConsoleMsg(UserIndex, "NPCNAME*" & NpcList(TempCharIndex).Numero & "*" & " " & estatus, FontTypeNames.FONTTYPE_INFO)
                    ' If UserList(UserIndex).flags.Privilegios And (PlayerType.Dios Or PlayerType.Admin) Then
                    ' Call WriteConsoleMsg(UserIndex, "Le pegó primero: " & NpcList(TempCharIndex).flags.AttackedFirstBy & ".", FontTypeNames.FONTTYPE_INFO)
                    ' Call WriteConsoleMsg(UserIndex, NpcList(TempCharIndex).Char.CharIndex, FontTypeNames.FONTTYPE_INFO)
                    'End If
                
                End If

476             FoundSomething = 1
478             UserList(UserIndex).flags.TargetNpcTipo = NpcList(TempCharIndex).NPCtype
480             UserList(UserIndex).flags.TargetNPC = TempCharIndex
482             UserList(UserIndex).flags.TargetUser = 0
484             UserList(UserIndex).flags.TargetObj = 0


            
            Dim i As Long, j As Long
                    
486                 For i = 1 To MAXUSERQUESTS
                    
488                     With UserList(UserIndex).QuestStats.Quests(i)
                    
490                         If .QuestIndex Then
492                             If QuestList(.QuestIndex).RequiredTargetNPCs Then
                    
494                                 For j = 1 To QuestList(.QuestIndex).RequiredTargetNPCs
                    
496                                     If QuestList(.QuestIndex).RequiredTargetNPC(j).NpcIndex = NpcList(TempCharIndex).Numero Then
498                                         If QuestList(.QuestIndex).RequiredTargetNPC(j).Amount > .NPCsTarget(j) Then
500                                             .NPCsTarget(j) = .NPCsTarget(j) + 1
                    
                                            End If
                                                
502                                         If QuestList(.QuestIndex).RequiredTargetNPC(j).Amount = .NPCsTarget(j) Then
504                                             Call FinishQuest(UserIndex, .QuestIndex, i)
506                                             Call WriteUpdateNPCSimbolo(UserIndex, TempCharIndex, 1)
508                                             Call WriteChatOverHead(UserIndex, "¡Quest Finalizada!", NpcList(TempCharIndex).Char.CharIndex, vbYellow)
510                                             Call WriteConsoleMsg(UserIndex, "Quest Finalizada!", FontTypeNames.FONTTYPE_INFOIAO)
                                            End If
                    
                                        End If
                    
512                                 Next j
                    
                                End If
                    
                            End If
                    
                        End With
                    
514                 Next i
        
            End If
    
516         If FoundChar = 0 Then
518             UserList(UserIndex).flags.TargetNPC = 0
520             UserList(UserIndex).flags.TargetNpcTipo = eNPCType.Comun
522             UserList(UserIndex).flags.TargetUser = 0

            End If
    
            '*** NO ENCOTRO NADA ***
524         If FoundSomething = 0 Then
526             UserList(UserIndex).flags.TargetNPC = 0
528             UserList(UserIndex).flags.TargetNpcTipo = eNPCType.Comun
530             UserList(UserIndex).flags.TargetUser = 0
532             UserList(UserIndex).flags.TargetObj = 0
534             UserList(UserIndex).flags.TargetObjMap = 0
536             UserList(UserIndex).flags.TargetObjX = 0
538             UserList(UserIndex).flags.TargetObjY = 0

                ' Call WriteConsoleMsg(UserIndex, "No ves nada interesante.", FontTypeNames.FONTTYPE_INFO)
            End If

        Else

540         If FoundSomething = 0 Then
542             UserList(UserIndex).flags.TargetNPC = 0
544             UserList(UserIndex).flags.TargetNpcTipo = eNPCType.Comun
546             UserList(UserIndex).flags.TargetUser = 0
548             UserList(UserIndex).flags.TargetObj = 0
550             UserList(UserIndex).flags.TargetObjMap = 0
552             UserList(UserIndex).flags.TargetObjX = 0
554             UserList(UserIndex).flags.TargetObjY = 0

                '  Call WriteConsoleMsg(UserIndex, "No ves nada interesante.", FontTypeNames.FONTTYPE_INFO)
            End If

        End If

        
        Exit Sub

LookatTile_Err:
556         Call RegistrarError(Err.Number, Err.Description & " Pos: " & Map & "-" & X & "-" & Y & " Usuario: " & UserList(UserIndex).name & " Extra.LookatTile", Erl)
558     If FoundChar = 2 Then
560         Call RegistrarError(Err.Number, Err.Description & " Pos: " & Map & "-" & X & "-" & Y & "Npc: " & NpcList(TempCharIndex).Numero & " Usuario: " & UserList(UserIndex).name & "Extra.LookatTile X LADDER", Erl)
        End If
562     Resume Next
        
End Sub

Function FindDirection(Pos As WorldPos, Target As WorldPos) As eHeading
        
        On Error GoTo FindDirection_Err
        

        '*****************************************************************
        'Devuelve la direccion en la cual el target se encuentra
        'desde pos, 0 si la direc es igual
        '*****************************************************************
        Dim X As Integer

        Dim Y As Integer

100     X = Pos.X - Target.X
102     Y = Pos.Y - Target.Y

        'NE
104     If Sgn(X) = -1 And Sgn(Y) = 1 Then
106         FindDirection = IIf(RandomNumber(0, 1), eHeading.NORTH, eHeading.EAST)
            Exit Function

        End If

        'NW
108     If Sgn(X) = 1 And Sgn(Y) = 1 Then
110         FindDirection = IIf(RandomNumber(0, 1), eHeading.WEST, eHeading.NORTH)
            Exit Function

        End If

        'SW
112     If Sgn(X) = 1 And Sgn(Y) = -1 Then
114         FindDirection = IIf(RandomNumber(0, 1), eHeading.WEST, eHeading.SOUTH)
            Exit Function

        End If

        'SE
116     If Sgn(X) = -1 And Sgn(Y) = -1 Then
118         FindDirection = IIf(RandomNumber(0, 1), eHeading.SOUTH, eHeading.EAST)
            Exit Function

        End If

        'Sur
120     If Sgn(X) = 0 And Sgn(Y) = -1 Then
122         FindDirection = eHeading.SOUTH
            Exit Function

        End If

        'norte
124     If Sgn(X) = 0 And Sgn(Y) = 1 Then
126         FindDirection = eHeading.NORTH
            Exit Function

        End If

        'oeste
128     If Sgn(X) = 1 And Sgn(Y) = 0 Then
130         FindDirection = eHeading.WEST
            Exit Function

        End If

        'este
132     If Sgn(X) = -1 And Sgn(Y) = 0 Then
134         FindDirection = eHeading.EAST
            Exit Function

        End If

        'misma
136     If Sgn(X) = 0 And Sgn(Y) = 0 Then
138         FindDirection = 0
            Exit Function

        End If

        
        Exit Function

FindDirection_Err:
140     Call RegistrarError(Err.Number, Err.Description, "Extra.FindDirection", Erl)
142     Resume Next
        
End Function

'[Barrin 30-11-03]
Public Function ItemNoEsDeMapa(ByVal index As Integer) As Boolean
        
        On Error GoTo ItemNoEsDeMapa_Err
        

100     ItemNoEsDeMapa = ObjData(index).OBJType <> eOBJType.otPuertas And ObjData(index).OBJType <> eOBJType.otForos And ObjData(index).OBJType <> eOBJType.otCarteles And ObjData(index).OBJType <> eOBJType.otArboles And ObjData(index).OBJType <> eOBJType.otYacimiento And ObjData(index).OBJType <> eOBJType.otTeleport And ObjData(index).OBJType <> eOBJType.OtCorreo And ObjData(index).OBJType <> eOBJType.OtDecoraciones

        
        Exit Function

ItemNoEsDeMapa_Err:
102     Call RegistrarError(Err.Number, Err.Description, "Extra.ItemNoEsDeMapa", Erl)
104     Resume Next
        
End Function

'[/Barrin 30-11-03]

Public Function MostrarCantidad(ByVal index As Integer) As Boolean
        
        On Error GoTo MostrarCantidad_Err
        
100     MostrarCantidad = ObjData(index).OBJType <> eOBJType.otPuertas And ObjData(index).OBJType <> eOBJType.otForos And ObjData(index).OBJType <> eOBJType.otCarteles And ObjData(index).OBJType <> eOBJType.otYacimiento And ObjData(index).OBJType <> eOBJType.otArboles And ObjData(index).OBJType <> eOBJType.OtCorreo And ObjData(index).OBJType <> eOBJType.otTeleport

        
        Exit Function

MostrarCantidad_Err:
102     Call RegistrarError(Err.Number, Err.Description, "Extra.MostrarCantidad", Erl)
104     Resume Next
        
End Function

Public Function EsObjetoFijo(ByVal OBJType As eOBJType) As Boolean
        
        On Error GoTo EsObjetoFijo_Err
        

100     EsObjetoFijo = OBJType = eOBJType.otForos Or OBJType = eOBJType.otCarteles Or OBJType = eOBJType.otArboles Or OBJType = eOBJType.otYacimiento Or OBJType = eOBJType.OtDecoraciones

        
        Exit Function

EsObjetoFijo_Err:
102     Call RegistrarError(Err.Number, Err.Description, "Extra.EsObjetoFijo", Erl)
104     Resume Next
        
End Function