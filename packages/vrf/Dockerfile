FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
RUN apt -yqq update --no-install-recommends >/dev/null && apt install --no-install-recommends -yqq git curl tar gzip build-essential ca-certificates debhelper devscripts fakeroot libnl-3-dev libnl-route-3-dev libnl-3-200 libnl-route-3-200
