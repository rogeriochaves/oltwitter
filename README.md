# README

Install Ruby 2.6+, Node.JS and yarn (🙄)
Then Postgress `brew install postgresql`
Then Ruby gems `bundle install`
Then Javascript libs `rails webpacker:install`
Then start the database server `pg_ctl -D /usr/local/var/postgres start`
Then create the database and tables `rails db:create && rails db:migrate`
You also need to set those environment variables:
```
TWITTER_CONSUMER_KEY=xxx
TWITTER_CONSUMER_SECRET=xxx
```

This should be enough to `rails s`