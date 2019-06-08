@echo off
:: Parameters
:: ROM file
:: Xpadder Profile 1
:: Xpadder Profile 2
:: Emulator Command line params

:: Set the current directory
pushd "%~dp0"

:: Set parameters
set "rom=%~6"
set config=%~3
set xpadder_p1=%~4
set xpadder_p2=%~5

:: Set dummy parameters (Test Data Only)
:: set rom=Defender (USA).a52
:: set config=Altirra-relative5.ini
:: set xpadder_p1=Atari 5200 P1 Default
:: set xpadder_p2=Atari 5200 P2 Default

::@echo Launch dir: "%~dp0" >>C:\Emulation\launch\output.txt
::@echo Current dir: "%CD%" >>C:\Emulation\launch\output.txt

:: Model 2 emulator expects the config files to be in the launch directory, so switch to the config file dir
pushd "..\configs\arcade-model2\"

set xpadder_launch="..\..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="..\..\emulators\model2\emulator.exe" %rom%

:: Launch xpadder profiles, then Launch the emuator with the config file
start "" %xpadder_launch% && start "" /WAIT %emulator_launch%