summary: Introduction to Webscraping
type: md
date: 1/30/2025
title: Introduction to Webscraping
image: ./img/tree-thumbnails/sl-intro.png
difficulty: advanced
authors: Adam Haile
categories: webscraping, python

<br>
<a href='/learning-tree?node=22' style='
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

<p style='color: white; margin-top: 2px;'>This is a beginner's introduction for how to perform webscraping using Python. Once you are able to webscrape, you will have a mountain of near limitless data at your fingertips. It's just up to you then on what data you need and how you'll format it!</p>

</div>

<br/>

<br/>
 
## What is webscraping?
Web scraping is the technique of extracting data from websites automatically using extraction/crawling software. It can be used to obtain **MASS** amounts of data. It's the most common technique used by companies that train Large Language Models to obtain their data. There are multiple different ways to scrape data, and can be formatted in both an [unstructured and structured](https://www.ibm.com/think/topics/structured-vs-unstructured-data) format. Many large services have APIs which will allow you to extract their data in a structured format. This is usually the best option, but not all websites expose their APIs in a way which allow this. In this situation, web scraping is your best solution.

For more information how how webscrapers work, check out this article! [https://www.geeksforgeeks.org/what-is-web-scraping-and-how-to-use-it/](https://www.geeksforgeeks.org/what-is-web-scraping-and-how-to-use-it/)

## How do webscrape?
Let's make our own webscraper using Python. For this, we'll start with making our webscraper in a new [Jupyter notebook](https://msoe-maic.com/library?nav=Articles&article=Learning_Resources-how-to-use-jupyter-notebooks) as it'll be the easiest to iterate and test our webscraper, but these same concepts can be used more autonomously in a Python file.

First, let's install some packages.

For this project, we are going to use:
- [Requests](https://requests.readthedocs.io/en/latest/)
- [Selenium](https://selenium-python.readthedocs.io/)
- [BeautifulSoup4](https://www.crummy.com/software/BeautifulSoup/bs4/doc/)

To install these, let's run this in a cell of the notebook:
```python
%pip install requests beautifulsoup4 selenium webdriver-manager
```
> webdriver-manager is an additional package we will need for Selenium

Now, let's import some of our packages
```
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
import time
```

Using these, we can now define our website scraping function.
```
def get_page_content(url):
    """
    Opens a URL using Selenium and retrieves the page contents
    
    Args:
        url (str): The URL to open
        
    Returns:
        tuple: (raw_html, parsed_text) where raw_html is the page source and 
               parsed_text is the cleaned text content
    """
    # Set up Chrome options
    chrome_options = Options()
    chrome_options.add_argument('--headless')  # Run in headless mode (no GUI)
    chrome_options.add_argument('--disable-gpu')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    
    # Initialize the Chrome WebDriver
    driver = webdriver.Chrome(
        service=Service(ChromeDriverManager().install()),
        options=chrome_options
    )
    
    try:
        # Open the URL
        driver.get(url)
        
        # Wait for a short time to ensure the page loads
        time.sleep(2)
        
        # Get the page source
        page_content = driver.page_source
        
        # Parse with BeautifulSoup
        soup = BeautifulSoup(page_content, 'html.parser')
        
        # Remove script and style elements
        for script in soup(["script", "style"]):
            script.decompose()
        
        # Find all code blocks and wrap their text in backticks
        code_blocks = soup.find_all(['pre', 'code'])
        for block in code_blocks:
            if block.string:
                block.string = f'```{block.string}```'
            else:
                # Handle nested elements within code blocks
                block.string = f'```{block.get_text()}```'
                
        # Get text and clean it
        text = soup.get_text().replace("```Copy", "```")
        
        # Clean up the text
        # Break into lines and remove leading/trailing space on each
        lines = (line.strip() for line in text.splitlines())
        
        # Break multi-headlines into a line each
        chunks = (phrase.strip() for line in lines for phrase in line.split("  "))
        
        # Drop blank lines
        text = '\n'.join(chunk for chunk in chunks if chunk)
        
        return page_content, text
    
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        return None, None
    
    finally:
        # Always close the browser
        driver.quit()
```

Let's look at this function piece-by-piece and understand what it does.
First, we start up a Chrome webdriver. This will be the component we use to actually load a webpage live, which means any JavaScript on a website will execute so we get all the content expected.

We then give a slight delay to ensure the page loads. This delay can be adjusted depending on your needs, just know that the smaller you make it, the more likely it may not be loaded 100% before extracting contents.

We can then extract the text contents of the page. This does not include text in things like images or videos, just the raw text on the website.

We can then create a BeautifulSoup object which we give our webpage content to, and can then clean up to to extract our desired text. Some of the cleanup we perform are removing the script elements and other excess things that wouldn't actually be visible to a user on the website normally, and we also perform some cleanup on code elements to make it look more like a code block.

For our formatting, we then rejoin the text together with newlines so it's easier to read.
Then we shutdown our driver so that we aren't losing resources that aren't being used.

Let's now give it a try! We can run it with the following:
```
print(get_page_content("https://msoe-maic.com/library?nav=Articles&article=001_What_is_the_Learning_Tree")[0])
```

We see that when we run this, with using the link given, we get something similar to the following:
![webscraping results](https://maic-fastapi-lambda.s3.amazonaws.com/img/misc/webscraping_output.png)

Great! We just scraped our first website! We can now use this same function to scrape more websites and get their content!

## Risks of webscraping
Not all websites "permit" webscraping. Some websites don't really want their content extracted, and it is generally recommended that you abide by these rules.
To find out if a website permits webscraping, you can read their robots.txt file. Most websites have one, and can be accessed by going to their root, and adding robots.txt to the end of the URL. (Ex: https://www.youtube.com/robots.txt). This type of contract is called a **gentleman's agreement**. This means it isn't a legally binding agreement, but relies on good faith of people who webscrape/webcrawl. We would highly encorage that if you are going to perform webscraping/crawling, that you abide by these agreements.

If you'd like to learn more about how the climate has changed between AI and the robots.txt file, the Verge has a great article about it here! [https://www.theverge.com/24067997/robots-txt-ai-text-file-web-crawlers-spiders](https://www.theverge.com/24067997/robots-txt-ai-text-file-web-crawlers-spiders)