WinWait("Select screen mode", "", 45)

Do
   WinActivate("Select screen mode")
   ControlClick("Select screen mode", "", "&Yes")
Until Not WinExists("Select screen mode")