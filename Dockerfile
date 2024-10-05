# Use a base image with a compatible Ubuntu version
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    python3 \
    python3-pip \
    ninja-build \
    clang-11 \
    clang++-11 \
    llvm-11-dev \
    libclang-11-dev \
    zlib1g-dev \
    libedit-dev \
    libncurses5-dev \
    libxml2-dev \
    libssl-dev \
    python3-setuptools \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install ANTLR4 C++ runtime
RUN mkdir -p /opt/antlr4 && \
    mkdir -p /opt/antlr4-install
    cd /opt/antlr4 && \
    git clone git clone https://github.com/antlr/antlr4.git && \
    cd antlr4 && git checkout 4.13.0 && \
    mkdir build && cd build && \
    cmake ../runtime/Cpp \
      -DCMAKE_BUILD_TYPE=RELEASE \
      -DCMAKE_INSTALL_PREFIX="/opt/antlr4-install" && \
    make && \
    make install &&
    export ANTLR_INS="/opt/antlr4-install"

# Clone LLVM and MLIR (LLVM-18)
WORKDIR /root
RUN git clone https://github.com/llvm/llvm-project.git && \
    cd llvm-project && \
    git checkout release/18.x

# Build LLVM with MLIR
WORKDIR /root/llvm-project/build
RUN cmake -G Ninja ../llvm \
      -DLLVM_ENABLE_PROJECTS="clang;mlir" \
      -DLLVM_TARGETS_TO_BUILD="X86" \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLVM_ENABLE_ASSERTIONS=ON && \
    ninja

# Set Clang 11 as the default compiler
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-11 100 \
    --slave /usr/bin/clang++ clang++ /usr/bin/clang++-11

# Set environment variables for LLVM
ENV PATH="/root/llvm-project/build/bin:$PATH"
ENV LD_LIBRARY_PATH="/root/llvm-project/build/lib:$LD_LIBRARY_PATH"

# Clean up
RUN apt-get autoremove -y && apt-get clean

# Default command
CMD ["bash"]
