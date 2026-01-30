@ECHO OFF
setlocal enabledelayedexpansion

REM Install packages
for /f %%P in (pkgs_to_add.txt) do (
  set CONDA_ENV=bandersnatch!RANDOM!
  call conda create -y -n !CONDA_ENV! pip
  call conda activate !CONDA_ENV!
  
  pip install --no-input %%P
  REM )

  REM Stage packages to be mirrored
  set TF=%TEMP%\!RANDOM!
  for /f %%Q in ('pip list') do (
    echo %%Q>> !TF!
  )
  more +2 !TF! >> pkgs_in_mirror.txt
  del !TF!
  sort /unique /c /o pkgs_in_mirror.txt pkgs_in_mirror.txt

  REM Delete throwaway conda env
  call conda deactivate
  call conda remove -n !CONDA_ENV! --all -y
)

REM Activate bandersnatch environment if required
call conda activate bandersnatch

REM Add packages to mirror
set CONF=%TEMP%\%RANDOM%
copy mirror-windows.conf %CONF%
for /f %%P in (pkgs_in_mirror.txt) do (
  echo     %%P>> %CONF%
)
bandersnatch -c %CONF% mirror --force-check
del %CONF%

REM Exit bandersnatch environment
call conda deactivate

REM Sync to S3
aws s3 sync bandersnatch\web s3://s3fs-mount-s3-prod/hdbpypi --delete --debug --profile hdbba-s3fs
