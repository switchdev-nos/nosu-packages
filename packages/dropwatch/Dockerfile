FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
RUN apt -yqq update --no-install-recommends >/dev/null && apt install --no-install-recommends -yqq git curl tar gzip build-essential ca-certificates debhelper devscripts fakeroot binutils-dev libnl-genl-3-dev libreadline-dev pkg-config libpcap-dev
