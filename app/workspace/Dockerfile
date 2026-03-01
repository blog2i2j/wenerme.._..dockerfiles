# syntax=docker/dockerfile:1
ARG ALPINE_RELEASE
FROM wener/ssh:${ALPINE_RELEASE}

RUN apk add --no-cache \
    bash-completion \
    coreutils \
    crane \
    fastfetch \
    file \
    git \
    htop \
    icu-data-full \
    jq \
    lsof \
    make \
    nodejs \
    npm \
    openssl \
    procps-ng \
    rclone \
    rsync \
    shadow \
    sysstat \
    tar \
    tcpdump \
    tmux \
    tree \
    util-linux \
    xxd \
    && npm add -g pnpm yarn
