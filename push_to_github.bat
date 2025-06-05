@echo off
echo Setting up GitHub repository...

echo Initializing git repository...
git init

echo Adding all files...
git add .

echo Creating initial commit...
git commit -m "Complete maintenance app implementation with role-based features"

echo Creating main branch...
git branch -M main

echo Adding remote repository...
git remote add origin https://github.com/AneesLayas/adsd-maintenance-simple.git

echo Pushing to GitHub...
git push -u origin main

echo Done! The code has been pushed to GitHub.
echo You can now check the Actions tab in your GitHub repository to monitor the APK build.
pause 