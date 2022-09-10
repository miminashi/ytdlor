#
# ビルド用ステージ
#
FROM ruby:3.1.2-slim-bullseye as builder

ENV DEBIAN_FRONTEND noninteractive
ENV APPROOT="/opt/ytdlor"
ENV DUMMY_KEY="SECRET_KEY_BASE"
ENV RAILS_ENV="production"

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install build-essential libsqlite3-dev libpq-dev && \
    apt-get clean

WORKDIR ${APPROOT}

COPY . ${APPROOT}

RUN gem install bundler && bundle install
RUN RAILS_ENV=${RAILS_ENV} SECRET_KEY_BASE=$(rails secret) rails assets:precompile

#
# 実行用ステージ
#
FROM ruby:3.1.2-slim-bullseye

ENV DEBIAN_FRONTEND noninteractive
ENV APPROOT="/opt/ytdlor"
ENV RAILS_LOG_TO_STDOUT="1"

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install libpq5 sqlite3 libvips42 youtube-dl && \
    apt-get clean

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /opt/ytdlor/public/assets /opt/ytdlor/public/assets

WORKDIR ${APPROOT}

COPY . ${APPROOT}

CMD rails about
