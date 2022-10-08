@echo Off
setlocal EnableDelayedExpansion

color e0

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

rem echo lists - BREAK
for /L %%i in (1,1,%i%) do (
    REM echo !index_list[%%i]!,!wallpapers_list[%%i]!
)
cd ..

REM get random wallpaper
set /a rnd=%random% %%%i% + 1
set random_wallpaper=!wallpapers_list[%rnd%]!
REM echo %random_wallpaper%

REM moved used wallpaper to correct folder
cd used_image
for /f %%f in ('dir /b ^| find /v /c ""') do (
    if %%f GTR 0 (
        for /f %%h in ('dir /b') do (
            cd ..
            move used_image\%%h images
            cd used_image
        )
    )
    cd ..
)

move images\%random_wallpaper% used_image

reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d %batch_path%\images\%random_wallpaper% /f
RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters


exit /b