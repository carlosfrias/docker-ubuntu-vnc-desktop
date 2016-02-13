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
        mesa-utils libgl1-mesa-dri \
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

EXPOSE 6080
WORKDIR /root
ENTRYPOINT ["/startup.sh"]
