# Committing Changes in GitHub
Date: 6/13/2025 

Author: Madison Engebose

This article explains what a commit is, how to make one using Git, and why writing clear, meaningful commit messages is important for tracking changes and collaborating effectively.

## What is a Commit?
A commit is like a snapshot of your project at a specific point in time. It captures the changes you've made to files in your Git repository so you can track progress, go back to earlier versions, and collaborate with others.

Every commit:
- has a message describing the change
- has a unique ID so Git can reference it
- is saved in your project's history

Think of it like hitting "save" in a video game, you're locking in your progess at that moment.

## How to Make a Commit
1. Make changes to your files
2. Stage the changes
    This tells Git which changes you want to include in the next commit.

    `git add filename.txt`

    Or add everything
    
    `git add .`
3. Create the commit
    
    `git commit -m "Short message explaining the change"`
    
    Example:

    `git commit -m "Added login button to homepage`

## Tips for Writing Good Commit Messages
- Be clear and concise
- Describe what changed and why if needed

    Good:

    `git commit -m "Fix typo in README"`

    Bad:

    `git commit -m "stuff"`

## Why Commits Matter
- They let you track your progress
- You can undo mistakes by going back to a previous commit
- They help your team understand what changed and why

## Conclusion
Commits are the foundation of version control in Git. They allow you to save progress, keep your code history organized, and collaborate with confidence. By making commits regularly and writing clear messages, you make your project easier to understand, maintain, and improve over time.