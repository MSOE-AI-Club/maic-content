# Pushing and Pulling in GitHub
Date: 6/13/2025 

Author: Madison Engebose

This article explains how to use `git push` and `git pull` to sync changes between your local Git repository and GitHub, helping you share updates and stay in sync with your team.

## Pushing and Pulling Changes
Once you've made commits in your local Git repository, you'll often want to share your work or get updates from others. That's where pushing and pulling comes in.

GitHub acts as the remote version of your repo, and Git helps you sync between your local and remote copies.

## What is `git push`?
Push = Send your local commits to GitHub.

`git push origin main`

This tells Git:
- `push` 
    - upload changes
- `origin`
    - the name of the remote repo
- `main`
    - the branch you're pushing to

## First Time Pushing Changes?
You might need:

`git push -u origin main`

The `-u` flag links your local `main` to the remote `main` so future pushes can just be:
`git push`

## What is `git pull`?
Pull = Get the latest commits from GitHub and merge them into your local branch.

`git pull origin main`

This tells Git:
- `pull`
    - download and merge changes
- `origin`
    - the remote repo
- `main`
    - the branch you want updates from

## When to Push and Pull

`git push`

- After you make local commits you want to share

`git pull`

- Before you start working or when collaborating

Pull before pushing to avoid conflicts.

## Common Issues
- Authentication erros
    - Make sure you're logged into GitHub and using the correct HTTPS or SSH URL.
- Merge Conflicts
    - If someone else changed the same lines of code, you’ll need to resolve them before pushing.

## Summary
- `git push` sends your changes to GitHub
- `git pull` gets the latest changes from GitHub
- Use both regulary to keep your work and your team in sync

## Conclusion
Pushing and pulling are essential parts of using Git and GitHub effectively. Pushing lets you share your work while pulling ensures you are working with the latest changes. By using these commands regularly and in the right order you will avoid conflicts and keep your project up to date.