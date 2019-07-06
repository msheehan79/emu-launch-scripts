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
set "rom=%~6"
set config=%~3
set xpadder_p1=%~4
set xpadder_p2=%~5

:: Model 2 emulator expects the config files to be in the launch directory, so switch to the config file dir
pushd "..\configs\arcade-model2\"

:: Set the launch strings for Xpadder and Model 2 Emulator
set xpadder_launch="..\..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="..\..\emulators\model2\emulator.exe" %rom%

:: Launch xpadder profiles, then Launch the emuator with the config file
start "" %xpadder_launch% && start "" /WAIT %emulator_launch%