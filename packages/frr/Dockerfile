FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
RUN apt -yqq update --no-install-recommends >/dev/null && apt install --no-install-recommends -yqq curl ca-certificates git autoconf automake libtool make libreadline-dev texinfo pkg-config libpam0g-dev libjson-c-dev bison flex python3-pytest libc-ares-dev python3-dev libsystemd-dev python-ipaddress python3-sphinx install-info build-essential libsystemd-dev libsnmp-dev perl libcap-dev equivs gnupg lsb-release chrpath gawk
RUN curl -s https://deb.frrouting.org/frr/keys.asc | apt-key add -
RUN echo deb https://deb.frrouting.org/frr $(lsb_release -s -c) frr-stable | tee -a /etc/apt/sources.list.d/frr.list
RUN apt -yqq update && apt --no-install-recommends -yqq install libyang-dev
