##
## ビルド用ステージ
##
## See: https://hub.docker.com/_/rust
##
#FROM ruby:3.1.2-buster as build_env
#
#ENV DEBIAN_FRONTEND noninteractive
#
#RUN apt-get update -y && apt-get upgrade -y
#
#WORKDIR /opt/ytdlor


#
# 実行用ステージ
#
FROM ruby:3.1.2-slim-bullseye

ENV APPROOT="/opt/ytdlor"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y install systemd build-essential && \
    apt-get clean

#COPY --from=build_env /usr/local/cargo/bin/sakura /usr/local/sbin/sakura

WORKDIR ${APPROOT}

COPY . ${APPROOT}

RUN gem install bundler && bundle install
RUN rails assets:precompile RAILS_ENV=production

STOPSIGNAL SIGRTMIN+3
CMD [ "/sbin/init" ]
