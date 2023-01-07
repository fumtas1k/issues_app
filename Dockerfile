FROM ruby:3.0.1
RUN apt-get update -qq &&\
    apt-get install -y build-essential libpq-dev postgresql-client nodejs npm vim imagemagick cron locales-all curl poppler-utils poppler-data &&\
    npm install n -g && n 16.16.0
RUN npm install -g yarn
RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN gem install bundler:2.3.8 && bundle config set force_ruby_platform true
RUN bundle install
COPY . /app
RUN cd app && yarn install
ENV TZ Asia/Tokyo
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
