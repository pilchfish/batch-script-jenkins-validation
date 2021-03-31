REM ECHO OFF

:: "tokens= " the line split up. 1 = first word, * = all line
:: (if "1:All hope is list" == "0" echo %j )
:: delimeter where to break the line being read as out put is like this
:: (if "1:All" == "5" echo hope is list )



REM for /f "tokens=1* delims=:" %%i in ('findstr /n .* "error_text_messages.txt"') do (
:PICK_RANDOM_ERROR_TEXT_MESSAGE
set /a rand=%random% %%9
for /f "tokens=1* delims=:" %%i in ('findstr /n .* "error_text_messages.txt"') do (
if "%%i"=="%rand%" echo %%j
)
