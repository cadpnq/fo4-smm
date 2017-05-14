ScriptName SettlementMenuManager:MainScript Extends Quest

Struct CustomMenu
	FormList TargetMenu
	Form ModMenu
	String PluginName
	String ModName
	String Author
EndStruct

FormList Property WorkshopMainMenu Auto Const
Holotape Property SMM_Holotape Auto Const
Bool Property Ready = False Auto

; is 1024 slots overkill? probably, but then again so was 640k
CustomMenu[] Chunk0
CustomMenu[] Chunk1
CustomMenu[] Chunk2
CustomMenu[] Chunk3
CustomMenu[] Chunk4
CustomMenu[] Chunk5
CustomMenu[] Chunk6
CustomMenu[] Chunk7

int ChunkCount = 8
int MenuCount = 0

; I don't really like this, but doing it with GetPropertyValue doesn't work.
CustomMenu[] Function GetChunk(int Number)
	If(Number == 0)
		Return Chunk0
	ElseIf (Number == 1)
		Return Chunk1
	ElseIf (Number == 2)
		Return Chunk2
	ElseIf (Number == 3)
		Return Chunk3
	ElseIf (Number == 4)
		Return Chunk4
	ElseIf (Number == 5)
		Return Chunk5
	ElseIf (Number == 6)
		Return Chunk6
	ElseIf (Number == 7)
		Return Chunk7
	EndIf
EndFunction

CustomMenu Function GetMenuStruct(int Index)
	int ChunkNumber = Math.floor(Index / 128)
	int ChunkAddress = Index % 128
	Return GetChunk(ChunkNumber)[ChunkAddress]
EndFunction

CustomMenu Function GetEmptyMenuStruct()
	int i = 0
	CustomMenu CurrentMenu
	While (i < ChunkCount * 128)
		CurrentMenu = GetMenuStruct(i)
		If (CurrentMenu.PluginName == "")
			Return CurrentMenu
		EndIf
		i += 1
	EndWhile
	; we should do something here. it means there are no empty slots available
EndFunction

; Go through every registered menu and:
; if the plugin is installed, install the menus
; if it isn't then try to clean up the menu formlists.
; there is some performance left on the table here. for more speed use
; GetChunk directly instead of GetMenuStruct. that will get rid of the
; overhead of a few function calls.
Function ProcessMenus(bool SafeMode = False)
	int i = 0
	int ProcessedMenus = 0
	CustomMenu CurrentMenu
	While (i < ChunkCount * 128)
		If (ProcessedMenus == MenuCount)
			Return
		EndIf

		CurrentMenu = GetMenuStruct(i)
		If (CurrentMenu.PluginName != "")
			If (Game.IsPluginInstalled(CurrentMenu.PluginName))
				Debug.Trace("installed menu: " + CurrentMenu.ModName)
				ProcessedMenus += 1
				If (SafeMode)
					CurrentMenu.TargetMenu.RemoveAddedForm(CurrentMenu.ModMenu)
				Else
					TryToInstallMenu(CurrentMenu)
				EndIf
			Else
				Debug.Trace("uninstalled menu: " + CurrentMenu.ModName)
				CleanFormList(CurrentMenu.TargetMenu)
				CurrentMenu.PluginName = ""
				MenuCount -= 1
			EndIf
		EndIf
		i += 1
	EndWhile
EndFunction

Function RegisterMenu(String PluginName, FormList TargetMenu, \
		Form ModMenu, String ModName, String Author)
	While (!Ready)
		Utility.Wait(0.5)
	EndWhile

	CustomMenu Menu = GetEmptyMenuStruct()
	Menu.PluginName = PluginName
	Menu.TargetMenu = TargetMenu
	Menu.ModMenu = ModMenu
	Menu.ModName = ModName
	Menu.Author = Author
	MenuCount += 1

	TryToInstallMenu(Menu)
EndFunction

Function TryToInstallMenu(CustomMenu Menu)
	If (!Menu.TargetMenu || !Menu.ModMenu)
		Return
	ElseIf (Menu.TargetMenu.HasForm(Menu.ModMenu))
		; already installed
		Return
	ElseIf (Menu.TargetMenu.GetSize() == 128)
		; menu already full, can't install
		Return
	Else
		Menu.TargetMenu.AddForm(Menu.ModMenu)
	EndIf
EndFunction

Function TryToUninstallMenu(CustomMenu Menu)
	If (!Menu.TargetMenu || !Menu.ModMenu)
		Return
	ElseIf (!Menu.TargetMenu.HasForm(Menu.ModMenu))
		Return
	EndIf
EndFunction

; unregister/uninstall the menus for a plugin
Function UnregisterMenus(String PluginName)
	int i = 0
	CustomMenu CurrentMenu
	While (i < ChunkCount * 128)
		CurrentMenu = GetMenuStruct(i)
		If (CurrentMenu.PluginName == PluginName)
			CurrentMenu.PluginName = ""
			CurrentMenu.TargetMenu.RemoveAddedForm(CurrentMenu.ModMenu)
			MenuCount -= 1
		EndIf
		i += 1
	EndWhile
EndFunction

Event OnQuestInit()
	RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
	RegisterForMenuOpenCloseEvent("WorkshopMenu")

	Game.GetPlayer().AddItem(SMM_Holotape as Form, 1, False)

	Chunk0 = new CustomMenu[128]
	Chunk1 = new CustomMenu[128]
	Chunk2 = new CustomMenu[128]
	Chunk3 = new CustomMenu[128]
	Chunk4 = new CustomMenu[128]
	Chunk5 = new CustomMenu[128]
	Chunk6 = new CustomMenu[128]
	Chunk7 = new CustomMenu[128]

	int i = 0
	While (i < 128)
		Chunk0[i] = new CustomMenu
		Chunk1[i] = new CustomMenu
		Chunk2[i] = new CustomMenu
		Chunk3[i] = new CustomMenu
		Chunk4[i] = new CustomMenu
		Chunk5[i] = new CustomMenu
		Chunk6[i] = new CustomMenu
		Chunk7[i] = new CustomMenu
		i += 1
	EndWhile

	Ready = True
EndEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
	If (asMenuName == "WorkshopMenu" && !abOpening)
			ProcessMenus()
	EndIf
EndEvent

Event Actor.OnPlayerLoadGame(Actor ActorRef)
	ProcessMenus()
	Debug.Trace(MenuToString(WorkshopMainMenu))
EndEvent

Function PrintFormlist(FormList f)
	int i = 0
	Debug.Trace("+++++++++++++++++++++++++++")
	While (i < f.GetSize())
			Debug.Trace(f.GetAt(i))
		i += 1
	EndWhile
EndFunction

String Function MenuToString(FormList Root, String Prefix = "")
	String ret = ""

	Form element
	int l = Root.GetSize()
	int i = 0
	While (i < l)
		element = Root.GetAt(i)
		If (element is FormList)
			ret += Prefix+ element + "\n" + \
				MenutoString(element as FormList, Prefix + "-")
		Else
			ret += Prefix + element + "\n"
		EndIf

		i += 1
	EndWhile

	Return ret
EndFunction

; Naive. Didn't work, but was worth a shot.
; Function CleanFormList(FormList f)
; 	int i = f.GetSize()
; 	While (i >= 0)
; 		Form element = f.GetAt(i)
; 		If (element == None)
; 			f.RemoveAddedForm(element)
; 		EndIf
; 		i -= 1
; 	EndWhile
; EndFunction

; Note that the recursion here will break if there are cycles in the
; settlement menu. I can't think of a situation where there would be, but if
; it happens this code will break. The game itself might actually break under
; those conditions as well.
Function CleanFormList(FormList f, bool Recurse = False)
	Form[] tmp = New Form[0]

	int l = f.GetSize()
	int i = 0
	While (i < l)
		tmp.Add(f.GetAt(i))
		i += 1
	EndWhile

	; out with the old
	f.Revert()

	; ...and back in with (some of) the old!
	l = tmp.Length
	i = 0
	While (i < l)
		If (tmp[i])
			If (Recurse && tmp[i] is FormList)
				CleanFormList(tmp[i] as FormList, True)
			EndIf
			f.AddForm(tmp[i])
		EndIf
		i += 1
	EndWhile
EndFunction
