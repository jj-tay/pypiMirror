@ECHO OFF

REM Activate bandersnatch environment if required
call conda activate bandersnatch

REM Add packages to mirror
set CONF=%TEMP%\%RANDOM%
copy mirror-windows.conf %CONF%
for /f %%P in (pkgs_in_mirror.txt) do (
  echo     %%P>> %CONF%
)
bandersnatch -c %CONF% mirror
bandersnatch -c %CONF% mirror
bandersnatch -c %CONF% mirror
del %CONF%

REM Exit bandersnatch environment
call conda deactivate

REM Sync to S3
aws s3 sync bandersnatch\web s3://s3fs-mount-s3-prod/hdbpypi --delete --debug --profile hdbba-s3fs
