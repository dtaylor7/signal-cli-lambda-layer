# Signal CLI lambda layer

A lambda layer that allows use of the [Signal CLI](https://github.com/AsamK/signal-cli) with lambda.

## Use prebuilt
| Lambda Runtime | Architecture | Signal CLI | Libsignal | &nbsp;
| - | - | - | - | - |
| Node.js 14.x | x86_64 | 0.11.3 | 0.20.0 | [Download](https://github.com/dtaylor7/signal-cli-lambda-layer/releases/download/0.11.3/node14-86_64-signalcli_0.11.3.zip)

## Usage

Upload the layer zip to S3 and create a lambda layer. Add the following environment variables the lambda function using the layer:

| Name | Value | Note |
| - | - | - |
| JAVA_HOME | /opt/jre17 | Set JAVA_HOME
| HOME | /tmp | Set directory for signal cli. Suggest you change this for each invocation of lambda
| XDG_DATA_HOME | /tmp | Set directory for signal cli. Suggest you change this for each invocation of lambda

The cli will be globally available within the lambda layer .eg `signal-cli -a ACCOUNT register`

## Build

1. Setup the correct lambda runtime, signal cli, libsignal versions inside the Dockerfile
2. Update the [JRE version](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html) for the correct architecture e.g. [x86_64](https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm), [aarch64/arm64](https://download.oracle.com/java/17/archive/jdk-17.0.5_linux-aarch64_bin.rpm)
3. Build using docker: `docker build -t signal-cli-lambda-layer`
4. Copy the layer.zip to the host `docker cp <instance id>:/opt/layer.zip  <output destination>`

## Build libsignal
Each version of signal-cli requires its own version of libsignal. This needs to be built in the same architecture as the lambda base.

Follow instructions in /generate-libsignal
