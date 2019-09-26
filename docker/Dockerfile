FROM ruby:2.6.3-alpine3.10

RUN apk add --update \
  build-base \
  git \
  tzdata \
  && rm -rf /var/cache/apk/*

RUN gem install puma

COPY . .

RUN gem build vogon.gemspec
RUN gem install vogon*.gem

CMD ["puma", "docker/config.ru"]
