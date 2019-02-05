FROM ruby:2.5

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle --version
RUN bundle install

COPY . .

CMD ["bundle", "exec", "ruby", "./run.rb"]
