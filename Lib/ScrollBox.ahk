;=============================================================================
; ScrollBox.ahk - Scrollable text display GUI helper
;
; SOURCE: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4837
; AUTHOR: Fanatic Guru
; LICENSE: Public domain (AHK forum post)
; VERSION: 1.21 (2018-06-09)
;
; Vendored snapshot for IdleCombos. Do not modify — update from source if needed.
;=============================================================================

;{ ScrollBox
; CHANGELOG:
; 2016 11 18		Version 1.2
; 2018 06 09		Version 1.21
;	Fixed issue with creating autosize control containing more than 32k characters
;
; FUNCTION to Create Gui Scroll Box 
;
;------------------------------------------------
;
; Method:
;   ScrollBox(String, Options, Label)
;
;   Parameters:
;   1) {String} String to be displayed in scroll box
;
;   2) {Options}
;		d		destroy Gui if exist and recreate new
;		w		word wrap
;		p		pause until Gui closed
;		h		hide Gui if exist
;		s		show Gui if exist
;		l		left justified
;		r		right justified
;		c		center justified
;		p%%		p followed by a number for ms to pause
;		f%%		f followed by a number for font size
;		f{%%}	f followed by font options in format of Gui font command
;		x%%		x followed by a number for x box location
;		y%% 	y followed by a number for y box location
;		h%%		h followed by a number for height of box
;		w%%		w followed by a number for width of box
;		t%%		t followed by a number for tab stop (can be multiple)
;		b1		OK button, pauses for response
;		b2		YES / NO buttons, pauses for response
;					Options of existing Gui can not be changed except for position and size
;
;	3)  {Label}	Identifier for dealing with multiply Gui, also the Label at the top of Gui
;				Used to create the Gui name, all non-valid characters are striped
;				If Label exist and String is null and Options is null then Gui is destroyed
;					Otherwise Gui will be updated with new string
;					And Options x, y, h, w can be used to reposition and resize Gui Window
;
;				If String and Label are null then all Gui are destroyed
;
; Returns: 
;		1		OK or YES button pushed
;		0		NO button pushed
;		-1		Gui closed or escaped without pushing button
;		-2		Gui either had no pause or pause finished causing Gui to close
;
; Global:
;   Creates a series of global gui labels prefixed with ScrollBox_Gui_Label_
;
; Note:
;	When scroll box attempts to auto adjust control to fit text it will fail on very large strings.
; 	If scroll box is given a height and width then larger strings can be displayed.
;	Closing the box or hitting escape will destroy the gui.
;
; Example:
;	ScrollBox(Text, "w b2 p5000 f{s16 cRed bold, Arial} x50 y50 h400 w400")
;
ScrollBox(String := "", Options := "", Label := "")
{
	Static Gui_List, Gui_Index
	DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
		SetWinDelay, % (Setting_A_WinDelay := A_WinDelay) ? 0 : 0
		if !Gui_List
			Gui_List := {}
		if Label
		{
			Gui_Label := "ScrollBox_Gui_Label_" RegExReplace(Label, "i)[^0-9a-z#_@\$]", "")
			Gui_Hwnd := Gui_List[Gui_Label]
			Win_Hwnd := DllCall("GetParent", UInt, Gui_Hwnd)
			if RegExMatch(RegExReplace(Options, "\{.*}"), "i)d")
				Gui, %Gui_Label%:Destroy
			else if WinExist("ahk_id " Win_Hwnd)
			{
				if String
					GuiControl,,%Gui_Hwnd%, %String%
				WinGetPos, WinX, WinY, WinW, WinH
				if RegExMatch(Options, "i)x(\d+)", Match)
					WinX := Match1
				if RegExMatch(Options, "i)y(\d+)", Match)
					WinY := Match1
				if RegExMatch(Options, "i)w(\d+)", Match)
					WinW := Match1
				if RegExMatch(Options, "i)h(\d+)", Match)
					WinH := Match1
				Winmove, ahk_id %Win_Hwnd%,, WinX, WinY, WinW, WinH
				if RegExMatch(Options, "i)h(?!\d)", Match)
					Gui, %Gui_Label%:Hide
				if RegExMatch(Options, "i)s", Match)
					Gui, %Gui_Label%:Show
				DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
				SetWinDelay, %Setting_A_WinDelay%
				return
			}
		}
		else
		{
			Gui_Index ++
			Gui_Label := "ScrollBox_Gui_Label_" Gui_Index
		}
		if (!String and !Options)
		{
			if Label
			{
				Gui_List.Delete(Gui_Label)
				Gui, %Gui_Label%:Destroy
			}
			else
			{
				for key, element in Gui_List
					Gui, %key%:Destroy
				Gui_List := {}
			}
			DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
			SetWinDelay, %Setting_A_WinDelay%
			return
		}
		Gui %Gui_Label%:Default
		Gui +LabelAllGui
		Adjust1 := 10
		ButtonPushed := -2
		if RegExMatch(Options, "i)f(\d+)", Match)
		{
			Gui, Font, s%Match1%
			Adjust1 := Match1
		}
		else if RegExMatch(Options, "i)f\{(.*)}", Match)
		{
			Options := RegExReplace(Options, "i)f\{.*}")
			StringSplit, Match, Match1, `,
			Gui, Font, %Match1%, % Trim(Match2)
			RegExMatch(Match1, "i)s(\d+)", Adjust)
		}
		else
			Gui, Font
		Gui, Margin, 20, 20
		;Gui, +ToolWindow +MinSize200x200 +Resize
		Gui, +MinSize200x200 +Resize
		;Gui, Color, FFFFFF
		Gui, Color, %BgColour%
		Opt := "hwndGui_Hwnd ReadOnly -E0x200 "
		if !(Options ~= "i)w(?!\d)")
			Opt .= "+0x300000 -wrap "
		if RegExMatch(Options, "i)h(\d+)", Match)
			Opt .= "h" Match1 " ", Control := true 
		if RegExMatch(Options, "i)w(\d+)", Match)
			Opt .= "w" Match1 " ", Control := true
		if (Options ~= "i)c")
			Opt .= "center "
		if (Options ~= "i)l")
			Opt .= "left "
		if (Options ~= "i)r")
			Opt .= "right "
		Loop
		{
			Pos ++
			if (Pos := RegExMatch(Options, "i)t(\d+)", Match, Pos))
				Opt .= "t" Match1 " "
		} until !Pos
		Opt_Show := "AutoSize "
		if RegExMatch(Options, "i)x(\d+)", Match)
			Opt_Show .= "x" Match1 " "
		if RegExMatch(Options, "i)y(\d+)", Match)
			Opt_Show .= "y" Match1 " "
		if Control
		{
			Gui, Add, Edit, % Opt
			GuiControl, , %Gui_Hwnd%, %String%
		}
		else
		{
			if (StrLen(String) < 32000)	; Gui control cannot be created with more than 32k of text directly
				Gui, Add, Edit, % Opt, %String%
			else
			{
				Gui, Add, Edit, % Opt, % SubStr(String, 1, 32000)
				GuiControl, , %Gui_Hwnd%, %String%
			}
		}
		if RegExMatch(Options, "i)b(1|2)", Match)
		{
			Button := Match1
			if (Button = 1)
				Gui, Add, Button, gAllGuiButtonOK hwndScrollBox_Button1_Hwnd Default, OK
			else
			{
				Gui, Add, Button, gAllGuiButtonYES hwndScrollBox_Button1_Hwnd Default, YES
				Gui, Add, Button, gAllGuiButtonNO hwndScrollBox_Button2_Hwnd, % " NO "
			}
		}
		Gui, Show, % Opt_Show, % Label ? Label : "ScrollBox"
		Gui_List[Gui_Label] := Gui_Hwnd
		Win_Hwnd := DllCall("GetParent", UInt, Gui_Hwnd)
		WinGetPos,X,Y,W,H, ahk_id %Win_Hwnd%
		WinMove, ahk_id %Win_Hwnd%,,X,Y,W-1,H-1 ; Move
		WinMove, ahk_id %Win_Hwnd%,,X,Y,W,H ; And Move Back to Force Recalculation of Margins
		if Button
			ControlSend,,{Tab}{Tab}+{Tab}, ahk_id %Gui_Hwnd% ; Move to Button
		else
			ControlSend,,^{Home}, ahk_id %Gui_Hwnd% ; Unselect Text and Move to Top of Control
		DllCall("HideCaret", "Int", Gui_Hwnd)
		if ((Options ~= "i)p(?!\d)") or (!(Options ~= "i)p") and Button))
			while (ButtonPushed = -2)
			Sleep 50
		else if RegExMatch(Options, "i)p(\d+)", Match)
		{
			TimeEnd := A_TickCount + Match1
			while (A_TickCount < TimeEnd and ButtonPushed = -2)
				Sleep 50
			Gui_List.Delete(Gui_Label)
			Gui, Destroy
		}
		DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
		SetWinDelay, %Setting_A_WinDelay%
		Gui, 1:Default
	return ButtonPushed

	AllGuiSize:
		Resize_Gui_Hwnd := Gui_List[A_Gui]
		if Button
		{
			if (Button = 1)
			{
				EditWidth := A_GuiWidth - 20
				EditHeight := A_GuiHeight - 20 - (Adjust1 * 3)
				ButtonX := EditWidth / 2 - Adjust1
				ButtonY := EditHeight + 20 + (Adjust1/6) 
				GuiControl, Move, %Resize_Gui_Hwnd%, W%EditWidth% H%EditHeight%
				GuiControl, Move, %ScrollBox_Button1_Hwnd%, X%ButtonX% Y%ButtonY%
			}
			else
			{
				EditWidth := A_GuiWidth - 20
				EditHeight := A_GuiHeight - 20 - (Adjust1 * 3)
				Button1X := EditWidth / 4 - (Adjust1 * 2)
				Button2X := 3 * EditWidth / 4 - (Adjust1 * 1.5)
				ButtonY := EditHeight + 20 + (Adjust1/6) 
				GuiControl, Move, %Resize_Gui_Hwnd%, W%EditWidth% H%EditHeight%
				GuiControl, Move, %ScrollBox_Button1_Hwnd%, X%Button1X% Y%ButtonY%
				GuiControl, Move, %ScrollBox_Button2_Hwnd%, X%Button2X% Y%ButtonY%
			}
		}
		else
		{
			EditWidth := A_GuiWidth - 20
			EditHeight := A_GuiHeight - 20
			GuiControl, Move, %Resize_Gui_Hwnd%, W%EditWidth% H%EditHeight%
		}
	return

	AllGuiButtonOK:
		ButtonPushed := 1
		Gui, %A_Gui%:Destroy
		Gui_List.Delete(A_Gui)
	return

	AllGuiButtonYES:
		ButtonPushed := 1
		Gui, %A_Gui%:Destroy
		Gui_List.Delete(A_Gui)
	return

	AllGuiButtonNO:
		ButtonPushed := 0
		Gui, %A_Gui%:Destroy
		Gui_List.Delete(A_Gui)
	return

	AllGuiEscape:
	AllGuiClose:
		ButtonPushed := -1
		Gui, %A_Gui%:Destroy
		Gui_List.Delete(A_Gui)
	return
}
