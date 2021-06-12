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

:: Set the launch strings for Xpadder and gzdoom
set xpadder_launch="..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="..\emulators\gzdoom\gzdoom.exe" -config ..\configs\ports\gzdoom\%config% -savedir C:\Emulation\saves\doom\doom -iwad C:\Emulation\roms\ports\doom\HEXEN.WAD -file %rom%

:: Make sure the emulator remains in focus during startup
start "" ..\util\scripts\emulator-focus GZDoom

:: Launch xpadder profiles, then Launch the emulator with the config file
IF "%xpadder_p1%" NEQ "" (
    start "" %xpadder_launch% && timeout 1 && start "" /WAIT %emulator_launch%
) ELSE (
    start "" /WAIT %emulator_launch%
)