FROM ubuntu:24.04

# ssh.service is left disabled, as on a stock install, where ssh.socket
# activates it. Enabling it creates the sshd.service alias, which a stock host
# does not have, and hides any task or handler that depends on it.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        cron \
        openssh-server \
        python3 \
        python3-apt \
        sudo \
        systemd \
        systemd-sysv \
    && rm -rf /var/lib/apt/lists/*

CMD ["/sbin/init"]
