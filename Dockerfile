#
# Stage for builder base
#
FROM ruby:3.1.4-slim-bookworm

ENV DEBIAN_FRONTEND noninteractive
ENV APPROOT="/opt/app"
ENV RAILS_LOG_TO_STDOUT="1"
ENV RAILS_ENV="development"

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install build-essential libpq-dev libpq5 libvips42 curl ffmpeg && \
    apt-get clean

RUN curl -L -O https://github.com/yt-dlp/yt-dlp/releases/download/2023.07.06/yt-dlp_linux && \
    mv yt-dlp_linux yt-dlp && \
    chmod +x yt-dlp && \
    mv yt-dlp /usr/local/bin/yt-dlp

WORKDIR ${APPROOT}

COPY Gemfile ${APPROOT}
COPY Gemfile.lock ${APPROOT}

RUN gem install bundler && bundle install

CMD rails about
