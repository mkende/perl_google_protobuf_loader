# DO NOT EDIT! This file is written by perl_setup_dist.
# If needed, you can add content at the end of the file.

# All official images are listed at:
# https://hub.docker.com/_/microsoft-vscode-devcontainers
#
# The default codespace Docker image has apt, apt-get, wget, git, perl and cpan
# (at least). But not cpanm.
# It still seems to work better than the "perl" default image.
# However, it’s too large. We use the C++ specific ones which has most of what we need.
# FROM mcr.microsoft.com/devcontainers/universal:2
FROM mcr.microsoft.com/vscode/devcontainers/cpp:debian

RUN apt-get update
RUN apt-get install -y aspell aspell-en cpanminus perlbrew libcpan-uploader-perl

ENV PERL_MM_USE_DEFAULT=1
RUN perlbrew init

# End of the template. You can add custom content below this line.

sudo apt-get install libprotoc-dev
