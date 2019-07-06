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
set core=%~2
set config=%~3
set xpadder_p1=%~4
set xpadder_p2=%~5

IF "%core%" EQU "mamearcade_libretro" (
    set "rom=%~6"
) ELSE (
    set "rom=%~1"
)

:: Set the launch strings for Xpadder and RA
set xpadder_launch="..\xpadder\Xpadder.exe" "..\configs\xpadder\profiles\%xpadder_p1%" "..\configs\xpadder\profiles\%xpadder_p2%"

IF "%core%" EQU "mamearcade_libretro" (
    set emulator_launch="..\emulators\retroarch\retroarch.exe" -L "..\emulators\retroarch-cores\%core%.dll" "%rom% -rp ..\roms\arcade\mame;..\roms\arcade\neo-geo;..\bios\arcade-mame;..\bios\arcade-neogeo" -c "..\configs\%config%" -v --log-file "..\emulators\retroarch\retroarch-log.txt"
) ELSE (
    set emulator_launch="..\emulators\retroarch\retroarch.exe" -L "..\emulators\retroarch-cores\%core%.dll" "%rom%" -c "..\configs\%config%" -v --log-file "..\emulators\retroarch\retroarch-log.txt"    
)

:: Alternate debug launch commands
:: IMPORTANT cannot put any comments inside the parenthesis above, else it will fail
::set emulator_launch="..\emulators\retroarch\retroarch_debug.exe" -L "..\emulators\retroarch-cores\%core%.dll" "%rom%" -c "..\configs\%config%" -v --log-file "..\emulators\retroarch\retroarch-log.txt"
::set emulator_launch="..\emulators\retroarch\retroarch.exe" -L "..\emulators\retroarch-cores\%core%.dll" "%rom%" -c "..\configs\%config%"

:: Launch xpadder profiles, then Launch the emuator with the config file
IF "%xpadder_p1%" NEQ "" (
    start "" %xpadder_launch% && start "" /WAIT %emulator_launch%
) ELSE (
    start "" /WAIT %emulator_launch%
)