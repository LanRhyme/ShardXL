@echo off
echo ============================================
echo Building ShardXL-Lib Rust library...
echo ============================================
cd /d "%~dp0external\ShardXL-Lib"
cargo build --release
if %errorlevel% neq 0 (
    echo ERROR: Rust build failed!
    exit /b 1
)

echo.
echo ============================================
echo Copying DLL to lib directory...
echo ============================================
copy /Y target\release\lighty_launcher.dll ..\..\lib\
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy DLL!
    exit /b 1
)

echo.
echo ============================================
echo Building Flutter Windows application...
echo ============================================
cd /d "%~dp0"
call "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
flutter build windows --debug

echo.
echo ============================================
echo Build complete!
echo ============================================
