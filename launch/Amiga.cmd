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

:: FS UAE emulator expects the path settings to be relative to the launcher directory, so switch to that dir
pushd "..\emulators\fsuae\"

set xpadder_launch="..\..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="System\Launcher\Windows\x86-64\fs-uae-launcher.exe" %config% "%rom%"
::set emulator_launch="System\Launcher\Windows\x86-64\fs-uae-launcher.exe" "--config:joystick_0_west_button=action_joy_1_fire_button --config:joystick_0_south_button=action_key_space" "%rom%"
::set emulator_launch="System\Launcher\Windows\x86-64\fs-uae-launcher.exe" --config:joystick_0_north_button=action_key_space "%rom%" 

:: set display refresh to 50Hz for PAL Games only (search filename for NTSC)
if x%rom:ntsc=%==x%rom% start "" ..\..\util\qres /r:50

:: Launch xpadder profiles, then Launch the emuator with the config file
IF "%xpadder_p1%" NEQ "" (
    start "" %xpadder_launch% && timeout 1 && start "" /WAIT %emulator_launch%
) ELSE (
    start "" /WAIT %emulator_launch%
)

:: restore refresh rate to 60Hz
..\..\util\qres /r:60