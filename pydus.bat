@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion


set "VERBOSE=0"
set "SRCDIR="
set "OUTDIR="
set "FORMAT=svg"


:: Parse options
:parse_args
if "%~1"=="" goto end_parse
if "%~1"=="-h" goto help
if "%~1"=="-help" goto help



if "%~1"=="-v" (
    set "VERBOSE=1"
    shift
    goto parse_args
)

if "%~1"=="-verbose" (
    set "VERBOSE=1"
    shift
    goto parse_args
)

if not defined SRCDIR (
    set "SRCDIR=%~1"
) else if not defined OUTDIR (
    set "OUTDIR=%~1"
) else if "%FORMAT%"=="svg" (
    set "FORMAT=%~1"
) else (
    echo ERROR: Too many arguments: %~1
    exit /b 1
)

shift
goto parse_args

:end_parse


:: Check for at least 2 arguments
set ARGCOUNT=0
for %%A in (%*) do set /a ARGCOUNT+=1

if %ARGCOUNT% LSS 1 (
    goto help
)


if %ARGCOUNT% LSS 2 (
    echo ERROR: At least two arguments required.
    echo Use --help for usage information
    exit /b 1
)

:: Check if source directory exists
if not exist "%SRCDIR%\" (
    echo ERROR: Source directory "%SRCDIR%" does not exist.
    exit /b 1
)
:: Check if output directory exists create it if not
if not exist "%OUTDIR%\" (
    mkdir "%OUTDIR%"
)


if !VERBOSE! equ 1 (
    echo VERBOSE=1
    echo SRCDIR=!SRCDIR!
    echo OUTDIR=!OUTDIR!
    echo FORMAT=!FORMAT!
)

:: Validate format
set "VALID_FORMAT=0"

if /i "%FORMAT%"=="svg" set VALID_FORMAT=1
if /i "%FORMAT%"=="png" set VALID_FORMAT=1
if /i "%FORMAT%"=="dot" set VALID_FORMAT=1
if /i "%FORMAT%"=="pdf" set VALID_FORMAT=1

if %VALID_FORMAT%==0 (
    echo ERROR: Invalid format "%FORMAT%"
    echo Valid formats: svg, png, dot, pdf
    exit /b 1
)


:: Check if pyreverse is installed
where pyreverse >nul 2>&1
if errorlevel 1 (
    echo ERROR: pyreverse not found. Please install pylint first:
	echo   pip install pylint
    exit /b 1
) else (
    echo pyreverse found!
)



set "TOTAL=0"
set "COUNT=0"
set "GENERATED=0"
set "SKIPPED=0"


if not exist "%OUTDIR%" (
    echo ERREUR : Le dossier de sortie "%OUTDIR%" n'existe pas.
    exit /b 1
)


set "TOTAL=0"
set "COUNT=0"
set "GENERATED=0"
set "SKIPPED=0"
set FILELIST=

:: List Python files (excluding __init__.py)
for /r "%SRCDIR%" %%F in (*.py) do (
    if /i not "%%~nxF"=="__init__.py" (
        set /a TOTAL+=1
		set FILELIST=!FILELIST! "%%F"
        if %VERBOSE%==1 echo Found: %%F
    )
)

echo.
echo ╔═══════════════════════════════════════════════════════════════════════════╗
echo ║                  PYDUS — Python Diagram UML Specific                      ║
echo ╚═══════════════════════════════════════════════════════════════════════════╝
echo.
echo Source directory    : %SRCDIR%
echo Output directory    : %OUTDIR%
echo Output format       : %FORMAT%
echo Files to process    : %TOTAL%
echo Verbose mode        : %VERBOSE%
echo.
echo Generating diagrams...
echo.


for %%F in (!FILELIST!) do (

	set /a COUNT+=1
	
	if "!VERBOSE!"=="0" (
		call :progress_bar !COUNT! !TOTAL!
						)
	
	:: Check if file contains a class
	findstr /R /C:"^[ ]*class[ ][A-Za-z0-9_][A-Za-z0-9_]*" "%%F" >nul
	if errorlevel 1 (
		set /a SKIPPED+=1

		if "!VERBOSE!"=="1" (
			echo SKIPPED: %%F ^(no class found^)
							)
			
					)

	if not errorlevel 1 (
		
		set "filename=%%~nF"
		
		:: Generate diagram
		if "%VERBOSE%"=="1" (
			echo Processing: %%F
			pyreverse -o "%FORMAT%" -p "!filename!" "%%F"
		) else (
			pyreverse -o "%FORMAT%" -p "!filename!" "%%F" >nul 2>&1
						)

	set "diagram_original=classes_!filename!.!FORMAT!"
	set "diagram_target=!OUTDIR!\!filename!.!FORMAT!"
	
	if exist "!diagram_original!" (
    move /Y "!diagram_original!" "!diagram_target!" >nul
    set /a GENERATED+=1
    if "!VERBOSE!"=="1" (
        echo SUCCESS: Generated !diagram_target!
    )
	) else (
		set /a SKIPPED+=1
		if "!VERBOSE!"=="1" (
			echo FAILED: Could not generate diagram for %%F
							)
			)
						)
		echo.
		
	
									)
									


echo.
echo ╔═══════════════════════════════════════════════════════════════════════════╗
echo ║                              SUMMARY                                      ║
echo ╠═══════════════════════════════════════════════════════════════════════════╣
echo ║  Total Python files      : %TOTAL%                                              ║
echo ║  Diagrams generated      : %GENERATED%                                              ║
echo ║  Files skipped           : %SKIPPED%                                              ║
echo ║  Output format           : %FORMAT%                                            ║
echo ║  Source directory        : %SRCDIR%
echo ║  Output directory        : %OUTDIR%
echo ╚═══════════════════════════════════════════════════════════════════════════╝
echo.

endlocal
goto :eof


:help
call :print_help
exit /b 0

:progress_bar
set progress=%1
set total=%2
set width=40

if "!total!"=="0" (
    echo total !total!
    set filled=0
    set empty=!width!
) else (
    set /a numerator=!progress! * !width! + !total! - 1
    set /a filled=numerator / !total!
    if !filled! gtr !width! set filled=!width!
    set /a empty=!width! - !filled!
)

<nul set /p="["
for /L %%i in (1,1,!filled!) do <nul set /p="█"
for /L %%i in (1,1,!empty!) do <nul set /p="░"
<nul set /p="] !progress!/!total!"
echo.
goto :eof


:print_help
					                  echo ╔═══════════════════════════════════════════════════════════════════════════╗
					                  echo ║                                                                           ║
					                  echo ║                ██████╗ ██╗   ██╗██████╗ ██╗   ██╗███████╗                 ║
					                  echo ║                ██╔══██╗╚██╗ ██╔╝██╔══██╗██║   ██║██╔════╝                 ║
					                  echo ║                ██████╔╝ ╚████╔╝ ██║  ██║██║   ██║███████╗                 ║
					                  echo ║                ██╔═══╝   ╚██╔╝  ██║  ██║██║   ██║╚════██║                 ║
					                  echo ║                ██║        ██║   ██████╔╝╚██████╔╝███████║                 ║
					                  echo ║                ╚═╝        ╚═╝   ╚═════╝  ╚═════╝ ╚══════╝                 ║
					                  echo ║                                                                           ║
					                  echo ║                        Python Diagram UML Specific                        ║
					                  echo ║                                                                           ║
					                  echo ╚═══════════════════════════════════════════════════════════════════════════╝
					                  echo. 
					                  echo DESCRIPTION
					                  echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
					                  echo Automatically generates specific UML diagrams for each Python file 
					                  echo containing one or more classes.
					                  echo. 
					                  echo Recursively scans a source directory, identifies Python files with classes,
					                  echo and generates a UML diagram in your chosen format for each one.
					                  echo. 
					                  echo Note: __init__.py files and scripts without classes are ignored.
					                  echo. 
					                  echo SYNTAX
					                  echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
					                  echo pydus [options] ^<source_directory^> ^<output_directory^> [format]
					                  echo. 
					                  echo OPTIONS
					                  echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
					                  echo -v, --verbose       Show detailed output from pyreverse
					                  echo -h, --help          Display this help message
					                  echo. 
					                  echo ARGUMENTS
					                  echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
					                  echo source_directory     Root directory containing .py files to analyze
					                  echo output_directory     Directory where generated files will be saved
					                  echo format              Output format: svg, png, dot, or pdf (default: svg)
					                  echo. 
					                  echo FORMATS
					                  echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
					                  echo svg    Scalable Vector Graphics (default, recommended)
					                  echo png    Portable Network Graphics (raster image)
					                  echo dot    Graphviz DOT format (for further processing)
					                  echo pdf    Portable Document Format
					                  echo. 
					                  echo USAGE EXAMPLES
					                  echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
					                  echo pydus ./my_project ./UML/class_diagrams
					                  echo pydus ./my_project ./UML/class_diagrams svg
					                  echo pydus ./my_project ./UML/class_diagrams png
					                  echo pydus -v ./my_project ./UML/class_diagrams pdf
					                  echo 
					                  echo This command will:
					                  echo 	• Recursively scan ./my_project
					                  echo 	• Detect all .py files containing classes
					                  echo 	• Generate one diagram file per file in ./UML/class_diagrams
					                  echo. 
					                  echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	exit /b 1
