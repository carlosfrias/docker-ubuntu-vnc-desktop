FROM ubuntu:14.04.3
MAINTAINER Doro Wu <fcwu.tw@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        libreoffice firefox \
        fonts-wqy-microhei \
        language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant libreoffice-l10n-zh-tw \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri sysv-rc-conf \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

ADD https://dl.dropboxusercontent.com/u/23905041/x11vnc_0.9.14-1.1ubuntu1_amd64.deb /tmp/
ADD https://dl.dropboxusercontent.com/u/23905041/x11vnc-data_0.9.14-1.1ubuntu1_all.deb /tmp/
RUN dpkg -i /tmp/x11vnc*.deb

ADD web /web/
RUN pip install -r /web/requirements.txt

ADD noVNC /noVNC/
ADD resources/nginx.conf /etc/nginx/sites-enabled/default
ADD startup.sh /
ADD doro-lxde-wallpapers /usr/share/doro-lxde-wallpapers/

ADD resources/supervisord.conf /etc/supervisor.conf
ADD resources/lxsession-supervisor.conf /etc/supervisor/conf.d/lxsession.conf
ADD resources/novnc-supervisor.conf /etc/supervisor/conf.d/novnc.conf
ADD resources/x11vnc-supervisor.conf /etc/supervisor/conf.d/x11vnc.conf
ADD resources/xvfb-supervisor.conf /etc/supervisor/conf.d/xvfb.conf
ADD resources/sshd-supervisor.conf /etc/supervisor/conf.d/sshd.conf
ADD resources/nginx-supervisor.conf /etc/supervisor/conf.d/nginx.conf

COPY resources/id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 0755 /root/.ssh/authorized_keys

RUN mkdir -p /var/run/sshd
RUN sysv-rc-conf sshd on

RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu \
    && echo "ubuntu:ubuntu" | chpasswd
USER ubuntu
RUN mkdir -p /home/ubuntu/.config/pcmanfm/LXDE/ \
    && cp /usr/share/doro-lxde-wallpapers/desktop-items-0.conf /home/ubuntu/.config/pcmanfm/LXDE/

USER root
WORKDIR /web
RUN ./run.py > /var/log/web.log 2>&1 &

EXPOSE 6080 22
WORKDIR /root
ENTRYPOINT ["/usr/bin/supervisord", "-n"]
