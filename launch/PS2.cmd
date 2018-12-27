@echo off
:: Parameters
:: ROM file
:: Xpadder Profile 1
:: Xpadder Profile 2
:: Emulator Command line params

:: Set the current directory
pushd "%~dp0"

set rom=%~1
set config=%~3
set xpadder_p1=%~4
set xpadder_p2=%~5

:: Set dummy parameters (Test Data Only)
:: set rom=Ultimate Ghosts 'N Goblins (USA).cso
:: set config=
:: set xpadder_p1=PSP
:: set xpadder_p2=

set xpadder_launch="..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="..\emulators\pcsx2\pcsx2.exe" "%rom%"

:: Launch xpadder profiles, then Launch the emuator with the config file
IF "%xpadder_p1%" NEQ "" (
    start "" %xpadder_launch% && start "" /WAIT %emulator_launch%
) ELSE (
    start "" /WAIT %emulator_launch%
)