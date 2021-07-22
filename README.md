# Twitter clone
This is a Twitter clone with python and mysql.
The mysql server file is provided in the whole-database-sql directory and all the procedures and triggers separated, are in the procedures-triggers-sql; however, they are also included in the whole-database-sql file.

## Features
- New users signing up 
- Logging into account
- Tweet
- Direct messages
- Liking tweets
- Blocking/Following
- Replying to tweets
- Adding hashtags in tweets
- Getting all the tweets for a certain hashtag
...

## How it works
First you need to run the twitter-clone.sql queries in a mysql database.
Then simply run:
```sh
python interface.py
```
Use the ```help``` to see the commands.
