@echo Off
setlocal EnableDelayedExpansion

color e0

:ask_time

echo How often do you want to change wallpaper
set /p time=Minutes: 


SET "var="&for /f "delims=0123456789" %%i in ("%time%") do set var=%%i
if defined var (
    echo You didn't enter a decimal number
    echo try again
    goto :ask_time
) else (
    echo %time%
    if %time% EQU 0 (
        echo You can't enter 0 minutes 
        echo try again
        goto :ask_time
    )
    if %time% GTR 166 (
        echo The number is too big
        echo Try again
        goto :ask_time
    )
    echo timer set with a cooldown of %time% minutes
)

set /a time*=60

set loop=0

:start

set batch_path=%cd%
cd /D %batch_path%

cd images
rem Generates indexes
set i=0

for /f %%f in ('dir /b /a-d-s-h ^| find /v /c ""') do (
    for /l %%a in (1, 1, %%f) do (
        set /A i+=1
        set index_list[!i!]=%%a
    )
)


rem Gives each index a value
set j=0
for /f %%f in ('dir /b /a-d-s-h') do (
    set /A j+=1
    set wallpapers_list[!j!]=%%f
)

rem makes sure every index has a value
if %i% neq %j% (
   echo A and B have not the same number of elements
   goto :EOF
)

cd ..

REM get random wallpaper
set /a rnd=%random% %%%i% + 1
set random_wallpaper=!wallpapers_list[%rnd%]!


REM moved used wallpaper to correct folder
cd used_image
for /f %%f in ('dir /b ^| find /v /c ""') do (
    if %%f GTR 0 (
        for /f %%h in ('dir /b') do (
            cd ..
            move used_image\%%h images >nul
            cd used_image
        )
    )
    cd ..
)

move images\%random_wallpaper% used_image >nul

reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d %batch_path%\used_image\%random_wallpaper% /f >nul
RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,true


set /a loop+=1
echo The wallpaper has changed %loop% times

TIMEOUT /T %time% /NOBREAK  >nul

goto :start

exit