@echo off
:: Parameters
:: ROM file
:: Xpadder Profile 1
:: Xpadder Profile 2
:: Emulator Command line params

:: Set the current directory
pushd "%~dp0"

set "rom=%~1"
set config=%~3
set xpadder_p1=%~4
set xpadder_p2=%~5

set xpadder_launch="..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="..\emulators\dolphin\dolphin.exe" -b -u ..\configs\%config% -e "%rom%"

:: Make sure the emulator remains in focus during startup
start "" ..\util\emulator-focus Dolphin

:: Launch xpadder profiles, then Launch the emulator with the config file
IF "%xpadder_p1%" NEQ "" (
    start "" %xpadder_launch% && timeout 1 && start "" /WAIT %emulator_launch%
) ELSE (
    start "" /WAIT %emulator_launch%
)