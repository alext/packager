FROM ubuntu:bionic

RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime

RUN apt-get update && apt-get install -y \
    build-essential \
    debhelper \
    devscripts \
    equivs \
    ruby \
    && rm -rf /var/lib/apt/lists/*
