@echo off
setlocal enabledelayedexpansion

set TARGET_DLL=%~1
set LIB_DLL=%~2
set CARGO_EXE=%~3
set MANIFEST_PATH=%~4

echo Building ShardXL-Lib Rust library...

%CARGO_EXE% build --release --manifest-path=%MANIFEST_PATH%
if !errorlevel! equ 0 (
    echo Cargo build succeeded
    exit /b 0
)

echo Cargo build failed with exit code !errorlevel!

if exist "%LIB_DLL%" (
    echo WARNING: Cargo build failed, but existing DLL found at %LIB_DLL%
    echo Continuing with existing DLL...
    exit /b 0
) else (
    echo ERROR: Cargo build failed and no existing DLL found
    exit /b 1
)
