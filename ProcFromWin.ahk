/*
	ProcFromWin
	Get the process name, pid, and other information from a window, and more.

	This program was created after I had a little trouble finding out where a 
	"fakeav" program was running from, so that I could kill and remove it.
	It has since been expanded quite a bit, to turn it into a (hopefully) useful 
	malware analysis/removal tool, with a number of (I think) nifty features. 
	I hope someone can put it to good use.

	Planned features (coming some day):
	~ Use psapi/GetProcessMemoryInfo and psapi/GetPerformanceInfo dllcalls to 
	get process performance info. 
		[http://msdn.microsoft.com/en-us/library/ms683219(v=VS.85).aspx] 
		[http://msdn.microsoft.com/en-us/library/ms683210(v=VS.85).aspx]
	~ Use psapi/EnumProcessModules and psapi/GetModuleInformation to gather 
	some info about what a proc is doing. 
		[http://msdn.microsoft.com/en-us/library/ms682631(v=VS.85).aspx] 
		[http://msdn.microsoft.com/en-us/library/ms683201(v=VS.85).aspx]
	~ Use netstat to get a list of connections a pid has established. 
	~ Use more built-in ahk functions to get more info about procs/windows.
	~ Add an input box to make it possible to specify the process/pid, so you 
	can get info about a process without it having a window open. 
	~ Add a spot in the ini file to specify a proc/pid to grab info from 
	immediately when PFW starts, so you don't miss those crafty popup thingies 
	that hide before you can get PFW open and point a cursor at the right 
	window and press the spacebar...
	~ Add a whole lot of other stuff to the ini file. 
	~ Fix a whole lotta bugs, and make everything work better on Win 7/8.
	~ Test on XP and/or before, and fix any bugs.
	~ Add a little OS detection & similar junk, just because.
	~ Redesign crappy guis, and make it so they don't break when there is more 
	text/other stuff than they expect.
	~ Add a "keep on top?" option.
	~ Add an Esc hotkey to close the emulate/help/about windows.
	~ If I can think of anything else that might be useful, add that in too. 
	~ Totally re-write functions from scratch, because they are CRAP, and 
	remove redundant 'Return's.
	~ Reformat everything to AHK_L syntax, because it doesn't just work in 
	basic anymore.
	~ CLEAN UP & REFORMAT MESSY CODE!
	~ Compile final (1.0) version for AHK_L x86, _L x64, and AHK basic mini x86, 
*/

;== Configuration: Edit this if you want to. ==;
KillAllSleepTime := 100   ;In milliseconds.
MainGuiColor := c3c3c3    ;I like just a neutral grayish color.
MainGuiTrans := 225       ;255 is fully visible, 0 is invisible. I think 225 works well.
;== End configuration ==;


;This is just to make changing the version/name string easier for me.
PFWVerString = ProcFromWin 0.A beta


  ;Set a few important things: 
DetectHiddenText, On
DetectHiddenWindows, On
#SingleInstance, Force




;== Gui Stuff ==;
MainGuiCreate:
Gui, Font, q5 s9 c000000, Segoe UI
Gui, Color, %MainGuiColor%
Gui, Font, s8
Gui, Add, Text,, Hold cursor over window and press `n spacebar to grab info.

MainGuiShow:
Gui, Show, Hide, %PFWVerString%
Gui +ToolWindow -Caption +AlwaysOnTop +LastFound
Gui, Show, x0 y0, %PFWVerString%
WinSet, Transparent, %MainGuiTrans%, %PFWVerString%

;== Tray Menu Stuff ==;
Menu, Tray, NoStandard
Menu, Tray, Add, &Help, HelpGui
Menu, Tray, Add, &About, AboutGui
Menu, Tray, Add, &Get Info by Name/PID, InputBox
Menu, Tray, Add, &Suspend/Resume, SuspendIt
Menu, Tray, Add, &Exit, EndIt
Menu, Tray, Tip, %PFWVerString%
Return

GuiClose:
OnExit:
Gui, Destroy
ExitApp
Return




Space::
GetWinInfo:
Win := GetWinofInterest()
ProcPID := GetProcPid(Win)
ProcFullPath := GetProcPath(ProcPID)
ProcName := GetJustProc(Win)
WinGetTitle, WinTitle, ahk_id %Win%
If WinTitle = 
  WinTitle = None
WinGetText, WinText, ahk_id %Win%
WinGetPos, XPos, YPos, WinWidth, WinHeight, ahk_id %Win%

CreateInfoWin:
IfWinExist, Window Information
	Gui, 2:Destroy
WinActivate, %PFWVerString%
Gui, 2:+owner1
Gui, 2:Add, Text,, Process: %ProcName%`nPID: %ProcPid%`nProcess location: %ProcFullPath%
Gui, 2:Add, Text, gKillItName Center, Kill all instances of process
Gui, 2:Add, Text, gKillItPid Center, Kill only this specific process. (Using PID)
Gui, 2:Add, Text, gDelIt Center, Try to delete exe.
Gui, 2:Add, Text, gMoreInfoGui Center, More information
Gui, 2:Show, h200, Window Information
Return

2GuiClose:
Gui, 2:Destroy
WinActivate, %PFWVerString%
Return

 ;The Gui options- Kill and Delete.
KillItName:
ProcessCloseAll(ProcName)
If Not ErrorLevel
	Gui, 2:Add, Text,, Process appears to have been killed successfully. 
ProcState := ProcessExist(ProcName)
Gui, 2:+Resize
Return

KillItPid:
ProcessCloseAll(ProcPID)
If Not ErrorLevel
	Gui, 2:Add, Text,, Process appears to have been killed successfully. 
ProcState := ProcessExist(ProcPID)
Gui, 2:+Resize
Return

DelIt:     ;No, you can't make it delete itself. :P
Process, close, %ProcName%
IfNotExist, %ProcFullPath%
	Gui, 2:Add, Text,, That file does not appear to exist.
IfExist, %ProcFullPath%
{
	FileDelete, %ProcFullPath%
	IfNotExist, %ProcFullPath%
		Gui, 2:Add, Text,, File successfully deleted.
}

Return
  ;End Gui 2 - WinInfo

  ;Gui 3 - About
AboutGui:
Gui, 3:+owner1
Gui, 3:Color, dddddd
Gui, 3:Font, c000044 s9 q5, Segoe UI
Gui, 3:Add, Text, gPFWHome, %PFWVerString%
Gui, 3:Add, Text, gMEHome, Created by george2. 
Gui, 3:Add, Text, gAHKHome, Made possible by AHK.
Gui, 3:Show,, About %PFWVerString%
Return

PFWHome:
;Run, www.[myhome].com/[pfwhomepage]?PWF
Return

MEHome:
;Run, www.[myhome].com/?PWF
Return

AHKHome:
Run, www.autohotkey.com
Return

3GuiClose:
Gui, 3:Destroy
WinActivate, %PFWVerString%
Return
  ;End Gui 3 - About

  ;Gui 4 - Help
HelpGui:
Gui, 4:+owner1
Gui, 4:Font, s9 q5, Segue UI
Gui, 4:Add, Text, Center, To use ProcFromWin, simply point your cursor over the `nwindow you want to analyze`, and hit the spacebar.`nThis should show you a window with information`nabout the window you selected`, and the options to `nkill and/or delete the exe running the window, `nor show more information about it.`n`nProcFromWin was designed after I ran into a `nscareware/fakeav that was using a script host to run `nitself`, and had a little trouble figuring out what `nexe/process the malware was using. I couldn't `nstop thinking about how much easier it `nwould have been if I had had a tool like this.`nNow I do. I hope someone else can put`nit to use for a similar purpose.`n`n
Gui, 4:Show,, ProcFromWin Help
Return

4GuiClose:
Gui, 4:Destroy
WinActivate, %PFWVerString%
Return
  ;End Gui 4 - Help

  ;Gui 5 - More Information
MoreInfoGui:
Gui, 5:+owner2
Gui, 5:Add, Picture,, %ProcFullPath%
Gui, 5:Add, Text, , Copyable executable location:
Gui, 5:Add, Edit, , %ProcFullPath%
Gui, 5:Add, Text, , `nWindow title: %WinTitle%
Gui, 5:Add, Text, , `nWindow text (if any):
Gui, 5:Add, Edit, , %WinText%
Gui, 5:Add, Text, , `nWindow size and position: XPos = %XPos%`, YPos = %YPos%`, Width = %WinWidth%`, Height = %WinHeight%
Gui, 5:Add, Text, gMakeFakeWin, `nEmulate window
Gui, 5:Add, Text, , 
Gui, 5:Show,, More Information
Gui, 5:+Resize
Return

5GuiClose:
Gui, 5:Destroy
Return
  ;End Gui 5 - More Info

  ;Gui 6 - Fake Window
MakeFakeWin:
Gui, 6:Destroy
Gui, 6:+owner5
Gui, 6:Add, Text,, %WinText%
Gui, 6:Show, W%WinWidth% H%WinHeight% X%XPos% Y%YPos%, %WinTitle%
WinMove, A,, %XPos%, %YPos%, %WinWidth%, %WinHeight%
WinSet, Transparent, 200, A
Gui, 6:+ToolWindow
Return

6GuiClose:
Gui, 6:Destroy
WinActivate, %PFWVerString%
Return

6GuiMinimize:
Gui, 6:Destroy
WinActivate, %PFWVerString%
Return
  ;End Gui 6 - Fake Window


SuspendIt:
If Suspent = 1
{
	Suspend
	WinRestore, %PFWVerString%
	WinShow, %PFWVerString%
	Suspent := 0
}
Else
{
	WinMinimize, %PFWVerString%
	WinHide, %PFWVerString%
	Suspent := 1
	Suspend
}
Return



InputBox:
Gui, 7:Destroy
Gui, 7:+owner1
Gui, 7:Add, Text, , What process would you like to get info about?
Gui, 7:Add, Text, , Process name (xxx.exe):
Gui, 7:Add, Edit, w100 vGetFromProc, %GetFromProc%
Gui, 7:Add, Text, , Or PID:
Gui, 7:Add, Edit, w100 vGetFromPID, %GetFromPID%
Gui, 7:Add, Button, gB7Clear, Clear
Gui, 7:Add, Button, gB7Go, Get Info
Gui, 7:Show, , Get info by name/pid
Return

B7Clear:
GetFromProc := ""
GetFromPID := ""
GuiControl, , GetFromProc, %GetFromProc%
GuiControl, , GetFromPID, %GetFromPID%
Return

B7Go:
Gui, Submit
If GetFromPID != 
{
	If Not (RegExMatch(GetFromPid, "S)^\d+$"))
	{
		MsgBox, %GetFromPID% is not a valid PID.
		GetFromPID := ""
		GuiControl, , GetFromPID, %GetFromPID%
		Goto, InputBox
	}
	Else 
	{
		ProcPID := GetFromPID
		
		Goto, GetInfoNoMouse
	}
}
Else If GetFromProc != 
{
	ProcName := GetFromProc
	
	Goto, GetInfoNoMouse
}
Return

GetInfoNoMouse:
;ProcPID := GetProcPid(Win)
ProcFullPath := GetProcPath(ProcPID)
;ProcName := GetJustProc(Win)
;WinGetTitle, WinTitle, ahk_id %Win%
;If WinTitle = 
;  WinTitle = None
;WinGetText, WinText, ahk_id %Win%
;WinGetPos, XPos, YPos, WinWidth, WinHeight, ahk_id %Win%
Goto, CreateInfoWin


EndIt:
ExitApp
Return
;=================;
;= End Gui Stuff =;
;^^^^^^^^^^^^^^^^^;










;====================================================;
;==	These are the functions used by the program.
;==	They are what makes it tick.
;==	They are also currently complete crap.
;====================================================;

GetWinofInterest() ;Get the ID of the window under the cursor
{
	MouseGetPos,,, Win
	Return, Win
}


GetProcPath(p_pid) {	  ;code contributed by an #ahk-er -- gets proc (exe) and full path from win. I didn't change a whole lot here, but I did make a few tweaks, and add the comments.
  	h_process := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", p_pid )
	If (ErrorLevel or h_process = 0)  ;Check for errors
		Return, "Error retrieving information!"  ;Usually happens when you try to grab info about an admin proc from pfw as normal user.
	name_size = 255   ;Don't let the path be over 255 chars long. I don't recommend changing this unless you have a valid reason.
	VarSetCapacity( ProcFullPath, name_size )    ; ^
	result := DllCall( "psapi.dll\GetModuleFileNameEx", "uint", h_process, "uint", 0, "str", ProcFullPath, "uint", name_size )    ;Call psapi.dll's GetModuleFileNameEx function. (I had to change this from the *A function to make it work in unicode ahk. (Thanks Uberi!))
	DllCall( "CloseHandle", h_process )   ;Release the dll
	Return, ProcFullPath
}

GetJustProc(win) {	;Get only the proc (exe) for the win
	WinGet, ProcName, ProcessName, ahk_id %win%
	Return, ProcName
}

GetProcPID(win) {	;Get just the pid
	WinGet, ProcPID, PID, ahk_id %Win%
	Return, ProcPID
}
Return

ProcessExist(exeName) {	;From https://github.com/camerb/AHKs/blob/master/FcnLib-Rewrites.ahk (Thanks camerb!)
	Process, Exist, %exeName%
	return !!ERRORLEVEL
}

ProcessClose(exeName) {	;From same
	Process, Close, %exeName%
}

ProcessCloseAll(exeName) {	;From same
	while ProcessExist(exeName) {
		ProcessClose(exeName)
		Sleep, %KillAllSleepTime%  ;Slightly modified from original. camerb had the sleep time set to 10 ms.
	}
}
