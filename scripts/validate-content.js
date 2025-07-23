#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('🔍 Validating content structure...');

let errors = [];
let warnings = [];

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
  try {
    const manifest = JSON.parse(fs.readFileSync('manifest.json', 'utf8'));
    console.log(`✅ manifest.json is valid JSON with ${manifest.files?.length || 0} files`);
    
    // Validate manifest structure
    if (!manifest.generated_at) warnings.push('manifest.json missing generated_at field');
    if (!manifest.files) errors.push('manifest.json missing files array');
    if (!manifest.cdn_base_url) warnings.push('manifest.json missing cdn_base_url field');
    
  } catch (err) {
    errors.push(`manifest.json is invalid JSON: ${err.message}`);
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

// Check index.html exists
if (!fs.existsSync('index.html')) {
  errors.push('Missing index.html - CDN landing page not found');
} else {
  console.log('✅ index.html exists');
}

// Summary
console.log('\n📋 Validation Summary:');
console.log(`✅ ${errors.length === 0 ? 'No errors found' : `${errors.length} error(s) found`}`);
console.log(`⚠️  ${warnings.length === 0 ? 'No warnings' : `${warnings.length} warning(s)`}`);

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