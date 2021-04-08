FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
RUN apt -yqq update --no-install-recommends >/dev/null && apt install --no-install-recommends -yqq git curl tar gzip build-essential ca-certificates debhelper devscripts fakeroot debhelper-compat dh-python python3-all python3-nose python3-six python3-setuptools python3-sphinx
