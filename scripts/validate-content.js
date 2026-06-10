#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('🔍 Validating content structure...');

let errors = [];
let warnings = [];
let manifestFiles = null;

function readJson(filePath, label) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (err) {
    errors.push(`${label} is invalid JSON: ${err.message}`);
    return null;
  }
}

function isNonEmptyString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

function addMissingFileError(projectId, fieldName, relativePath) {
  errors.push(`Project "${projectId}" ${fieldName} references missing file: ${relativePath}`);
}

function validateProjectAsset(projectId, projectDir, fieldName, relativePath) {
  if (!isNonEmptyString(relativePath)) {
    errors.push(`Project "${projectId}" ${fieldName} must be a non-empty string`);
    return;
  }

  if (/^[a-zA-Z][a-zA-Z\d+\-.]*:/.test(relativePath) || relativePath.startsWith('/')) {
    return;
  }

  const normalizedPath = relativePath.replace(/^\.\//, '');
  const fullPath = path.join(projectDir, normalizedPath);
  if (!fs.existsSync(fullPath)) {
    addMissingFileError(projectId, fieldName, normalizedPath);
  }
}

function validateProjectMetadata(projectId) {
  const projectDir = path.join('projects', projectId);
  const metadataPath = path.join(projectDir, 'metadata.json');

  if (!fs.existsSync(projectDir)) {
    errors.push(`Project "${projectId}" is listed in projects/projects.json but folder is missing`);
    return;
  }

  if (!fs.existsSync(metadataPath)) {
    errors.push(`Project "${projectId}" is missing metadata.json`);
    return;
  }

  const metadata = readJson(metadataPath, `Project "${projectId}" metadata.json`);
  if (!metadata) return;

  ['title', 'members', 'description', 'date', 'type', 'content'].forEach(field => {
    if (!isNonEmptyString(metadata[field])) {
      errors.push(`Project "${projectId}" metadata.${field} must be a non-empty string`);
    }
  });

  if (!Array.isArray(metadata.tags) && !isNonEmptyString(metadata.tags)) {
    errors.push(`Project "${projectId}" metadata.tags must be an array or non-empty string`);
  }

  if (Array.isArray(metadata.tags)) {
    metadata.tags.forEach((tag, index) => {
      if (!isNonEmptyString(tag)) {
        errors.push(`Project "${projectId}" metadata.tags[${index}] must be a non-empty string`);
      }
    });
  }

  if (metadata.thumbnail) {
    if (typeof metadata.thumbnail === 'string') {
      validateProjectAsset(projectId, projectDir, 'thumbnail', metadata.thumbnail);
    } else if (typeof metadata.thumbnail === 'object') {
      const thumbnailPath = metadata.thumbnail.path || (metadata.thumbnail.filename ? `images/${metadata.thumbnail.filename}` : '');
      validateProjectAsset(projectId, projectDir, 'thumbnail', thumbnailPath);
    } else {
      errors.push(`Project "${projectId}" metadata.thumbnail must be a string or object`);
    }
  }

  if (metadata.images !== undefined) {
    if (!Array.isArray(metadata.images)) {
      errors.push(`Project "${projectId}" metadata.images must be an array when present`);
    } else {
      metadata.images.forEach((image, index) => {
        if (!image || typeof image !== 'object') {
          errors.push(`Project "${projectId}" metadata.images[${index}] must be an object`);
          return;
        }

        if (!isNonEmptyString(image.filename)) {
          errors.push(`Project "${projectId}" metadata.images[${index}].filename must be a non-empty string`);
          return;
        }

        if (!isNonEmptyString(image.mimeType)) {
          warnings.push(`Project "${projectId}" metadata.images[${index}].mimeType is missing`);
        }

        validateProjectAsset(projectId, projectDir, `images[${index}]`, path.join('images', image.filename));
      });
    }
  }

  if (isNonEmptyString(metadata.content)) {
    const markdownImagePattern = /!\[[^\]]*\]\(([^)]+)\)/g;
    let match;
    while ((match = markdownImagePattern.exec(metadata.content)) !== null) {
      validateProjectAsset(projectId, projectDir, 'content image', match[1]);
    }
  }

  if (manifestFiles) {
    const expectedPaths = [
      'projects/projects.json',
      metadataPath.replace(/\\/g, '/')
    ];

    if (metadata.images && Array.isArray(metadata.images)) {
      metadata.images.forEach(image => {
        if (image && isNonEmptyString(image.filename)) {
          expectedPaths.push(path.join(projectDir, 'images', image.filename).replace(/\\/g, '/'));
        }
      });
    }

    expectedPaths.forEach(expectedPath => {
      if (!manifestFiles.has(expectedPath)) {
        errors.push(`manifest.json missing project file: ${expectedPath}`);
      }
    });
  }
}

function validateProjects() {
  const projectsIndexPath = path.join('projects', 'projects.json');

  if (!fs.existsSync('projects')) {
    warnings.push('projects directory does not exist');
    return;
  }

  if (!fs.existsSync(projectsIndexPath)) {
    errors.push('Missing projects/projects.json');
    return;
  }

  const projectsIndex = readJson(projectsIndexPath, 'projects/projects.json');
  if (!projectsIndex) return;

  if (!Array.isArray(projectsIndex.projects)) {
    errors.push('projects/projects.json must contain a projects array');
    return;
  }

  const seenProjectIds = new Set();
  projectsIndex.projects.forEach((projectId, index) => {
    if (!isNonEmptyString(projectId)) {
      errors.push(`projects/projects.json projects[${index}] must be a non-empty string`);
      return;
    }

    if (seenProjectIds.has(projectId)) {
      errors.push(`Duplicate project id in projects/projects.json: ${projectId}`);
      return;
    }

    seenProjectIds.add(projectId);
    validateProjectMetadata(projectId);
  });

  console.log(`✅ projects/projects.json references ${projectsIndex.projects.length} project(s)`);
}

// Check if required directories exist
const requiredDirs = ['articles', 'data', 'images'];
requiredDirs.forEach(dir => {
  if (!fs.existsSync(dir)) {
    errors.push(`Missing required directory: ${dir}`);
  } else {
    console.log(`✅ Directory exists: ${dir}`);
  }
});

// Check if manifest.json exists and is valid
if (fs.existsSync('manifest.json')) {
  const manifest = readJson('manifest.json', 'manifest.json');
  if (manifest) {
    console.log(`✅ manifest.json is valid JSON with ${manifest.files?.length || 0} files`);
    
    // Validate manifest structure
    if (!manifest.generated_at) warnings.push('manifest.json missing generated_at field');
    if (!manifest.files) errors.push('manifest.json missing files array');
    if (!manifest.cdn_base_url) warnings.push('manifest.json missing cdn_base_url field');

    if (Array.isArray(manifest.files)) {
      manifestFiles = new Set(manifest.files);
    }
  }
} else {
  warnings.push('manifest.json does not exist - run "npm run build" to generate');
}

// Check for common file naming issues
function validateDirectory(dirPath) {
  if (!fs.existsSync(dirPath)) return;
  
  const files = fs.readdirSync(dirPath, { withFileTypes: true });
  files.forEach(file => {
    const fullPath = path.join(dirPath, file.name);
    
    if (file.isDirectory()) {
      validateDirectory(fullPath);
    } else {
      // Check for spaces in filenames (can cause URL issues)
      if (file.name.includes(' ')) {
        warnings.push(`File has spaces in name: ${fullPath} (consider using underscores or hyphens)`);
      }
      
      // Check for unusual characters
      if (!/^[a-zA-Z0-9._\-\s]+$/.test(file.name)) {
        warnings.push(`File has special characters: ${fullPath}`);
      }
    }
  });
}

requiredDirs.forEach(validateDirectory);
validateDirectory('projects');
validateProjects();

// Check index.html exists
if (!fs.existsSync('index.html')) {
  errors.push('Missing index.html - CDN landing page not found');
} else {
  console.log('✅ index.html exists');
}

// Summary
console.log('\n📋 Validation Summary:');
console.log(`${errors.length === 0 ? '✅ No errors found' : `❌ ${errors.length} error(s) found`}`);
console.log(`${warnings.length === 0 ? '✅ No warnings' : `⚠️  ${warnings.length} warning(s)`}`);

if (errors.length > 0) {
  console.log('\n❌ Errors:');
  errors.forEach(error => console.log(`  - ${error}`));
}

if (warnings.length > 0) {
  console.log('\n⚠️  Warnings:');
  warnings.forEach(warning => console.log(`  - ${warning}`));
}

if (errors.length > 0) {
  console.log('\n🚨 Validation failed - please fix errors before deployment');
  process.exit(1);
} else {
  console.log('\n🎉 Content validation passed!');
} 