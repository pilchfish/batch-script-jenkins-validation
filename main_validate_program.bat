ECHO OFF
title: "Jenkins Code Validation Script"
setlocal ENABLEDELAYEDEXPANSION

:: IMPORTANT must call and load configuraton.bat file first
ECHO config_file :: %_has_config_file_been_loaded%
:FIRSTTIMELOADCONFIGURATIONFILE
if defined _has_config_file_been_loaded (GOTO SECONDTIMELOADCONFIGURATIONFILE) else (GOTO LOADCONFIGURATIONFILE)
:SECONDTIMELOADCONFIGURATIONFILE
if %_has_config_file_been_loaded%=="true" (
    set /p _load_config_choice="If terminal not refreshed, do you wish to (re)load configuration file? (y/yes/ any other key to ignore) "
    if %_load_config_choice%=="y" if %_load_config_choice%=="yes" (
        GOTO LOADCONFIGURATIONFILE
    )ELSE GOTO MAIN_MENU
) ELSE GOTO LOADCONFIGURATIONFILE

:LOADCONFIGURATIONFILE
if EXIST configuration.bat (
    call configuration.bat
    set _has_config_file_been_loaded="true"
    ) else (
        ECHO no configuration file found!!!
        set _has_config_file_been_loaded="false"
    )
) GOTO EOF

:: batch script variables
set _COUNTER=0
set _ATTEMPT_LIMIT_REACHED=2

:: commandline arg1 = jenkins file to validate
set arg1=%1


:TESTFILEPASSEDINASARG1
if [%1] == [] (
    ECHO No Jenkins file passed as arg1
    GOTO EOF
)
GOTO DOESJENKINSFILEEXIST


:MAIN_MENU
ECHO:
ECHO Select local or cloud Jenkins Server to validate against
ECHO.
ECHO ****** MAIN MENU ********
ECHO  1. Local Jenkins Server
ECHO  2. Cloud Jenkins Server
ECHO:
ECHO  3. Change file
ECHO:
ECHO: 4. Start Jenkins Localhost GUI
ECHO:
ECHO: 5. Set up Credentials for Cloud Jenkins
ECHO:
ECHO  x. to EXIT
ECHO ************************
ECHO.
set /p _main_menu_id="Enter your selection: "
ECHO:

GOTO VALIDATEINPUT

ECHO errorlevel is ::  %ERRORLEVEL%
EXIT /B %ERRORLEVEL%


:: FUNCTIONS

:: MENU and Input Val_idation
:DOESJENKINSFILEEXIST
if EXIST %arg1% (
    set FILE="jenkinsfile=%arg1%"
    GOTO MAIN_MENU
    ) else (
        echo file no exist, please try again.
    )
GOTO EOF

:VALIDATEINPUT
if %_main_menu_id% EQU 1 (
    GOTO LOCALHOST_JENKINS
    )
if %_main_menu_id% EQU 2 (
    GOTO CLOUD_JENKINS
    )
if %_main_menu_id% EQU 3 (
    GOTO CHANGE_FILE
)
if %_main_menu_id% EQU 4 (
    GOTO START_LOCALHOST_MANUALLY
)
if %_main_menu_id% EQU 5 (
    GOTO CLOUDSETUP
)
if "%_main_menu_id%"=="x" (GOTO EOF)
if "%_main_menu_id%"=="X" (GOTO EOF)
if %_main_menu_id% NEQ 1 if %_main_menu_id% NEQ 2 if %_main_menu_id% NEQ 4 if %_main_menu_id% NEQ 5(
    GOTO WRONGINPUTSELECTION
)
GOTO EOF

:WRONGINPUTSELECTION
ECHO:
ECHO Error!... Please make make a selection off menu
GOTO MAIN_MENU
GOTO EOF

:: LOCALHOST JENKINS FLOW (methods)
:: entry point
:LOCALHOST_JENKINS
    :ISJENKINSSERVERRUNNING
    tasklist /FI "IMAGENAME eq jenkins.exe" 2>NUL | find /I /N "jenkins.exe">NUL
    if "%ERRORLEVEL%"=="0" (
        echo Local Jenkins Server up and running
        GOTO ISJAVAEXERUNNING
    )
    if NOT %ERRORLEVEL%=="0" (
        echo Local Jenkins Server is down
        GOTO ISJAVAEXERUNNING
    )
    GOTO EOF
    :ISJAVAEXERUNNING
    tasklist /FI "IMAGENAME eq java.exe" 2>NUL | find /I /N "java.exe">NUL
    if "%ERRORLEVEL%"=="0" (
        echo Local Java Jar up and running
        GOTO ISJAVACONSOLERUNNING
    )
    if NOT %ERRORLEVEL%=="0" (
        echo Local Java exe is down
        GOTO ISJAVACONSOLERUNNING
    )
    GOTO EOF
    :ISJAVACONSOLERUNNING
    tasklist /FI "SESSIONNAME eq console" 2>NUL | find /I /N "java.exe">NUL
    if "%ERRORLEVEL%"=="0" (
        echo Local Java Console up and running
        ECHO Will now establish connection to Localhost
        GOTO VALATECODELOCAL
    )
    if NOT %ERRORLEVEL%=="0" (
        GOTO STARTLOCALJENKINS
    )
    GOTO EOF

    :STARTLOCALJENKINS
    if %_COUNTER% LEQ %_ATTEMPT_LIMIT_REACHED% (
        ECHO Local Jenkin Server is NOT running
        ECHO Will attempt to start Server now
        START cmd /C java -jar "%_drive_letter%\%_path_to_jenkins_war%\jenkins.war"
        REM START cmd /C java -jar "C:\Program Files\Jenkins WAR\jenkins.war"
        timeout /T 20
        set /A _COUNTER=!_COUNTER!+1
        ECHO !_COUNTER!
        GOTO ISJENKINSSERVERRUNNING
    ) else (
        GOTO DECISIONTIME
    )
    GOTO EOF

    :DECISIONTIME
    ECHO:
    ECHO ## ERROR DETECTED ##
    ECHO Too many attemps to start localhost
    ECHO:
    set /p _tryCloudServer="Do you want to attempt to validate jenkins file on Cloud Server instead? (y/n)... "
    if "%_tryCloudServer%"=="y" (GOTO CLOUD_JENKINS) else (GOTO WRONGINPUTSELECTION)
    if "%_tryCloudServer%"=="yes" (GOTO CLOUD_JENKINS) else (GOTO WRONGINPUTSELECTION)
    GOTO EOF

    :VALATECODELOCAL
    ECHO:
    ECHO will now validate code to Local Jenkins server
    ECHO validation file to send ::  %FILE%
    call %_jenkins_file_prefix%localhost.bat %FILE%
    GOTO EOF


:START_LOCALHOST_MANUALLY
    :MENU_MANUAL_JENKINS
    ECHO:
    ECHO Setup Local Jenkins Server
    ECHO.
    ECHO ****** LOCAL MENU *******
    ECHO  1. Open Explorer to find 'jenkins.war'
    ECHO  2. Input filepath for 'jenkins.war'
    ECHO:
    ECHO  3. Change port (default :8080)
    ECHO:
    ECHO  4. Start Localhost
    ECHO:
    ECHO  x. back to Main Menu
    ECHO ************************
    ECHO.
    set /p _local_menu_id="Enter your selection: "
    ECHO:

    :VALIDATEINPUT
    if %_local_menu_id% EQU 1 (
        GOTO OPENEXPLORER
        )
    if %_local_menu_id% EQU 2 (
        GOTO SETWARPATH
        )
    if %_local_menu_id% EQU 3 (
        GOTO SETPORT
        )
    if %_local_menu_id% EQU 4 (
        GOTO STARTJENKINSGUI
        )
    if "%_local_menu_id%"=="x" (GOTO MAIN_MENU)
    if "%_local_menu_id%"=="X" (GOTO MAIN_MENU)
    if %_local_menu_id% NEQ 1 if %_local_menu_id% NEQ 2 if %_local_menu_id% NEQ 3 if %_local_menu_id% NEQ 4(
        GOTO WRONGINPUTSELECTION
    )
    GOTO EOF

    :WRONGINPUTSELECTION
    ECHO:
    ECHO Error!... Please make make a selection off menu
    GOTO MENU_MANUAL_JENKINS
    GOTO EOF

    :OPENEXPLORER
    start /wait Explorer
    GOTO EOF

    :SETWARPATH
        :GETWARPATH
        ECHO.
        ECHO Current pathfile location in '%_drive_letter%' drive is
        ECHO %_drive_letter%\%_path_to_jenkins_war%\
        ECHO.

        :SETWARPATH
        set arg1=
        set /p arg1="New jenkins war file path: "
        GOTO TESTWARDRIVEPASSEDINASARG1

        :TESTWARDRIVEPASSEDINASARG1
        ECHO ####### New jenkins war file path is: %arg1%
        if [%arg1%] == [] (
            ECHO No jenkins war file path passed as arg1
            GOTO SETWARPATH
        )
        set _path_to_jenkins_war=%arg1%
        GOTO MENU_MANUAL_JENKINS

    :SETPORT
        :GETPORTNUMBER
        ECHO.
        ECHO Current port number set is '%_localhost_port%'
        ECHO.

        :SETPORTNUMBER
        set arg1=
        set /p arg1="New jenkins war file path: "
        GOTO TESTPORTNUMBERPASSEDINASARG1

        :TESTPORTNUMBERPASSEDINASARG1
        ECHO ####### New port number to be set is %arg1%:
        if [%arg1%] == [] (
            ECHO No port number passed as arg1
            GOTO SETPORTNUMBER
        )
        set _localhost_port=%arg1%
        GOTO MENU_MANUAL_JENKINS

    :STARTJENKINSGUI
    START cmd /C java -jar "%_drive_letter%\%_path_to_jenkins_war%\jenkins.war"
    ECHO Waiting for localhost Jenkins to start
    timeout /T 20
    START /wait %_default_browser% %_web_protocal_localhost%:%_localhost_port%
    GOTO MAIN_MENU


:: CLOUD JENKINS FLOW (methods)
:: entry point
:CLOUD_JENKINS
    :VALATECODECLOUD
    ECHO:
    ECHO will now validate code to Cloud Jenkins server
    ECHO validation file to send ::  %FILE%
    call %_jenkins_file_prefix%cloud.bat "%FILE%"
    GOTO EOF

:: CHANGE_FILE FLOW (methods)
:CHANGE_FILE
    :CURRENTFILE
    ECHO.
    ECHO Current file is
    ECHO %FILE%
    ECHO.

    :NEWFILENAME
    set arg1=
    set /p arg1="New file name: "
    GOTO TESTFILEPASSEDINASARG1

    :TESTFILEPASSEDINASARG1
    ECHO ####### new file name is %arg1%
    if [%arg1%] == [] (
        ECHO No Jenkins file passed as arg1
        GOTO NEWFILENAME
    )
    set FILE="jenkinsfile=%arg1%"
    GOTO MAIN_MENU


:: Set up Credentials for Cloud Jenkins
:CLOUDSETUP
    :MENU_CLOUD
    ECHO:
    ECHO Setup cloud Jenkins Server
    ECHO.
    ECHO ****** CLOUD MENU *******
    ECHO  1. Get Jenkins Cloud API key
    ECHO  2. CRUMB
    ECHO:
    ECHO  x. back to Main Menu
    ECHO ************************
    ECHO.
    set /p _cloud_menu_id="Enter your selection: "
    ECHO:

    :VALIDATEINPUT
    if %_cloud_menu_id% EQU 1 (
        GOTO GETCLOUDUSERNAME
        )
    if %_cloud_menu_id% EQU 2 (
        GOTO GETCLOUDCRUMB
        )
    if "%_cloud_menu_id%"=="x" (GOTO MAIN_MENU)
    if "%_cloud_menu_id%"=="X" (GOTO MAIN_MENU)
    if %_cloud_menu_id% NEQ 1 if %_cloud_menu_id% NEQ 2 (
        GOTO WRONGINPUTSELECTION
    )
    GOTO EOF

    :WRONGINPUTSELECTION
    ECHO:
    ECHO Error!... Please make make a selection off menu
    GOTO MENU_CLOUD
    GOTO EOF


    :GETUSERDETAILSCLOUD

        :GETCLOUDUSERNAME
        if [%_jenkins_cloud_username%] == [] (
            ECHO No username added, please enter again...
            GOTO SETCLOUDUSERNAME
        )
        ECHO Username to be used is: %_jenkins_cloud_username%
        GOTO GETCLOUDAPIKEY
        GOTO EOF

        :SETCLOUDUSERNAME
        set /p _jenkins_cloud_username="Please enter your Jenkins Cloud username: "

        :GETCLOUDAPIKEY
            :LOADCLOUDAPIKEY
            ECHO **** Intructions ****
            ECHO Your default browser will open in another window, and take you to the Jenkins settings page
            ECHO You will need to click on 'Show Legacy API Key' to display the details
            ECHO Then "Copy&Paste" the required API key back into this windows command prompt
            ECHO:
            ECHO You can close the Browser window once copied
            ECHO:
            timeout /T 10
            ECHO %_default_browser% %_https%%_dnb_base_url_jenkins%%_jenkins_api_key_uri%
            start %_default_browser% %_https%%_dnb_base_url_jenkins%%_jenkins_api_key_uri%
                :COPYCLOUDAPIKEY
                set /p _cloud_api_key="Please enter your Jenkins Cloud API key: "
                if [%_cloud_api_key%] == [] (
                    ECHO No API added, please enter again...
                    GOTO COPYCLOUDAPIKEY
                )
            GOTO CLOUDSETUP
            GOTO EOF

            :GETCLOUDCRUMB
            ECHO **** Intructions ****
            ECHO Your default browser will open in another window, and take you to the Jenkins settings page
            ECHO You will need to click on 'Show Legacy API Key' to display the details
            ECHO Then "Copy&Paste" the required API key back into this windows command prompt
            ECHO:
            ECHO You can close the Browser window once copied
            ECHO:
            timeout /T 10
            ECHO %_default_browser% %_https%%_dnb_base_url_jenkins%%_jenkins_crumb_uri%
            start %_default_browser% %_https%%_dnb_base_url_jenkins%%_jenkins_crumb_uri%
                :COPYCLOUDCRUMBKEY
                set _cloud_crumb_key=
                set /p _cloud_crumb_key="Please enter your Jenkins Cloud CRUMB key: "
                if [%_cloud_crumb_key%] == [] (
                    ECHO No CRUMB added, please enter again...
                    GOTO COPYCLOUDCRUMBKEY
                )
            GOTO CLOUDSETUP
            GOTO EOF

:: LAST METHOD OF THEM ALL
:EOF
ECHO Exiting Program, have a nice day!
EXIT /B 0
