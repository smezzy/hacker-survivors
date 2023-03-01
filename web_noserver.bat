@ECHO off
if exist ./makelove.toml (
	python -m makelove lovejs
) else (
	python -m makelove --init
	python -m makelove lovejs
)
for %%I in (.) do set CurrDirName=%%~nxI
cd builds/lovejs
"%ProgramFiles%\WinRAR\winrar.exe" x -ibck %CurrDirName%-lovejs.zip *.*
cd %CurrDirName%
pause >nul