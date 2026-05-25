FROM ubuntu:26.04

# Use mistral user with UID 1001
ARG USERNAME=mistral
ARG USER_UID=1001
ARG USER_GID=1001


# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    bash \
    gcc-13 \
    g++-13 \
    cmake \
    git \
    build-essential \
    make \
    ninja-build \
    pkg-config \
    libsqlite3-dev \
    sqlite3 \
    cppcheck \
    clang-format \
    clang-tidy \
    valgrind \
    libgtest-dev \
    google-mock \
    libssl-dev \
    libjwt-dev \
    curl \
    wget \
    ca-certificates \
    vim \
    python3-pytest \
    openssl \
    libyaml-cpp-dev \
    libgmock-dev \
    sudo \
    git \
    doxygen \
    libreadline-dev \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${USER_GID} ${USERNAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER mistral
ENV PATH="/home/mistral/.local/bin:$PATH"
# Install Devstral Vibe CLI and set up PATH
# The install script modifies shell config, so we need to source it
RUN curl -LsSf https://mistral.ai/vibe/install.sh | bash && \
    # Source the shell profile to get the updated PATH
    if [ -f /home/mistral/.bashrc ]; then . /home/mistral/.bashrc; fi && \
    if [ -f /home/mistral/.profile ]; then . /home/mistral/.profile; fi && \
    # Make vibe installation accessible to non-home/mistral users
    # (uv installs to /home/mistral/.local which is not world-readable by default)
    chmod 755 /home/mistral && \
    chmod -R 755 /home/mistral/.local && \
    # Symlink vibe to /usr/local/bin for PATH access
    VIBE_PATH=$(find /home/mistral -name vibe -type f -executable 2>/dev/null | head -1) && \
    if [ -n "$VIBE_PATH" ]; then \
        sudo ln -s "$VIBE_PATH" /usr/local/bin/vibe && \
        echo "Vibe installed at: $VIBE_PATH"; \
    else \
        echo "ERROR: Vibe binary not found after installation" && exit 0; \
    fi
# 

# Set working directory
WORKDIR /workspace

# Default command - use shell to load environment
CMD ["/bin/bash", "-l", "-c", "vibe", "--trust" ,"--agent", "auto-approve"]
