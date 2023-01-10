FROM alpine:3.17

RUN \
  apk --update add build-base git graphviz libffi-dev libxml2-dev libxslt-dev \
  nodejs openssl-dev rsync ruby ruby-bigdecimal ruby-bundler \
  ruby-dev ruby-io-console ruby-irb ruby-json zlib-dev gcompat && \
  rm -rf /var/cache/apk/*

WORKDIR /app

COPY Gemfile* ./

RUN gem install bundler --no-document

RUN bundle install --without debug

EXPOSE 4567

ENTRYPOINT [ "bundle exec middleman server" ]
