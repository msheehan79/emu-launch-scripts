@echo off
:: Parameters
:: ROM file
:: Xpadder Profile 1
:: Xpadder Profile 2
:: Emulator Command line params
:: Base Path to ROM file

:: Set the current directory
pushd "%~dp0"

:: Set parameters
set "rom=%~1"
::set config=%~3
set xpadder_p1=%~4
set xpadder_p2=%~5
set "path=%~3"
set "basepath=%~dp0"

:: The launch path needs to be the game directory
pushd %path%

::set xpadder_launch="..\..\..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set xpadder_launch="%basepath%\..\xpadder\Xpadder.exe" "%basepath%\..\configs\xpadder\profiles\%xpadder_p1%" "%basepath%\..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="%rom%"

start "" %xpadder_launch% && start "" /WAIT %emulator_launch%
