<br>
<a href='/learning-tree?node=78' style='
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
This article covers essential Git commands every beginner should know, including how to create a repository, track changes, collaborate using branches, and sync with GitHub.
</p>

</div>

<br/>

<br/>

## Why Read?
Git has a lot of commands, but you don't need to learn them all at once. Here are the most commonly used ones that will help you create, track, and share your work with confidence.

## Check the Status of Your Repo
`git status`

Shows which files have been changes, added, or deleted, and what's staged for the next commit.

## Initialize a Git Repository
`git init`

Starts tracking your folder with Git by creating a hidden `.git` directory.

## Clone a remote repository
`git clone https://github.com/user/repo.git`

Copies an entire GitHub repository to your local machine. 

## Stage Changes for Commit
`git add filename.txt`

Stages one file. Or stage everything.

`git add .`

## Save Changes With a Commit
`git commit -m "Your message here"`

Creates a snapshot of the stages changes with a message describing what you did.

## Push Changes to GitHub
`git push origin branch-name`

Sends your commits to the remote repository.

## Pull the Latest Changes
`git pull origin branch-name`

Gets the newest commits from GitHub and updates your local branch.

## Create a New Branch
`git checkout -b new-branch-name`

Creates and switches to a new branch.

## Merge a Branch
``` 
git checkout main
git merge branch-name
```

Combines the work from a feature branch into your main branch.

## Conclusion
Learning these basic Git commands gives you the tools to manage your projects, track your progress, and collaborate with others more effectively. Mastering them will build a strong foundation for using Git in real-world development.