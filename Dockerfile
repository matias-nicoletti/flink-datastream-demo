FROM debian:stable-slim

ARG CORRETTO_JAVA_VERSION
ARG JAVA_HOME_VERSION
ARG FLINK_VERSION
ARG SCALA_VERSION
ARG ARCHITECTURE

RUN apt-get update && apt-get install -y java-common cmake libopenblas-dev libsuitesparse-dev libgsl-dev libglpk-dev wget

# Download amazon corretto
RUN wget https://corretto.aws/downloads/latest/amazon-corretto-$CORRETTO_JAVA_VERSION-linux-jdk.deb
RUN dpkg --install amazon-corretto-$CORRETTO_JAVA_VERSION-linux-jdk.deb

# Set required java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-$JAVA_HOME_VERSION-amazon-corretto
ENV JDK_HOME=$JAVA_HOME

# Download and extract flink
WORKDIR /
RUN wget http://archive.apache.org/dist/flink/flink-$FLINK_VERSION/flink-$FLINK_VERSION-bin-scala_$SCALA_VERSION.tgz
RUN tar xvf flink-$FLINK_VERSION-bin-scala_$SCALA_VERSION.tgz
RUN echo "rest.bind-address: 0.0.0.0" >> /flink-$FLINK_VERSION/conf/flink-conf.yaml