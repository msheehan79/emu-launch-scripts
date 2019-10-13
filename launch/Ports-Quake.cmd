@echo off
:: Parameters
:: ROM file (full path)
:: Xpadder Profile 1
:: Xpadder Profile 2
:: Emulator Command line params
:: ROM file (base filename only)

:: Set the current directory
pushd "%~dp0"

:: Set parameters
set "rom=%~1"
set config=%~3
set xpadder_p1=%~4
set xpadder_p2=%~5

:: quakespasm generates logfiles in the current directory so switch to the emulators dir to output them there
pushd "..\emulators\quakespasm\"

:: Set the launch strings for Xpadder and emulator
set xpadder_launch="..\..\xpadder\Xpadder.exe" "..\..\configs\xpadder\profiles\%xpadder_p1%" "..\..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="quakespasm.exe" -basedir ..\..\roms\ports\quake %config%

:: Make sure the emulator remains in focus during startup
start "" ..\util\emulator-focus QuakeSpasm

:: Launch xpadder profiles, then Launch the emulator with the config file
IF "%xpadder_p1%" NEQ "" (
    start "" %xpadder_launch% && timeout 1 && start "" /WAIT %emulator_launch%
) ELSE (
    start "" /WAIT %emulator_launch%
)