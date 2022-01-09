FROM ruby:2.7.2 as build

WORKDIR /app

RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install -y nodejs

RUN npm install -g yarn
COPY package.json yarn.lock ./
RUN yarn install --check-files

# Install gems locally so we can copy it all to the alpine image for a lean runtime
RUN bundle config set path 'vendor/bundle'
COPY Gemfile Gemfile.lock ./
RUN bundle install --verbose --jobs 20 --retry 5

COPY . .

ENV RAILS_ENV production
RUN bundle exec rake assets:precompile

#----------------------------------------------------------------------

FROM ruby:2.7.2-alpine

WORKDIR /app
COPY --from=build /app /app

RUN apk add --update build-base libffi-dev tzdata

RUN bundle config set path 'vendor/bundle'
RUN bundle install

EXPOSE 3002
ENV RAILS_ENV production

CMD ["bundle", "exec", "rails", "server", "-p", "3002", "-b", "0.0.0.0"]