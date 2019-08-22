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
set "rom=%~dp1"
set config=%~3
set xpadder_p1=%~4
set xpadder_p2=%~5

:: Set the launch strings for Xpadder and emulator
set xpadder_launch="..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"
set emulator_launch="..\emulators\bstone\bstone.exe" --profile_dir "..\configs\%config%" --data_dir %rom%

:: Launch xpadder profiles, then Launch the emulator with the config file
IF "%xpadder_p1%" NEQ "" (
    start "" %xpadder_launch% && timeout 1 && start "" /WAIT %emulator_launch%
) ELSE (
    start "" /WAIT %emulator_launch%
)