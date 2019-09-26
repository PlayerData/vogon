FROM ruby:2.6.3-alpine3.10

RUN adduser -D -u 1000 puma

RUN apk add --update \
  build-base \
  git \
  openssl-dev \
  tzdata \
  && rm -rf /var/cache/apk/*

RUN gem install puma

COPY . .

RUN gem build vogon.gemspec
RUN gem install vogon*.gem

USER puma

CMD ["puma", "docker/config.ru"]
