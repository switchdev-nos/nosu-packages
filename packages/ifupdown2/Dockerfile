FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
RUN apt -yqq update --no-install-recommends >/dev/null && apt install --no-install-recommends -yqq git curl tar gzip build-essential ca-certificates debhelper devscripts devscripts dh-systemd fakeroot python-all python-docutils iproute2 python3-ipaddr python3-argcomplete python3-setuptools dh-python python3-all python3-setuptools python3-docutils
