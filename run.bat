for /f "usebackq delims=" %%a in (`PWD`) do set SHELL_PATH=%%a
echo %SHELL_PATH%
SET DISPLAY=192.168.1.10:0
docker run -it --privileged --rm -e DISPLAY=%DISPLAY% -e GIT_USER_NAME="Takahiro Shizuki" -e GIT_USER_EMAIL=shizu@futuregadget.com -v /%SHELL_PATH%:/mnt/docke_dir -v /c/Users/shizuki/:/home/host_user -p 80:80 -p 5432:5432 local/ubuntu_php7_pgsql96

