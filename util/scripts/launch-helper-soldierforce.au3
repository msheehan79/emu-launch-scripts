WinWait("Soldier Force", "", 45)

Do
   WinActivate("Soldier Force")
   ControlClick("Soldier Force", "", "??")
Until Not WinExists("Soldier Force")


