<br>
<a href='/learning-tree?node=82' style='
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
This article explains how branching and merging work in Git and GitHub, showing how to safely make changes, test new features, and combine work back into the main project.
</p>

</div>

<br/>

<br/>

## Branching and Merging
Branching lets you work on a separate version of your project without changing the main code. It's useful for testing new features, fixing bugs, or experimenting. Then you can merge the changes back into the main branch when you're ready.

## What is a Branch?
A branch is like a copy of your project where you can safely make changes. By default, every Git repository starts with a branch called `main` (or sometimes `master`).

When you create a new branch, you can:
- Work independently from the main code
- Try new things without risk
- Switch between branches as needed

## Creating a New Branch
`git checkout -b feature/my-new-idea`

This creates and switches to a new branch called `feature/my-new-idea`.

To switch between branches:

`git checkout main`

To see all branches:

`git branch`

## Merging a Branch
When you're done with your changes and want to add them back to main:
1. Switch to the main branch

    `git checkout main `

2. Merge your feature branch into main:

    `git merge feature/my-new-idea `

This brings in all the changes from your feature branch into `main`.

## Merge Conflicts
Sometimes Git can't automatically combine changes. This is called a merge conflict.

Git will tell you which files have conflicts. You'll need to:

1. Open the file and choose which changes to keep
2. Save the file
3. Add and commit the resolved file

    ```
    git add conflicted-file.txt
    git commit -m "Resolve merge conflict"
    ```

## Summary
- Branching helps you work in parallel without breaking the main code
- Merging combines changes from one branch into another
- Use branches to organize your work and collaborate more safely

## Conclusion
Branching and merging are key to working efficiently with Git. They let you develop features, fix bugs, and collaborate without interfering with the main codebase. By using branches properly and resolving merge conflicts when they arise, you can keep your projects organized and your workflow smooth.