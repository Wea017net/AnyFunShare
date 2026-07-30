@echo off
chcp 65001 > nul
echo ==========================================
echo  afs_server.exe を終了しています...
echo ==========================================

taskkill /f /im afs_server.exe

if %errorlevel% equ 0 (
    echo.
    echo [success] afs_server.exe を正常に終了しました。
) else (
    echo.
    echo [info] afs_server.exe は起動していないか、既に終了しています。
)

echo ==========================================
pause