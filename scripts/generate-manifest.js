#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function globToRegex(glob) {
  let regexString = glob
    .replace(/[.+?^${}()|[\]\\]/g, '\\$&')
    .replace(/\*/g, '.*');
  return new RegExp('^' + regexString + '$');
}

console.log('🔍 Generating manifest.json...');

let ignorePatterns = [];
try {
  const ignoreContent = fs.readFileSync('.manifestignore', 'utf8');
  const patterns = ignoreContent.split(/\r?\n/).filter(line => line.trim() !== '' && !line.startsWith('#'));
  ignorePatterns = patterns.map(globToRegex);
  console.log('📋 Loaded ignore patterns:', patterns);
} catch (err) {
  if (err.code !== 'ENOENT') {
    console.error("❌ Error reading .manifestignore:", err);
  } else {
    console.log('📋 No .manifestignore file found, including all files');
  }
}

function walkDir(dir, baseDir = dir) {
  const files = fs.readdirSync(dir, { withFileTypes: true });
  return files.flatMap(file => {
    const fullPath = path.join(dir, file.name);
    const relativePath = path.relative(baseDir, fullPath).replace(/\\/g, '/');

    const isIgnored = ignorePatterns.some(regex => {
      const matches = regex.test(relativePath);
      if (matches) {
        console.log(`🚫 Ignoring: ${relativePath}`);
      }
      return matches;
    });

    if (isIgnored) {
      return [];
    }

    if (file.isDirectory()) {
      return walkDir(fullPath, baseDir);
    } else {
      console.log(`📄 Including: ${relativePath}`);
      return [relativePath];
    }
  });
}

try {
  const fileList = walkDir('.');
  const manifest = { 
    generated_at: new Date().toISOString(), 
    files: fileList,
    cdn_base_url: "https://msoe-ai-club.github.io/maic-content/",
    version: "1.0.0",
    total_files: fileList.length,
    categories: {
      articles: fileList.filter(f => f.startsWith('articles/')).length,
      images: fileList.filter(f => f.startsWith('images/')).length,
      data: fileList.filter(f => f.startsWith('data/')).length
    }
  };
  
  fs.writeFileSync('manifest.json', JSON.stringify(manifest, null, 2));
  console.log(`✅ Generated manifest.json with ${fileList.length} files`);
  console.log(`📊 Categories: ${manifest.categories.articles} articles, ${manifest.categories.images} images, ${manifest.categories.data} data files`);
} catch (error) {
  console.error('❌ Error generating manifest:', error);
  process.exit(1);
} 