FROM ruby:3.0.1
RUN apt-get update -qq &&\
    apt-get install -y build-essential libpq-dev postgresql-client nodejs npm vim imagemagick cron locales-all curl poppler-utils poppler-data \
    && npm install n -g && n 16.16.0
RUN npm install -g yarn && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN gem install bundler:2.4.7 && bundle config set force_ruby_platform true
RUN bundle install
COPY . /app
RUN yarn
ENV TZ=Asia/Tokyo \
    LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:ja
