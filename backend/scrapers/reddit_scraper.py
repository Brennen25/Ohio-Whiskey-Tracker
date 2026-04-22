import praw

class RedditScraper:
    def __init__(self, client_id, client_secret, user_agent):
        self.reddit = praw.Reddit(
            client_id=client_id,
            client_secret=client_secret,
            user_agent=user_agent
        )

    def search_whiskey_releases(self, subreddit='whiskey', query='whiskey release', limit=10):
        subreddit_instance = self.reddit.subreddit(subreddit)
        results = subreddit_instance.search(query, limit=limit)
        return [(post.title, post.url, post.created_utc) for post in results]

# Example usage:
# scraper = RedditScraper('your_client_id', 'your_client_secret', 'your_user_agent')
# releases = scraper.search_whiskey_releases()  
# print(releases)  
