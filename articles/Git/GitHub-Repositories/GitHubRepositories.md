# GitHub Repositories
Date: 6/13/2025 

Author: Madison Engebose

This article explains what a GitHub repository is and walks through how to create, connect, and manage both local and remote repositories to track and share your projects.

## Creating and Managing Repositories
A repository (often shortened to 'repo') is a folder that Git tracks. It stores all the files for a project along with a complete history of every change ever made. Repos can live locall on your computer or remotely ona site like GitHub.

## What's in a Repository?
- Your project files
    - code, documents, images, etc.
- A `.git` folder
    - contains Git's verison history and configuration (created automatically)
- Optionally a `.gitignore` file
    - tells Git which files to ignore
- A README.md file
    - explains what your project is about

## Creating a Local Repository
1. Open a GitBash terminal or command prompt
2. Navigate to your prject folder:
`cd path/to/your/folder`
3. Initialize Git in the folder:
`git init`
4. Start tracking files

## Creating a Repository on GitHub
1. Go to [github.com](https://github.com)
2. Click the + icon in the top right corner
    - Choose new repository
3. Fill in:
    - Repository name
    - Optional description
    - Public or private
    - Optionally initialize with a README
4. Click Create Repository

## Connecting Your Local Repo to GitHub
Once you've created a GitHub repo, link your local one to it:
```
git remote add origin https://github.com/your-username/repo-name.git
git push -u origin main
```
This pushes your local code to GutHub. The `-u` flag sets "origin" as the default remote so future pushes can just be `git push`.

## Conclusion
Repositories are the foundation of working with Git and GitHub. They store your project files and track every change you make. By learning how to create and connect local and remote repositories, you set yourself up to manage your work efficiently and collaborate with others more effectively.