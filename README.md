# Good Ol' Twitter

Now you can go back in time, to use the old twitter, the best twitter, whithout all complications of the modern world, just simple text, no likes, no images, videos, algorithmic feed with a tweet that was liked by a follower of a follower, NO, just original twitter, from where we should never have left

<img width="892" alt="oltwitter" src="https://user-images.githubusercontent.com/792201/73158128-448bfc00-40e3-11ea-8fc5-9d705b42378d.png">

Access now: https://oltwitter.herokuapp.com/

# Contributing

Install Ruby 2.6+, Node.JS and yarn (🙄)
Then Postgress `brew install postgresql`
Then Ruby gems `bundle install`
Then Javascript libs `rails webpacker:install`
Then start the database server `pg_ctl -D /usr/local/var/postgres start`
Then create the database and tables `rails db:create && rails db:migrate`
Copy the .env.sample file to .env and change it with actual twitter credentials:
```
TWITTER_CONSUMER_KEY=xxx
TWITTER_CONSUMER_SECRET=xxx
```

This should be enough to `rails s`