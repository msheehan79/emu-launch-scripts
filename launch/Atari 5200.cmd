@echo off
:: Parameters
:: ROM file
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

set xpadder_launch="..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="..\emulators\altirra\Altirra64.exe" /portablealt:..\configs\%config% "%rom%"

:: Make sure the emulator remains in focus during startup
start "" ..\util\emulator-focus Altirra

:: Launch xpadder profiles, then Launch the emuator with the config file
start "" %xpadder_launch% && timeout 1 && start "" /WAIT %emulator_launch%