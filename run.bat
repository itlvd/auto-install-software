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

cecho {CF}Silent mode{#}{\n}

for %%a in (Downloaded\*.msi) do (
	echo Installing %%a
	msiexec /i %~dp0%%a /qn /l*v msi.log

	if "%errorlevel%" == "0" (cecho {0A}    Done{#}{\n}) else (goto err)

)

cecho {CF}Manual mode{#}{\n}
for %%a in (Downloaded\*.exe) do (
	echo Installing %%a
	start /wait %~dp0%%a

	if "%errorlevel%" == "0" (cecho {0A}    Done{#}{\n}) else (goto err)
)

cecho {9F} Successful {#}{\n}
goto END

:err
echo "Error : %errorlevel%"

:END
pause
