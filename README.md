# Beat Store
A marketplace for me to store, manage and license my beats.

## Handy Links
- [Hetzner Projects](https://console.hetzner.com/projects): Deployments
- [Cloudfare Admin](https://dash.cloudflare.com): Domain, DNS & internet services
- [Google OAuth2 Client](https://console.cloud.google.com/auth/clients): Oauth2
- [Coveralls](https://coveralls.io/github/ethanliu24/beatstore): Code coverage report

## Installation

### Stripe
Stripe will handle payments with Stripe Checkout. Install the [Stripe CLI](https://docs.stripe.com/stripe-cli) to test Stripe webhooks locally.
Run the following command to install it on:
- Mac: `brew install stripe/stripe-cli/stripe`

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
1. `psql -U $(whoami) -d postgres -c "\du"` - Checks all database roles you have

## Environment Set Up
See `ENV_SETUP.md` for more info.

## Running

### Backend Server

Run this to start the server:
```
$ ./bin/dev
```

This command executes `Procfile.dev` and runs all commands defined in there.

### Stripe CLI
This is for testing Stripe webhooks locally. In a seperate terminal and run the following commands:

1. `stripe login`
    - This will prompt you to go to an url to log in
2. `stripe listen --forward-to localhost:3000/webhooks/stripe/payments`
    - This will output a webhook signiture event in format `whsec_...`
    - Open rails credentials: `VISUAL="code --wait" rails credentials:edit`
    - in `stripe.test.payments_webhook_secret`, if the signiture is different, replace it with the newly generated signiture
3. `stripe trigger <webhook-event>`
    - This will trigger a Stripe webhook event and will be picked up by localhost

More details [here](https://dashboard.stripe.com/test/webhooks/create?endpoint_location=local).


## Testing
To run tests, use the commands below.
```
$ rspec  $ run all tests
$ rspec <directory-or-file>  # run all tests in the given directory or file

# or alternatively, use "bundle exec rspec" instead of rspec
```

## Editing Credentials
1. In the rails project, enter rails credentials editing enviornment using this command:
`VISUAL="code --wait" rails credentials:edit`
    - _Instead of "code", you can use the command that opens the editor of your choice, e.g. "cursor"_
2. Add the desired credentials to the file
3. Close the file to save.
4. Fetch the credentials in the appropriate `settings.*.yml` config file, do NOT hardcode any sensitive information.

## Tabler Icons
All icons are from [Tabler](https://tabler.io/icons). Add new icons by:
1. Visit the website and find the icon wanted
2. Download the icon in svg, at size `24`, stroke `2`
3. In `app/assets/svg/icons/tabler/`, put the svg in `outline/` or `fill/` folder, depeding on the icon downloaded
4. Commit to git
5. The file name is the param passed in the `icon` helper. Currently there are `outline` (default) and `filled` variants available

_Do NOT run `rails generate rails_icons:install --libraries=tabler`, it will pull all icons which will slow things down dramatically._

## Clearing tmp
The project size can get extremely large in development because running tests creates a lot of fixtures in local active storage.
You can clean up the `tmp/` directory every once in a while. Refer to [the official docs](https://guides.rubyonrails.org/v4.1.0/command_line.html#tmp) for more details.

```
$ rails tmp:clear # clear all files in tmp/

$ rails tmp:storage:clear # likely what you want to run the most
```
