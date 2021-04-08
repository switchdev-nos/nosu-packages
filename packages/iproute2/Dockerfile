FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
RUN apt -yqq update --no-install-recommends >/dev/null && apt install --no-install-recommends -yqq git curl tar gzip build-essential ca-certificates debhelper bison flex pkg-config libelf-dev libmnl-dev libcap-dev libselinux-dev libxtables-dev libatm1-dev libbsd-dev libdb-dev
