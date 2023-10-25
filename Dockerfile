FROM ruby:3.2.2

RUN mkdir -p /var/www/app
WORKDIR /var/www/app

COPY Gemfile* /var/www/app/
RUN bundle install
