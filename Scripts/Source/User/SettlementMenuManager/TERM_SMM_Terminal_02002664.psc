;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname SettlementMenuManager:TERM_SMM_Terminal_02002664 Extends Terminal \
  Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
; menu rescue
  SettlementMenuManager:MainScript SMM = smm_MenuInstaller as \
    SettlementMenuManager:MainScript
  SMM.CleanFormList(SMM.WorkshopMainMenu, True)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
; safe mode
  SettlementMenuManager:MainScript SMM = smm_MenuInstaller as \
    SettlementMenuManager:MainScript
  SMM.ProcessMenus(True)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
; debug log
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property smm_MenuInstaller Auto Const
