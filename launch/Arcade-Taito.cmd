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

:: for these arcade games, the filename alone minus extension and path is used as the parameter to the emulator
FOR /F "delims=" %%i IN ("%rom%") DO (
    set romname=%%~ni
)

:: Set parameters
:: set rom=C:\Emulation\roms\intellivision\Armor Battle (World).int
:: set config=intellivision\kbdhackfile.kbd
:: set core=prosystem_libretro

:: set xpadder_p1=Intellivision Left
:: set xpadder_p2=Intellivision Right

set xpadder_launch="..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="..\emulators\typextra\typextra.exe" -gl "%romname%" -hc

:: Launch xpadder profiles, then Launch the emuator with the config file
IF "%xpadder_p1%" NEQ "" (
    start "" %xpadder_launch% && timeout 1 && start "" /WAIT %emulator_launch%
) ELSE (
    start "" /WAIT %emulator_launch%
)