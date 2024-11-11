# ベースステージ
FROM ruby:3.1.4-slim-bookworm AS base

ENV DEBIAN_FRONTEND noninteractive
ENV APPROOT="/opt/app"
ENV RAILS_LOG_TO_STDOUT="1"

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends build-essential libpq-dev libpq5 libvips42 curl ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L -O https://github.com/yt-dlp/yt-dlp/releases/download/2024.11.04/yt-dlp_linux && \
    mv yt-dlp_linux yt-dlp && \
    chmod +x yt-dlp && \
    mv yt-dlp /usr/local/bin/yt-dlp

WORKDIR ${APPROOT}

COPY Gemfile ${APPROOT}
COPY Gemfile.lock ${APPROOT}

# テスト用のステージ
FROM base AS test
RUN apt-get update && \
    apt-get install -y wget gnupg --no-install-recommends && \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
    apt-get update && apt-get install -y google-chrome-stable --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*
ENV RAILS_ENV="test"
RUN gem install bundler && bundle install
CMD rails about


# 開発用のステージ
FROM base AS development
ENV RAILS_ENV="development"
RUN gem install bundler && bundle install
CMD rails about

# ビルド用のステージ
FROM base AS build
ENV RAILS_ENV="production"
ARG REDIS_URL
RUN gem install bundler && bundle install --without development test
COPY . ${APPROOT}
RUN SECRET_KEY_BASE=$(rails secret) rails assets:precompile

# 本番用のステージ
FROM ruby:3.1.4-slim-bookworm AS production
ENV APPROOT="/opt/app"
ENV RAILS_ENV="production"
ENV RAILS_LOG_TO_STDOUT="1"
ARG REDIS_URL
WORKDIR ${APPROOT}
COPY --from=build ${APPROOT} ${APPROOT}
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /usr/local/bin/yt-dlp /usr/local/bin/yt-dlp
RUN apt-get update && apt-get -y --no-install-recommends install libpq5 ffmpeg libvips42 && apt-get clean && rm -rf /var/lib/apt/lists/*
CMD rails about
