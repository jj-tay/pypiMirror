@ECHO OFF
setlocal enabledelayedexpansion

REM Activate bandersnatch environment if required
call conda activate bandersnatch

REM Add packages to mirror
REM Use AWS shared credentials via profile
set AWS_PROFILE=hdbba-s3fs
REM Optional if credentials/config are in non-default locations:
REM set AWS_SHARED_CREDENTIALS_FILE=%USERPROFILE%\.aws\credentials
REM set AWS_CONFIG_FILE=%USERPROFILE%\.aws\config
set CONF=%TEMP%\%RANDOM%
copy mirror-windows.conf %CONF%
for /f %%P in (pkgs_in_mirror.txt) do (
  echo     %%P>> %CONF%
)
bandersnatch -c %CONF% mirror --force-check
del %CONF%

REM Exit bandersnatch environment
call conda deactivate
