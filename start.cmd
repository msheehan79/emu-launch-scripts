:: Batch file to launch pegasus
:: Reads the pegasus folder path from file pegasus.txt in the same directory
@echo off

:: Set the current directory
pushd "%~dp0"

if [%1] == [] goto usage

call :print_head %1
goto :eof

REM
REM read_config
REM Reads the first non-blank line in the file %1 into a variable.
REM
:print_head
setlocal EnableDelayedExpansion
set /a counter=0

for /f ^"usebackq^ eol^=^

^ delims^=^" %%a in (%1) do (
        if "!counter!"==1 goto :eof
        set pegasus-path=%%a
        set /a counter+=1
)

goto :start

:usage
echo Usage: start.cmd pegasus.txt

:start
IF "%pegasus-path%" NEQ "" (
    start "" "%pegasus-path%\pegasus-fe.exe" --portable
)