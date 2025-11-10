<br>
<a href='/learning-tree?node=80' style='
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
This article explains what a commit is, how to make one using Git, and why writing clear, meaningful commit messages is important for tracking changes and collaborating effectively.
</p>

</div>

<br/>

<br/>

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