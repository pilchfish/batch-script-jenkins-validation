<<<<<<< HEAD
ECHO "is-program-running
title: "Jenkins Code Val_idation"

ECHO OFF

:: batch script variables
set _COUNTER=0
set _ATTEMPT_LIMIT_REACHED=2
set _JENKINS_FILE_PREFIX=local-validate-jenkins-code-in-
REM set MENU_INPUT
:: commandline arg1 = jenkins file to val_idate
set arg1=%1

:TESTFILEPASSEDINASARG1
if [%1] == [] (
    ECHO No Jenkins file passed as arg1
    GOTO EOF
)
GOTO DOESJENKINSFILEEXIST
set FILE="jenkinsfile=%arg1%"


:MENU
ECHO:
ECHO Select local or cloud Jenkins Server to validate against
ECHO.
ECHO ****** MAIN MENU ********
ECHO  1. Local Jenkins Server
ECHO  2. Cloud Jenkins Server
ECHO:
ECHO  3. Change file
ECHO:
ECHO: 4. Start Jenkins Localhost (manually)
ECHO: 5. Set up Credentials for Cloud Jenkins
ECHO:
ECHO  x. to EXIT
ECHO ************************
ECHO.
set /p _id="Enter your selection: "
ECHO:

GOTO VALIDATEINPUT

ECHO errorlevel is ::  %ERRORLEVEL%
EXIT /B %ERRORLEVEL%


:: FUNCTIONS

:: MENU and Input Val_idation
:DOESJENKINSFILEEXIST
if EXIST %arg1% (
    GOTO MENU
    ) else (
        echo file no exist
    )
GOTO EOF

:VALIDATEINPUT
if %_id% EQU 1 (
    GOTO LOCALHOST_JENKINS
    )
if %_id% EQU 2 (
    GOTO CLOUD_JENKINS
    )
if %_id% EQU 3 (
    GOTO CHANGE_FILE
)
if "%_id%"=="x" (GOTO EOF)
if "%_id%"=="X" (GOTO EOF)
if %_id% NEQ 1 if %_id% NEQ 2 (
    GOTO WRONGINPUTSELECTION
)
GOTO EOF

:WRONGINPUTSELECTION
ECHO:
ECHO Error!... Please make make a selection off menu
GOTO MENU
GOTO EOF

:: LOCALHOST JENKINS FLOW (methods)
:: entry point
:LOCALHOST_JENKINS
    :ISJENKINSSERVERRUNNING
    tasklist /FI "IMAGENAME eq jenkins.exe" 2>NUL | find /I /N "jenkins.exe">NUL
    if "%ERRORLEVEL%"=="0" (
        echo Local Jenkins Server up and running
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
        START cmd /C java -jar "C:\Program Files\Jenkins WAR\jenkins.war"
        timeout /T 20
        set /A %_COUNTER%=%_COUNTER%+1
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
    call %_JENKINS_FILE_PREFIX%localhost.bat %FILE%
    GOTO EOF


:: CLOUD JENKINS FLOW (methods)
:: entry point
:CLOUD_JENKINS
    :VALATECODECLOUD
    ECHO:
    ECHO will now validate code to Cloud Jenkins server
    call %_JENKINS_FILE_PREFIX%cloud.bat "%FILE%"
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
    REM GOTO DOESJENKINSFILEEXIST
    set FILE="jenkinsfile=%arg1%"
    GOTO MENU


:: Set up Credentials for Cloud Jenkins
:CLOUDSETUP
    :MENU_CLOUD
    ECHO:
    ECHO Setup cloud Jenkins Server
    ECHO.
    ECHO ****** CLOUD MENU *******
    ECHO  1. Username and API key
    ECHO  2. CRUMB
    ECHO:
    ECHO  x. back to Main Menu
    ECHO ************************

    :VALIDATEINPUT
    if %_id% EQU 1 (
        GOTO GETCLOUDUSERNAME
        )
    if %_id% EQU 2 (
        GOTO GETCLOUDAPIKEY
        )
    if "%_id%"=="x" (GOTO EOF)
    if "%_id%"=="X" (GOTO EOF)
    if %_id% NEQ 1 if %_id% NEQ 2 (
        GOTO WRONGINPUTSELECTION
    )
    GOTO EOF

    :WRONGINPUTSELECTION
    ECHO:
    ECHO Error!... Please make make a selection off menu
    GOTO MENU_CLOUD
    GOTO EOF


    :GETUSERDETAILS

        :GETCLOUDUSERNAME
        set /p _cloud_user_name="Please enter your Jenkins Cloud username: "
        if [%_cloud_user_name%] == [] (
            ECHO No username added, please enter again...
            GOTO GETUSERDETAILS
        )
        GOTO GETUSERDETAILS
        GOTO EOF

        :GETCLOUDAPIKEY
        ECHO **** Intructions ****
        ECHO Chrome will open in another window, and take you to the Jenkins settings page
        ECHO You will need to click on 'Show Legacy API Key' to display the details
        ECHO Then Copy&Paste the required API key back into this windows command prompt
        timeout /T 10
        start /wait chrome.exe https://deployjenkins.utils.dnbaws.net/user/%_cloud_user_name%/configure
        set /p _cloud_api_key="Please enter your Jenkins Cloud API key: "
        if [%_cloud_api_key%] == [] (
            ECHO No API added, please enter again...
            GOTO CLOUDSETUP
        )
        GOTO GETUSERDETAILS
        GOTO EOF





:: LAST METHOD OF THEM ALL
:EOF
ECHO Exiting Program, have a nice day!
EXIT /B 0
=======
ECHO OFF
title: "Jenkins Code Validation Script"

:: IMPORTANT must call and load configuraton.bat file first
ECHO config_file :: %_has_config_file_been_loaded%
:FIRSTTIMELOADCONFIGURATIONFILE
if defined _has_config_file_been_loaded (GOTO SECONDTIMELOADCONFIGURATIONFILE) else (GOTO LOADCONFIGURATIONFILE)
:SECONDTIMELOADCONFIGURATIONFILE
if %_has_config_file_been_loaded%=="true" (
    set /p _load_config_choice="If terminal not refreshed, do you wish to (re)load configuration file? (y/yes/n/no) "
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
ECHO: 4. Start Jenkins Localhost (manually)
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
    GOTO CHANGE_FILE
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
        START cmd /C java -jar "C:\Program Files\Jenkins WAR\jenkins.war"
        timeout /T 20
        set /A %_COUNTER%=%_COUNTER%+1
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
    REM GOTO DOESJENKINSFILEEXIST
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
>>>>>>> master
