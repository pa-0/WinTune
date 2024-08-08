CreatePopupTheme(Ctr, *) {
	Ctr.GetPos(&xCtr,&yCtr,&wCtr,&hCtr)
	g:=Ctr.Gui
	g.GetPos(&xG,&yG)
	g2:=CreateDlg(g, 0, Themes.%App.ThemeSelected%.TextColorHover)
	g2.SetFont("s" App.MainFontSize+1)
	x:=80
	For k,v In Themes.OwnProps() {
		BtnSys_SaveOptimizeConfigTab:=g2.AddText('vTheme_Color_' k ' c' v.BackColor ' x' x ' y' 6 ' w30 h30',App.ThemeSelected=k?Chr(0xEC61):Chr(0xE91F))
		BtnSys_SaveOptimizeConfigTab.SetFont("s" (App.ThemeSelected=k?22:20),App.IconFont)
		BtnSys_SaveOptimizeConfigTab.OnEvent("Click", Theme_Color_Click)
		x+=38
	}
	Theme_Color_Click(Ctr, *) {
		ThemeClicked:=SubStr(Ctr.Name,13)
		If ThemeClicked=App.ThemeSelected
			Return
		PrevCtr:=Ctr.Gui["Theme_Color_" App.ThemeSelected]
		
		App.ThemeSelected:=ThemeClicked
		SetTheme(g, Themes.%App.ThemeSelected%)
		PrevCtr.Text:=Chr(0xE91F)
		PrevCtr.SetFont("s20")
		Ctr.Text:=Chr(0xEC61)
		Ctr.SetFont("s22")
		IniWrite App.ThemeSelected, "config.ini", "General", "Theme"
	}
	
	BGImage:=IniRead("config.ini", "Gui", "BGImage", 0)
	g2.SetFont("cFFFFFF")
	g2.AddText("xm",GetLangText("Text_BackgroundImage") ":")
	g2.AddRadio("vSetting_BGImage_Radio w80 h25" (BGImage==0?" Checked":""), GetLangText("Text_None")).OnEvent("Click",BGImage_Radio_None_Click)
	g2.AddRadio("yp h25" (BGImage==1?" Checked":""), GetLangText("Text_DefaultImage")).OnEvent("Click",BGImage_Radio_Default_Click)
	IsCustomBGImage:=(BGImage&&BGImage!=0&&BGImage!=1?1:0)
	g2.AddRadio("w80 h25 xm" (IsCustomBGImage?" Checked":""), GetLangText("Text_Custom")).OnEvent("Click",BGImage_Radio_Custom_Click)
	BGImageEdit:=g2.AddEdit("w200 h25 ReadOnly -Wrap r1 yp c202020" (IsCustomBGImage?"":" Disabled"), (IsCustomBGImage?BGImage:""))
	BtnSelectImage:=g2.AddButton("yp h25 Background" Themes.%App.ThemeSelected%.TextColorHover (IsCustomBGImage?"":" Disabled"), "...")
	BtnSelectImage.OnEvent("Click",BtnSelectImage_Click)
	
	BGImage_Radio_None_Click(*) {
		BtnSelectImage.Enabled:=False
		BGImageEdit.Enabled:=False
		BGImageEdit.Value:=""
		If SetBGImage(g["BGImage"],0)
			IniWrite 0, "config.ini", "Gui", "BGImage"
	}
	BGImage_Radio_Default_Click(*) {
		BtnSelectImage.Enabled:=False
		BGImageEdit.Enabled:=False
		BGImageEdit.Value:=""
		If SetBGImage(g["BGImage"],1)
			IniDelete "config.ini", "Gui", "BGImage"
	}
	BGImage_Radio_Custom_Click(*) {
		BtnSelectImage.Enabled:=True
		BGImageEdit.Enabled:=True
	}
	BtnSelectImage_Click(*) {
		g.Opt("+Disabled")
		g2.Opt("+OwnDialogs")
		HideToolTip()
		SelectedFile := FileSelect(3, , "Open a image", "")
		If SelectedFile {
			If SetBGImage(g["BGImage"],SelectedFile) {
				BGImageEdit.Value:=SelectedFile
				IniWrite SelectedFile, "config.ini", "Gui", "BGImage"
			}
		}
		g2.Opt("-OwnDialogs")
		g.Opt("-Disabled")
	}
	
	tX:=xG+xCtr-(343-wCtr)/2
	tY:=yG+yCtr+hCtr+6
	g2.Show("x" tX " y" tY)
	If WinWaitNotActive(g2)
		DestroyDlg
}

SetTheme(g, Theme) {
	g.BackColor:=Theme.BackColor
	g.SetFont("c" Theme.TextColor)
	ToolTipOptions.SetColors("0x" Theme.BackColor, "0x" Theme.TextColor)
	pToken:=Gdip_Startup()
	SetBGNavSelect(g)
	SetBGPanel(g)
	Gdip_Shutdown(pToken)
	SetMenuTheme()
	For Hwnd, GuiCtrlObj in g {
		SetCtrlTheme(GuiCtrlObj)
	}
}
