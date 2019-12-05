FROM ruby:2.6.5

RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential

ENV INSTALL_PATH /usr/src/service
ENV HOME=$INSTALL_PATH PATH=$INSTALL_PATH/bin:$PATH
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

RUN gem install rails -v 5.1.7

ADD Gemfile* ./
RUN set -ex && bundle install --no-deployment
