:: this file holds all the configuration details used
:: some deatils can become 'sensitive' hence placing here
:: and this file is added to git.ignore

:: ** this file is called from main method and ran before anything else **

:: User specific - Change for each user
:: Can set these to work stright off
set _jenkins_cloud_username=<add_your_jenkins_username>
REM set _cloud_crumb_key=
REM set _cloud_api_key=
set _default_browser=<add_your_default_browser.exe>


:: Default - Job specific

:: Jenkins Cloud Details
set _web_protocol_cloud=https://
:: Jenkins Localhost Details
set _web_protocal_localhost=http://localhost
set _localhost_port=8080

:: URLs for Jenkins
set _dnb_base_url_jenkins=<add_your_jenkins_base_URL>
set _jenkins_api_key_uri=/user/%_jenkins_cloud_username%/configure
set _jenkins_crumb_uri=/crumbIssuer/api/json?tree=crumb
set _jenkins_validate_uri=/pipeline-model-converter/validate

:: file paths
set _jenkins_file_prefix=local-validate-jenkins-code-in-


REM for /f "delims=" %%x in (configuration.txt) do (set "%%x")
