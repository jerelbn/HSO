FROM ubuntu:20.04

# Temporarily disable interactive installs
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update \
    && apt install -yq \
    # Generic
    sudo \
    bash-completion \
    build-essential \
    software-properties-common \
    libc++-dev \
    cmake \
    clang-format \
    ninja-build \
    git \
    gdb \
    # Optimization
    gfortran \
    libatlas-base-dev \
    libblas-dev \
    liblapack-dev \
    libsuitesparse-dev \
    libcxsparse3 \
    libfftw3-dev \
    # Graphical
    gnuplot \
    libglfw3-dev \
    libglu1-mesa-dev \
    freeglut3-dev \
    mesa-common-dev \
    libgl1-mesa-dev \
    libglew-dev \
    wayland-protocols \
    # Other libraries
    python3-dev \
    python3-pip \
    doxygen \
    ccache \
    libboost-all-dev \
    libgtest-dev \
    libopencv-dev \
    libyaml-cpp-dev \
    libjsoncpp-dev\
    libeigen3-dev \
    libxkbcommon-dev \
    libopenni-dev \
    libavdevice-dev \
    libgflags-dev \
    # Warning fixes
    language-pack-en-base \
    libcanberra-gtk3-module \
    && apt autoremove -yq \
    && apt clean -yq \
    && rm -rf /var/lib/apt/lists/*

# Pangolin
RUN git clone https://github.com/stevenlovegrove/Pangolin.git \
    && mkdir Pangolin/build \
    && cd Pangolin/build \
    && git checkout v0.8 \
    && cmake \
        -D CMAKE_BUILD_TYPE=Release \
        -D BUILD_SHARED_LIBS=ON    \
        -D BUILD_EXAMPLES=OFF      \
        -D BUILD_TESTS=OFF         \
        .. \
    && make -j $(nproc) \
    && make install \
    && cd ../.. \
    && rm -rf Pangolin

ARG DEBIAN_FRONTEND=interactive

# Add non root user
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && adduser --disabled-password --gecos '' --uid $USER_UID --gid $USER_GID $USERNAME \
    && adduser $USERNAME sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Startup the user and bash
USER $USERNAME
ENV SHELL=/bin/bash

# Suppress spurious warnings on video playback and some GUIs
ENV NO_AT_BRIDGE=1
ENV XDG_RUNTIME_DIR=/run/user/1000

# Ensure that GTSAM is on the library path
ENV LD_LIBRARY_PATH=/usr/local/lib

# Make sure cmake can find cuda
ENV CUDA_TOOLKIT_ROOT=/usr/local/cuda

# Show git branch in terminal
RUN echo "\n# Show git branch in terminal\nexport GIT_PS1_SHOWDIRTYSTATE=1" \
    "\nsource /usr/lib/git-core/git-sh-prompt" \
    "\nexport PS1='\\\[\\\033[01;36m\\\]\\\u\\\[\\\033[01;32m\\\]" \
    "\\\W\\\[\\\033[00;31m\\\]\$(__git_ps1)\\\[\\\033[01;36m\\\] \\\$\\\[\\\033[01;0m\\\] '" \
    >> ~/.bashrc
