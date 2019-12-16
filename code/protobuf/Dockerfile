FROM ruby:2.6.5

RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential protobuf-compiler

ENV INSTALL_PATH /usr/src/protobuf
ENV HOME=$INSTALL_PATH PATH=$INSTALL_PATH/bin:$PATH
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

RUN gem install protobuf
