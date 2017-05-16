ScriptName SettlementMenuManager:MenuInstaller Extends Quest

String Property PluginName Auto
{The name of your plugin (*.esp)}
String Property ModName Auto
{The name of your mod.}
String Property Author Auto
{Your name.}

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
