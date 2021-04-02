FROM ubuntu:rolling
LABEL maintainer="realmadsci"
ENV DEBIAN_FRONTEND=noninteractive 

# Platform installs:
RUN apt-get update && apt-get install -y \
    bash-completion \
    sudo \
  && rm -rf /var/lib/apt/lists/*

# Add a non-root user as the default user
##############
RUN useradd --create-home --shell /bin/bash fuzzer
RUN usermod -aG sudo fuzzer
RUN echo "fuzzer:password" | chpasswd
USER fuzzer
RUN printf "alias ll='ls $LS_OPTIONS -l'\nalias l='ls $LS_OPTIONS -lA'\n\n# enable bash completion in interactive shells\nif [ -f /etc/bash_completion ] && ! shopt -oq posix; then\n    . /etc/bash_completion\nfi\n" > ~/.bashrc

WORKDIR /home/fuzzer

# Mount the host here if you want when you run the script
RUN mkdir /home/fuzzer/host

# Zork installs
USER root
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    libncurses5-dev \
  && rm -rf /var/lib/apt/lists/*
USER fuzzer

RUN git clone https://github.com/realmadsci/zork.git zork


# Debugging installs
USER root
RUN apt-get update && apt-get install -y \
    gdb \
    wget \
    python3-minimal \
    xxd \
    vim \
    nano \
  && rm -rf /var/lib/apt/lists/*
USER fuzzer

# Add gef (this also requires wget and python3 packages to be installed
RUN wget -O ~/.gdbinit-gef.py -q https://github.com/hugsy/gef/raw/master/gef.py
RUN echo source ~/.gdbinit-gef.py >> ~/.gdbinit
RUN echo "export LC_ALL=C.UTF-8\n" >> ~/.bashrc


# Fuzzer installs
USER root
RUN apt-get update && apt-get install -y \
    afl++-clang \
    tmux \
  && rm -rf /var/lib/apt/lists/*
USER fuzzer


CMD "/bin/bash"
