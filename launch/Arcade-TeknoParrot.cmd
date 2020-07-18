@echo off
:: Parameters
:: ROM file (Base filename only)
:: Xpadder Profile 1
:: Xpadder Profile 2
:: Emulator Command line params

:: Set the current directory
pushd "%~dp0"

:: Set parameters
set "rom=%~1"
set config=%~3
set xpadder_p1=%~4
set xpadder_p2=%~5

:: These games don't seem to render properly at 4K so set the display to 1080p
set base_res="3840x2160, 32 bits @ 60 Hz."
set target_res="1920x1080, 32 bits @ 60 Hz."

:: TeknoParrot doesn't seem to launch if it is not called from its own directory
pushd "..\emulators\teknoparrot\"

:: Check current resolution and set to 1080p if it is not already
FOR /F "skip=3 tokens=* USEBACKQ" %%g IN (`..\..\util\qres /S`) do (
    IF "%%g" NEQ %target_res% (
        call :display1080p
    )
)

:: Set the launch strings for Xpadder and emulator
set xpadder_launch="..\..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="TeknoParrotUi.exe" --profile=%rom% --startMinimized

:: Launch xpadder profiles, then Launch the emulator with the config file
IF "%xpadder_p1%" NEQ "" (
    start "" %xpadder_launch% && timeout 1 && start "" /WAIT %emulator_launch%
) ELSE (
    start "" /WAIT %emulator_launch%
)

:: After game ends, loop through supported resolutions to make sure 4K is supported before attempting to switch back
FOR /F "tokens=* USEBACKQ" %%g IN (`..\..\util\qres /L`) do (
    IF "%%g" EQU %base_res% (
        call :display4k
        goto :exit
    )
)

:exit
EXIT /B %ERRORLEVEL%

:display1080p
..\util\qres /X:1920 /Y:1080 /R:60
EXIT /B 0

:display4k
..\util\qres /X:3840 /Y:2160 /R:60
EXIT /B 0