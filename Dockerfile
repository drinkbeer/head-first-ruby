FROM ruby:2.5

RUN apt-get update

COPY . /tmp/www/ruby
WORKDIR /tmp/www/ruby

RUN gem install bundler
RUN bundle install

# Expose port 8080 to the outside world
EXPOSE 8080

CMD ["ruby","lib/index.rb"]  