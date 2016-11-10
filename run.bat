SET HOST_IP=192.168.1.10
docker run -it --privileged --rm -e HOST_IP=%HOST_IP% -e DISPLAY=%HOST_IP%:0 -p 80:80 -p 5432:5432 -e GIT_USER_NAME="Takahiro Shizuki" -e GIT_USER_EMAIL=shizu@futuregadget.com local/ubuntu_php7_pgsql96
