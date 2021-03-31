# batch-script-jenkins-validation
Me messing around to help try and validate Jenkins code for syntax errors before introduced into Jenkins Pipeline Job 

# The Why bother
The idea behind this was to be able to validate a **.groovy** Jenkins Script
file before it is ran within a Jenkins Server.


As the more errors caught before a Jenkins Job starts and Master/Slaves spin into action, the hope is to save time waiting to find out if its a syntax fail.
## Why .bat script
Beats me. I work on a Windows machine and open CMD more than PowerShell.
# The Files
The file structure should look like this

- Main Folder
  - configuration.txt
  - main_validate_program.bat
  - validate-jenkins-code-in-cloud.bat
  - validate-jenkins-code-in-local.bat
  - text_message_error.txt
  - text_message_success.txt

# The How to run the code
The **.bat** file is ran via Windows Command Line Terminal.


The **configuration.bat** file will need to be update. This file is read in to the **main_validate_program.bat** and uses *set* to make the parameter available in the Windows Terminal environment. You change as musch in this faile as like, but the minimum required is anywhere where you find **< >** mentioned.
>For example
>>set _default_browser=**<add_your_default_browser.exe>**

The main entry point into the program is via **main_validate_program.bat**.

The is no *setting up* required in this file.
The main thing to note is it takes **1 argument** which is the *absolute path* to the Jenkins file you wish to test, *unless you add the file into the root of the folder where **main_validate_program.bat** is located.*
> For example
>> main_validate_program.bat ***arg1***

>> main_validate_program.bat C:/path/to/jenkins/script/to/test/jenkinsfile.groovy

## What should happen

In short, the **Jenkins Script File** is sent via **cURL** to a given URL endpoint on either a users *Jenkins Cloud Server* or a *Jenkins Server running in Localhost*, where it will be validated for known syntax error.

As mention on the Jenkins.io website https://www.jenkins.io/doc/book/pipeline/development/ 

- main_validate_program.bat reads in setting from configuration.bat
- User makes a selection from the Main Menu
- JenkinsFile.groovy is passed to either
  - validate-jenkins-code-in-cloud.bat
  - validate-jenkins-code-in-local.bat
- validate-jenkins-code-in-*.bat file sends the JenkinsFile.groovy to the chosen Jenkins Server for Validation
    - validate-jenkins-code-in-*.bat reads in from either
      - text_message_error.txt
      - text_message_success.txt
    - And displays the output error or success it receives from the Jenkins Server
- Program exits


On re-running the program again the User is presented with an option to re-load from the configuration.bat file or ignore. This option is there so any previously set parameters from the previous run are not overwritten.



# Bugs
I am sure there are plenty, including code enhancements.

Any feedback is welcome.
