WinWait("Pegasus", "", 45)

Do
   WinActivate("Pegasus")
Until Not WinExists("Pegasus")
