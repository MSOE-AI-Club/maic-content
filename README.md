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

### Projects
```
GET /projects/projects.json
GET /projects/{project-id}/metadata.json
GET /projects/{project-id}/images/{filename}.{ext}
```
Student project write-ups for the website Projects page. The index file lists project folder IDs, and each project folder contains a `metadata.json` document plus any referenced images.

## 🚀 Usage Examples

### JavaScript/TypeScript
```javascript
// Fetch content manifest
const response = await fetch('https://msoe-ai-club.github.io/maic-content/manifest.json');
const manifest = await response.json();
console.log('Available files:', manifest.files);

// Load a specific article
const article = await fetch('https://msoe-ai-club.github.io/maic-content/articles/Basic AI/001_What_is_the_Learning_Tree.md');
const content = await article.text();

// Display an image
const imageUrl = 'https://msoe-ai-club.github.io/maic-content/images/thumbnails/ai_basics.png';
document.getElementById('myImage').src = imageUrl;
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
├── projects/          # Student project metadata and assets
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

### Adding Projects
Projects use the same CDN file-serving pattern as articles, data, and images, but the website loads them through an explicit index:

```
projects/
├── projects.json
└── {project-id}/
    ├── metadata.json
    └── images/
        └── thumbnail.png
```

`projects/projects.json` lists project IDs:

```json
{
  "projects": ["needham_2026"]
}
```

Each `metadata.json` follows the website `ProjectDocument` contract:

```json
{
  "title": "Project title",
  "members": "Member One, Member Two",
  "description": "Short gallery summary.",
  "date": "2026-03-27",
  "tags": ["AI", "Robotics"],
  "projectTerm": "Spring",
  "projectYear": "2026",
  "projectCategory": "Innovation Lab",
  "sponsor": "Sponsor name",
  "aiCategory": ["Vision", "NLP"],
  "type": "Project",
  "thumbnail": {
    "filename": "thumbnail.png",
    "mimeType": "image/png",
    "path": "images/thumbnail.png"
  },
  "content": "## Overview\n\nMarkdown body with ![images](images/example.png).",
  "images": [
    {
      "filename": "thumbnail.png",
      "mimeType": "image/png"
    }
  ]
}
```

To publish a project exported from the website Project Editor:

1. Unzip the exported package.
2. Create `projects/{project-id}/`.
3. Move `metadata.json` and `images/` into that folder.
4. Append `{project-id}` to `projects/projects.json`.
5. Run `npm run build` to regenerate `manifest.json`.
6. Run `npm run validate` to confirm metadata and image references.

## 🤖 Automation

The CDN is fully automated using GitHub Actions:
- **Manifest Generation**: Automatically catalogs all content files
- **GitHub Pages Deploy**: Builds and deploys on every push
- **CORS Configuration**: Sets proper headers for API usage

## 📝 License

MIT License - See LICENSE file for details.

## 🎓 Milwaukee School of Engineering AI Club

Learn more about MAIC at [our website](https://msoe-ai-club.github.io/maic-website/)