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
set "rom=%~nx1"
set "rompath=%~dp1"
set config=%~3
set xpadder_p1=%~4
set xpadder_p2=%~5

:: eduke32 generates config and cache files in the current directory so switch to the config dir to output them there
pushd "..\configs\ports\duke3d\"

:: Set the launch strings for Xpadder and emulator
set xpadder_launch="..\..\..\xpadder\Xpadder.exe" "..\..\xpadder\profiles\%xpadder_p1%" "..\..\xpadder\profiles\%xpadder_p2%"
set emulator_launch="..\..\..\emulators\eduke32\eduke32.exe" -cfg %config% -j %rompath% -gamegrp %rom%

:: Make sure the emulator remains in focus during startup
start "" ..\..\..\util\scripts\emulator-focus EDuke32

:: Launch xpadder profiles, then Launch the emulator with the config file
IF "%xpadder_p1%" NEQ "" (
    start "" %xpadder_launch% && timeout 1 && start "" /WAIT %emulator_launch%
) ELSE (
    start "" /WAIT %emulator_launch%
)