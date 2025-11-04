<br>
<a href='/learning-tree?node=83' style='
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
This article outlines key best practices for using Git and GitHub effectively, including how to write meaningful commits, use branches, avoid common mistakes, and keep your codebase clean and secure.
</p>

</div>

<br/>

<br/>

## Best Practices
Using Git isn't just about learning the commands, it's also about using them well. Following best practices helps keep your code organized, understandable, and safe, especially when working on a team.

## Commit Often, But Meaningfully
Don't wait too long to commit your changes. Frequent commits help brak down your work into manageable chunks and make it easier to review or undo mistakes. 

Good:

`git commit -m "Add search bar component"`

Bad:

`git commit -m "fixed stuff"`

## Write Clear, Descriptive Commit Messages
Your commit messages should explain what you changed and, if helpful, why. This makes the history readable for both you and your team.

Format tip:

`<verb> <what changed> - optional explanation`

Example:

`Fix broken image link on homepage`

### Use Branches for Features or Fixes
Keep your main branch clean and production-ready by doing your work in separate branches.

`git checkout -b feature/signup-form`

When the work is complete, merge it back into `main`.

## Pull Before You Push
Always run `git pull` before pushing your changes to avoid conflicts and make sure your local copy is up to date.

`git pull origin main`

## Don't Commit Secrets or Large Files
Never commit:
- API keys
- Passwords
- `.env` files
- Huge datasets or binaries

Use a `.gitignore` file to prevent these from being tracked.

## Keep You `.gitignore` File Up-to-Date
Add files or folders you don't want Git to track.

## Conclusion
Following Git best practices helps you write cleaner code, collaborate more smoothly, and avoid headaches down the line. Whether you're working solo or with a team, habits like committing often, using branches, and avoiding sensitive files will make your workflow more efficient and professional.