## Working with Jupyer notebooks

The simplest way to start up a jupyter notebook is to open up an anaconda session. You can get anaconda [here].(https://www.anaconda.com/download)
Once downloaded, simply find the Jupyter notebook tab and click launch on the jupyter notebook card. You will be broyght to a similar looking screen like the one below.
![Alt text](<./images/misc/Screenshot 2023-08-28 204717.png>)

## Making a Jupyter Directory and your first Notebook

I recomend clicking "New" and then "Folder". Then renaming the untitled folder to Jupyter. Then enter the folder, and click new again, this time selecting "Python 3(ipykernel)". This will make you your first notebook!

---

## MATLAB users: Live Scripts and Running MATLAB in Jupyter

If you primarily use MATLAB, two good options exist for interactive development:

1. MATLAB Live Scripts (`.mlx`) — MATLAB's built-in interactive notebooks. They support mixing narrative text with code and are excellent for engineering workflows. Open `.mlx` files using MATLAB's Live Editor.
2. Use the MATLAB Jupyter kernel — this lets you run MATLAB code inside Jupyter notebooks if you prefer a Jupyter-style interface.

MATLAB Live Scripts are recommended for most MATLAB-first users — they are well-integrated with toolboxes like the Deep Learning Toolbox and are easiest to use for signal processing or control tasks.

## How are notebooks different than normal code?

Each piece of code within each cell, will execute without executing any other code. This allows you to "mess around" and experiment with code that you know is flawed. Without jupyter notebooks, every time you fixed a small error anywhere in your code, we would have to re-run the whole entire file! When we are dealing with large data-sets, this could cost us hours!

## Common Juypter Notebook Commands

- `Shift + Enter` - Run the cell and move to the next cell
- `Ctrl + Enter` - Run the cell and stay on the same cell
- `Alt + Enter` - Run the cell and make a new cell below it
- `Ctrl + S` - Save the notebook
- `Ctrl + Z` - Undo
- `Ctrl + Y` - Redo
- `Ctrl + Shift + -` - Split the cell at the cursor
- `Ctrl + Shift + P` - Open the command palette
- `Ctrl + Shift + F` - Open the search box
- `Ctrl + Shift + P` - Open the command palette
