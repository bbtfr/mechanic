FROM ruby:2.2
MAINTAINER Theo Li <bbtfrr@gmail.com>

RUN apt-get update \
  && apt-get install -y  --no-install-recommends \
  nodejs postgresql-client sqlite3

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --without development test

# Install foreman
RUN gem install foreman

COPY . /usr/src/app

EXPOSE 80

ENV RAILS_ENV production

RUN bundle exec rake db:create db:migrate
RUN bundle exec rake assets:precompile
CMD foreman start -f Procfile
