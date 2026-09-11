FROM ubuntu:24.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        cron \
        openssh-server \
        python3 \
        python3-apt \
        sudo \
        systemd \
        systemd-sysv \
    && rm -rf /var/lib/apt/lists/* \
    && systemctl enable ssh

CMD ["/sbin/init"]
