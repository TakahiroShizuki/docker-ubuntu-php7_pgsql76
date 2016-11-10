FROM ubuntu:trusty
MAINTAINER Takahiro Shizuki <shizuki@bauport.io>

ENV CLIENT_HOME /root


# set package repository mirror
RUN sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive/%g" /etc/apt/sources.list

# dependencies
RUN apt-get update -o Acquire::ForceIPv4=true
RUN apt-get install -y p7zip bzip2 cmake curl git man nkf ntp psmisc software-properties-common tmux unzip vim wget
RUN apt-get clean

# git latest
RUN add-apt-repository -y ppa:git-core/ppa
RUN apt-get update -o Acquire::ForceIPv4=true
RUN apt-get install -y git tig


# x window relations
RUN apt-get -y install insserv sysv-rc-conf python-appindicator xterm xfce4-terminal leafpad vim-gtk
RUN apt-get clean


# Install dev packages
RUN apt-get install -y gcc-4.7 make autoconf automake
RUN apt-get clean
RUN ln -sf /usr/bin/gcc-4.7 /usr/bin/gcc


# ansible2
RUN apt-get -y install python-dev python-pip libyaml-dev libffi-dev libssl-dev
RUN pip install --upgrade setuptools
RUN pip install --upgrade pip
RUN pip install ansible markupsafe
RUN mkdir -p $CLIENT_HOME/ansible
RUN bash -c 'echo 127.0.0.1 ansible_connection=local > $CLIENT_HOME/ansible/localhost'


# security
RUN apt-get install -y fail2ban
RUN apt-get clean


# Option, User Environment

# japanese packages
RUN wget -t 1 -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | apt-key add -
RUN wget -t 1 -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | apt-key add -
RUN wget -t 1 https://www.ubuntulinux.jp/sources.list.d/wily.list -O /etc/apt/sources.list.d/ubuntu-ja.list
RUN apt-get update -o Acquire::ForceIPv4=true
RUN apt-get -y install language-pack-ja-base language-pack-ja fonts-ipafont-gothic dbus-x11
RUN apt-get -y install dictionaries-common
RUN perl /usr/share/debconf/fix_db.pl
RUN dpkg-reconfigure dictionaries-common
RUN apt-get -y install uim-skk uim-utils uim-xim uim-gtk3
RUN apt-get -y install skkdic skkdic-cdb skkdic-extra skksearch skktools
RUN update-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja
RUN apt-get clean

WORKDIR /usr/share/skk
RUN wget -N http://openlab.ring.gr.jp/skk/dic/SKK-JISYO.L.gz
RUN wget -N http://openlab.ring.gr.jp/skk/dic/SKK-JISYO.jinmei.gz
RUN wget -N http://openlab.ring.gr.jp/skk/dic/SKK-JISYO.geo.gz
RUN wget -N http://openlab.ring.gr.jp/skk/dic/SKK-JISYO.propernoun.gz
RUN wget -N http://openlab.ring.gr.jp/skk/dic/SKK-JISYO.station.gz
RUN wget -N http://openlab.ring.gr.jp/skk/dic/SKK-JISYO.law.gz
RUN wget -N http://openlab.ring.gr.jp/skk/dic/SKK-JISYO.requested.gz
RUN wget -N http://openlab.ring.gr.jp/skk/dic/SKK-JISYO.edict.tar.gz
RUN wget -N http://openlab.ring.gr.jp/skk/dic/zipcode.tar.gz

RUN gunzip < SKK-JISYO.L.gz > SKK-JISYO.L
RUN gunzip < SKK-JISYO.jinmei.gz > SKK-JISYO.jinmei
RUN gunzip < SKK-JISYO.geo.gz > SKK-JISYO.geo
RUN gunzip < SKK-JISYO.propernoun.gz > SKK-JISYO.propernoun
RUN gunzip < SKK-JISYO.station.gz > SKK-JISYO.station
RUN gunzip < SKK-JISYO.law.gz > SKK-JISYO.law
RUN gunzip < SKK-JISYO.requested.gz > SKK-JISYO.requested
RUN tar xafO zipcode.tar.gz ./zipcode/SKK-JISYO.zipcode > SKK-JISYO.zipcode
RUN tar xaf SKK-JISYO.edict.tar.gz SKK-JISYO.edict

RUN skkdic-expr SKK-JISYO.L \
 + SKK-JISYO.jinmei + SKK-JISYO.geo + SKK-JISYO.propernoun \
 + SKK-JISYO.station + SKK-JISYO.law + SKK-JISYO.edict + SKK-JISYO.zipcode \
 + SKK-JISYO.requested \
 | skkdic-sort > SKK-JISYO.merged
RUN mv SKK-JISYO.L SKK-JISYO.L.org
RUN cp -p SKK-JISYO.merged SKK-JISYO.L
RUN skk2cdb SKK-JISYO.merged /usr/share/skk/SKK-JISYO.L.cdb

ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
ENV LC_CTYPE ja_JP.UTF-8

ENV GTK_IM_MODULE 'uim'
ENV QT_IM_MODULE 'uim'
ENV XMODIFIERS '@im=uim'
RUN echo export ENV GTK_IM_MODULE=uim >> $CLIENT_HOME/.bashrc
RUN echo export QT_IM_MODULE=uim >> $CLIENT_HOME/.bashrc
RUN echo "if ps -ef | grep -v grep | grep uim > /dev/null; then echo; else bash -c 'uim-xim &'; fi" >> $CLIENT_HOME/.bashrc
RUN echo export XMODIFIERS=\'@im=uim\' >> $CLIENT_HOME/.bashrc


# diff merge
WORKDIR $CLIENT_HOME/src
RUN wget -t 1 http://download-us.sourcegear.com/DiffMerge/4.2.0/diffmerge_4.2.0.697.stable_amd64.deb
RUN dpkg -i diffmerge_4.2.0.697.stable_amd64.deb


# Set Env
RUN umask 002
ENV SHELL /bin/bash
RUN mkdir $CLIENT_HOME/.ssh
RUN chmod 600 $CLIENT_HOME/.ssh
RUN git config --global push.default simple

# Set Timezone
RUN cp /usr/share/zoneinfo/Japan /etc/localtime

# OpenGL env
env LIBGL_ALWAYS_INDIRECT 1
#env DRI_PRIME 1

# fonts
RUN cd /usr/local/share/fonts && \
    wget -t 1 http://www.rs.tus.ac.jp/yyusa/ricty_diminished/ricty_diminished-4.0.1.tar.gz -O ricty_diminished.tar.gz && \
    tar xvzf ricty_diminished.tar.gz

	
# Install Apache2
RUN apt-get install -y apache2 apache2-dev
RUN apt-get clean
COPY apache2.conf /etc/apache2/
COPY envvars /etc/envvars/
COPY 000-default.conf /etc/apache2/sites-enabled/


# copy source PostgreSQL 9.6
RUN bash -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN apt-get install wget ca-certificates
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN apt-get update -o Acquire::ForceIPv4=true && apt-get -y upgrade
RUN apt-get -y install postgresql-9.6 pgadmin3
RUN apt-get clean

# copy source PHP7。0
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update -o Acquire::ForceIPv4=true && apt-get clean
RUN apt-get install -y php7.0-fpm php7.0-pgsql php7.0 libapache2-mod-php7.0


# cifs
RUN mkdir -p /mnt/host/Downloads


# options
# .bashrc
RUN bash -c 'echo alias ls=\"ls --color\" >> $CLIENT_HOME/.bashrc'

# dropbox
WORKDIR /usr/bin
RUN wget -t 1 https://raw.github.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh
RUN chmod +x dropbox_uploader.sh


# docker run
WORKDIR /opt/src
ADD terminalrc $CLIENT_HOME/.config/xfce4/terminal/

WORKDIR $CLIENT_HOME
RUN echo docker run -it --rm -e DISPLAY=\$DISPLAY -v /\$SHELL_PATH:/mnt/docke_dir -v /\$HOME:/home/host_user -p 80:80 -p 5432:5432 local/php7_pgsql96

CMD xfce4-terminal --tab --command "bash -c 'echo \"TODO: dropbox_uploader.sh && cd /opt/src/ && ansible-playbook -v --extra-vars "taskname=copy_ssh" ansible/playbook.yml && ./run_ansible.sh\" && echo \"press any key.\" && read'"
