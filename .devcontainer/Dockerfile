# Use Ubuntu 24.04 LTS as the base image
FROM ubuntu:24.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies for C++20 development
RUN apt-get update && \
    apt-get install -y \
        # Essential build tools
        build-essential \
        cmake \
        ninja-build \
        pkg-config \
        # C++20 compiler (GCC 13+ for full C++20 support)
        gcc-13 \
        g++-13 \
        # Clang as alternative compiler
        clang-18 \
        clang++-18 \
        clang-format-18 \
        clang-tidy-18 \
        # Additional development tools
        gdb \
        lldb \
        valgrind \
        # Version control and utilities
        git \
        curl \
        wget \
        unzip \
        zip \
        # Python for potential tooling
        python3 \
        python3-pip \
        # Libraries and dependencies
        libfmt-dev \
        # Additional utilities
        bash-completion \
        tree \
        htop \
        vim \
        nano \
        less \
        # Networking tools for debugging
        netcat-openbsd \
        telnet \
        # Documentation tools
        doxygen \
        graphviz \
    && rm -rf /var/lib/apt/lists/*

# Set up alternatives for GCC/Clang
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-18 100 && \
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-18 100 && \
    update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-18 100

# Create a non-root user matching the standard devcontainer setup
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user with proper permissions
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Set up the workspace directory with proper permissions
RUN mkdir -p /workspace && chown -R $USERNAME:$USERNAME /workspace

# Install latest CMake (Ubuntu 24.04 should have a recent version, but let's be sure)
RUN CMAKE_VERSION=$(curl -s https://api.github.com/repos/Kitware/CMake/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+') && \
    curl -L "https://github.com/Kitware/CMake/releases/latest/download/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz" | \
    tar -xz -C /opt && \
    ln -sf /opt/cmake-${CMAKE_VERSION}-linux-x86_64/bin/cmake /usr/local/bin/cmake && \
    ln -sf /opt/cmake-${CMAKE_VERSION}-linux-x86_64/bin/ctest /usr/local/bin/ctest

# Configure git with safe directory (for when working with bind mounts)
RUN git config --system --add safe.directory '*'

# Switch to the non-root user
USER $USERNAME

# Set up user environment
RUN echo 'export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> ~/.bashrc && \
    echo 'alias ll="ls -alF"' >> ~/.bashrc && \
    echo 'alias la="ls -A"' >> ~/.bashrc && \
    echo 'alias l="ls -CF"' >> ~/.bashrc && \
    echo 'export CMAKE_BUILD_TYPE=Debug' >> ~/.bashrc && \
    echo 'export CXX=g++' >> ~/.bashrc && \
    echo 'export CC=gcc' >> ~/.bashrc

# Set the default working directory
WORKDIR /workspace

# Expose common development ports (can be overridden)
EXPOSE 8080 3000 5000

# Default command
CMD ["/bin/bash"]