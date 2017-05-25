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
          TryToUninstallMenu(CurrentMenu)
        Else
          TryToInstallMenu(CurrentMenu)
        EndIf
      Else
        Debug.Trace("uninstalled menu: " + CurrentMenu.ModName)
        TryToUninstallMenu(CurrentMenu)
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
  Else
    Menu.TargetMenu.AddForm(Menu.ModMenu)
  EndIf
EndFunction

Function TryToUninstallMenu(CustomMenu Menu)
  If (!Menu.TargetMenu)
    Return
  ElseIf (!Menu.ModMenu)
    CleanFormList(Menu.TargetMenu)
  Else
    Menu.TargetMenu.RemoveAddedForm(Menu.ModMenu)
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
EndEvent

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

; TODO: dump the information of each registered menu
Function DumpMenu()
  Debug.OpenUserLog("SettlementMenuDump")
  Debug.TraceUser("SettlementMenuDump", MenuToString(WorkshopMainMenu))
  Debug.CloseUserLog("SettlementMenuDump")
EndFunction

; Note that the recursion here will break if there are cycles in the
; settlement menu. I can't think of a situation where there would be, but if
; it happens this code will break. The game itself might actually break under
; those conditions as well.

; The process of removing the nones from a formlist is split into four parts:
;  1. Determine if the formlist needs cleaned (has none in it)
;  2. Gather all of the non-none values into array(s)
;  3. Revert the formlist
;  4. Add the values back from the array(s)
Function CleanFormList(FormList f, bool Recurse = False, \
    int index = -1)
  int i = 0
  Form element

  If (index == -1)
    bool dirty = False
    index = f.GetSize() - 1

    i = index
    While (i >= 0)
      element = f.GetAt(i)
      If (element == None)
        dirty = True
      EndIf

      If (element is FormList && Recurse)
        CleanFormList(element as FormList, Recurse)
      EndIf
      i -= 1
    EndWhile

    If (dirty)
      CleanFormList(f, Recurse, index)
    EndIf
  Else
    Form[] tmp = New Form[0]

    While ((i < 128) && (index >= 0))
      element = f.GetAt(index)
      If (element != None)
        tmp.Add(element)
        i += 1
      EndIf
      index -= 1
    EndWhile

    If (index == -1)
      f.Revert()
    Else
      CleanFormList(f, Recurse, index)
    EndIf

    i = tmp.Length - 1
    While (i > -1)
      f.AddForm(tmp[i])
      i -= 1
    EndWhile
  EndIf
EndFunction

; This was for testing CleanFormList on large FormLists
; Function Flatten(FormList FL, FormList Head = None) global
;   If (Head == None)
;     Flatten(FL, FL)
;     Return
;   EndIf
;
;   Form element
;   int i = 0
;   While (i < FL.GetSize())
;     element = FL.GetAt(i)
;     If (element is FormList)
;       Flatten(element as FormList, Head)
;     Else
;       Head.AddForm(element)
;     EndIf
;
;     i += 1
;   EndWhile
; EndFunction
;
; Function BreakMenu() global
;   SettlementMenuManager:MainScript MainScript = \
;     Game.GetFormFromFile(0x0000633A, "SettlementMenuManager.esp") as \
;     SettlementMenuManager:MainScript
;   Flatten(MainScript.WorkshopMainMenu)
;   Debug.Messagebox("the menu is ready to be broken")
; EndFunction
