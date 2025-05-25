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

### Gems
Install all the gems with bundle:
```
$ bundle install
```

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

### Tabler Icons
Icons are not committed to the repo due to the large amount of it, so newly cloned projects will need to install them. Icons are from [Tabler](https://tabler.io/icons).
```
$ rails generate rails_icons:install --libraries=tabler
```


## Running
Run this to start the server:
```
$ ./bin/dev
```

The reason we use this instead of `rails s` is so that Tailwind can watch for changes. If not working on views, either command works.


## Testing
To run tests, use the commands below.
```
$ rspec  $ run all tests
$ rspec <directory-or-file>  # run all tests in the given directory or file

# or alternatively, use "bundle exec rspec" instead of rspec
```
