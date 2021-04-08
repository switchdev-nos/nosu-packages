FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
RUN apt -yqq update --no-install-recommends >/dev/null && apt install --no-install-recommends -yqq git curl tar gzip build-essential ca-certificates debhelper devscripts fakeroot libpcap-dev libvirt-dev libnfnetlink-dev libxml2-dev libssl-dev libdbus-1-dev
