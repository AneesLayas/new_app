@echo off
echo Setting up GitHub repository...

echo Creating .gitignore file...
echo build/ > .gitignore
echo .dart_tool/ >> .gitignore
echo .idea/ >> .gitignore
echo .vscode/ >> .gitignore
echo *.iml >> .gitignore
echo local.properties >> .gitignore

echo Initializing git repository...
git init

echo Adding all files...
git add .

echo Creating initial commit...
git commit -m "Initial commit: Complete maintenance app implementation"

echo Creating main branch...
git branch -M main

echo Adding remote repository...
git remote add origin https://github.com/aneesurrehman/maintenance-app.git

echo Pushing to GitHub...
git push -u origin main

echo Done! The code has been pushed to GitHub.
echo You can now check the Actions tab in your GitHub repository to monitor the APK build.
pause 