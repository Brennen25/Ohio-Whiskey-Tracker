import tweepy

class TwitterScraper:
    def __init__(self, api_key, api_secret_key, access_token, access_token_secret):
        self.auth = tweepy.OAuthHandler(api_key, api_secret_key)
        self.auth.set_access_token(access_token, access_token_secret)
        self.api = tweepy.API(self.auth)

    def track_users(self, user_ids):
        for user_id in user_ids:
            try:
                # Fetch user timeline
                tweets = self.api.user_timeline(user_id=user_id, count=10, tweet_mode='extended')
                for tweet in tweets:
                    print(f'New tweet from {user_id}: {tweet.full_text}')
            except tweepy.TweepError as e:
                print(f'Error fetching tweets from {user_id}: {e}')

# Example usage
if __name__ == '__main__':
    # Replace with your own credentials
    API_KEY = 'your_api_key'
    API_SECRET_KEY = 'your_api_secret_key'
    ACCESS_TOKEN = 'your_access_token'
    ACCESS_TOKEN_SECRET = 'your_access_token_secret'

    scraper = TwitterScraper(API_KEY, API_SECRET_KEY, ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
    # Replace with user IDs you want to track
    user_ids = ['user_id_1', 'user_id_2']
    scraper.track_users(user_ids)