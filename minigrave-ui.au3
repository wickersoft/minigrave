#include <Array.au3>
#include <ComUDF.au3>
#include <WinAPI.au3>
#include <GDIPlus.au3>

#include <ButtonConstants.au3>
#include <ColorConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <UpdownConstants.au3>
#Region ### START Koda GUI section ### Form=C:\Users\Dennis\Desktop\minigrave-ui.kxf
$Form1_1 = GUICreate("minigrave-ui 1.0.0", 754, 543, 483, 200, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_WINDOWEDGE))
$iLeftmostSteps = GUICtrlCreateInput("1500", 8, 96, 57, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_RIGHT))
$Updown1 = GUICtrlCreateUpdown($iLeftmostSteps, BitOR($GUI_SS_DEFAULT_UPDOWN, $UDS_ARROWKEYS, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1, 32767, 1500)
$iTopmostSteps = GUICtrlCreateInput("1500", 72, 64, 57, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_RIGHT))
$Updown2 = GUICtrlCreateUpdown($iTopmostSteps, BitOR($GUI_SS_DEFAULT_UPDOWN, $UDS_ARROWKEYS, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1, 32767, 0)
$iWidthSteps = GUICtrlCreateInput("0", 544, 452, 57, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_RIGHT))
$Updown3 = GUICtrlCreateUpdown($iWidthSteps, BitOR($GUI_SS_DEFAULT_UPDOWN, $UDS_ARROWKEYS, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1, 32767, 0)
GUICtrlSetState(-1, $GUI_DISABLE)
$iHeightSteps = GUICtrlCreateInput("0", 480, 488, 57, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_RIGHT))
$Updown4 = GUICtrlCreateUpdown($iHeightSteps, BitOR($GUI_SS_DEFAULT_UPDOWN, $UDS_ARROWKEYS, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1, 32767, 0)
GUICtrlSetState(-1, $GUI_DISABLE)
$iStepsPerPx = GUICtrlCreateInput("1", 664, 61, 81, 21)
$Updown5 = GUICtrlCreateUpdown($iStepsPerPx, BitOR($GUI_SS_DEFAULT_UPDOWN, $UDS_ARROWKEYS, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1, 100, 1)
$Label1 = GUICtrlCreateLabel("Steps/px", 616, 64, 47, 17)
$iGear = GUICtrlCreateInput("4", 664, 107, 81, 21)
$Updown6 = GUICtrlCreateUpdown($iGear, BitOR($GUI_SS_DEFAULT_UPDOWN, $UDS_ARROWKEYS, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1, 8, 0)
$Label2 = GUICtrlCreateLabel("Gear", 633, 111, 27, 17)
$bGotoTopLeft = GUICtrlCreateButton("Goto", 8, 56, 57, 33)
$bGotoBotRight = GUICtrlCreateButton("Goto", 544, 480, 57, 33)
$bGotoTopRight = GUICtrlCreateButton("Goto", 544, 56, 57, 33)
$bGotoBotLeft = GUICtrlCreateButton("Goto", 8, 488, 57, 33)
$bGoHome = GUICtrlCreateButton("Detect Home", 608, 408, 137, 49)
$bBurn = GUICtrlCreateButton("Burn", 608, 464, 137, 49)
GUICtrlSetState(-1, $GUI_DISABLE)
$Progress1 = GUICtrlCreateProgress(8, 528, 737, 9)
GUICtrlSetState(-1, $GUI_HIDE)
$bLoop = GUICtrlCreateButton("Loop", 608, 360, 57, 41)
$Pic1 = GUICtrlCreatePic("", 72, 96, 465, 385, -1, $GUI_WS_EX_PARENTDRAG)
$bLaserOn = GUICtrlCreateButton("Laser ON", 688, 360, 57, 41)
$bLoadFile = GUICtrlCreateButton("Load File", 8, 8, 57, 33)
$iComPort = GUICtrlCreateInput("\\.\COM9", 569, 15, 65, 21)
$bConnectReset = GUICtrlCreateButton("Connect + Reset", 640, 8, 105, 33)
$iBacklash = GUICtrlCreateInput("25", 664, 130, 81, 21)
$Updown7 = GUICtrlCreateUpdown($iBacklash, BitOR($GUI_SS_DEFAULT_UPDOWN, $UDS_ARROWKEYS, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1, 255, 0)
$Label3 = GUICtrlCreateLabel("Backlash", 613, 134, 48, 17)
$Label4 = GUICtrlCreateLabel("Top Z", 131, 67, 33, 17)
$Label5 = GUICtrlCreateLabel("Left X", 17, 120, 32, 17)
$Label6 = GUICtrlCreateLabel("Height", 443, 492, 35, 17)
$Label7 = GUICtrlCreateLabel("Width", 554, 435, 32, 17)
$lDimensionsPreview = GUICtrlCreateLabel("0x0mm                                         ", 72, 484, 160, 17)
$iSkipZ = GUICtrlCreateInput("0", 664, 84, 81, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_NUMBER))
$Updown8 = GUICtrlCreateUpdown($iSkipZ, BitOR($GUI_SS_DEFAULT_UPDOWN, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1, 100, 0)
$Label8 = GUICtrlCreateLabel("Skip Z", 626, 88, 35, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

$start_gear = 3
Const $iBaud = 1000000
$sCOM = "\\.\COM7"
Global $hComPort
Global $hImage = "", $hbwImage = ""
Global $cancel_pressed = 0

GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

_GDIPlus_Startup()
$hBrushBg = _GDIPlus_BrushCreateSolid(0xFFF0F0F0)
$brushBlue = _GDIPlus_BrushCreateSolid(0xFF0000FF)
$hGraphic = _GDIPlus_GraphicsCreateFromHWND($Form1_1)

GUICtrlSetData($iGear, $start_gear)

;lockUiNoPort()

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case 0
		Case $GUI_EVENT_CLOSE
			Exit
		Case $bConnectReset
			connectToPort(GUICtrlRead($iComPort))
		Case $bGoHome
			detectHome()
			setGear()
		Case $bGotoTopLeft
			accelToAndWait(GUICtrlReadNumber($iLeftmostSteps), GUICtrlReadNumber($iTopmostSteps))
		Case $bGotoTopRight
			accelToAndWait(GUICtrlReadNumber($iLeftmostSteps) + GUICtrlReadNumber($iWidthSteps), GUICtrlReadNumber($iTopmostSteps))
		Case $bGotoBotLeft
			accelToAndWait(GUICtrlReadNumber($iLeftmostSteps), GUICtrlReadNumber($iTopmostSteps) - GUICtrlReadNumber($iHeightSteps))
		Case $bGotoBotRight
			accelToAndWait(GUICtrlReadNumber($iLeftmostSteps) + GUICtrlReadNumber($iWidthSteps), GUICtrlReadNumber($iTopmostSteps) - GUICtrlReadNumber($iHeightSteps))
		Case $iGear
			setGear()
		Case $iBacklash
			setBacklash()
		Case $iStepsPerPx
			setStepsPerPixel()
			validateStepRatios()
		Case $bLoop
			bitmapTest(1)
		Case $bLaserOn
			bitmapTest(0)
		Case $bLoadFile
			loadFile()
		Case $iSkipZ
			validateStepRatios()
		Case $bBurn
			burn()
		Case Else
			;ConsoleWrite("control " & $nMsg & @CRLF)
	EndSwitch
WEnd

; React on a button click
Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	;ConsoleWrite("k> " & $lParam & @CRLF)
	If $wParam = $bBurn Then
		ConsoleWrite("cancel!" & @CRLF)
		$cancel_pressed = 1
	EndIf
	; On exit the default AutoIt3 internal message handler will run
	; It will also run if "Return" returns $GUI_RUNDEFMSG as below
	; Using "Return" with any other value (or no value at all) means the AutoIt handler
	; will not run
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND

Func connectToPort($port)
	_ComClosePort($hComPort)

	If openComPort() Then
		resetUi()

		setGear()
		setStepsPerPixel()
		setBacklash()

		unlockUiNoPort()
	Else
		lockUiNoPort()
	EndIf
EndFunc   ;==>connectToPort


; ===================================================         ACTUALLY BURNING IT      ======================================================

Func burn()
	lockUiBurning()
	displayFile()
	$cancel_pressed = 0
	GUICtrlSetData($Progress1, 0)

	$leftXBound = GUICtrlReadNumber($iLeftmostSteps) - 1024
	$rightXBound = $leftXBound + _GDIPlus_ImageGetWidth($hbwImage) * GUICtrlReadNumber($iStepsPerPx) + 2 * 1024 + GUICtrlReadNumber($iBacklash)

	$prev_start = $rightXBound
	$z_start = GUICtrlReadNumber($iTopmostSteps)
	$z_location = $z_start
	$z_bottom = $z_start - GUICtrlReadNumber($iHeightSteps)
	$z_steps = GUICtrlReadNumber($iSkipZ) + 1

	ConsoleWrite("!> z_steps: " & $z_steps & @CRLF)

	setBitmapWidth()

	$prev_image_z = -1
	While $z_location > $z_bottom
		If $cancel_pressed Then ExitLoop

		$z_image_location = Floor(($z_start - $z_location) / GUICtrlReadNumber($iStepsPerPx))
		If $z_image_location <> $prev_image_z Then
			Dim $pixel_buffer[1024]
			For $i = 0 To _GDIPlus_ImageGetWidth($hbwImage) - 1
				$array_index = Floor($i / 8)
				$array_bit = 7 - Mod($i, 8)

				$pixel = _GDIPlus_BitmapGetPixel($hbwImage, $i, $z_image_location)
				If BitAND($pixel, 0x00FFFFFF) = 0 Then
					$pixel_buffer[$array_index] = BitOR($pixel_buffer[$array_index], BitShift(1, -$array_bit))
				EndIf
			Next

			$bin_string = "0x"
			For $i = 0 To Ceiling(_GDIPlus_ImageGetWidth($hbwImage) / 8) - 1
				$bin_string &= Hex($pixel_buffer[$i], 2)
			Next
			writeBitmap(Binary($bin_string))
			$prev_image_z = $z_location
		EndIf

		displayLiveProgress($z_location, $z_start, $z_bottom)
		; write bitmap

		If $prev_start = $leftXBound Then
			accelToAndWait($rightXBound, $z_location)
			; send it to the left
			drawLine(0)
			$prev_start = $rightXBound
		Else
			accelToAndWait($leftXBound, $z_location)
			; send it to the right
			drawLine(1)
			$prev_start = $leftXBound
		EndIf
		GUICtrlSetData($Progress1, 100 * ($z_start - $z_location) / GUICtrlReadNumber($iHeightSteps))

		$z_location -= $z_steps
	WEnd

	While GUIGetMsg()
	WEnd
	detectHome()
	unlockUiBurning()
	displayFile()
EndFunc   ;==>burn

Func drawLine($is_x_pos)
	;Sleep(200)
	;Return
	$cmd = Binary("0x62" & Hex($is_x_pos, 2) & "0A")
	$ok = _comRunBin($cmd)
	If $ok <> "OK" Then
		MsgBox(0, "minigrave-ui", "Error running a command!")
	EndIf
EndFunc   ;==>drawLine

; ===================================================         GRAPHICS PROCESSING      ======================================================

Func loadFile()
	$file = FileOpenDialog("minigrave-ui", @DesktopDir, "(*.jpg;*.png;*.bmp)")
	If @error Then Return
	ingestFile($file)
	If @error then Return

	displayFile()

	FileDelete(@DesktopDir & "\debug.png")
	_GDIPlus_ImageSaveToFile($hbwImage, @DesktopDir & "\debug.png")
EndFunc   ;==>loadFile

Func ingestFile($file)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_ImageDispose($hbwImage)

	ConsoleWrite("+> Ingesting file " & $file & "   (" & @error & ")" & @CRLF)
	$hImage = _GDIPlus_ImageLoadFromFile($file)
	Dim $size[2]
	ConsoleWrite(@ScriptLineNumber & ": " & @error & @CRLF)
	$size[0] = _GDIPlus_ImageGetWidth($hImage)
	ConsoleWrite(@ScriptLineNumber & ": " & @error & @CRLF)
	$size[1] = _GDIPlus_ImageGetHeight($hImage)

	If $size[0] > 8191 Then
		MsgBox(16, "minigrave-ui", "Bitmap too wide! Max 8192 pixels")
		Return SetError(1)
	EndIf


	$hbwImage = _GDIPlus_ImageClone($hImage)

	$tPalette = _GDIPlus_PaletteInitialize(2, $GDIP_PaletteTypeFixedBW, 0, False)
	ConsoleWrite(@ScriptLineNumber & ": " & @error & @CRLF)
	_GDIPlus_BitmapConvertFormat($hbwImage, $GDIP_PXF01INDEXED, $GDIP_DitherTypeDualSpiral8x8, $GDIP_PaletteTypeFixedBW, $tPalette)
	;_GDIPlus_BitmapConvertFormat($hbwImage, $GDIP_PXF01INDEXED, $GDIP_DitherTypeSolid, $GDIP_PaletteTypeFixedBW, $tPalette)
	;_GDIPlus_BitmapConvertFormat($hbwImage, $GDIP_PXF01INDEXED, $GDIP_DitherTypeErrorDiffusion, $GDIP_PaletteTypeCustom, $tPalette)
	ConsoleWrite(@ScriptLineNumber & ": " & @error & @CRLF)
	setStepsPerPixel()
	GUICtrlSetState($bBurn, $GUI_ENABLE)
EndFunc   ;==>ingestFile

Func displayFile()
	Dim $picCoords[4] = [72, 96, 465, 385]
	Dim $size[2]

	ConsoleWrite(@ScriptLineNumber & ": " & @error & @CRLF)
	$size[0] = _GDIPlus_ImageGetWidth($hbwImage)
	ConsoleWrite(@ScriptLineNumber & ": " & @error & @CRLF)
	$size[1] = _GDIPlus_ImageGetHeight($hbwImage)
	ConsoleWrite(@ScriptLineNumber & ": " & @error & @CRLF)

	$fill_x = $picCoords[2] / $size[0]
	$fill_y = $picCoords[3] / $size[1]

	If $fill_x > $fill_y Then $fill_x = $fill_y
	If $fill_y > $fill_x Then $fill_y = $fill_x

	$draw_x = Round($fill_x * $size[0])
	$draw_y = Round($fill_y * $size[1])

	$offset_x = Round(($picCoords[2] - $draw_x) / 2)
	$offset_y = Round(($picCoords[3] - $draw_y) / 2)

	ConsoleWrite("Displaying $file with " & $size[0] & "x" & $size[1] & " in " & $draw_x & "x" & $draw_y & " at " & $offset_x & "," & $offset_y & " by " & $fill_x & " / " & $fill_y & @CRLF)

	;_GDIPlus_GraphicsDispose($hGraphic)
	ConsoleWrite(@ScriptLineNumber & ": " & @error & @CRLF)
	_GDIPlus_GraphicsFillRect($hGraphic, $picCoords[0], $picCoords[1], $picCoords[2], $picCoords[3], $hBrushBg)
	_GDIPlus_GraphicsDrawImageRect($hGraphic, $hbwImage, $picCoords[0] + $offset_x, $picCoords[1] + $offset_y, $draw_x, $draw_y)
	ConsoleWrite(@ScriptLineNumber & ": " & @error & @CRLF)
EndFunc   ;==>displayFile


Func displayLiveProgress($z_location, $z_start, $z_bottom)
	Dim $picCoords[4] = [72, 96, 465, 385]
	Dim $size[2]

	$size[0] = _GDIPlus_ImageGetWidth($hbwImage)
	$size[1] = _GDIPlus_ImageGetHeight($hbwImage)

	$fill_x = $picCoords[2] / $size[0]
	$fill_y = $picCoords[3] / $size[1]

	If $fill_x > $fill_y Then $fill_x = $fill_y
	If $fill_y > $fill_x Then $fill_y = $fill_x

	$draw_x = Round($fill_x * $size[0])
	$draw_y = Round($fill_y * $size[1])

	$offset_x = Round(($picCoords[2] - $draw_x) / 2)
	$offset_y = Round(($picCoords[3] - $draw_y) / 2)


	;_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_GraphicsFillRect($hGraphic, $picCoords[0], $picCoords[1], $picCoords[2], $picCoords[3], $hBrushBg)
	_GDIPlus_GraphicsDrawImageRect($hGraphic, $hbwImage, $picCoords[0] + $offset_x, $picCoords[1] + $offset_y, $draw_x, $draw_y)

	$progress_norm = ($z_start - $z_location) / ($z_start - $z_bottom)
	$progress_y = _GDIPlus_ImageGetHeight($hbwImage) * $progress_norm
	$progress_pic_y = $picCoords[3] * $progress_norm
	ConsoleWrite("@> drawing at " & $progress_y & " and " & $progress_pic_y & @CRLF)
	_GDIPlus_GraphicsDrawImageRectRect($hGraphic, $hImage, 0, 0, _GDIPlus_ImageGetWidth($hImage), $progress_y, $picCoords[0]+ $offset_x, $picCoords[1] + $offset_y, $draw_x, $draw_y * $progress_norm)
	_GDIPlus_GraphicsFillRect($hGraphic, $picCoords[0], $picCoords[1] + $offset_y + $progress_norm * $draw_y, $picCoords[2], 1, $brushBlue)
	ConsoleWrite(@ScriptLineNumber & ": " & @error & @CRLF)
EndFunc


; ===================================================         GUI MANIPULATION         ======================================================

Func validateStepRatios()
	If GUICtrlReadNumber($iStepsPerPx) / (GUICtrlReadNumber($iSkipZ) + 1) <> Round(GUICtrlReadNumber($iStepsPerPx) / (GUICtrlReadNumber($iSkipZ) + 1)) Then
		GUICtrlSetBkColor($iSkipZ, 0xFF8888)
		GUICtrlSetBkColor($iStepsPerPx, 0xFF8888)
	Else
		GUICtrlSetBkColor($iSkipZ, 0xFFFFFF)
		GUICtrlSetBkColor($iStepsPerPx, 0xFFFFFF)
	EndIf
EndFunc   ;==>validateStepRatios

Func lockUiNoPort()
	For $i = 0 To 1000
		If $i <> $iComPort And $i <> $bConnectReset Then GUICtrlSetState($i, $GUI_DISABLE)
	Next
	GUICtrlSetState($iComPort, $GUI_ENABLE)
	GUICtrlSetState($bConnectReset, $GUI_ENABLE)
EndFunc   ;==>lockUiNoPort

Func unlockUiNoPort()
	For $i = 0 To 1000
		If $i <> $iComPort And $i <> $bConnectReset Then GUICtrlSetState($i, $GUI_ENABLE)
	Next
	GUICtrlSetState($bBurn, $GUI_DISABLE)
EndFunc   ;==>unlockUiNoPort

Func lockUiBurning()
	For $i = 0 To 1000
		If $i <> $bBurn And $i <> $Progress1 Then GUICtrlSetState($i, $GUI_DISABLE)
	Next
	GUICtrlSetState($Progress1, $GUI_SHOW)
	GUICtrlSetData($bBurn, "Cancel")
EndFunc   ;==>lockUiBurning

Func unlockUiBurning()
	For $i = 0 To 1000
		If $i <> $bBurn And $i <> $Progress1 Then GUICtrlSetState($i, $GUI_ENABLE)
	Next
	GUICtrlSetState($Progress1, $GUI_HIDE)
	GUICtrlSetData($bBurn, "Burn")
EndFunc   ;==>unlockUiBurning

Func resetUi()
	GUICtrlSetData($iLeftmostSteps, 1500)
	GUICtrlSetData($iTopmostSteps, 1000)
	GUICtrlSetData($iWidthSteps, 0)
	GUICtrlSetData($iHeightSteps, 0)
	GUICtrlSetData($iStepsPerPx, 1)
	GUICtrlSetData($iGear, $start_gear)
	GUICtrlSetData($iBacklash, 25)
	GUICtrlSetData($bLaserOn, "Laser ON")
EndFunc   ;==>resetUi

Func GUICtrlReadNumber($input)
	Return Number(GUICtrlRead($input))
EndFunc   ;==>GUICtrlReadNumber

; ===================================================        PARAMETER READ/WRITE     ======================================================

Func setGear()
	$hg = Hex(GUICtrlReadNumber($iGear), 2)
	$cmd = Binary("0x47" & $hg & "0A")
	$ok = _comRunBin($cmd)
	If $ok <> "OK" Then
		MsgBox(0, "minigrave-ui", "Error running a command!")
	EndIf
EndFunc   ;==>setGear

Func setStepsPerPixel()
	$hs = Hex(GUICtrlReadNumber($iStepsPerPx), 2)
	$cmd = Binary("0x50" & $hs & "0A")
	$ok = _comRunBin($cmd)
	If $ok <> "OK" Then
		MsgBox(0, "minigrave-ui", "Error running a command!")
	EndIf

	$size_w = _GDIPlus_ImageGetWidth($hbwImage)
	$size_h = _GDIPlus_ImageGetHeight($hbwImage)

	GUICtrlSetData($iWidthSteps, $size_w * GUICtrlReadNumber($iStepsPerPx))
	GUICtrlSetData($iHeightSteps, $size_h * GUICtrlReadNumber($iStepsPerPx))
	GUICtrlSetData($iTopmostSteps, 1000 + ($size_h * GUICtrlReadNumber($iStepsPerPx)))
	GUICtrlSetData($iTopmostSteps, 1000 + $size_h * GUICtrlReadNumber($iStepsPerPx))
EndFunc   ;==>setStepsPerPixel

Func setBacklash()
	$hb = Hex(GUICtrlReadNumber($iBacklash), 2)
	$cmd = Binary("0x42" & $hb & "0A")
	$ok = _comRunBin($cmd)
	If $ok <> "OK" Then
		MsgBox(0, "minigrave-ui", "Error running a command!")
	EndIf
EndFunc   ;==>setBacklash

Func setBitmapWidth()
	$hw = Hex(_GDIPlus_ImageGetWidth($hbwImage), 4)
	$cmd = Binary("0x57" & StringMid($hw, 3, 2) & StringMid($hw, 1, 2) & "0A")
	$ok = _comRunBin($cmd)
	If $ok <> "OK" Then
		MsgBox(0, "minigrave-ui", "Error running a command!")
	EndIf
EndFunc   ;==>setBitmapWidth

Func writeBitmap($pixel_binary)
	$cmd = Binary("0x700A")
	$ok = _comRunBin($cmd)
	If $ok <> "READY" And $ok <> "OK" Then
		MsgBox(0, "minigrave-ui", "Error running a command!")
		Return
	EndIf

	_comRunBin($pixel_binary)
EndFunc   ;==>writeBitmap

; ===================================================       MOTOR/LASER CONTROL      ======================================================

Func bitmapTest($dir)
	setBitmapWidth()
	;writeBitmap()
	drawLine($dir)
EndFunc   ;==>bitmapTest

Func accelToAndWait($x, $z)
	$hx = Hex($x, 4)
	$hz = Hex($z, 4)
	ConsoleWrite("accel to " & $x & "/" & $hx & " " & $z & "/" & $hz & @CRLF)
	$cmd = Binary("0x67" & StringMid($hx, 3, 2) & StringMid($hx, 1, 2) & StringMid($hz, 3, 2) & StringMid($hz, 1, 2) & "0A")
	$ok = _comRunBin($cmd)
	If $ok <> "OK" Then
		MsgBox(0, "minigrave-ui", "Error running a command!")
	EndIf
EndFunc   ;==>accelToAndWait

Func detectHome()
	$ok = _comRunBin(Binary("0x480A"))
	If $ok <> "OK" Then
		MsgBox(0, "minigrave-ui", "Error running a command!")
	EndIf
EndFunc   ;==>detectHome

; ===================================================       SERIAL PORT HANDLING      ======================================================

Func openComPort()
	$hComPort = _ComOpenPort($sCOM & " baud=" & $iBaud)

	If @error Then
		MsgBox(0, "minigrave-ui", "Error: Port not available")
		Return 0
	EndIf

	Sleep(2000)
	$a = _comRunCmd("0")
	If $a = "Hello" Or $a = "OK" Then
		Return 1
	Else
		MsgBox(0, "minigrave-ui", "Error: Device not recognized. Expected 'Hello', got: " & $a & "(len " & StringLen($a) & ")")
	EndIf
	Return 0
EndFunc   ;==>openComPort

Func _comRunBin($msg)
	ConsoleWrite("+> " & BinaryToString($msg))
	ConsoleWrite("*> " & $msg)
	_comSendBinary($hComPort, $msg)
	$resp = _comRecvMsg()
	ConsoleWrite("-> " & $resp & @CRLF)
	Return $resp
EndFunc   ;==>_comRunBin

Func _comRunCmd($msg)
	$msg &= @LF
	ConsoleWrite("+> " & $msg)
	_comSendMsg($msg)
	$resp = _comRecvMsg()
	ConsoleWrite("-> " & $resp & @CRLF)
	Return $resp
EndFunc   ;==>_comRunCmd

Func _comSendMsg($msg)
	$bns = Binary($msg)
	_ComSendBinary($hComPort, $bns)
EndFunc   ;==>_comSendMsg

Func _comRecvMsg()
	;return "OK"
	$out = ""
	While 1
		$a = _ComReadByte($hComPort)
		If $a = -1 Then ContinueLoop
		If $a = 0x0D Then ContinueLoop
		$a = ChrW($a)
		If $a = @LF Then Return $out
		$out &= $a
	WEnd
EndFunc   ;==>_comRecvMsg

#cs
Func _comRecvBin()
	$out = binary("")
	While 1
		$a = _ComReadByte($hComPort)
		If $a = -1 Then ContinueLoop
		If $a = 0x0D Then ContinueLoop
		If $a = 0x0A Then
			Return BinaryToString($out)
		EndIf
		$out &= $a ;binaryappend($out, $a)
	WEnd
	Return $out
EndFunc   ;==>_comRecvBin

Func binaryappend($bin_a, $bin_b)
	$len = BinaryLen($bin_a) + BinaryLen($bin_b)
	$offset = BinaryLen($bin_a)
	$ptr = $offset + 1
	$struct = DllStructCreate("byte[" & $len & "]")
	DllStructSetData($struct, 1, $bin_a)
	While $ptr <= $len
		DllStructSetData($struct, 1, BinaryMid($bin_b, $ptr - $offset, 1), $ptr)
		$ptr += 1
	WEnd
	$bin_c = DllStructGetData($struct, 1)
	$struct = 0
	Return $bin_c
EndFunc   ;==>binaryappend
#ce
