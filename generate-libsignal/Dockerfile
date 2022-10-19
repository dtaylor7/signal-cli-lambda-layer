## This script generates the libsignal_jni.so required to run signal-cli for lambda
## It will out put the file libsignal_jni.so in the root (/root/libsignal_jni.so).

FROM public.ecr.aws/lambda/nodejs:14.2022.10.11.10-x86_64

ENV LIB_SIGNAL_VERSION=0.20.0

# install dependancies
RUN yum -y update \
  && yum install -y tar zip gzip bzip2-devel ed gcc gcc-c++ gcc-gfortran \
  less libcurl-devel openssl openssl-devel readline-devel xz-devel \
  zlib-devel glibc-static libcxx libcxx-devel llvm-toolset-7 zlib-static \
  findutils wget unzip protobuf-compiler cmake3 clang

# map cmake to cmake3
RUN ln -s /usr/bin/cmake3 /usr/bin/cmake

# install java
RUN wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm && \
  rpm -Uvh jdk-17_linux-x64_bin.rpm && \
  export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::") && \
  export PATH=$JAVA_HOME/bin:$PATH

# install gradle
RUN wget https://services.gradle.org/distributions/gradle-5.0-bin.zip && \
  unzip -d /opt/gradle gradle-*.zip && \
  export GRADLE_HOME=/opt/gradle/gradle-5.0 && \
  export PATH=${GRADLE_HOME}/bin:${PATH}

# install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
RUN source "$HOME/.cargo/env" && \
  rustup default nightly

# get libsignal
RUN wget https://github.com/signalapp/libsignal/archive/refs/tags/v${LIB_SIGNAL_VERSION}.zip -O ./libsignal-${LIB_SIGNAL_VERSION}.zip && \
  unzip libsignal-${LIB_SIGNAL_VERSION}.zip

# build libsignal
RUN source "$HOME/.cargo/env" && \
  cd libsignal-${LIB_SIGNAL_VERSION}/java && \
  sed -i "s/include ':android'//" settings.gradle && \
  cp ../target/release/libsignal_jni.so ~/