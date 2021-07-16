@echo off
:: Parameters
:: ROM file
:: Xpadder Profile 1
:: Xpadder Profile 2
:: Emulator Command line params

:: Set the current directory
pushd "%~dp0"

set "rom=%~6"
set config=%~3
set xpadder_p1=%~4
set xpadder_p2=%~5

IF "%config%"=="" (set config=default)

:: copy the appropriate control INI file over
cp "C:\emulation\configs\arcade-naomi2\%config%\padDemul.ini" "C:\emulation\emulators\demul\"

set xpadder_launch="..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="..\emulators\demul\demul.exe" -run=naomi -rom="%rom%"

:: Make sure the emulator remains in focus during startup
start "" ..\util\scripts\emulator-focus Demul

:: Launch xpadder profiles, then Launch the emulator with the config file
IF "%xpadder_p1%" NEQ "" (
    start "" %xpadder_launch% && timeout 1 && start "" /WAIT %emulator_launch%
) ELSE (
    start "" /WAIT %emulator_launch%
)