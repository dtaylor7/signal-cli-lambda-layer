# Create libsignal_jni.so

This script generates the libsignal_jni.so required to run signal-cli for lambda.

It will out put the file libsignal_jni.so in the root (/root/libsignal_jni.so).


## Build libsignal
Each version of signal-cli requires its own version of libsignal. This needs to be built in the same architecture as the lambda base.

1. Setup the correct lambda runtime, libsignal versions inside the Dockerfile
2. Update the [JRE version](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html) for the correct architecture e.g. [x86_64](https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm), [aarch64/arm64](https://download.oracle.com/java/17/archive/jdk-17.0.5_linux-aarch64_bin.rpm)
3. Build using docker: `docker build -t libsignal`
4. Copy the layer.zip to the host `docker cp <instance id>:/root/libsignal_jni.so <output destination>`