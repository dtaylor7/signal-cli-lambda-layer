FROM public.ecr.aws/lambda/nodejs:14.2022.10.11.10-x86_64

ENV SIGNAL_CLI_VERSION=0.11.3
ENV LIB_SIGNAL_VERSION=0.20.0

# install dependancies
RUN yum -y update \
  && yum install -y tar zip gzip bzip2-devel ed gcc gcc-c++ gcc-gfortran \
  less libcurl-devel openssl openssl-devel readline-devel xz-devel \
  zlib-devel glibc-static libcxx libcxx-devel llvm-toolset-7 zlib-static \
  findutils wget unzip protobuf-compiler cmake3 clang

# install java
RUN wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm && \
  rpm -Uvh jdk-17_linux-x64_bin.rpm

# copy in pre-built libsignal_jni.so
COPY ./libsignal-builds/libsignal_jni-${LIB_SIGNAL_VERSION}-x86_64.so /var/task/libsignal_jni.so

# setup signal-cli
RUN wget https://github.com/AsamK/signal-cli/releases/download/v${SIGNAL_CLI_VERSION}/signal-cli-${SIGNAL_CLI_VERSION}-Linux.tar.gz && \
  tar xf signal-cli-${SIGNAL_CLI_VERSION}-Linux.tar.gz && \
  rm signal-cli-${SIGNAL_CLI_VERSION}-Linux.tar.gz && \
  zip -d signal-cli-${SIGNAL_CLI_VERSION}/lib/libsignal-client-*.jar libsignal_jni.so && \
  zip signal-cli-${SIGNAL_CLI_VERSION}/lib/libsignal-client-*.jar libsignal_jni.so

## move signal-cli
RUN cp -R /var/task/signal-cli-$SIGNAL_CLI_VERSION/bin /opt && \
  cp -R /var/task/signal-cli-$SIGNAL_CLI_VERSION/lib /opt

# setup minimum JRE
RUN jlink --add-modules "$(java --list-modules | cut -f1 -d'@' | tr '\n' ',')" --compress 0 --no-man-pages --no-header-files --strip-debug --output /opt/jre17
RUN find /opt/jre17/lib -name *.so -exec strip -p --strip-unneeded {} \;
RUN java -Xshare:dump -version
RUN rm /opt/jre17/lib/classlist && \
  cp /usr/java/jdk-17.*/lib/server/classes.jsa /opt/jre17/lib/server/classes.jsa

# dependancies for signal-cli
RUN cp /usr/bin/xargs /opt/bin && \
  cp /usr/bin/sed /opt/bin && \
  cp /usr/bin/uname /opt/bin && \
  cp /usr/bin/tr /opt/bin

# boostrap for lambda layer
RUN touch /opt/bootstrap && \
  printf '#!/bin/sh\n\n/opt/jre17/bin/java --add-opens java.base/java.util=ALL-UNNAMED -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Xshare:on -cp "/opt/aws-lambda-java-runtime-interface-client-1.1.0.jar:/opt/aws-lambda-java-core-1.2.1.jar:/opt/aws-lambda-java-serialization-1.0.0.jar:$LAMBDA_TASK_ROOT:$LAMBDA_TASK_ROOT/*:$LAMBDA_TASK_ROOT/lib/*" com.amazonaws.services.lambda.runtime.api.client.AWSLambda "$_HANDLER"' > /opt/bootstrap && \
  chmod 755 /opt/bootstrap
RUN curl -4 -L https://repo.maven.apache.org/maven2/com/amazonaws/aws-lambda-java-runtime-interface-client/1.1.0/aws-lambda-java-runtime-interface-client-1.1.0.jar -o /opt/aws-lambda-java-runtime-interface-client-1.1.0.jar && \
  curl -4 -L https://repo.maven.apache.org/maven2/com/amazonaws/aws-lambda-java-core/1.2.1/aws-lambda-java-core-1.2.1.jar -o /opt/aws-lambda-java-core-1.2.1.jar && \
  curl -4 -L https://repo.maven.apache.org/maven2/com/amazonaws/aws-lambda-java-serialization/1.0.0/aws-lambda-java-serialization-1.0.0.jar -o /opt/aws-lambda-java-serialization-1.0.0.jar

# zip up layer
RUN cd /opt/ && \
  find . -type f -exec zip layer.zip {} +

# you can now export layer with following command:
# docker cp <container id>:/opt/layer.zip <output folder>