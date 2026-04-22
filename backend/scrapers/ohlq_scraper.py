import requests
from bs4 import BeautifulSoup

# Function to scrape allocated whiskey locations

def scrape_allocated_whiskey():
    url = 'https://ohlq.com/'  # URL of the OHLQ website
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')

    # Logic to find allocated whiskey locations
    allocated_whiskey = []
    for item in soup.find_all('div', class_='allocated-whiskey-item'):
        location = item.find('span', class_='location').text
        availability = item.find('span', class_='availability').text
        release_info = item.find('span', class_='release-info').text
        allocated_whiskey.append({
            'location': location,
            'availability': availability,
            'release_info': release_info
        })

    return allocated_whiskey

# Example usage:
if __name__ == '__main__':
    allocated = scrape_allocated_whiskey()
    print(allocated)