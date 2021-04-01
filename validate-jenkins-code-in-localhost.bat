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

:: loads number of options to choose from from text_message_success.txt
for /f %%b in ('type text_message_success.txt ^| find "" /v /c') do (
    REM echo line count is %%b
    set _success_message_lines=%%b
    )
)
:: loads number of options to choose from from text_message_error.txt
for /f %%b in ('type text_message_error.txt ^| find "" /v /c') do (
    REM echo line count is %%b
    set _error_message_lines=%%b
    )
)

:: uncomment if running as stand alone file
REM set arg1=%1
REM if [%1] == [] (
REM     ECHO %Red%No Jenkins file passed as arg1
REM     EXIT /B
REM )
REM set FILE="jenkinsfile=%arg1%"

:: make directory to hold error Files
set ERRORFILE=errors_found.txt

:DELETE_FILES
IF EXIST %ERRORFILE% (
    ECHO %Yellow%Deleting file: errors_found.txt%White%
    del %ERRORFILE%
    ECHO.
) ELSE (
    ECHO No file to delete.
)
IF EXIST error.txt del error.txt
IF EXIST jenkins.txt del jenkins.txt
IF EXIST jenkinsfile.txt del jenkinsfile.txt
IF EXIST html.txt del html.txt

:CURL
ECHO %Yellow% Initiating localhost connection now...
ECHO %Cyan%

ECHO localhost and file :: %FILE%
ECHO:
curl -X POST -F %FILE% %_web_protocal_localhost%:%_localhost_port%%_jenkins_validate_uri% 1>&2 >%ERRORFILE%


ECHO %Yellow%
REM timeout 3
ECHO.

IF EXIST %ERRORFILE% (
    findstr /I /B /L  "Errors" %ERRORFILE%>error.txt
    REM ECHO error :: %errorlevel%
    if !errorlevel!==0 (
        GOTO ERRORS_FOUND
    )
    REM findstr /I /L "Jenkinsfile" "successfully" "validated" %ERRORFILE%>jenkins.txt
    REM ECHO jenkins :: %errorlevel%
    REM if errorlevel==0 (
    REM     GOTO JENKINS_FOUND
    REM )
    findstr /I /B "<html>" %ERRORFILE%>html.txt
    REM ECHO html :: %errorlevel%
    if !errorlevel!==0 (
        GOTO HTML_FOUND
    )
    findstr /I "<DOCTYPE html>" %ERRORFILE%>doctype.txt
    REM ECHO html :: %errorlevel%
    if !errorlevel!==0 (
        GOTO DOCTYPE_FOUND
    )
    findstr /I /B "Jenkinsfile" %ERRORFILE%>jenkinsfile.txt
    REM ECHO Jenkinsfile :: %errorlevel%
    if !errorlevel!==0 (
        GOTO JENKINSFILE_FOUND
    )
    ECHO IFs failed to catch any errors/success clauses
    ECHO Unknow Error detected. Clues may lie within the "errors_found.txt" file
    ECHO Please update code if you would like to catch this next time
)

:ERRORS_FOUND
REM echo errors found
GOTO PRINT_OUT_JENKINS_ERROR_FOUND
GOTO EOF

REM :JENKINS_FOUND
REM REM echo jenkins found
REM GOTO PRINT_OUT_JENKINS_ERROR_FOUND
REM GOTO EOF

:HTML_FOUND
REM echo html found
GOTO PRINT_OUT_CURL_ERROR
GOTO EOF

:DOCTYPE_FOUND
REM echo doctype found
GOTO PRINT_OUT_SERVER_ERROR
GOTO EOF

:JENKINSFILE_FOUND
REM echo Jenkinsfile found
GOTO PRINT_OUT_JENKINS_SUCCESS
GOTO EOF

:PRINT_OUT_JENKINS_ERROR_FOUND
ECHO %Magenta%
    :PICK_RANDOM_ERROR_TEXT_MESSAGE
    set /a rand=%random% %%_error_message_lines
    for /f "tokens=1* delims=:" %%i in ('findstr /n .* "text_message_error.txt"') do (
        if "%%i"=="%rand%" echo %%j
    )
ECHO.%Red%
FOR /F "tokens=*" %%x in (%ERRORFILE%) DO echo %%x
GOTO EOF

:PRINT_OUT_JENKINS_SUCCESS
ECHO %Magenta%
    :PICK_RANDOM_SUCCESS_TEXT_MESSAGE
    set /a rand=%random% %%_success_message_lines
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

:PRINT_OUT_SERVER_ERROR
ECHO %Magenta%Server Error detected. Please check your LOG files
ECHO.%Red%
FOR /F "tokens=*" %%x in (%ERRORFILE%) DO echo %%x
GOTO EOF

:EOF
ECHO.
ECHO %White%
ENDLOCAL
EXIT /B 0
