# builder
FROM ruby:3.1.2-slim-bullseye as builder

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install build-essential libsqlite3-dev libpq-dev && \
    apt-get clean

RUN gem install -i /usr/local/bundle sequel pg sqlite3

# runner
FROM ruby:3.1.2-slim-bullseye

ENV DEBIAN_FRONTEND noninteractive
ENV APPROOT="/opt/data_migration"

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install sqlite3 libpq5 && \
    apt-get clean

COPY --from=builder /usr/local/bundle /usr/local/bundle

WORKDIR ${APPROOT}

COPY . ${APPROOT}

CMD ./data_migration.sh
