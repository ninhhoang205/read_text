#include <GuiConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <ColorConstants.au3>
#include <ComboConstants.au3>
#include <SliderConstants.au3>
#include <GuiMenu.au3>
#include <WindowsConstants.au3>
#include <Constants.au3>
#include "includes/play-logo.au3"

Global $oErrorHandler = ObjEvent("AutoIt.Error", "_ErrFunc")

Global $sAppVersion = "2.5"
Global Const $SVSFlagsAsync = 1
Global Const $SVSFPurgeBeforeSpeak = 2
Global $isPaused = False
Global $g_bComError = False   ; co bat loi COM (dung de phat hien voice-token bi hong/da go)
Global $sConfigFile = @ScriptDir & "\ReadText.ini"

Global $bAutoUpdate = False
Global $bAutoClipboard = False
Global $bStartup = False

Global $sGoogleVoiceExe = @ScriptDir & "\lib\google_voice.exe"
Global $sSpeakExe = @ScriptDir & "\lib\SpeakToText.exe"

OnAutoItExitRegister("_SaveConfig")

FileChangeDir(@ScriptDir)

; ---- Ngon ngu ----
Global $sLangFile   = @ScriptDir & "\vi.ini"
Global $sActiveLang = IniRead($sConfigFile, "Settings", "Language", "en")

; =============================================================================
; LOCALIZATION ENGINE
; Tiếng Anh được nhúng trực tiếp trong code (không cần file).
; Tiếng Việt đọc từ vi.ini (UTF-8 BOM), section [vi].
; =============================================================================

Global $g_oEN
$g_oEN = ObjCreate("Scripting.Dictionary")
$g_oEN("app_title")                = "ReadText version "
$g_oEN("label_enter_text")         = "&Enter text"
$g_oEN("label_select_voice")       = "&Select voice"
$g_oEN("btn_refresh_voice")        = "Refresh"
$g_oEN("tip_refresh_voice")        = "Refresh the voice list to detect newly installed voices"
$g_oEN("tip_voice_refreshed")      = "Voice list refreshed."
$g_oEN("preview_title")            = "Preview"
$g_oEN("label_volume")             = "&Volume"
$g_oEN("label_rate")               = "&Rate"
$g_oEN("label_pitch")              = "&Pitch"
$g_oEN("lang_label")               = "Language:"
$g_oEN("btn_read_text")            = "Read&Text"
$g_oEN("btn_my_message")           = "m&y message"
$g_oEN("btn_save_text")            = "Save Text, Ctrl+S"
$g_oEN("btn_open_text")            = "Open Text Files, Ctrl+O"
$g_oEN("btn_save_audio")           = "Save &Audio"
$g_oEN("btn_listen_text")          = "&Listen text"
$g_oEN("btn_pause")                = "Pause"
$g_oEN("btn_resume")               = "Resume"
$g_oEN("btn_stop")                 = "Stop"
$g_oEN("btn_get_clipboard")        = "Retrieve text from &clipboard"
$g_oEN("btn_speak_to_text")        = "Speak to Text (Microphone)"
$g_oEN("btn_menu")                 = "&Menu"
$g_oEN("btn_close")                = "&Close"
$g_oEN("btn_ok")                   = "&OK"
$g_oEN("btn_cancel")               = "&Cancel"
$g_oEN("btn_accept")               = "Accept"
$g_oEN("btn_decline")              = "Decline"
$g_oEN("btn_download")             = "&Download"
$g_oEN("btn_send")                 = "Send"
$g_oEN("menu_about")               = "about..."
$g_oEN("menu_check_updates")       = "check for &updates" & @TAB & "Ctrl+Shift+U"
$g_oEN("menu_contribute")          = "c&ontribute"
$g_oEN("menu_changelog")           = "view changelog"
$g_oEN("menu_send_feedback")       = "Send &feedback..."
$g_oEN("menu_tutorial")            = "tutorial"
$g_oEN("menu_tut_vi")              = "vietnamese"
$g_oEN("menu_tut_en")              = "english"
$g_oEN("menu_contact")             = "contact with me"
$g_oEN("menu_facebook")            = "Facebook"
$g_oEN("menu_email")               = "Email"
$g_oEN("menu_settings")            = "Settings..." & @TAB & "Ctrl+Shift+S"
$g_oEN("menu_exit")                = "exit"
$g_oEN("warning_title")            = "Warning"
$g_oEN("error_title")              = "Error"
$g_oEN("success_title")            = "Success"
$g_oEN("warning_enter_text")       = "Please enter your text."
$g_oEN("error_sapi")               = "Cannot use SAPI 5. Please try again."
$g_oEN("error_sapi_obj")           = "SAPI Object Error."
$g_oEN("error_file_not_found")     = "File not found: "
$g_oEN("error_file_missing")       = "File not found!"
$g_oEN("error_parse_version")      = "Could not parse version information."
$g_oEN("error_http_obj")           = "Cannot create HTTP Object."
$g_oEN("error_http_status")        = "Cannot connect to update server. Status Code: "
$g_oEN("error_no_internet")        = "No internet connection."
$g_oEN("error_conn_failed")        = "Connection failed. Please check your internet."
$g_oEN("error_feedback_empty")     = "Please describe your idea before sending."
$g_oEN("error_text_file_missing")  = "Cannot find file: "
$g_oEN("warning_clipboard_empty")  = "The clipboard is empty! Please copy the text first."
$g_oEN("success_clipboard")        = "Text retrieved from clipboard successfully."
$g_oEN("about_title")              = "About"
$g_oEN("about_text")               = "ReadText version: %1, by developer Vo Dinh Hung."
$g_oEN("my_message_title")         = "Message"
$g_oEN("my_message_text")          = "Hello everyone! Thank you for your continued support. The software is undergoing many changes to provide you with a better experience. Please happily accept this gift from us, a dream we have cherished for many years."
$g_oEN("save_audio_dialog")        = "Save audio as..."
$g_oEN("save_audio_progress")      = "Downloading from Google..."
$g_oEN("save_audio_progress_title")= "Saving Audio"
$g_oEN("save_audio_success")       = "Audio saved successfully: "
$g_oEN("save_audio_fail")          = "Failed to save audio. Check internet connection."
$g_oEN("save_audio_success_sapi")  = "Audio saved successfully."
$g_oEN("save_text_dialog")         = "Save text as..."
$g_oEN("save_text_success")        = "Text saved successfully."
$g_oEN("open_text_dialog")         = "Open text file..."
$g_oEN("listening_tooltip")        = "Listening... Please speak now."
$g_oEN("listening_tooltip_title")  = "Microphone"
$g_oEN("update_checking")          = "Checking for updates..."
$g_oEN("update_available_title")   = "Update Available"
$g_oEN("update_new_version")       = "New version (%1)!"
$g_oEN("update_current")           = "Current version: "
$g_oEN("update_changelog_for")     = "Changelog for "
$g_oEN("update_question")          = "Do you want to download and install this update now?"
$g_oEN("update_downloading")       = "Downloading Update"
$g_oEN("update_wait")              = "Please wait while downloading..."
$g_oEN("update_please_wait")       = "Please wait"
$g_oEN("update_connecting")        = "Connecting..."
$g_oEN("update_success")           = "Downloaded successfully!" & @CRLF & "File saved as: "
$g_oEN("update_no_update_title")   = "No Update Available"
$g_oEN("update_no_update")         = "You are using the latest version (%1)."
$g_oEN("update_downloading_gui")   = "Downloading update"
$g_oEN("changelog_title")          = "Changelog"
$g_oEN("changelog_not_found")      = "No changelog found."
$g_oEN("license_title")            = "License Agreement"
$g_oEN("license_prompt")           = "Please read and accept the license agreement to continue:"
$g_oEN("license_not_found")        = "license.txt not found."
$g_oEN("settings_title")           = "Settings"
$g_oEN("settings_auto_update")     = "Automatically check for updates on startup"
$g_oEN("settings_auto_clip")       = "Automatically retrieve text from clipboard"
$g_oEN("settings_startup")         = "Startup with Windows"
$g_oEN("feedback_title")           = "Send Feedback"
$g_oEN("feedback_lbl_title")       = "Title:"
$g_oEN("feedback_lbl_desc")        = "Describe your idea:"
$g_oEN("feedback_placeholder")     = "[Feature]: "
$g_oEN("contribute_title")         = "Contribute"
$g_oEN("restart_notice")           = "Language changed. The app will restart now."

Global $g_oVI = 0   ; cache chuỗi VI, nạp bởi _LangLoad

Func _LangLoad($sLang = "en")
    $sActiveLang = StringLower($sLang)
    If $sActiveLang = "en" Or Not FileExists($sLangFile) Then
        $g_oVI = 0
        Return
    EndIf
    $g_oVI = ObjCreate("Scripting.Dictionary")
    Local $aSection = IniReadSection($sLangFile, "vi")
    If IsArray($aSection) Then
        For $i = 1 To $aSection[0][0]
            $g_oVI($aSection[$i][0]) = $aSection[$i][1]
        Next
    EndIf
EndFunc

Func _T($sKey)
    If IsObj($g_oVI) And $g_oVI.Exists($sKey) Then Return $g_oVI($sKey)
    If IsObj($g_oEN) And $g_oEN.Exists($sKey) Then Return $g_oEN($sKey)
    Return "[?" & $sKey & "?]"
EndFunc

Func _TF($sKey, $s1)
    Return StringReplace(_T($sKey), "%1", $s1)
EndFunc

_LangLoad($sActiveLang)
_CheckFirstRunLicense()
logo(1)

Global $g_oSAPI
$g_oSAPI = ObjCreate("SAPI.SpVoice")
If @error Then
    MsgBox(16, _T("error_title"), _T("error_sapi"))
    Exit
EndIf

; =============================================================================
; BUILD GUI
; =============================================================================
Global $hGUI = GuiCreate(_T("app_title") & $sAppVersion, 350, 730)
GuiSetBkColor($COLOR_BLUE)

; ---- Text input ----
Global $lblEnterText = GuiCtrlCreateLabel(_T("label_enter_text"), 10, 5)
GUICtrlSetColor(-1, 0xFFFFFF)
Global $entertext    = GuiCtrlCreateEdit("", 10, 25, 330, 50)

; ---- Voice combo ----
Global $lblSelectVoice = GuiCtrlCreateLabel(_T("label_select_voice"), 10, 85)
GUICtrlSetColor(-1, 0xFFFFFF)
Global $comboVoice     = GuiCtrlCreateCombo("", 10, 105, 250, 20, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))
PopulateVoiceComboBox($comboVoice)
Global $btnRefreshVoice = GuiCtrlCreateButton(_T("btn_refresh_voice"), 265, 104, 75, 22, $WS_TABSTOP)
GUICtrlSetTip($btnRefreshVoice, _T("tip_refresh_voice"))

; ---- Sliders ----
Global $lblVolume    = GuiCtrlCreateLabel(_T("label_volume"), 10, 135)
GUICtrlSetColor(-1, 0xFFFFFF)
Global $sliderVolume = GuiCtrlCreateSlider(10, 153, 330, 30, BitOR($TBS_AUTOTICKS, $WS_TABSTOP))
GUICtrlSetLimit($sliderVolume, 100, 0)
GUICtrlSetData($sliderVolume, 100)

Global $lblRate      = GuiCtrlCreateLabel(_T("label_rate"), 10, 193)
GUICtrlSetColor(-1, 0xFFFFFF)
Global $sliderRate   = GuiCtrlCreateSlider(10, 211, 330, 30, BitOR($TBS_AUTOTICKS, $WS_TABSTOP))
GUICtrlSetLimit($sliderRate, 10, -10)
GUICtrlSetData($sliderRate, 0)

Global $lblPitch     = GuiCtrlCreateLabel(_T("label_pitch"), 10, 251)
GUICtrlSetColor(-1, 0xFFFFFF)
Global $sliderPitch  = GuiCtrlCreateSlider(10, 269, 330, 30, BitOR($TBS_AUTOTICKS, $WS_TABSTOP))
GUICtrlSetLimit($sliderPitch, 10, -10)
GUICtrlSetData($sliderPitch, 0)

; ---- Action buttons ----
Global $button          = GuiCtrlCreateButton(_T("btn_read_text"),      40, 310, 280, 30)
Global $message         = GuiCtrlCreateButton(_T("btn_my_message"),    135, 348,  80, 40)
Global $saveText        = GuiCtrlCreateButton(_T("btn_save_text"),      50, 398, 230, 30)
Global $openText        = GuiCtrlCreateButton(_T("btn_open_text"),      50, 433, 230, 30)
Global $saveAudio       = GuiCtrlCreateButton(_T("btn_save_audio"),     50, 468, 230, 30)
Global $tts             = GuiCtrlCreateButton(_T("btn_listen_text"),    50, 503, 230, 30)
Global $btnPause        = GuiCtrlCreateButton(_T("btn_pause"),          50, 538, 110, 32)
Global $btnStop         = GuiCtrlCreateButton(_T("btn_stop"),          170, 538, 110, 32)
Global $btnGetClipboard = GuiCtrlCreateButton(_T("btn_get_clipboard"),  50, 578, 230, 30)
Global $btnSpeakToText  = GuiCtrlCreateButton(_T("btn_speak_to_text"), 50, 613, 230, 30)
Global $btnMenuHelp     = GuiCtrlCreateButton(_T("btn_menu"),           50, 648, 230, 30)

; ---- Context menu ----
Global $dummyMenu        = GuiCtrlCreateDummy()
Global $contextMenu      = GuiCtrlCreateContextMenu($dummyMenu)
Global $menu1            = GuiCtrlCreateMenuItem(_T("menu_about"),          $contextMenu)
Global $menuUpdate       = GuiCtrlCreateMenuItem(_T("menu_check_updates"),  $contextMenu)
Global $menu2            = GuiCtrlCreateMenuItem(_T("menu_contribute"),     $contextMenu)
Global $menuChangelog    = GuiCtrlCreateMenuItem(_T("menu_changelog"),      $contextMenu)
Global $menuSendFeedback = GuiCtrlCreateMenuItem(_T("menu_send_feedback"),  $contextMenu)

Global $SubMenu1  = GuiCtrlCreateMenu(_T("menu_tutorial"), $contextMenu)
Global $menuitem1 = GuiCtrlCreateMenuItem(_T("menu_tut_vi"), $SubMenu1)
Global $menuitem2 = GuiCtrlCreateMenuItem(_T("menu_tut_en"), $SubMenu1)

Global $subMenu2  = GuiCtrlCreateMenu(_T("menu_contact"), $contextMenu)
Global $facebook  = GuiCtrlCreateMenuItem(_T("menu_facebook"), $subMenu2)
Global $email     = GuiCtrlCreateMenuItem(_T("menu_email"),    $subMenu2)

Global $menuSettings = GuiCtrlCreateMenuItem(_T("menu_settings"), $contextMenu)
GuiCtrlCreateMenuItem("", $contextMenu)
Global $menu3 = GuiCtrlCreateMenuItem(_T("menu_exit"), $contextMenu)

_LoadConfig()
GuiSetState()

Local $aAccelKeys[4][2] = [["^s", $saveText], ["^o", $openText], ["^+s", $menuSettings], ["^+u", $menuUpdate]]
GUISetAccelerators($aAccelKeys)

If $bAutoClipboard Then _GetClipboardText(True)
If $bAutoUpdate    Then _CheckGithubUpdate()

; =============================================================================
; MAIN LOOP
; =============================================================================
While 1
    Switch GuiGetMSG()
        Case $GUI_EVENT_CLOSE, $menu3
            _SaveConfig()
            SoundPlay(@ScriptDir & "\sounds\exit.wav", 1)
            Exit

        Case $menuChangelog
            SoundPlay("sounds/enter.wav")
            _ShowChangelog()

        Case $menuSendFeedback
            SoundPlay("sounds/enter.wav")
            _Show_Send_Feedback_Window()

        Case $btnPause
            If Not IsGoogleVoice(GuiCtrlRead($comboVoice)) Then
                If $isPaused Then
                    $g_oSAPI.Resume()
                    $isPaused = False
                    GUICtrlSetData($btnPause, _T("btn_pause"))
                Else
                    $g_oSAPI.Pause()
                    $isPaused = True
                    GUICtrlSetData($btnPause, _T("btn_resume"))
                EndIf
            EndIf

        Case $btnStop
            $g_oSAPI.Speak("", $SVSFPurgeBeforeSpeak)
            ProcessClose("google_voice.exe")
            $isPaused = False
            GUICtrlSetData($btnPause, _T("btn_pause"))

        Case $menuSettings
            SoundPlay("sounds/enter.wav")
            _ShowSettings()
            _SaveConfig()

        Case $sliderVolume, $sliderRate, $sliderPitch
            _SaveConfig()

        Case $btnGetClipboard
            SoundPlay("sounds/enter.wav")
            _GetClipboardText(False)
            _SaveConfig()

        Case $btnRefreshVoice
            SoundPlay("sounds/enter.wav")
            _RefreshVoiceComboBox()
            _SaveConfig()

        Case $btnSpeakToText
            _PerformSpeakToText()

        Case $btnMenuHelp
            SoundPlay("sounds/enter.wav")
            Local $hMenuHandle = GuiCtrlGetHandle($contextMenu)
            _GUICtrlMenu_TrackPopupMenu($hMenuHandle, $hGUI)

        Case $menuUpdate
            SoundPlay("sounds/enter.wav")
            _CheckGithubUpdate()

        Case $menu1
            SoundPlay("sounds/enter.wav")
            MsgBox(64, _T("about_title"), _TF("about_text", $sAppVersion))

        Case $message
            SoundPlay("sounds/message.wav")
            MsgBox(0, _T("my_message_title"), _T("my_message_text"))

        Case $facebook
            SoundPlay("sounds/enter.wav")
            ShellExecute("https://www.facebook.com/profile.php?id=100083295244149")

        Case $email
            SoundPlay("sounds/enter.wav")
            ShellExecute("https://mail.google.com/mail/u/0/?fs=1&tf=cm&source=mailto&to=vodinhhungtnlg@gmail.com")

        Case $menuitem2
            SoundPlay("sounds/enter.wav")
            _ShowFileContent("Tutorial (English)", "readme\ReadmeEnglish.txt")

        Case $menuitem1
            SoundPlay("sounds/enter.wav")
            _ShowFileContent("Tutorial (Vietnamese)", "readme\ReadmeVietnamese.txt")

        Case $button
            SoundPlay("sounds/enter.wav")
            ReadText()

        Case $tts
            Local $sSelectedVoice = GuiCtrlRead($comboVoice)
            Local $ok             = GuiCtrlRead($entertext)
            Local $vol            = GuiCtrlRead($sliderVolume)
            Local $rate           = GuiCtrlRead($sliderRate)
            Local $pitch          = GuiCtrlRead($sliderPitch)

            If StringStripWS($ok, 8) = "" Then
                SoundPlay("sounds/enter.wav")
                MsgBox(48, _T("warning_title"), _T("warning_enter_text"))
            Else
                If IsGoogleVoice($sSelectedVoice) Then
                    If Not FileExists($sGoogleVoiceExe) Then
                        MsgBox(16, _T("error_title"), _T("error_file_not_found") & $sGoogleVoiceExe)
                    Else
                        Local $sLangCode  = ($sSelectedVoice = "Google Vietnamese") ? "vi" : "en"
                        Local $sCleanText = StringReplace($ok, '"', "'")
                        Run('"' & $sGoogleVoiceExe & '" ' & $sLangCode & ' "' & $sCleanText & '"', @ScriptDir, @SW_HIDE)
                    EndIf
                Else
                    If Not IsObj($g_oSAPI) Then
                        MsgBox(16, _T("error_title"), _T("error_sapi_obj"))
                        Exit
                    EndIf
                    For $oToken In $g_oSAPI.GetVoices()
                        If $oToken.GetDescription() = $sSelectedVoice Then
                            $g_oSAPI.Voice = $oToken
                            ExitLoop
                        EndIf
                    Next
                    $g_oSAPI.Volume = $vol
                    $g_oSAPI.Rate   = $rate
                    Local $ssml = '<sapi><pitch middle="' & $pitch & '">' & $ok & '</pitch></sapi>'
                    $g_oSAPI.Speak($ssml, 1)
                EndIf
            EndIf

        Case $saveAudio
            _SaveAudioHotkey()
        Case $saveText
            _SaveTextHotkey()
        Case $openText
            _OpenTextHotkey()
        Case $menu2
            SoundPlay("sounds/enter.wav")
            contribute()
    EndSwitch
WEnd

; =============================================================================
; FUNCTIONS
; =============================================================================

; Cap nhat nhan tat ca controls sau khi doi ngon ngu
Func _RebuildGUI()
    WinSetTitle($hGUI, "", _T("app_title") & $sAppVersion)
    ; Labels
    GUICtrlSetData($lblEnterText,     _T("label_enter_text"))
    GUICtrlSetData($lblSelectVoice,   _T("label_select_voice"))
    GUICtrlSetData($btnRefreshVoice,  _T("btn_refresh_voice"))
    GUICtrlSetTip($btnRefreshVoice,   _T("tip_refresh_voice"))
    GUICtrlSetData($lblVolume,        _T("label_volume"))
    GUICtrlSetData($lblRate,          _T("label_rate"))
    GUICtrlSetData($lblPitch,         _T("label_pitch"))
    ; Buttons
    GUICtrlSetData($button,           _T("btn_read_text"))
    GUICtrlSetData($message,          _T("btn_my_message"))
    GUICtrlSetData($saveText,         _T("btn_save_text"))
    GUICtrlSetData($openText,         _T("btn_open_text"))
    GUICtrlSetData($saveAudio,        _T("btn_save_audio"))
    GUICtrlSetData($tts,              _T("btn_listen_text"))
    GUICtrlSetData($btnPause,         _T("btn_pause"))
    GUICtrlSetData($btnStop,          _T("btn_stop"))
    GUICtrlSetData($btnGetClipboard,  _T("btn_get_clipboard"))
    GUICtrlSetData($btnSpeakToText,   _T("btn_speak_to_text"))
    GUICtrlSetData($btnMenuHelp,      _T("btn_menu"))
    GUICtrlSetData($menu1,            _T("menu_about"))
    GUICtrlSetData($menuUpdate,       _T("menu_check_updates"))
    GUICtrlSetData($menu2,            _T("menu_contribute"))
    GUICtrlSetData($menuChangelog,    _T("menu_changelog"))
    GUICtrlSetData($menuSendFeedback, _T("menu_send_feedback"))
    GUICtrlSetData($menuitem1,        _T("menu_tut_vi"))
    GUICtrlSetData($menuitem2,        _T("menu_tut_en"))
    GUICtrlSetData($menuSettings,     _T("menu_settings"))
    GUICtrlSetData($menu3,            _T("menu_exit"))
EndFunc

Func _PerformSpeakToText()
    If Not FileExists($sSpeakExe) Then
        MsgBox(16, _T("error_title"), _T("error_file_missing"))
        Return
    EndIf
    Local $sCurrentVoice = GuiCtrlRead($comboVoice)
    Local $sLang = "vi-VN"
    If StringInStr($sCurrentVoice, "English") Or StringInStr($sCurrentVoice, "David") Or StringInStr($sCurrentVoice, "Zira") Then
        $sLang = "en-US"
    EndIf
    SoundPlay("sounds\start.wav", 1)
    ToolTip(_T("listening_tooltip"), Default, Default, _T("listening_tooltip_title"), 1)
    Local $iPID    = Run('"' & $sSpeakExe & '" ' & $sLang, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
    Local $bOutput = Binary("")
    While ProcessExists($iPID)
        $bOutput &= StdoutRead($iPID, False, True)
        Sleep(50)
    WEnd
    $bOutput &= StdoutRead($iPID, False, True)
    SoundPlay("sounds\stop.wav", 0)
    ToolTip("")
    Local $sOutput = StringStripWS(BinaryToString($bOutput, 4), 3)
    If $sOutput <> "" Then
        Local $sCurrentText = GuiCtrlRead($entertext)
        GUICtrlSetData($entertext, ($sCurrentText <> "") ? ($sCurrentText & " " & $sOutput) : $sOutput)
    EndIf
EndFunc

Func IsGoogleVoice($sName)
    Return ($sName = "Google English" Or $sName = "Google Vietnamese")
EndFunc

Func _SaveAudioHotkey()
    Local $sSelectedVoice = GuiCtrlRead($comboVoice)
    Local $ok = GuiCtrlRead($entertext)
    If StringStripWS($ok, 8) = "" Then
        SoundPlay("sounds/enter.wav")
        MsgBox(48, _T("warning_title"), _T("warning_enter_text"))
        Return
    EndIf
    SoundPlay("sounds/enter.wav")
    Local $sFile = FileSaveDialog(_T("save_audio_dialog"), @ScriptDir, "WAV Files (*.wav)|MP3 Files (*.mp3)", 16, "output.wav")
    If @error Or $sFile = "" Then Return
    If StringRight($sFile, 4) <> ".mp3" And StringRight($sFile, 4) <> ".wav" Then $sFile &= ".wav"

    If IsGoogleVoice($sSelectedVoice) Then
        Local $sLangCode  = ($sSelectedVoice = "Google Vietnamese") ? "vi" : "en"
        Local $sCleanText = StringReplace($ok, '"', "'")
        ProgressOn(_T("save_audio_progress_title"), _T("save_audio_progress"), _T("update_please_wait"))
        Local $pid = Run('"' & $sGoogleVoiceExe & '" ' & $sLangCode & ' "' & $sCleanText & '" "' & $sFile & '"', @ScriptDir, @SW_HIDE)
        ProcessWaitClose($pid)
        ProgressOff()
        MsgBox(FileExists($sFile) ? 64 : 16, FileExists($sFile) ? _T("success_title") : _T("error_title"), FileExists($sFile) ? _T("save_audio_success") & $sFile : _T("save_audio_fail"))
    Else
        Local $vol   = GuiCtrlRead($sliderVolume)
        Local $rate  = GuiCtrlRead($sliderRate)
        Local $pitch = GuiCtrlRead($sliderPitch)
        Local $oStream = ObjCreate("SAPI.SpFileStream")
        $oStream.Open($sFile, 3, False)
        For $oToken In $g_oSAPI.GetVoices()
            If $oToken.GetDescription() = $sSelectedVoice Then
                $g_oSAPI.Voice = $oToken
                ExitLoop
            EndIf
        Next
        $g_oSAPI.Volume = $vol
        $g_oSAPI.Rate   = $rate
        $g_oSAPI.AudioOutputStream = $oStream
        $g_oSAPI.Speak('<sapi><pitch middle="' & $pitch & '">' & $ok & '</pitch></sapi>')
        $oStream.Close()
        $g_oSAPI.AudioOutputStream = 0
        MsgBox(64, _T("success_title"), _T("save_audio_success_sapi"))
    EndIf
EndFunc

; Kiem tra mot voice-token co thuc su dung duoc khong. SAPI liet ke voice tu
; registry (HKLM/HKCU ...\Speech\Voices\Tokens), nen mot giong da go cai co the
; van con "bong ma" trong registry neu bo go cai khong don dep sach.
; LUU Y: chi gan $g_oSAPI.Voice = $oToken KHONG du de phat hien loi - SAPI chi
; luu tham chieu token, engine that su chi duoc "bind" (nap DLL) khi Speak()
; duoc goi. Vi vay phai ep goi Speak() that (dong bo, tat am luong de khong
; phat ra tieng) thi loi COM (token hong / engine da bi go) moi lo dien va bi
; $oErrorHandler bat lai qua $g_bComError.
; CANH BAO HIEU NANG: ham nay ep Windows nap engine TTS that su vao bo nho, co
; the mat tu vai chuc mms den vai giay cho MOI giong (dac biet la cac giong
; ngon ngu day du / neural voice). Vi vay CHI goi ham nay khi nguoi dung chu
; dong bam "Lam moi" (_RefreshVoiceComboBox) - KHONG duoc goi luc khoi dong
; ung dung, vi se lam app load rat cham neu may co nhieu giong cai san.
Func _IsVoiceTokenValid($oToken)
    $g_bComError = False
    $g_oSAPI.Voice = $oToken
    If $g_bComError Then Return False
    $g_oSAPI.Speak(" ", $SVSFPurgeBeforeSpeak)
    If $g_bComError Then Return False
    Return True
EndFunc

; Liet ke nhanh danh sach giong SAPI - CHI doc du lieu tu registry
; (GetDescription), KHONG nap engine that (khong goi Speak/_IsVoiceTokenValid).
; Dung luc khoi dong ung dung de khong lam cham qua trinh mo app. Vi khong
; kiem tra sau, mot giong da bi go co the tam thoi van con hien o day cho den
; khi nguoi dung bam nut "Lam moi" (xem _RefreshVoiceComboBox).
Func PopulateVoiceComboBox($hCombo)
    Local $sList = ""
    If IsObj($g_oSAPI) Then
        For $oToken In $g_oSAPI.GetVoices()
            $sList &= $oToken.GetDescription() & "|"
        Next
    EndIf
    $sList &= "Google English|Google Vietnamese"
    GuiCtrlSetData($hCombo, $sList)
    If IsObj($g_oSAPI) And $g_oSAPI.GetVoices().Count > 0 Then
        GuiCtrlSetData($hCombo, $g_oSAPI.GetVoices().Item(0).GetDescription())
    Else
        GuiCtrlSetData($hCombo, "Google English")
    EndIf
EndFunc

; Kiem tra ky tung giong SAPI bang cach goi Speak() that (xem _IsVoiceTokenValid)
; va tra ve danh sach CHI GOM cac giong con dung duoc (dang "Voice1|Voice2|...|",
; co dau | cuoi cung, hoac rong neu khong co giong SAPI nao hop le). Cham hon
; PopulateVoiceComboBox nhieu vi phai nap tung engine - chi nen goi khi nguoi
; dung chu dong yeu cau lam moi.
Func _GetValidSapiVoiceList()
    Local $sValidList = ""
    If IsObj($g_oSAPI) Then
        ; Tat am luong tam thoi trong luc kiem tra, vi _IsVoiceTokenValid can
        ; goi Speak() that su de ep engine khoi tao (xem ghi chu tren ham do)
        Local $iSavedVolume = $g_oSAPI.Volume
        $g_oSAPI.Volume = 0
        For $oToken In $g_oSAPI.GetVoices()
            If _IsVoiceTokenValid($oToken) Then $sValidList &= $oToken.GetDescription() & "|"
        Next
        $g_oSAPI.Volume = $iSavedVolume
    EndIf
    Return $sValidList
EndFunc

; Cap nhat lai danh sach giong doc (bat ky giong nao vua duoc cai them vao he
; thong) ma khong lam mat lua chon hien tai cua nguoi dung, neu giong do van con.
; Ham nay co the mat vai giay neu may co nhieu giong SAPI (vi phai nap thu
; tung engine de kiem tra - xem _GetValidSapiVoiceList), nen se hien mot cua
; so "vui long cho" trong luc xu ly.
Func _RefreshVoiceComboBox()
    ; Dung phat am truoc, vi doi tuong SAPI se duoc tao lai ben duoi
    If IsObj($g_oSAPI) Then
        $g_oSAPI.Speak("", $SVSFPurgeBeforeSpeak)
    EndIf
    ProcessClose("google_voice.exe")
    $isPaused = False
    GUICtrlSetData($btnPause, _T("btn_pause"))

    Local $sCurrentVoice = GuiCtrlRead($comboVoice)

    ; Tao lai doi tuong SAPI de buoc Windows liet ke lai danh sach voice-token,
    ; vi mot the hien SAPI.SpVoice da mo co the khong thay giong moi cai dat.
    Local $oNewSAPI = ObjCreate("SAPI.SpVoice")
    If Not IsObj($oNewSAPI) Then
        MsgBox(16, _T("error_title"), _T("error_sapi_obj"))
        Return
    EndIf
    $g_oSAPI = $oNewSAPI

    ; Hien cua so "vui long cho" vi buoc kiem tra tung giong co the mat vai giay
    Local $hWaitGUI = GuiCreate(_T("update_downloading_gui"), 320, 90, -1, -1, BitOR($WS_CAPTION, $WS_POPUP), BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
    GuiSetBkColor($COLOR_WHITE, $hWaitGUI)
    Local $lblWait = GuiCtrlCreateLabel(_T("update_please_wait"), 10, 30, 300, 30, $ES_CENTER)
    GuiCtrlSetFont($lblWait, 10, 400, 0, "Arial")
    GuiSetState(@SW_SHOW, $hWaitGUI)

    Local $sValidSapiVoices = _GetValidSapiVoiceList()

    GuiDelete($hWaitGUI)

    GuiCtrlSetData($comboVoice, $sValidSapiVoices & "Google English|Google Vietnamese")
    Local $iPipePos = StringInStr($sValidSapiVoices, "|")
    If $iPipePos > 0 Then
        GuiCtrlSetData($comboVoice, StringLeft($sValidSapiVoices, $iPipePos - 1))
    Else
        GuiCtrlSetData($comboVoice, "Google English")
    EndIf

    ; Khoi phuc lai lua chon cu, nhung chi khi giong do van con VA van dung duoc
    ; (neu giong dang chon da bi go that su, khong "hoi sinh" no lai)
    Local $bFound = IsGoogleVoice($sCurrentVoice)
    If Not $bFound And $sCurrentVoice <> "" Then
        If StringInStr("|" & $sValidSapiVoices, "|" & $sCurrentVoice & "|") Then $bFound = True
    EndIf
    If $bFound And $sCurrentVoice <> "" Then GUICtrlSetData($comboVoice, $sCurrentVoice)

    MsgBox(64, _T("success_title"), _T("tip_voice_refreshed"))
EndFunc

Func _ShowSettings()
    Local $hSettingGUI = GuiCreate(_T("settings_title"), 350, 250, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU), -1, $hGUI)
    GuiSetBkColor($COLOR_WHITE)
    Local $chkAutoUpdate  = GuiCtrlCreateCheckbox(_T("settings_auto_update"), 20,  20, 300, 20)
    Local $chkAutoClip    = GuiCtrlCreateCheckbox(_T("settings_auto_clip"),   20,  50, 300, 20)
    Local $chkStartupWin  = GuiCtrlCreateCheckbox(_T("settings_startup"),     20,  80, 300, 20)

    ; ---- Ngôn ngữ ----
    GuiCtrlCreateLabel(_T("lang_label"), 20, 118, 130, 20)
    Local $cboLang = GuiCtrlCreateCombo("", 155, 115, 160, 22, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))
    GUICtrlSetData($cboLang, "English|Vietnamese", ($sActiveLang = "vi") ? "Vietnamese" : "English")

    Local $btnOk     = GuiCtrlCreateButton(_T("btn_ok"),     60,  185, 80, 30)
    Local $btnCancel = GuiCtrlCreateButton(_T("btn_cancel"), 200, 185, 80, 30)
    If $bAutoUpdate    Then GUICtrlSetState($chkAutoUpdate,  $GUI_CHECKED)
    If $bAutoClipboard Then GUICtrlSetState($chkAutoClip,    $GUI_CHECKED)
    If $bStartup       Then GUICtrlSetState($chkStartupWin,  $GUI_CHECKED)
    Local $sRegKey  = "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    Local $sAppName = "ReadTextApp"
    GuiSetState(@SW_SHOW, $hSettingGUI)
    While 1
        Switch GuiGetMSG()
            Case $GUI_EVENT_CLOSE, $btnCancel
                GuiDelete($hSettingGUI)
                Return
            Case $btnOk
                $bAutoUpdate    = (BitAND(GUICtrlRead($chkAutoUpdate),  $GUI_CHECKED) = $GUI_CHECKED)
                $bAutoClipboard = (BitAND(GUICtrlRead($chkAutoClip),    $GUI_CHECKED) = $GUI_CHECKED)
                $bStartup       = (BitAND(GUICtrlRead($chkStartupWin),  $GUI_CHECKED) = $GUI_CHECKED)
                IniWrite($sConfigFile, "Settings", "AutoUpdate",    $bAutoUpdate    ? "true" : "false")
                IniWrite($sConfigFile, "Settings", "AutoClipboard", $bAutoClipboard ? "true" : "false")
                IniWrite($sConfigFile, "Settings", "Startup",       $bStartup       ? "true" : "false")
                If $bStartup Then
                    RegWrite($sRegKey, $sAppName, "REG_SZ", @ScriptFullPath)
                Else
                    RegDelete($sRegKey, $sAppName)
                EndIf

                ; ---- Lưu ngôn ngữ VÀ khởi động lại nếu thay đổi ----
                Local $sNewLang = (GUICtrlRead($cboLang) = "Vietnamese") ? "vi" : "en"
                Local $bLangChanged = ($sNewLang <> $sActiveLang)
                $sActiveLang = $sNewLang   ; cập nhật trước khi _SaveConfig ghi
                _SaveConfig()              ; ghi tất cả gồm Language=$sActiveLang mới
                SoundPlay("sounds/enter.wav")
                GuiDelete($hSettingGUI)
                If $bLangChanged Then
                    MsgBox(64, _T("settings_title"), _T("restart_notice"))
                    ShellExecute(@ScriptFullPath)
                    Exit
                EndIf
                Return
        EndSwitch
    WEnd
EndFunc

Func _GetClipboardText($bSilent)
    Local $sClipText = ClipGet()
    If @error Or StringStripWS($sClipText, 8) = "" Then
        If Not $bSilent Then MsgBox(48, _T("warning_title"), _T("warning_clipboard_empty"))
    Else
        GUICtrlSetData($entertext, $sClipText)
        If Not $bSilent Then MsgBox(64, _T("success_title"), _T("success_clipboard"))
    EndIf
EndFunc

Func _CheckGithubUpdate()
    Local $hCheckGUI = GuiCreate("", 300, 80, -1, -1, BitOR($WS_CAPTION, $WS_POPUP), BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
    GuiSetBkColor(0xFFFFFF, $hCheckGUI)
    Local $lblCheck = GuiCtrlCreateLabel(_T("update_checking"), 10, 25, 280, 30, $ES_CENTER)
    GuiCtrlSetFont($lblCheck, 10, 400, 0, "Arial")
    GuiSetState(@SW_SHOW, $hCheckGUI)
    Sleep(3000)
    GuiDelete($hCheckGUI)

    If Ping("github.com", 2000) = 0 And Ping("google.com", 2000) = 0 Then
        SoundPlay("sounds/update_error.wav")
        MsgBox(48, _T("update_available_title"), _T("error_no_internet"))
        Return
    EndIf

    Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
    If Not IsObj($oHTTP) Then
        MsgBox(16, _T("error_title"), _T("error_http_obj"))
        Return
    EndIf
    $oHTTP.Open("GET", "https://api.github.com/repos/ninhhoang205/read_text/releases/latest", False)
    $oHTTP.Send()
    If @error Then
        SoundPlay("sounds/update_error.wav")
        MsgBox(48, _T("update_available_title"), _T("error_conn_failed"))
        Return
    EndIf
    If $oHTTP.Status <> 200 Then
        MsgBox(48, _T("update_available_title"), _T("error_http_status") & $oHTTP.Status)
        Return
    EndIf

    Local $aMatch = StringRegExp($oHTTP.ResponseText, '"tag_name":\s*"([^"]+)"', 3)
    If Not IsArray($aMatch) Then
        MsgBox(16, _T("error_title"), _T("error_parse_version"))
        Return
    EndIf

    Local $sLatestVersion = StringReplace($aMatch[0], "v", "")
    If $sLatestVersion = $sAppVersion Then
        MsgBox(64, _TF("update_no_update_title", $sAppVersion), _TF("update_no_update", $sAppVersion))
        Return
    EndIf

    SoundPlay("sounds/update.wav")
    Local $sChangelog = ""
    Local $aBodyMatch = StringRegExp($oHTTP.ResponseText, '"body":\s*"([^"\\]*(?:\\.[^"\\]*)*)"', 3)
    If IsArray($aBodyMatch) Then
        $sChangelog = _StripMarkdown(_UnescapeJSON($aBodyMatch[0]))
    EndIf

    Local $hUpdateGUI = GuiCreate(_T("update_available_title"), 400, 450)
    GUICtrlCreateLabel(_TF("update_new_version", $sLatestVersion), 10, 10, 380, 25)
    GUICtrlSetColor(-1, 0xFFFFFF)
    GUICtrlSetFont(-1, 11, 800)
    GUICtrlCreateLabel(_T("update_current") & $sAppVersion, 10, 40, 380, 20)
    GUICtrlSetColor(-1, 0xFFFFFF)
    GUICtrlCreateLabel(_T("update_changelog_for") & $sLatestVersion & ":", 10, 60, 380, 20)
    GUICtrlCreateEdit($sChangelog, 10, 80, 380, 310, BitOR($ES_AUTOVSCROLL, $ES_READONLY, $WS_VSCROLL, $WS_TABSTOP))
    GUICtrlCreateLabel(_T("update_question"), 10, 345, 380, 20)
    GUICtrlSetColor(-1, 0xFFFFFF)
    GUICtrlSetFont(-1, 9, 600)
    Local $btnDownload = GUICtrlCreateButton(_T("btn_download"),  80, 400, 100, 30, $WS_TABSTOP)
    Local $btnCancel   = GUICtrlCreateButton(_T("btn_cancel"),   220, 400, 100, 30, $WS_TABSTOP)
    GuiSetState(@SW_SHOW, $hUpdateGUI)

    Local $iDownload = 0
    While 1
        Switch GuiGetMSG()
            Case $GUI_EVENT_CLOSE, $btnCancel
                GuiDelete($hUpdateGUI)
                ExitLoop
            Case $btnDownload
                $iDownload = 6
                GuiDelete($hUpdateGUI)
                ExitLoop
        EndSwitch
    WEnd

    If $iDownload = 6 Then
        Local $downloadGui = GuiCreate(_T("update_downloading_gui"), 400, 100, -1, -1)
        GuiSetBkColor($COLOR_WHITE)
        GuiCtrlCreateLabel(_T("update_please_wait"), 40, 35)
        GuiSetState(@SW_SHOW, $downloadGui)

        Local $sSavePath = @ScriptDir & "\read_text.zip"
        ProgressOn(_T("update_downloading"), _T("update_wait"), "0%")
        DllCall("winmm.dll", "int", "PlaySoundW", "wstr", @ScriptDir & "\sounds\updating.wav", "ptr", 0, "dword", 0x0009)
        Local $hDownload = InetGet("https://github.com/ninhhoang205/read_text/releases/latest/download/read_text.zip", $sSavePath, 1, 1)
        Do
            Sleep(100)
            Local $iBytesRead = InetGetInfo($hDownload, 0)
            Local $iFileSize  = InetGetInfo($hDownload, 1)
            If $iFileSize > 0 Then
                ProgressSet(Round(($iBytesRead / $iFileSize) * 100), Round(($iBytesRead / $iFileSize) * 100) & "% complete")
            Else
                ProgressSet(0, _T("update_connecting"))
            EndIf
        Until InetGetInfo($hDownload, 2)
        InetClose($hDownload)
        DllCall("winmm.dll", "int", "PlaySoundW", "ptr", 0, "ptr", 0, "dword", 0)
        ProgressOff()
        GuiDelete($downloadGui)
        SoundPlay("sounds/updated.wav")
        MsgBox(64, _T("success_title"), _T("update_success") & $sSavePath)
        _SaveConfig()
        Run("unzip.exe")
        Exit
    EndIf
EndFunc

Func _CheckFirstRunLicense()
    If IniRead($sConfigFile, "Settings", "LicenseAccepted", "false") = "true" Then Return
    _ShowLicenseAgreement()
EndFunc

Func _ShowLicenseAgreement()
    Local $sContent = _T("license_not_found")
    Local $sLicenseFile = @ScriptDir & "\license.txt"
    If FileExists($sLicenseFile) Then $sContent = FileRead($sLicenseFile)
    Local $licGui = GuiCreate(_T("license_title"), 500, 500, -1, -1, BitOR($WS_CAPTION, $WS_POPUPWINDOW, $WS_VISIBLE))
    GuiSetBkColor($COLOR_BLUE, $licGui)
    GuiCtrlCreateLabel(_T("license_prompt"), 10, 10, 480, 20)
    GUICtrlSetColor(-1, 0xFFFFFF)
    GUICtrlCreateEdit($sContent, 10, 35, 480, 400, BitOR($ES_AUTOVSCROLL, $ES_READONLY, $ES_MULTILINE, $WS_VSCROLL, $WS_TABSTOP))
    Local $btnAccept  = GUICtrlCreateButton(_T("btn_accept"),  130, 450, 110, 32, $WS_TABSTOP)
    GUICtrlSetState(-1, $GUI_DEFBUTTON)
    Local $btnDecline = GUICtrlCreateButton(_T("btn_decline"), 260, 450, 110, 32, $WS_TABSTOP)
    GuiSetState(@SW_SHOW, $licGui)
    WinActivate($licGui)
    While 1
        Switch GuiGetMSG()
            Case $GUI_EVENT_CLOSE, $btnDecline
                OnAutoItExitUnRegister("_SaveConfig")
                GuiDelete($licGui)
                Exit
            Case $btnAccept
                IniWrite($sConfigFile, "Settings", "LicenseAccepted", "true")
                GuiDelete($licGui)
                ExitLoop
        EndSwitch
    WEnd
EndFunc

Func _ShowFileContent($sTitle, $sFilePath)
    If Not FileExists($sFilePath) Then
        MsgBox(0, _T("error_title"), _T("error_text_file_missing") & $sFilePath)
        Return
    EndIf
    Local $displayGui = GuiCreate($sTitle, 500, 500)
    GUICtrlCreateEdit(FileRead($sFilePath), 20, 20, 450, 400, BitOR($ES_AUTOVSCROLL, $ES_READONLY, $WS_VSCROLL, $WS_TABSTOP))
    Local $btnClose = GUICtrlCreateButton(_T("btn_close"), 200, 430, 100, 30, $WS_TABSTOP)
    GuiSetState(@SW_SHOW, $displayGui)
    While 1
        Switch GuiGetMSG()
            Case $GUI_EVENT_CLOSE, $btnClose
                GuiDelete($displayGui)
                ExitLoop
        EndSwitch
    WEnd
EndFunc

Func _OpenTextHotkey()
    SoundPlay("sounds/enter.wav")
    Local $sFile = FileOpenDialog(_T("open_text_dialog"), @ScriptDir, "Text files (*.txt)", 1)
    If @error Or $sFile = "" Then Return
    GUICtrlSetData($entertext, FileRead($sFile))
EndFunc

Func _SaveTextHotkey()
    SoundPlay("sounds/enter.wav")
    Local $sFile = FileSaveDialog(_T("save_text_dialog"), @ScriptDir, "Text files (*.txt)", 16, "output.txt")
    If @error Or $sFile = "" Then Return
    Local $text = GuiCtrlRead($entertext)
    FileDelete($sFile)
    FileWrite($sFile, $text)
    MsgBox(64, _T("success_title"), _T("save_text_success"))
EndFunc

Func ReadText()
    Local $text = GuiCtrlRead($entertext)
    If StringStripWS($text, 8) = "" Then
        SoundPlay("sounds/enter.wav")
        MsgBox(48, _T("warning_title"), _T("warning_enter_text"))
        Return
    EndIf
    Local $displayGui = GuiCreate(_T("preview_title"), 500, 500)
    GUICtrlCreateEdit($text, 20, 20, 450, 400, BitOR($ES_AUTOVSCROLL, $ES_READONLY, $WS_VSCROLL, $WS_TABSTOP))
    Local $btnClose = GUICtrlCreateButton(_T("btn_close"), 200, 430, 100, 30, $WS_TABSTOP)
    GuiSetState(@SW_SHOW, $displayGui)
    While 1
        Switch GuiGetMSG()
            Case $GUI_EVENT_CLOSE, $btnClose
                GuiDelete($displayGui)
                ExitLoop
        EndSwitch
    WEnd
EndFunc

Func contribute()
    Local $congui = GuiCreate(_T("contribute_title"), 700, 700)
    GuiSetBkColor($COLOR_RED)
    Local $con = ""
    If FileExists("contribute.txt") Then $con = FileRead("contribute.txt")
    GUICtrlCreateEdit($con, 20, 20, 650, 600, BitOR($ES_AUTOVSCROLL, $ES_READONLY, $WS_VSCROLL, $WS_TABSTOP))
    Local $btnClose = GUICtrlCreateButton(_T("btn_close"), 300, 630, 100, 30, $WS_TABSTOP)
    GuiSetState(@SW_SHOW, $congui)
    While 1
        Switch GuiGetMSG()
            Case $GUI_EVENT_CLOSE, $btnClose
                GuiDelete($congui)
                ExitLoop
        EndSwitch
    WEnd
EndFunc

Func _Show_Send_Feedback_Window()
    Local $gui = GuiCreate(_T("feedback_title"), 420, 320, -1, -1, BitOR($WS_CAPTION, $WS_POPUPWINDOW, $WS_VISIBLE))
    GuiSetBkColor($COLOR_BLUE, $gui)
    GuiCtrlCreateLabel(_T("feedback_lbl_title"), 10, 10, 400, 20)
    GUICtrlSetColor(-1, 0xFFFFFF)
    Local $idTitle = GuiCtrlCreateInput(_T("feedback_placeholder"), 10, 30, 400, 22)
    GuiCtrlCreateLabel(_T("feedback_lbl_desc"), 10, 62, 400, 20)
    GUICtrlSetColor(-1, 0xFFFFFF)
    Local $idDesc = GUICtrlCreateEdit("", 10, 84, 400, 170, BitOR($ES_WANTRETURN, $ES_AUTOVSCROLL, $WS_VSCROLL))
    Local $btnSend   = GUICtrlCreateButton(_T("btn_send"),   220, 270, 90, 32, $WS_TABSTOP)
    GUICtrlSetState(-1, $GUI_DEFBUTTON)
    Local $btnCancel = GUICtrlCreateButton(_T("btn_cancel"), 320, 270, 90, 32, $WS_TABSTOP)
    GuiSetState(@SW_SHOW, $gui)
    WinActivate($gui)
    ControlFocus($gui, "", $idTitle)
    While 1
        Switch GuiGetMSG()
            Case $GUI_EVENT_CLOSE, $btnCancel
                GuiDelete($gui)
                ExitLoop
            Case $btnSend
                Local $sTitle = GUICtrlRead($idTitle)
                Local $sDesc  = GUICtrlRead($idDesc)
                If StringStripWS($sDesc, 3) = "" Then
                    MsgBox(48, _T("feedback_title"), _T("error_feedback_empty"))
                    ContinueLoop
                EndIf
                ShellExecute("https://github.com/ninhhoang205/read_text/issues/new?template=feature_request.yml&title=" & _URLEncode($sTitle) & "&description=" & _URLEncode($sDesc))
                GuiDelete($gui)
                ExitLoop
        EndSwitch
    WEnd
EndFunc

Func _ShowChangelog()
    Local $sContent = _T("changelog_not_found")
    Local $sFilePath = @ScriptDir & "\changelog.txt"
    If FileExists($sFilePath) Then
        $sContent = _StripMarkdown(FileRead($sFilePath))
    EndIf
    Local $hGUIch = GuiCreate(_T("changelog_title"), 400, 450)
    GUICtrlCreateEdit($sContent, 10, 10, 380, 380, BitOR($ES_AUTOVSCROLL, $ES_READONLY, $WS_VSCROLL, $WS_TABSTOP))
    Local $btnClose = GUICtrlCreateButton(_T("btn_close"), 150, 400, 100, 30, $WS_TABSTOP)
    GuiSetState(@SW_SHOW, $hGUIch)
    While 1
        Switch GuiGetMSG()
            Case $GUI_EVENT_CLOSE, $btnClose
                GuiDelete($hGUIch)
                ExitLoop
        EndSwitch
    WEnd
EndFunc

Func _LoadConfig()
    If Not FileExists($sConfigFile) Then Return
    Local $iLeft = IniRead($sConfigFile, "Window", "Left", -1)
    Local $iTop  = IniRead($sConfigFile, "Window", "Top",  -1)
    If $iLeft <> -1 And $iTop <> -1 Then WinMove($hGUI, "", $iLeft, $iTop)
    Local $sVoice = IniRead($sConfigFile, "Settings", "Voice", "")
    If $sVoice <> "" Then GUICtrlSetData($comboVoice, $sVoice)
    GUICtrlSetData($sliderVolume, IniRead($sConfigFile, "Settings", "Volume", 100))
    GUICtrlSetData($sliderRate,   IniRead($sConfigFile, "Settings", "Rate",   0))
    GUICtrlSetData($sliderPitch,  IniRead($sConfigFile, "Settings", "Pitch",  0))
    $bAutoUpdate    = (IniRead($sConfigFile, "Settings", "AutoUpdate",    "false") = "true")
    $bAutoClipboard = (IniRead($sConfigFile, "Settings", "AutoClipboard", "false") = "true")
    $bStartup       = (IniRead($sConfigFile, "Settings", "Startup",       "false") = "true")
    ; Khong doc/khoi phuc lai van ban da nhap tu lan truoc (khong luu van ban
    ; giua cac phien lam viec, vi ly do rieng tu). Neu tep cau hinh cu (ban
    ; truoc) con sot lai du lieu "Data/LastText", xoa luon de dep va chac chan
    ; khong con ton tai.
    IniDelete($sConfigFile, "Data")
EndFunc

Func _SaveConfig()
    If Not WinExists($hGUI) Then Return
    IniWrite($sConfigFile, "Settings", "Voice",         GUICtrlRead($comboVoice))
    IniWrite($sConfigFile, "Settings", "Volume",        GUICtrlRead($sliderVolume))
    IniWrite($sConfigFile, "Settings", "Rate",          GUICtrlRead($sliderRate))
    IniWrite($sConfigFile, "Settings", "Pitch",         GUICtrlRead($sliderPitch))
    IniWrite($sConfigFile, "Settings", "AutoUpdate",    $bAutoUpdate    ? "true" : "false")
    IniWrite($sConfigFile, "Settings", "AutoClipboard", $bAutoClipboard ? "true" : "false")
    IniWrite($sConfigFile, "Settings", "Startup",       $bStartup       ? "true" : "false")
    IniWrite($sConfigFile, "Settings", "Language",      $sActiveLang)
    ; Khong luu van ban trong o nhap vao tep cau hinh nua - dong phan mem xong
    ; la mat, khong con luu tru o dau ca (ke ca khong con "Data/LastText" sot
    ; lai tu ban cu, phong khi _LoadConfig chua kip chay xoa no).
    IniDelete($sConfigFile, "Data")
EndFunc

Func _URLEncode($sText)
    Local $sEncoded = ""
    For $i = 1 To BinaryLen(StringToBinary($sText, 4))
        Local $iByte = Int(BinaryMid(StringToBinary($sText, 4), $i, 1))
        If ($iByte >= 48 And $iByte <= 57) Or ($iByte >= 65 And $iByte <= 90) Or ($iByte >= 97 And $iByte <= 122) Or $iByte = 45 Or $iByte = 95 Or $iByte = 46 Or $iByte = 126 Then
            $sEncoded &= Chr($iByte)
        Else
            $sEncoded &= "%" & Hex($iByte, 2)
        EndIf
    Next
    Return $sEncoded
EndFunc

Func _UnescapeJSON($sString)
    $sString = StringReplace($sString, '\"', '"')
    $sString = StringReplace($sString, '\\', '\')
    $sString = StringReplace($sString, '\/', '/')
    $sString = StringReplace($sString, '\b', Chr(8))
    $sString = StringReplace($sString, '\f', Chr(12))
    $sString = StringReplace($sString, '\n', @LF)
    $sString = StringReplace($sString, '\r', @CR)
    $sString = StringReplace($sString, '\t', @TAB)
    Local $aMatch = StringRegExp($sString, "(?i)\\u([0-9a-f]{4})", 3)
    If IsArray($aMatch) Then
        For $i = 0 To UBound($aMatch) - 1
            $sString = StringReplace($sString, "\u" & $aMatch[$i], ChrW(Dec($aMatch[$i])))
        Next
    EndIf
    Return $sString
EndFunc

Func _StripMarkdown($sText)
    $sText = StringRegExpReplace($sText, "<[^>]*>", "")
    $sText = StringRegExpReplace($sText, "(\*\*|__)(.*?)\1", "$2")
    $sText = StringRegExpReplace($sText, "(\*|_)(.*?)\1", "$2")
    $sText = StringRegExpReplace($sText, "(?m)^#+\s+", "")
    $sText = StringRegExpReplace($sText, "\[(.*?)\]\(.*?\)", "$1")
    $sText = StringRegExpReplace($sText, "!\[.*?\]\(.*?\)", "")
    $sText = StringRegExpReplace($sText, "`(.+?)`", "$1")
    $sText = StringReplace($sText, "```", "")
    $sText = StringRegExpReplace($sText, "(?m)^>\s+", "")
    $sText = StringRegExpReplace($sText, "(?m)^\s*[\-\*\+]\s+", "")
    $sText = StringRegExpReplace($sText, "(?m)^\s*[\-\*\+]\s+\[[ xX]\]\s+", "")
    $sText = StringRegExpReplace($sText, "(?m)^\s*\d+\.\s+", "")
    $sText = StringRegExpReplace($sText, "(?m)^[\-\*_]{3,}\s*$", "")
    Return $sText
EndFunc

Func _ErrFunc()
    ; Duoc goi tu dong khi co loi COM (vd: mot SAPI voice-token con sot lai
    ; trong registry nhung engine that su da bi go). Chi ghi nhan bang co,
    ; khong hien MsgBox, giu dung hanh vi "khong crash" nhu truoc.
    $g_bComError = True
EndFunc
