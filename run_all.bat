@echo off
title TOEIC Prepwise - Fullstack Launcher
color 0B
echo ===================================================================
echo           KHOI DONG HE THONG TOEIC PREPWISE (FULLSTACK)
echo ===================================================================
echo.
echo 1. Dang khoi dong Backend (ASP.NET Core - Port 5000)...
start "TOEIC Backend (ASP.NET Core - Port 5000)" cmd /k "cd /d D:\1210\backend\aspnet-core\src\TrieuHiNeCon.Web.Mvc && dotnet run"

echo 2. Doi 5 giay de Backend san sang...
timeout /t 5 /nobreak >nul

echo 3. Dang khoi dong Frontend (Flutter Web - Port 8080)...
start "TOEIC Frontend (Flutter - Port 8080)" cmd /k "cd /d D:\1210\frontend && flutter run -d web-server --web-port 8080"

echo.
echo ===================================================================
echo   CA 2 SERVER DA DUOC KHOI DONG THANH CONG!
echo   - Backend Admin Portal: http://localhost:5000
echo   - Frontend Student App: http://localhost:8080
echo ===================================================================
echo.
pause
