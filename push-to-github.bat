@echo off
echo ========================================
echo Pushing LinkKart to GitHub
echo ========================================
echo.
echo Repository: https://github.com/sunnylingampelly/linkkart.git
echo Branch: main
echo.
echo ========================================
echo.

echo Checking git status...
git status

echo.
echo Adding any new changes...
git add .

echo.
echo Creating commit...
set /p commit_message="Enter commit message (or press Enter for default): "
if "%commit_message%"=="" set commit_message="Update LinkKart project"
git commit -m "%commit_message%"

echo.
echo Pushing to GitHub...
echo.
echo NOTE: You may need to authenticate with GitHub
echo.
git push -u origin main

echo.
echo ========================================
echo Push Complete!
echo ========================================
echo.
echo View your repository at:
echo https://github.com/sunnylingampelly/linkkart
echo.
pause
