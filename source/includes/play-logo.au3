#include-once
#include <Misc.au3>

Func logo($playing = 0)
    If $playing = 1 Then
        Local $loadingfrm = GUICreate("loading", 300, 300)
        GUISetBkColor($COLOR_BLUE)
        GuiCtrlCreateLabel("welcome to vdh productions", 10, 5, 280, 20)

        Local $skipLabel = GuiCtrlCreateLabel("press enter to skip logo", 10, 270, 280, 20)
        GUICtrlSetColor($skipLabel, $COLOR_WHITE)

        GUISetState()

        Local $hDLL = DllOpen("user32.dll")

        If _LogoWait(2000, $hDLL) Then
            _CloseLogo($loadingfrm, $hDLL)
            Return
        EndIf

        Local $welcome_text = GUICtrlCreateLabel("welcome", 80, 150, 150, 80)
        GUICtrlSetFont($welcome_text, 30, 700, "Arial")
        GUICtrlSetColor($welcome_text, $COLOR_WHITE)
        _PlayLogoSound(@ScriptDir & "\sounds\logo.wav")

        If _LogoWait(4000, $hDLL) Then
            _CloseLogo($loadingfrm, $hDLL)
            Return
        EndIf

        GUICtrlDelete($welcome_text)
        GUICtrlDelete($skipLabel)
        GUISetBkColor($COLOR_RED)

        _LogoWait(5000, $hDLL)

        _StopLogoSound()
        DllClose($hDLL)
        GUIDelete($loadingfrm)
    Else
        ;start
    EndIf
EndFunc

; Opens and plays the logo sound under our own MCI alias ("VDHLogoSound"),
; instead of the built-in SoundPlay(), so we can reliably control its
; volume/stop it later regardless of AutoIt's internal implementation.
Func _PlayLogoSound($sFile)
    If Not FileExists($sFile) Then Return
    DllCall("winmm.dll", "long", "mciSendStringW", "wstr", 'open "' & $sFile & '" type waveaudio alias VDHLogoSound', "wstr", "", "long", 0, "hwnd", 0)
    DllCall("winmm.dll", "long", "mciSendStringW", "wstr", "play VDHLogoSound", "wstr", "", "long", 0, "hwnd", 0)
EndFunc

; Closes the logo window when the user skips it with Enter: fades the
; logo sound down to silence and stops it completely (instead of
; letting it keep playing in the background), then closes the window.
Func _CloseLogo($hWnd, $hDLL)
    _FadeOutLogoSound()
    GUIDelete($hWnd)
    DllClose($hDLL)
EndFunc

; Gradually lowers the volume of the sound opened by _PlayLogoSound(),
; then stops and closes it. Harmless no-op if no sound is currently open.
Func _FadeOutLogoSound()
    Local $iSteps = 10
    For $i = $iSteps To 0 Step -1
        Local $iVol = Round($i / $iSteps * 1000) ; MCI volume range is 0-1000
        DllCall("winmm.dll", "long", "mciSendStringW", "wstr", "setaudio VDHLogoSound volume to " & $iVol, "wstr", "", "long", 0, "hwnd", 0)
        Sleep(20)
    Next
    _StopLogoSound()
EndFunc

; Stops and releases the logo sound's MCI device immediately, no fade.
Func _StopLogoSound()
    DllCall("winmm.dll", "long", "mciSendStringW", "wstr", "stop VDHLogoSound", "wstr", "", "long", 0, "hwnd", 0)
    DllCall("winmm.dll", "long", "mciSendStringW", "wstr", "close VDHLogoSound", "wstr", "", "long", 0, "hwnd", 0)
EndFunc

; Waits up to $iMs milliseconds, polling for Enter. Returns True if the user
; pressed Enter to skip (caller should stop the logo sequence), False if the
; full duration elapsed normally.
Func _LogoWait($iMs, $hDLL)
    Local $iElapsed = 0
    While $iElapsed < $iMs
        If _IsPressed("0D", $hDLL) Then ; 0D = VK_RETURN (Enter)
            ; Wait for the key to be released so it doesn't leak into the next screen
            Do
                Sleep(10)
            Until Not _IsPressed("0D", $hDLL)
            Return True
        EndIf
        Sleep(20)
        $iElapsed += 20
    WEnd
    Return False
EndFunc
