<br>
<a href='/learning-tree?node=24' style='
    background-color: #31313a;
    color: gainsboro;
    padding: 6px 16px;
    border: none
    border-radius: 4px;
    text-transform: uppercase;
    font-family: "Roboto", sans-serif;
    font-size: 1em;
    font-weight: bold;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;'
>
  View in Learning Tree
</a>

<br>
<br>
<br>

<div style='
  position: relative;
  padding: 10px; 
  border-radius: 5px;
  background-color: rgba(0, 0, 0, 0.85); 
  border: 4px solid transparent;
  background-image: linear-gradient(90deg, rgba(0, 0, 0, 0.85), rgba(0, 0, 0, 0.85)), linear-gradient(90deg, gold, orange, gold);
  background-origin: border-box;
  background-clip: padding-box, border-box;
'>

<svg width='200' height='50' style='display: block; margin-bottom: 5px;'>
  <text x='0' y='35' font-size='35' font-family='Arial' font-weight='bold' fill='gold'>
    Why Read?
    <animate attributeName='fill' values='gold; orange; gold' dur='3s' repeatCount='indefinite' />
  </text>
</svg>

<p style='color: white; margin-top: 2px;'>This article is a continuation of the Intro to Webscraping series where now we are looking at how we can use Google Search to get websites to extract data from with a more freeform input structure. This will provide greater flexibility in creating datasets of general topics you have an interest in or creating your own knowledge bases!</p>

</div>

<br/>

<br/>
 
## Using SERP to Search Google

In the last two articles, we learned how to webscrape and how to structure webscraped data. Now, we are going to look at one last step. We are going to look at a process called **webcrawling**.

Webcrawling is when you crawl the general internet in search websites. This can be any websites or very specific topic of websites. You can then scrape these sites and use our prior techniques to create your own datasets.

To do this, we are going to use a process called SERP (Search Engine Results Page). SERP is a standard where the results that you would get from a search engine are returned instead in a JSON structure from an API that you can then parse through, as if you had searched it on Google or some other search engine.

## Installing Necessary Packages + Setup

For this example, we shouldn't need to install any extra python packages, we will be using purely built-in Python modules (however if you get an error saying that `requests` is not installed, run `pip install requests` in a terminal). We will however need to setup an account with a provider called [Serper.dev](https://serper.dev/). They will provide for us the searching API endpoints to do our Google search (for our example, you can just create a free account which will provide you with 2500 credits, or about 1250 Google searches).
1. Go to [Serper.dev](https://serper.dev/)
2. Press the Sign Up button in the top right
3. Create an account
4. Once your account is created, in the top right, press the API Key button
5. On the API Key page, press "Copy" -- Store this key for later use somewhere.

## Using Serper to Search

Now, lets go set up our SERP Search and try getting some websites. We're going to search for the "iphone 14 pro" in this example, but feel free to try your own queries.

```
import os
import json
import requests
from functools import lru_cache
```

We're first going to import our necessary packages. These will allow us to make a request to the Serper API. We also are going to add a cache to our function so we don't end up redoing a request to Serper and wasting credits for the same query (we can generally expect that right now, the search results for a given query probably won't change).

```
os.environ["SERPER_API_KEY"] = "<serper_api_key>"

@lru_cache(maxsize=1000)
def serp_search(query):
    url = "https://google.serper.dev/search"
    payload = json.dumps({
        "q": query,
    })

    headers = {
        'X-API-KEY': os.environ["SERPER_API_KEY"],
        'Content-Type': 'application/json',
    }

    response = requests.post(url, headers=headers, data=payload)
    return response.json()
```

Now we are defining our search function. We also can set our API Key here in place of <serper_api_key>. 

This function will make our request to the serper endpoint that supports search. For this example, we are doing a Google search, however Serper also supports searching Google Images, Videos, Places, and more.

```
results = serp_search("iphone 14 pro")["organic"]
for result in results:
    print(result["title"])
    print(result["link"])
```

Now we can try out our query! We should get a result similar to the one below:

Buy iPhone 14 and iPhone 14 Plus - Apple
https://www.apple.com/shop/buy-iphone/iphone-14
Apple iPhone 14 Pro, 128GB, Deep Purple - Unlocked (Renewed)
https://www.amazon.com/Apple-iPhone-128GB-Deep-Purple/dp/B0BN92X6XK
iPhone 14 Pro - Technical Specifications - Apple Support
https://support.apple.com/en-us/111849
Learn About iPhone 14 Pro and iPhone 14 Pro Max - Best Buy
https://www.bestbuy.com/site/iphone/learn-about-iphone-14-pro/pcmcat1662579751749.c?id=pcmcat1662579751749
Refurbished iPhone - iPhone 14 Pro - Apple
https://www.apple.com/shop/refurbished/iphone/iphone-14-pro
iPhone 14 Pro - Wikipedia
https://en.wikipedia.org/wiki/IPhone_14_Pro
Longterm review of iPhone 14 Pro : r/iPhone14Pro - Reddit
https://www.reddit.com/r/iPhone14Pro/comments/1gdu8zl/longterm_review_of_iphone_14_pro/
Apple iPhone 14 Pro - Full phone specifications - GSMArena.com
https://www.gsmarena.com/apple_iphone_14_pro-11860.php
Apple iPhone 14: Prices, 2 Colors, Sizes, Features & Specs - T-Mobile
https://www.t-mobile.com/cell-phone/apple-iphone-14

And now we are all set to start webcrawling! Try tying this function in with your web scraper (built in the last two articles) and start building your own datasets!
