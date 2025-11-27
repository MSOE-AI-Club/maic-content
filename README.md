# MAIC Content CDN 🧠

Milwaukee AI Club's Educational Content Delivery Network - A fast, reliable CDN for accessing educational AI/ML content, articles, and resources.

## 🌐 Live CDN

**Base URL**: `https://msoe-ai-club.github.io/maic-content/`

## 📡 API Endpoints

### Content Manifest

```
GET /manifest.json
GET /api/manifest.json  (alternative endpoint)
```

Returns a JSON manifest with all available files, metadata, and CDN information.

### Articles

```
GET /articles/{category}/{filename}.md
```

Access educational articles organized by category:

- Basic AI
- Computer Vision
- Natural Language Processing (NLP)
- Supervised Learning
- Unsupervised Learning
- Reinforcement Learning
- Rosie (MSOE's HPC cluster)
- Research papers and presentations

### Images & Assets

```
GET /images/{category}/{filename}.{ext}
```

Thumbnails, diagrams, logos, and visual resources.

### Data Files

```
GET /data/{category}/{filename}.json
```

Structured data including configurations, achievements, contact info, and datasets.

## 🚀 Usage Examples

### JavaScript/TypeScript

```javascript
// Fetch content manifest
const response = await fetch(
  "https://msoe-ai-club.github.io/maic-content/manifest.json"
);
const manifest = await response.json();
console.log("Available files:", manifest.files);

// Load a specific article
const article = await fetch(
  "https://msoe-ai-club.github.io/maic-content/articles/Basic AI/001_What_is_the_Learning_Tree.md"
);
const content = await article.text();

// Display an image
const imageUrl =
  "https://msoe-ai-club.github.io/maic-content/images/thumbnails/ai_basics.png";
document.getElementById("myImage").src = imageUrl;
```

### Python

```python
import requests

# Get manifest
response = requests.get('https://msoe-ai-club.github.io/maic-content/manifest.json')
manifest = response.json()

# Download article
article = requests.get('https://msoe-ai-club.github.io/maic-content/articles/Basic AI/003_What_is_AI.md')
content = article.text
```

### MATLAB

```matlab
% MATLAB has built-in web utilities that make it easy to fetch JSON and
% simple files. MATLAB is popular in engineering and numerical computing
% and is a good alternative where matrix computing and engineering toolboxes
% are helpful.

% Get manifest
options = weboptions('ContentType', 'json'); % Ensure JSON is decoded to struct
manifest = webread('https://msoe-ai-club.github.io/maic-content/manifest.json', options);

% Download article text (Markdown)
articleUrl = 'https://msoe-ai-club.github.io/maic-content/articles/Basic AI/003-what-is-ai/003_What_is_AI.md';
mdText = webread(articleUrl);
mdText = convertStringsToChars(mdText); % Ensure it's a char vector
disp(mdText(1:300)); % show first 300 characters
```

### cURL

```bash
# Get manifest
curl https://msoe-ai-club.github.io/maic-content/manifest.json

# Download specific file
curl https://msoe-ai-club.github.io/maic-content/articles/Computer Vision/001_comp-vis.md
```

## ✨ Features

- **CORS Enabled**: Cross-origin requests supported for web applications
- **Fast Global CDN**: Powered by GitHub Pages with global edge locations
- **Auto-updating**: Content automatically indexed and deployed on push
- **RESTful API**: Clean, predictable URL structure
- **Organized Content**: Logical folder structure for easy navigation
- **Caching Optimized**: Proper cache headers for performance

## 🏗️ Development

### Local Setup

```bash
git clone https://github.com/MSOE-AI-Club/maic-content.git
cd maic-content
npm install
```

### Local Development

#### Starts the local content server/CDN

```bash
npm run dev
```

### Content Structure

```
├── articles/           # Educational articles and tutorials
├── data/              # JSON data files and configurations
├── images/            # Visual assets and thumbnails
├── manifest.json      # Auto-generated file index
└── index.html         # CDN documentation page
```

### Adding Content

1. Add your content files to the appropriate directory
2. Push to main branch
3. GitHub Actions will automatically:
   - Generate updated manifest.json
   - Deploy to GitHub Pages CDN
   - Make content available globally

## 🤖 Automation

The CDN is fully automated using GitHub Actions:

- **Manifest Generation**: Automatically catalogs all content files
- **GitHub Pages Deploy**: Builds and deploys on every push
- **CORS Configuration**: Sets proper headers for API usage

## 📝 License

MIT License - See LICENSE file for details.

## 🎓 Milwaukee School of Engineering AI Club

Learn more about MAIC at [our website](https://msoe-ai-club.github.io/maic-website/)
