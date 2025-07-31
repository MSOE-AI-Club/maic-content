<br>
<a href='/learning-tree?node=23' style='
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

<p style='color: white; margin-top: 2px;'>This article is a continuation of the Intro to Webscraping article. This one goes into how to structure and format data obtained from webscraping. This will make use of large language models, as they are the easiest way to structure freeform data. Structuring data can be an important step in making a good model, so structing webscraped data can create a mountain of good data.</p>

</div>

<br/>

<br/>
 
## Structuring Webscraped Results

By now, you should have a webscraper that is able to extract website content using Selenium and return the text content rendered on that website. We will now look at how we can structure this data for more general purpose machine learning applications.

## Installing Necessary Packages + Setup

First, we're going to need some new packages for this.  
You'll want to start with running `pip install pydantic pydantic-ai pandas`. You can learn more about Pydantic [here](https://docs.pydantic.dev/latest/), Pydantic AI [here](https://ai.pydantic.dev/) and Pandas [here](https://pandas.pydata.org/).

Next, you'll want to create a Gemini free-tier API key. This will get you access to the Gemini Flash models for free (no card info needed), with a limit of about 30 requests a minute.
1. Go to the [Gemini AI Studio](https://aistudio.google.com)
2. Click "Sign in to Google AI Studio"
3. Enter your Google account info (or create a Google account if you do not have one).
4. Hit the "Get API Key" button
5. Scroll down and press "Create API Key"

It should return to you your API key! Make sure to store this somewhere (make a text file on your PC or something) for now as we will need to come back to it later. Once you close out of it on Gemini AI Studio, you can't copy that key again so make sure you have it copied somewhere for later. 

If you lose your key, you'll just have to create a new one.

## Using PydanticAI to Structure Web Results

Now we have an LLM we can use to structure our web results. Let's use it to structure the [refurbished iPhone 14 Pro page](https://www.apple.com/shop/refurbished/iphone/iphone-14-pro) on Apple.

```
from typing import List
from pydantic import BaseModel, Field

class ProductResult(BaseModel):  
    model: str = Field(description='The model of the product')
    description: str = Field(description='The description of the product')
    cost: int = Field(description="The cost of the product")
    isp: str = Field(description="The internet service provider")
    color: str = Field(description="The color of the product")
    refurbished: bool = Field(description="Whether the product is refurbished")

class RequestResults(BaseModel):
    products: List[ProductResult] = Field(description='The list of product results')
```

What we're doing here is defining a custom data structure which we want the LLM to conform to. It will produce it's results in this same data type with the fields we have specified filled in with the appropriate data from the webpage. We then also create a RequestResults model so that we can get a list of our custom classes.

```
import os
from pydantic_ai import Agent

os.environ["GEMINI_API_KEY"] = "<gemini_api_key>"

agent = Agent(  
    'google-gla:gemini-1.5-flash',
    result_type=RequestResults,
    system_prompt='Be concise, reply with one sentence.',  
)

@agent.system_prompt  
async def add_customer_name(ctx) -> str:
    return f"Your goal is to extract product information from web scraped pages and format it to a structured response."
```

Now we are setting up our LLM Agent. This will be our way of interacting with the model. **At this point, you can put your Gemini API Key in place of the <gemini_api_key> text** 

We're also going to define a **system prompt**. This is a special prompt that tells the LLM who it is in the current context. You can also feel free to tune this later and see how the system prompt can impact outputs!

```
content = get_page_content("https://www.apple.com/shop/refurbished/iphone/iphone-14-pro")

result = await agent.run(content[1])

import pandas as pd
from IPython.display import display

item_dicts = [item.dict() for item in result.data.products]
df = pd.DataFrame(item_dicts)
display(df.head(20))
```

Now we're going to run our model! First thing we're going to do is get our website (make sure you're using your get_page_content function we designed in the last article) so we can get the page content. Then we can give it to our model, and we will get back a list of our dataclasses that will contain the data we need. We can then iterate it and put it into a Pandas dataframe to view. Below is an example of what the table should look like.

<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>model</th>
      <th>description</th>
      <th>cost</th>
      <th>isp</th>
      <th>color</th>
      <th>refurbished</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>iPhone 13 Pro Max</td>
      <td>Refurbished iPhone 13 Pro Max 512GB - Graphite...</td>
      <td>929</td>
      <td>Unlocked</td>
      <td>Graphite</td>
      <td>True</td>
    </tr>
    <tr>
      <th>1</th>
      <td>iPhone 13 Pro Max</td>
      <td>Refurbished iPhone 13 Pro Max 512GB - Silver (...</td>
      <td>929</td>
      <td>Unlocked</td>
      <td>Silver</td>
      <td>True</td>
    </tr>
    <tr>
      <th>2</th>
      <td>iPhone 13 Pro Max</td>
      <td>Refurbished iPhone 13 Pro Max 512GB - Gold (Un...</td>
      <td>929</td>
      <td>Unlocked</td>
      <td>Gold</td>
      <td>True</td>
    </tr>
    <tr>
      <th>3</th>
      <td>iPhone 13 Pro Max</td>
      <td>Refurbished iPhone 13 Pro Max 512GB - Sierra B...</td>
      <td>929</td>
      <td>Unlocked</td>
      <td>Sierra Blue</td>
      <td>True</td>
    </tr>
    <tr>
      <th>4</th>
      <td>iPhone 14 Pro Max</td>
      <td>Refurbished iPhone 14 Pro Max 512GB - Silver (...</td>
      <td>1019</td>
      <td>Unlocked</td>
      <td>Silver</td>
      <td>True</td>
    </tr>
    <tr>
      <th>5</th>
      <td>iPhone 14 Pro Max</td>
      <td>Refurbished iPhone 14 Pro Max 512GB - Gold (Un...</td>
      <td>1019</td>
      <td>Unlocked</td>
      <td>Gold</td>
      <td>True</td>
    </tr>
    <tr>
      <th>6</th>
      <td>iPhone 14 Pro Max</td>
      <td>Refurbished iPhone 14 Pro Max 512GB - Deep Pur...</td>
      <td>1019</td>
      <td>Unlocked</td>
      <td>Deep Purple</td>
      <td>True</td>
    </tr>
    <tr>
      <th>7</th>
      <td>iPhone 13 Pro Max</td>
      <td>Refurbished iPhone 13 Pro Max 1TB - Gold (Unlo...</td>
      <td>1099</td>
      <td>Unlocked</td>
      <td>Gold</td>
      <td>True</td>
    </tr>
    <tr>
      <th>8</th>
      <td>iPhone 13 Pro Max</td>
      <td>Refurbished iPhone 13 Pro Max 1TB - Sierra Blu...</td>
      <td>1099</td>
      <td>Unlocked</td>
      <td>Sierra Blue</td>
      <td>True</td>
    </tr>
  </tbody>
</table>
</div>

Congratulations! You have now structured web data from webscraping! Feel free to now try other websites, modifying the dataclass, and also changing the system prompt for different responses!
