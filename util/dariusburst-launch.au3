WinWait("DARIUSBURST CS Launcher", "", 45)

Do
   WinActivate("DARIUSBURST CS Launcher")
   ControlClick("DARIUSBURST CS Launcher", "", "Launch")
Until Not WinExists("DARIUSBURST CS Launcher")


