<br>
<a href='/learning-tree?node=18' style='
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

<p style='color: white; margin-top: 2px;'>You may already be familiar with the Rosie Dashboard, but it's also possible to connect to Rosie with a command line. In fact, sometimes it's easier or necessary to do so. The terminal is your friend if: the Rosie dashboard is down, you have to reset your password, or you want to quickly make a change without navigating through the dashboard or starting a job. Furthermore, connecting to Rosie from VSCode gives you all the benefits of VSCode with all the computing power of Rosie!</p>

</div>

<br/>

<br/>

## Setting up SSH Config for Easier Connections
You can set up an SSH config file to make connecting to Rosie easier in the future. First, open (or create) the config file located at `~/.ssh/config` on your local machine. Then, add the following lines:

```
Host ROSIE
    HostName dh-mgmt2.hpc.msoe.edu
    User your_username@ad.msoe.edu

# Use ProxyJump to connect to compute nodes through the login node
Host dh-node*
    HostName %h
    User your_username@ad.msoe.edu
    ProxyJump ROSIE
```

Replace `your_username` with your actual MSOE username. Now, you can connect to Rosie simply by using the command `ssh ROSIE` in your terminal or by selecting "ROSIE" from the Remote SSH extension in VSCode. If you have jobs started on ROSIE, this setup also allows you to connect directly to compute nodes (e.g., `dh-node1`, `dh-node2`, etc.) through Rosie using the same SSH config.

If you have any other devices you need to connect through from SSH, you can add additional `Host` entries to this config file following the same format.

Common error: If your connection times out before it connects, press `Ctrl + ,` to open Settings, search for `Remote.SSH: Connect Timeout`, change the value from `30` to `120`, and try again.

## Download the "SSH" Extension

1. Open VSCode
2. Click the "Extensions" icon in the left toolbar (pictured below).  
![extension icon](/images/article_content/extensions-view-icon.png) 
3. Search for "Remote SSH" and click the "Remote - SSH" extension (pictured below)  
![remote ssh](/images/article_content/remote-ssh.png)
4. Click install, and then you should have a blue icon on the bottom-left (pictured below)  
![blue icon](/images/article_content/ssh-icon.png)

## Start a Connection + Enter Your Info

Once the extension is installed, click the blue icon on the bottom-left to open an SSH connection menu. Out of the presented options, you should choose "Connect to Host" or "Connect Current Window to Host". The former opens a new VSCode window while the ladder connects the current window.

You may be prompted to choose a configuration file location at this point or in later steps. Make sure to choose the location of your `~/.ssh/config` file if you created one in the previous section.

If you set up the SSH config file as described earlier, you should see "ROSIE" as an option to connect to. Select that option to connect to Rosie.

You need to be using global protect now if you're not on MSOE's campus network. If you're prompted to choose an OS, choose "Linux". Finally, enter your Rosie password if prompted, and then you will be connected to Rosie in VSCode once everything finishes loading!

You can can then follow the same steps to connect to any other devices you set up in your SSH config file.

## Using Terminals and the File Browser

Once you are connected, you can open a terminal the way you normally would in VSCode. However, this terminal will be running on Rosie rather than on your local machine! Since the terminal is on Rosie, you can do anything you may want to do from the Rosie dashboard terminal or from a local terminal that you ran `ssh` in. For instance, you can run `squeue` to see running jobs.

To use the standard VSCode file browser, you have to press "Open Folder" and manually navigate to a folder to open (`/home/ad.msoe.edu/{msoe username}` is a good first choice). Then, you have to enter your Rosie password again.

## Tips & Tricks

### Open Files in VSCode via the Terminal

It's possible to fully use Rosie through VSCode without even opening the file browser! If you have a terminal open, the `code` command opens a Rosie file in your local instance of VSCode, and all change you make are saved on Rosie. For instance, if you have a script in your home directory named `script.py`, you can run these commands to open the script in VSCode if you're connected to Rosie:
```bash
cd ~
code script.py
```

### Start Slurm Jobs to Use Rosie's GPUs

[Check out this article](/library?nav=Articles&article=Learning_Resources-Advanced-Slurm) for a full guide on using slurm to request Rosie's GPUs.

### Jernel (Jupyter Notebooks in VSCode Running on Rosie)

[Check out this article](/library?nav=Articles&article=Learning_Resources-Jernel) for a full guide on *Jernel* (a tool to run local VSCode Jupyter notebooks on Rosie).