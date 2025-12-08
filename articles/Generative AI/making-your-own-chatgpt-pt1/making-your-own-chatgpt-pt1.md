<br>
<a href='/learning-tree?node=53' style='
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

<p style='color: white; margin-top: 2px;'>By reading this article, you'll learn how to run your own AI chatbot using Meta's Llama 3.2 90B Vision model on MSOE's ROSIE supercomputer. You'll set up a Jupyter notebook environment, write Python code to send requests to the model, and even analyze images using AI – all without needing expensive cloud API credits. Let's build your own Chat-GPT!</p>

</div>

<br/>
<br/>

# Introduction

Ever wanted to run your own version of ChatGPT? While OpenAI's GPT models require paid API access, MSOE students have access to something special: **ROSIE**, our on-campus supercomputer, running Meta's powerful **Llama 3.2 90B Vision Instruct** model. This model can understand both text and images, making it incredibly versatile for AI projects.

In this tutorial, you'll learn how to:
- Set up a Jupyter notebook environment on ROSIE via Open OnDemand (OOD)
- Write Python code to communicate with the Llama 3.2 model
- Send text prompts and receive AI-generated responses
- Analyze images using the model's vision capabilities
- Handle streaming responses for real-time text generation

**Prerequisites**: Before starting this tutorial, make sure you have:
- ROSIE account access (see [ROSIE Pt1: Getting Access](/library?nav=Articles&article=1-getting-rosie-access))
- Basic Python knowledge
- Familiarity with the ROSIE web portal (see [ROSIE Pt3: Using ROSIE Web Portal](/library?nav=Articles&article=3-rosie-web))

---

## What is Llama 3.2?

![Meta Llama 3.2](<https://scontent-ord5-2.xx.fbcdn.net/v/t39.2365-6/461179924_892945479558448_4846394290454647920_n.png?_nc_cat=105&ccb=1-7&_nc_sid=e280be&_nc_ohc=wzwmlQtJQooQ7kNvwFudJD5&_nc_oc=AdkhVsSTMcpg4jIbknGb-jzAVWP_5oEiSFKIufsKRJvbRfynE01Ju9GTe7nj57TV2do&_nc_zt=14&_nc_ht=scontent-ord5-2.xx&_nc_gid=RdiL-szjRynfzWtkmTo8tg&oh=00_AflyuHKLF9PhZgGco17CIGdmREsg2f1vjd-nJig78LziCg&oe=6951A290>)
*Source: Meta*

**Llama 3.2** is Meta's latest open-source large language model (LLM). The version running on ROSIE is the **90B Vision Instruct** variant, which means:

- **90B**: The model has 90 billion parameters – the "weights" that determine how it processes and generates text. More parameters generally means more capability.
- **Vision**: Unlike text-only models, this version can analyze images and answer questions about visual content.
- **Instruct**: The model has been fine-tuned to follow instructions and have helpful conversations, similar to ChatGPT.

The model runs on ROSIE's DGX H100 nodes, which are equipped with NVIDIA's most powerful AI accelerators. This allows the model to generate responses quickly, even with its massive size.

### Powered by NVIDIA NIM

The Llama 3.2 model on ROSIE is served using **[NVIDIA NIM](https://developer.nvidia.com/nim)** (NVIDIA Inference Microservices). NIM is a set of optimized inference microservices that make it easy to deploy AI models at scale. Key benefits include:

- **Optimized Performance**: NIM automatically applies the best inference optimizations for NVIDIA hardware, ensuring fast response times.
- **OpenAI-Compatible API**: NIM exposes models via an API that follows the OpenAI Chat Completions format, making it easy to use familiar tools and libraries.
- **Production-Ready**: NIM handles all the complexity of model serving, load balancing, and GPU memory management.

This means you get enterprise-grade AI inference without needing to configure complex model serving infrastructure yourself!

---

## Step 1: Setting Up Your ROSIE Environment

First, let's get a Jupyter notebook running on ROSIE. We'll use Open OnDemand (OOD), ROSIE's web portal.

### 1.1 Connect to ROSIE

1. **If you're off-campus**, connect to MSOE's VPN using Global Protect first (see [Global Protect Setup](/library?nav=Articles&article=global-protect))

2. Navigate to ROSIE's Open OnDemand portal: **[https://dh-ood.hpc.msoe.edu](https://dh-ood.hpc.msoe.edu)**

3. Log in with your MSOE credentials

### 1.2 Start a Jupyter Notebook Session

1. From the OOD dashboard, click on **"My Interactive Sessions"** in the top menu

2. Select **"Jupyter Notebook - Containerized"** from the available options

3. Configure your session with these settings:
   - **Number of GPUs**: `0` (we don't need a GPU – the Llama model runs on a separate server)
   - **Time**: `2` hours (adjust based on how long you plan to work)
   - **Container Image**: `Tensorflow 2.x` or `PyTorch` (either works fine for this tutorial)
   - **Job Description**: `AI Club - Llama 3.2 Tutorial`

4. Click **"Launch"** and wait for your session to start (usually less than a minute)

5. Once ready, click **"Connect to Jupyter Notebook"**

### 1.3 Create Your Notebook

1. In the Jupyter file browser, navigate to your preferred working directory (or create an `MAIC` folder if you haven't already)

2. Click **"New"** → **"Python 3 (ipykernel)"** to create a new notebook

3. Rename your notebook to something descriptive like `llama_chatbot.ipynb`

---

## Step 2: Understanding the API

The Llama 3.2 model on ROSIE is served via a REST API that follows the **OpenAI Chat Completions format**. This is great news because:

- It's a widely-used standard, so skills transfer to other AI services
- Many tutorials and libraries support this format
- The interface is simple and intuitive

Here's how communication works:

```
Your Code  →  HTTP POST Request  →  Llama 3.2 Server  →  AI Response
```

The key endpoint is:
```
http://dh-dgxh100-2.hpc.msoe.edu:8001/v1/chat/completions
```

This URL points to a DGX H100 node running the Llama model via NVIDIA NIM. The `/v1/chat/completions` path follows the OpenAI API standard, which NIM implements for compatibility.

---

## Step 3: Your First Chat Request

Let's write some code! In your Jupyter notebook, start with a simple text-only conversation.

### 3.1 Import Required Libraries

```python
import requests
import json

# The Llama 3.2 API endpoint on ROSIE
API_URL = "http://dh-dgxh100-2.hpc.msoe.edu:8001/v1/chat/completions"

# Model identifier
MODEL_NAME = "meta/llama-3.2-90b-vision-instruct"
```

### 3.2 Create a Simple Chat Function

```python
def chat_with_llama(prompt, stream=False):
    """
    Send a message to the Llama 3.2 model and get a response.
    
    Args:
        prompt (str): Your message/question for the AI
        stream (bool): If True, returns response token by token
        
    Returns:
        str: The AI's response
    """
    
    headers = {
        "Authorization": "Bearer $NO_API_KEY_REQUIRED",
        "Accept": "text/event-stream" if stream else "application/json"
    }
    
    payload = {
        "model": MODEL_NAME,
        "messages": [
            {
                "role": "user",
                "content": prompt
            }
        ],
        "max_tokens": 512,
        "temperature": 0.7,
        "top_p": 0.9
    }
    
    response = requests.post(API_URL, headers=headers, json=payload)
    
    if stream:
        # Handle streaming response
        complete_response = ""
        for line in response.iter_lines():
            if line:
                try:
                    decoded = line.decode("utf-8")
                    if decoded.startswith("data: "):
                        json_str = decoded[6:]  # Remove "data: " prefix
                        if json_str.strip() == "[DONE]":
                            break
                        data = json.loads(json_str)
                        content = data['choices'][0]['delta'].get('content', '')
                        complete_response += content
                        print(content, end='', flush=True)  # Real-time output
                except (json.JSONDecodeError, KeyError):
                    pass
        print()  # New line after streaming
        return complete_response
    else:
        # Handle regular response
        result = response.json()
        return result['choices'][0]['message']['content']
```

### 3.3 Test It Out!

```python
# Ask a simple question
response = chat_with_llama("What is machine learning? Explain it in 2-3 sentences.")
print(response)
```

**Example output:**
```
Machine learning is a subset of artificial intelligence where computers learn patterns 
from data without being explicitly programmed. Instead of following hard-coded rules, 
ML algorithms improve their performance over time by analyzing examples and making 
predictions based on what they've learned.
```

### 3.4 Try Streaming Mode

Streaming is useful when you want to see the response as it's being generated, just like ChatGPT:

```python
# Watch the response generate in real-time!
response = chat_with_llama(
    "Write a short poem about coding at midnight.", 
    stream=True
)
```

---

## Step 4: Understanding the Parameters

Let's break down the key parameters you can adjust:

| Parameter | Description | Recommended Value |
|-----------|-------------|-------------------|
| `max_tokens` | Maximum length of the response | 512-2048 |
| `temperature` | Controls randomness (0 = deterministic, 1 = creative) | 0.7 |
| `top_p` | Nucleus sampling threshold | 0.9 |

### Temperature Examples

```python
# Very deterministic/focused response
response = chat_with_llama(
    "What is 2 + 2?",
    temperature=0.1
)

# More creative/varied response
response = chat_with_llama(
    "Write a creative story about a robot.",
    temperature=0.9
)
```

---

## Step 5: Vision Capabilities – Analyzing Images

One of the most exciting features of Llama 3.2 is its ability to understand images! Let's explore this.

### 5.1 Upload an Image

First, upload an image to your ROSIE directory. You can:
- Drag and drop a file into the Jupyter file browser
- Use the Jupyter upload button
- Transfer via command line

For this example, let's say you have an image called `test_image.png` in your notebook directory.

### 5.2 Create a Vision Analysis Function

```python
import base64
from pathlib import Path

def analyze_image(image_path, question="What is in this image?"):
    """
    Send an image to Llama 3.2 for analysis.
    
    Args:
        image_path (str): Path to the image file
        question (str): What you want to know about the image
        
    Returns:
        str: The AI's description/analysis
    """
    
    # Read and encode the image
    with open(image_path, "rb") as f:
        image_data = f.read()
        image_b64 = base64.b64encode(image_data).decode()
    
    # Check image size (API has a limit)
    if len(image_b64) > 180_000:
        raise ValueError("Image too large! Please use a smaller image (< ~135KB).")
    
    # Determine image type from extension
    extension = Path(image_path).suffix.lower().replace('.', '')
    if extension == 'jpg':
        extension = 'jpeg'
    
    headers = {
        "Authorization": "Bearer $NO_API_KEY_REQUIRED",
        "Accept": "application/json"
    }
    
    # Format the message with the image embedded
    payload = {
        "model": MODEL_NAME,
        "messages": [
            {
                "role": "user",
                "content": f'{question} <img src="data:image/{extension};base64,{image_b64}" />'
            }
        ],
        "max_tokens": 1024,
        "temperature": 0.7,
        "top_p": 0.9
    }
    
    response = requests.post(API_URL, headers=headers, json=payload)
    result = response.json()
    
    return result['choices'][0]['message']['content']
```

### 5.3 Analyze an Image

```python
# Analyze an image
description = analyze_image("test_image.png", "Describe this image in detail.")
print(description)

# Ask specific questions about images
answer = analyze_image("chart.png", "What trends do you see in this graph?")
print(answer)
```

---

## Step 6: Building a Conversational Chatbot

The examples so far send single messages. Let's build a true chatbot that remembers conversation history!

### 6.1 Create a Chatbot Class

```python
class LlamaChatbot:
    """A conversational chatbot using Llama 3.2 on ROSIE."""
    
    def __init__(self, system_prompt=None):
        """
        Initialize the chatbot.
        
        Args:
            system_prompt (str): Optional system instructions for the AI
        """
        self.api_url = "http://dh-dgxh100-2.hpc.msoe.edu:8001/v1/chat/completions"
        self.model = "meta/llama-3.2-90b-vision-instruct"
        self.conversation_history = []
        
        # Add system prompt if provided
        if system_prompt:
            self.conversation_history.append({
                "role": "system",
                "content": system_prompt
            })
    
    def chat(self, message, stream=True):
        """
        Send a message and get a response, maintaining conversation history.
        
        Args:
            message (str): Your message
            stream (bool): Whether to stream the response
            
        Returns:
            str: The AI's response
        """
        # Add user message to history
        self.conversation_history.append({
            "role": "user",
            "content": message
        })
        
        headers = {
            "Authorization": "Bearer $NO_API_KEY_REQUIRED",
            "Accept": "text/event-stream" if stream else "application/json"
        }
        
        payload = {
            "model": self.model,
            "messages": self.conversation_history,
            "max_tokens": 1024,
            "temperature": 0.7,
            "top_p": 0.9,
            "stream": stream
        }
        
        response = requests.post(self.api_url, headers=headers, json=payload)
        
        if stream:
            assistant_response = ""
            for line in response.iter_lines():
                if line:
                    try:
                        decoded = line.decode("utf-8")
                        if decoded.startswith("data: "):
                            json_str = decoded[6:]
                            if json_str.strip() == "[DONE]":
                                break
                            data = json.loads(json_str)
                            content = data['choices'][0]['delta'].get('content', '')
                            assistant_response += content
                            print(content, end='', flush=True)
                    except (json.JSONDecodeError, KeyError):
                        pass
            print()
        else:
            result = response.json()
            assistant_response = result['choices'][0]['message']['content']
        
        # Add assistant response to history
        self.conversation_history.append({
            "role": "assistant",
            "content": assistant_response
        })
        
        return assistant_response
    
    def clear_history(self):
        """Clear the conversation history (keeps system prompt if set)."""
        system_prompt = None
        if self.conversation_history and self.conversation_history[0]["role"] == "system":
            system_prompt = self.conversation_history[0]
        self.conversation_history = [system_prompt] if system_prompt else []
        print("Conversation history cleared!")
```

### 6.2 Have a Conversation

```python
# Create a chatbot with a personality
bot = LlamaChatbot(system_prompt="""You are a helpful AI tutor specializing in 
machine learning and programming. You explain concepts clearly and provide 
examples when helpful. Keep responses concise but informative.""")

# Start chatting!
bot.chat("Hi! Can you explain what a neural network is?")
```

```python
# Continue the conversation - the bot remembers context!
bot.chat("How is that different from a traditional algorithm?")
```

```python
# Ask a follow-up
bot.chat("Can you give me a simple Python example?")
```

### 6.3 Interactive Chat Loop

For a more interactive experience:

```python
def interactive_chat():
    """Run an interactive chat session."""
    print("=" * 50)
    print("Welcome to ROSIE's Llama 3.2 Chatbot!")
    print("Type 'quit' to exit, 'clear' to reset history")
    print("=" * 50)
    
    bot = LlamaChatbot(system_prompt="You are a helpful, friendly AI assistant.")
    
    while True:
        user_input = input("\nYou: ").strip()
        
        if user_input.lower() == 'quit':
            print("Goodbye!")
            break
        elif user_input.lower() == 'clear':
            bot.clear_history()
            continue
        elif not user_input:
            continue
            
        print("\nLlama: ", end="")
        bot.chat(user_input, stream=True)

# Run the interactive chat
interactive_chat()
```

---

## Step 7: Best Practices and Tips

### Prompt Engineering Tips

1. **Be specific**: Instead of "Tell me about AI", try "Explain how convolutional neural networks process images, with a simple analogy."

2. **Provide context**: If you're asking about code, include the relevant code snippet.

3. **Use system prompts**: Set up the AI's role and behavior for more consistent responses.

### Error Handling

```python
def safe_chat(prompt, max_retries=3):
    """Chat with automatic retry on errors."""
    for attempt in range(max_retries):
        try:
            return chat_with_llama(prompt)
        except requests.exceptions.RequestException as e:
            print(f"Attempt {attempt + 1} failed: {e}")
            if attempt < max_retries - 1:
                print("Retrying...")
            else:
                return "Sorry, unable to get a response. Please try again later."
```

### Performance Considerations

- **Token limits**: The model has a context window limit. Very long conversations may need history trimming.
- **Response time**: Expect 2-10 seconds for responses depending on length.
- **Concurrent users**: During peak times, response times may increase.

---

## What's Next?

Congratulations! You've learned how to:
- ✅ Set up a Jupyter environment on ROSIE
- ✅ Send prompts to Llama 3.2 and receive responses
- ✅ Handle streaming for real-time output
- ✅ Analyze images using vision capabilities
- ✅ Build a conversational chatbot with memory

In **Part 2**, we'll take things further by:
- Building a web interface for your chatbot
- Adding RAG (Retrieval-Augmented Generation) for custom knowledge bases
- Fine-tuning responses for specific use cases
- Deploying your chatbot as a web application

---

## Complete Code Reference

Here's the full code from this tutorial in one place:

```python
import requests
import json
import base64
from pathlib import Path

# Configuration
API_URL = "http://dh-dgxh100-2.hpc.msoe.edu:8001/v1/chat/completions"
MODEL_NAME = "meta/llama-3.2-90b-vision-instruct"

def chat_with_llama(prompt, stream=False, temperature=0.7, max_tokens=512):
    """Send a message to Llama 3.2 and get a response."""
    headers = {
        "Authorization": "Bearer $NO_API_KEY_REQUIRED",
        "Accept": "text/event-stream" if stream else "application/json"
    }
    
    payload = {
        "model": MODEL_NAME,
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": max_tokens,
        "temperature": temperature,
        "top_p": 0.9,
        "stream": stream
    }
    
    response = requests.post(API_URL, headers=headers, json=payload)
    
    if stream:
        complete_response = ""
        for line in response.iter_lines():
            if line:
                try:
                    decoded = line.decode("utf-8")
                    if decoded.startswith("data: "):
                        json_str = decoded[6:]
                        if json_str.strip() == "[DONE]":
                            break
                        data = json.loads(json_str)
                        content = data['choices'][0]['delta'].get('content', '')
                        complete_response += content
                        print(content, end='', flush=True)
                except (json.JSONDecodeError, KeyError):
                    pass
        print()
        return complete_response
    else:
        return response.json()['choices'][0]['message']['content']

def analyze_image(image_path, question="What is in this image?"):
    """Analyze an image using Llama 3.2's vision capabilities."""
    with open(image_path, "rb") as f:
        image_b64 = base64.b64encode(f.read()).decode()
    
    if len(image_b64) > 180_000:
        raise ValueError("Image too large!")
    
    extension = Path(image_path).suffix.lower().replace('.', '')
    if extension == 'jpg':
        extension = 'jpeg'
    
    headers = {
        "Authorization": "Bearer $NO_API_KEY_REQUIRED",
        "Accept": "application/json"
    }
    
    payload = {
        "model": MODEL_NAME,
        "messages": [{
            "role": "user",
            "content": f'{question} <img src="data:image/{extension};base64,{image_b64}" />'
        }],
        "max_tokens": 1024,
        "temperature": 0.7,
        "top_p": 0.9
    }
    
    response = requests.post(API_URL, headers=headers, json=payload)
    return response.json()['choices'][0]['message']['content']

# Example usage
if __name__ == "__main__":
    # Text chat
    print(chat_with_llama("Hello! What can you help me with today?"))
    
    # Streaming chat
    chat_with_llama("Tell me a fun fact about AI.", stream=True)
```

---

## Troubleshooting

**"Connection refused" error**
- Make sure you're connected to MSOE's network (either on campus or via Global Protect VPN)

**"Model not found" error**
- The model server may be temporarily down. Try again in a few minutes or contact MAIC for status updates.

**Slow responses**
- The model is shared among all users. Peak times (afternoon/evening) may have longer wait times.

**Image too large**
- Resize your image to under 135KB before encoding, or use image compression.

---

## Resources

- [ROSIE Documentation](https://docs.hpc.msoe.edu)
- [Llama 3.2 Model Card](hhttps://ai.meta.com/blog/llama-3-2-connect-2024-vision-edge-mobile-devices/)
- [NVIDIA NIM Documentation](https://developer.nvidia.com/nim) - Learn more about the inference platform powering this model
- [OpenAI API Documentation](https://platform.openai.com/docs/api-reference/chat) (same format as NIM API)

Happy coding! 🦙🤖

