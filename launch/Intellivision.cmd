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

set xpadder_launch="..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
::set emulator_launch="..\emulators\jzintv\bin\jzintv.exe" -p "..\bios\intellivision" -q -z1440x1080,32 -v1 -f1 %config% "%rom%"
::set emulator_launch="..\emulators\jzintv\bin\jzintv.exe" -p "..\bios\intellivision" -q -z3 -v1 -f1 %config% "%rom%"
set emulator_launch="..\emulators\jzintv\bin\jzintv.exe" -p "..\bios\intellivision" -q -z1024x768,32 -v1 -f1 %config% "%rom%"

:: Launch xpadder profiles, then Launch the emulator with the config file
IF "%xpadder_p1%" NEQ "" (
    start "" %xpadder_launch% && timeout 1 && start "" /WAIT %emulator_launch%
) ELSE (
    start "" /WAIT %emulator_launch%
)