# Just cause work is on 3.3.0 lol
FROM ruby:3.3.0

RUN gem install bundler

WORKDIR /app

COPY Gemfile* ./

RUN bundle install

COPY main.rb .

CMD ["ruby", "main.rb"]
