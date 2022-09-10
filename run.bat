@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------   

cecho {CF}Downloading the software from the server.txt file{#}{\n}
wget.exe -N -P Downloaded --content-disposition -i server.txt -q --show-progress

cecho {CF}Being installed with silent mode{#}{\n}

for %%a in (Downloaded\*.msi) do (
echo Installing the program from %%a
msiexec /i %~dp0%%a /qn
cecho {0A}    Successful{#}{\n}
)

cecho {CF}Being installed with manual mode{#}{\n}
for %%a in (Downloaded\*.exe) do (
echo Installing %%a
%~dp0%%a
cecho {0A}    Successful{#}{\n})

cecho {9F} Done {#}{\n}
pause
