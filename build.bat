@ECHO off
if exist ./makelove.toml (
	python -m makelove win32 lovejs
) else (
	python -m makelove --init
	python -m makelove win32 lovejs	
)
echo --------------
echo Done.
pause >nul