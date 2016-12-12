# xcode-bots-tweet
Post-integration script that tweets build status

To use, you'll need to create a new account on Twitter and get in the developer program (I know). Then set the following environment variables sometime before the script is run:
* `TWITTER_OAUTH_CONSUMER_KEY`
* `TWITTER_OAUTH_CONSUMER_SECRET`
* `TWITTER_OAUTH_TOKEN`
* `TWITTER_OAUTH_TOKEN_SECRET`

The OAuth implementation is bare minimum I could get away with. Enjoy.
