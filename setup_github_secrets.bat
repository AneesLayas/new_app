@echo off
echo Setting up GitHub secrets for Android build...

REM Check if keystore exists
if not exist "keystore.jks" (
    echo Creating new keystore...
    keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
)

REM Convert keystore to base64
echo Converting keystore to base64...
certutil -encodehex -f keystore.jks temp.txt 0x40000001

echo.
echo Please add these secrets to your GitHub repository:
echo.
echo 1. ANDROID_KEYSTORE_BASE64: (Content of temp.txt)
echo 2. ANDROID_KEYSTORE_PASSWORD: (Your keystore password)
echo 3. ANDROID_KEY_ALIAS: upload
echo 4. ANDROID_KEY_PASSWORD: (Your key password)
echo 5. ANDROID_HOME: %LOCALAPPDATA%\Android\Sdk
echo.
echo Steps to add secrets:
echo 1. Go to your GitHub repository
echo 2. Click Settings
echo 3. Click Secrets and Variables ^> Actions
echo 4. Click New repository secret
echo 5. Add each secret with its corresponding value
echo.
echo After adding secrets, delete temp.txt for security
echo.
pause 