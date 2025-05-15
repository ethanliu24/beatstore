# Beat Store
A marketplace for me to store, manage and license my beats.

Things to cover:

* Ruby version

* System dependencies

* Configuration

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Installation

### PostgreSQL
First install Postgresql if haven't yet and create a super user.

Then, create a database called `beatstore` with password `beatstore`. This will be used for development and test.
Follow the steps below to set it up:

```
$ psql  # will enter the enviornment to modify databases, make sure you run as the super user

# do the following
CREATE ROLE beatstore WITH LOGIN PASSWORD 'beatstore';
ALTER ROLE beatstore CREATEDB;
\q  # exit enviornment

rails db:setup  # set up dev and test databases for rails
```

Useful commands:
1. `psql -U $(whoami) -d postgres -c "\du"` - Checks all databases you have
