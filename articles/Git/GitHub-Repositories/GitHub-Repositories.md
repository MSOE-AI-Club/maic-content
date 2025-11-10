<br>
<a href='/learning-tree?node=79' style='
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

<p style='color: white; margin-top: 2px;'>
This article explains what a GitHub repository is and walks through how to create, connect, and manage both local and remote repositories to track and share your projects.
</p>

</div>

<br/>

<br/>

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