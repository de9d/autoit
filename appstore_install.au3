#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         Den H.

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include "wd_helper.au3"
#include "wd_capabilities.au3"

_DownloadAndInstallExample()

Func _DownloadAndInstallExample()
	# REMARK
	#   This script requires additional UDFs and WD to run correctly

	#Region ; Precondition 1: remove old setup file if exists
	
	Local $SetupFilePath = "C:\Users\" & @UserName & "\Downloads\Setup.exe"
	If FileExists($SetupFilePath) Then FileDelete($SetupFilePath)
		
	#EndRegion ; Precondition 1: remove old setup file if exists

	#Region ; Precondition 2: initialize webdriver sesion

	; specify driver, port and other options
	_WD_Option('Driver', 'msedgedriver.exe')
	_WD_Option('Port', 9515)

	; start the driver
	_WD_Startup()
	If @error Then Return SetError(@error, @extended, 0)

	; create capabilites for session
	_WD_CapabilitiesStartup()
	_WD_CapabilitiesAdd('w3c', True)
	_WD_CapabilitiesAdd('excludeSwitches', 'enable-automation')
	Local $sCapabilities = _WD_CapabilitiesGet()

	; create session with given Capabilities
	Local $WD_SESSION = _WD_CreateSession($sCapabilities)
	If @error Then Return SetError(@error, @extended, 0) 

	#EndRegion ; Precondition 2: initialize webdriver sesion

	#Region ; Scenario: download and install PC App Store

	; Step 1: navigate to website
	Local $sURL = "https://pcapp.store"
	_WD_Navigate($WD_SESSION, $sURL)
	If @error Then Return SetError(@error, @extended, 0)

	; wait for loading process ends
	_WD_LoadWait($WD_SESSION, 1000)
	If @error Then Return SetError(@error, @extended, 0)

	; Step 2: find Download button
	Local $sXPath = "//*[@id='header_btns']/button"
	Local $sElement = _WD_FindElement($WD_SESSION, $_WD_LOCATOR_ByXPath, $sXPath)
	If @error Then Return SetError(@error, @extended, 0)
		
	; Step 3: click Download button
	_WD_ElementAction($WD_SESSION, $sElement, 'click')
	If @error Then Return SetError(@error, @extended, 0) 

	; Step 4: wait until file download complete
	Local $begin = TimerInit()
	While TimerDiff($begin) < 300000
		If FileExists($SetupFilePath) Then ExitLoop
	WEnd
	If @error Then Return SetError(@error, @extended, 0) 
		
	; Step 5: launch downloaded file
	ShellExecute($SetupFilePath)
	If @error Then Return SetError(@error, @extended, 0) 
	
	; Step 6: click Next in setup wizard
	WinWaitActive(" PC App Store  Setup")
	Send("!n")
	If @error Then Return SetError(@error, @extended, 0) 
	
	; Step 7: click Install in setup wizard
	WinWaitActive(" PC App Store  Setup", "Where should we install the app?")
	Send("!i")
	If @error Then Return SetError(@error, @extended, 0) 
	
	; Step 8: verify PC Store App is installed
	Local $appShortcutPath = "C:\Users\" & @UserName & "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\PC App Store.lnk"
	$begin = TimerInit()
	While TimerDiff($begin) < 300000
		If FileExists($appShortcutPath) Then ExitLoop
	WEnd
	If @error Then Return SetError(@error, @extended, 0) 
	
	ShellExecute($appShortcutPath)
	WinWaitActive("PC App Store", "PC App Store is up and running")
	Send("{Enter}")
	If @error Then Return SetError(@error, @extended, 0) 

	#EndRegion ; download and install PC App Store

	#Region ; Tear Down

	; delete WD session
	_WD_DeleteSession($WD_SESSION)
	If @error Then Return SetError(@error, @extended, 0) 

	; close WD
	_WD_Shutdown()
	If @error Then Return SetError(@error, @extended, 0)
		
	; TO-DO: uninstall app

	#EndRegion ; Clean Up

EndFunc   ;==> _DownloadAndInstallExample