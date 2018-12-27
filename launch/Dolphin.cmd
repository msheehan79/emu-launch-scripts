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

:: Set parameters
:: set rom=Centipede (USA).zip
:: set config=retroarch.cfg
:: set core=prosystem_libretro

:: set xpadder_p1=Atari 5200 P1 Default
:: set xpadder_p2=Atari 5200 P2 Default

set xpadder_launch="..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="..\emulators\dolphin\dolphin.exe" "%rom%"

:: Launch xpadder profiles, then Launch the emuator with the config file
IF "%xpadder_p1%" NEQ "" (
    start "" %xpadder_launch% && start "" /WAIT %emulator_launch%
) ELSE (
    start "" /WAIT %emulator_launch%
)