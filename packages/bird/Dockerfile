FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
RUN apt -yqq update --no-install-recommends >/dev/null && apt install --no-install-recommends -yqq git curl tar gzip build-essential ca-certificates debhelper pkg-config debhelper-compat libssh-gcrypt-dev flex bison libncurses5-dev libreadline-dev docbook-xsl dpkg-dev linuxdoc-tools-latex m4 opensp quilt texlive-latex-extra xsltproc
