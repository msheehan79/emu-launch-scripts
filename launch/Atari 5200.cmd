@echo off
:: Parameters
:: ROM file
:: Xpadder Profile 1
:: Xpadder Profile 2
:: Emulator Command line params

:: Set the current directory
pushd "%~dp0"

:: Set parameters
set rom=%~1
set config=%~3
set xpadder_p1=%~4
set xpadder_p2=%~5

:: Set dummy parameters (Test Data Only)
:: set rom=Defender (USA).a52
:: set config=Altirra-relative5.ini
:: set xpadder_p1=Atari 5200 P1 Default
:: set xpadder_p2=Atari 5200 P2 Default

:: @echo Launch dir: "%~dp0" >>C:\Emulation\launch\output.txt
:: @echo Current dir: "%CD%" >>C:\Emulation\launch\output.txt

set xpadder_launch="..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="..\emulators\altirra\Altirra64.exe" /portablealt:..\configs\atari5200\%config% "..\roms\atari5200\%rom%"

:: Launch xpadder profiles, then Launch the emuator with the config file
start "" %xpadder_launch% && start "" /WAIT %emulator_launch%