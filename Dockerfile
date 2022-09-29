#
# Stage for builder base
#
FROM ruby:3.1.2-slim-bullseye as builder_base

ENV DEBIAN_FRONTEND noninteractive
ENV APPROOT="/opt/app"
ARG REDIS_URL

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install build-essential libpq-dev && \
    apt-get clean

WORKDIR ${APPROOT}

COPY Gemfile ${APPROOT}
COPY Gemfile.lock ${APPROOT}


#
# Stage for development builder
#
FROM builder_base as development_builder

ENV RAILS_ENV="development"
RUN gem install bundler && bundle install

#
# Stage for production builder
#
FROM builder_base as production_builder

ENV RAILS_ENV="production"
RUN gem install bundler && bundle install
COPY . ${APPROOT}
RUN SECRET_KEY_BASE=$(rails secret) rails assets:precompile


#
# Runner Base
#
FROM ruby:3.1.2-slim-bullseye as runner_base

ENV DEBIAN_FRONTEND noninteractive
ENV APPROOT="/opt/app"
ENV RAILS_LOG_TO_STDOUT="1"

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install libpq5 libvips42 youtube-dl && \
    apt-get clean

WORKDIR ${APPROOT}

CMD rails about


#
# Stage for development
#
FROM runner_base as development
ENV RAILS_ENV="development"
COPY --from=development_builder /usr/local/bundle /usr/local/bundle


#
# Stage for production
#
FROM runner_base as production
ENV RAILS_ENV="production"
COPY --from=production_builder /usr/local/bundle /usr/local/bundle
COPY . ${APPROOT}
COPY --from=production_builder /opt/app/public/assets /opt/app/public/assets
