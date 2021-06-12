; Will keep a program in focus for up to 10 seconds before exiting. This will ensure the emulator remains in focus for the launch, then will exit so it isn't taking up any memory.
; Expected cmd line parameter is the emulator program to monitor

#include <Misc.au3>

; Only allow one instance of the script
If _Singleton(@ScriptName, 1) = 0 Then Exit (-1)

; Terminate script if no command-line arguments
If $CmdLine[0] = 0 Then Exit (1)

Global $program
$program = $CmdLine[1]

WinWait($program, "", 45)
Local $i = 0
Do
   WinActivate($program)
   Sleep(1000)
   $i = $i + 1
Until (Not WinExists($program)) OR ($i = 10)