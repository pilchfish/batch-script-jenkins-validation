ECHO OFF
echo.
set ESC=
set Black=%ESC%[30m
set Red=%ESC%[31m
set Green=%ESC%[32m
set Yellow=%ESC%[33m
set Blue=%ESC%[34m
set Magenta=%ESC%[35m
set Cyan=%ESC%[36m
set White=%ESC%[37m

setlocal ENABLEDELAYEDEXPANSION

set arg1=%1
if [%1] == [] (
    ECHO %Red%No Jenkins file passed as arg1
    EXIT /B
)
set FILE="jenkinsfile=%arg1%"

set ERRORFILE=errors_found.txt

IF EXIST %ERRORFILE% (
    ECHO %Yellow%Deleting file: errors_found.txt%White%
    del %ERRORFILE%
    REM timeout 2
    ECHO.
) ELSE (
    ECHO No file to delete.
)

ECHO %Yellow% Initiating localhost connection now...
ECHO %Cyan%

REM START "C:\Program Files\Jenkins WAR\jenkins.war"
REM CMD java jar "C:\Program Files\Jenkins WAR\pipeline.gdsl\"
ECHO localhost and file :: %FILE%
REM START "chrome.exe" %FILE% "http://localhost:8080/pipeline-model-converter/validate"
curl -X POST -F %FILE% http://localhost:8080/pipeline-model-converter/validate 1>&2 >%ERRORFILE%
REM curl -u <username:api_key> -X POST -H <crumb> -F %FILE% https://deployjenkins.utils.dnbaws.net/pipeline-model-converter/validate 1>&2 >%ERRORFILE%

ECHO %Yellow%
REM timeout 3
ECHO.

IF EXIST %ERRORFILE% (
    REM FOR /F %%x in (%ERRORFILE%) DO (
        findstr /i "Errors" %ERRORFILE% >nul
        findstr /i "Jenkins" %ERRORFILE%>nul
        REM findstr /i "Errors" %ERRORFILE%
        REM echo %ERRORLEVEL% or !errorlevel!v
        if !errorlevel!==0 (
            ECHO %Magenta%All hope is lost!!
            ECHO.%Red%
            FOR /F "tokens=*" %%x in (%ERRORFILE%) DO echo %%x
        ) else (
            ECHO.
            ECHO %Green%
            REM FOR /F "tokens=*" %%x in (%ERRORFILE%) DO echo %%x
            ECHO %Magenta%Your code has hope!
        )
    REM )

)
REM findstr /i "Error." %ERRORFILE% >nul
REM if %ERRORLEVEL%==0 (
REM     ECHO %Magenta%All hope is lost!!
REM     ECHO.%Red%
REM     FOR /F "tokens=*" %%x in (%ERRORFILE%) DO echo %%x
REM ) else (
REM     ECHO %Magenta%Your code has hope!
REM     ECHO.
REM     ECHO %Green%
REM     FOR /F "tokens=*" %%x in (%ERRORFILE%) DO echo %%x
REM )
ECHO.
ECHO %White%
