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

:: set vriables if running as stand alone file
REM set arg1=%1
REM if [%1] == [] (
REM     ECHO %Red%No Jenkins file passed as arg1
REM     EXIT /B
REM )
REM set FILE="jenkinsfile=<%arg1%"

set ERRORFILE=errors_found.txt

:DELETE_FILES
IF EXIST %ERRORFILE% (
    ECHO %Yellow%Deleting file: errors_found.txt%White%
    del %ERRORFILE%
    timeout 2
    ECHO.
) ELSE (
    ECHO No file to delete.
)
IF EXIST error.txt del error.txt
IF EXIST jenkins.txt del jenkins.txt
IF EXIST jenkinsfile.txt del jenkinsfile.txt
IF EXIST html.txt del html.txt
tmeout 1

:CURL
ECHO %Yellow% Initiating CURL now...
ECHO %Cyan%
ECHO file to test :: %FILE%
ECHO:
curl -u %_jenkins_cloud_username%:%_cloud_api_key% -X POST -H %_jenkins_crumb_uri% -F %FILE% https://%_dnb_base_url_jenkins%%_jenkins_validate_uri% 1>&2 >%ERRORFILE%

ECHO %Yellow%
REM timeout 3
ECHO.

IF EXIST %ERRORFILE% (
    findstr /I /B /L  "Errors" %ERRORFILE%>error.txt
    ECHO error :: %errorlevel%
    if !errorlevel!==0 (
        GOTO ERRORS_FOUND
    )
    REM findstr /I /L "Jenkinsfile" "successfully" "validated" %ERRORFILE%>jenkins.txt
    REM ECHO jenkins :: %errorlevel%
    REM if errorlevel==0 (
    REM     GOTO JENKINS_FOUND
    REM )
    findstr /I /B /L "<html>" %ERRORFILE%>html.txt
    ECHO html :: %errorlevel%
    if !errorlevel!==0 (
        GOTO HTML_FOUND
    )
    findstr /I /B /L "Jenkinsfile" %ERRORFILE%>jenkinsfile.txt
    ECHO Jenkinsfile :: %errorlevel%
    if !errorlevel!==0 (
        GOTO JENKINSFILE_FOUND
    )
    ECHO IFs failed to catch any errors/success clauses
)

:ERRORS_FOUND
REM echo errors found
GOTO PRINT_OUT_JENKINS_ERROR_FOUND
GOTO EOF
:JENKINS_FOUND
REM echo jenkins found
GOTO PRINT_OUT_JENKINS_ERROR_FOUND
GOTO EOF
:HTML_FOUND
REM echo html found
GOTO PRINT_OUT_CURL_ERROR
GOTO EOF
:JENKINSFILE_FOUND
REM echo Jenkinsfile found
GOTO PRINT_OUT_JENKINS_SUCCESS
GOTO EOF

:PRINT_OUT_JENKINS_ERROR_FOUND
ECHO %Magenta%
    :PICK_RANDOM_ERROR_TEXT_MESSAGE
    set /a rand=%random% %%10
    for /f "tokens=1* delims=:" %%i in ('findstr /n .* "text_message_error.txt"') do (
        if "%%i"=="%rand%" echo %%j
    )
ECHO.%Red%
FOR /F "tokens=*" %%x in (%ERRORFILE%) DO echo %%x
GOTO EOF

:PRINT_OUT_JENKINS_SUCCESS
ECHO %Magenta%
    :PICK_RANDOM_SUCCESS_TEXT_MESSAGE
    set /a rand=%random% %%6
    for /f "tokens=1* delims=:" %%i in ('findstr /n .* "text_message_success.txt"') do (
        if "%%i"=="%rand%" echo %%j
    )
ECHO %Green%
ECHO But...
FOR /F "tokens=*" %%x in (%ERRORFILE%) DO echo %%x
GOTO EOF

:PRINT_OUT_CURL_ERROR
ECHO %Magenta%Error found in CURL, please check syntax or credentials
ECHO.%Red%
FOR /F "tokens=*" %%x in (%ERRORFILE%) DO echo %%x
GOTO EOF

:EOF
ECHO.
ECHO %White%
EXIT /B 0
