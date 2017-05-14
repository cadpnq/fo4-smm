ScriptName SettlementMenuManager:MenuInstaller Extends Quest

String Property PluginName Auto
String Property ModName Auto
String Property Author Auto

Struct Menu
	FormList TargetMenu
	Form ModMenu
EndStruct

Menu[] Property Menus Auto

Event OnQuestInit()
	SettlementMenuManager:MainScript MainScript = \
		Game.GetFormFromFile(0x0000633A, "SettlementMenuManager.esp") as \
		SettlementMenuManager:MainScript

	int i = 0;
	While (i < Menus.Length)
		MainScript.RegisterMenu(PluginName, Menus[i].TargetMenu, \
			Menus[i].ModMenu, ModName, Author)
		i += 1
	EndWhile
EndEvent
