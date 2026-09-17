<br>
<a href='/learning-tree?node=6' style='
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

<p style='color: white; margin-top: 2px;'>By reading this article, you will be able to successfully log into ROSIE for the first time and access the web portal interface.</p>

</div>

<br/>

<br/>

## Logging In For the First Time

This guide will walk you through the process of logging into ROSIE for the first time using SSH (Secure Shell). SSH provides secure remote access to the ROSIE computing cluster.

**Network Requirements:**
ROSIE can only be accessed through MSOE's campus network. If you are connecting from off-campus (including the ITC) or using the "MSOE Guest" network, you must use Global Protect, MSOE's VPN. This should come with your MSOE-issued laptop. For personal machines, you can install Global Protect by reading [this](https://msoe-maic.com/library/?nav=Articles&article=global-protect) article.

## Prerequisites: Check Your SSH Client

Modern versions of Windows, macOS, and Linux include an SSH client, so you do not need to install additional software to connect to ROSIE.

- **Windows:** Open Command Prompt, PowerShell, or Windows Terminal.
- **macOS:** Open Terminal.
- **Linux:** Open your preferred terminal.

To verify that SSH is available, run:

```bash
ssh -V
```

If Windows reports that `ssh` is not recognized, search for **Optional features** in Windows Settings and install **OpenSSH Client**. Then reopen your terminal and run `ssh -V` again.

## Connecting to ROSIE

Here's what we'll accomplish in this section:

1. SSH into ROSIE using the command: `ssh "username@ad.msoe.edu"@dh-mgmt2.hpc.msoe.edu`
2. Enter your MSOE password
3. Verify successful connection

### Step 1: SSH Into ROSIE



#### Open a Terminal

Open Command Prompt, PowerShell, or Windows Terminal on Windows. On macOS or Linux, open Terminal. Then enter:


```bash
ssh "username@ad.msoe.edu"@dh-mgmt2.hpc.msoe.edu
```

**Important Notes:**
- The quotes around your username are required (not just placeholders)
- Replace "username" with your MSOE username (your email without @msoe.edu)
- Your first SSH login may be slower than usual due to authentication caching

You should see a prompt similar to this: 

![alt text](/images/article_content/ssh_1.png)


### Step 2: Enter Your Password

Enter your standard MSOE login password. **Important notes:**
- Your password will not appear on screen as you type (this is normal for security)
- If you make a mistake, press Delete/Backspace several times to clear the entry and try again
- Press Enter when finished typing your password

## You're Connected!
You should see the following screen -- you can now use ROSIE!

![alt text](/images/article_content/rosie_success.png)


Once you see the ROSIE banner, you are successfully connected, and your personal directory has been created at `/home/ad.msoe.edu/{msoe username}`.

### Test Your Connection

Try running a simple command to verify everything is working:

```bash
ls
```

This will list the contents of your home directory on ROSIE.

## What's Next?

Now that you've successfully connected via SSH, you can move on to using ROSIE's web interface with Jupyter Notebooks for a more user-friendly experience. Learn more in the next article: [Using The ROSIE Web Interface](https://msoe-maic.com/library/?nav=Articles&article=3-rosie-web).

For additional technical details about ROSIE access, you can also reference the [official HPC documentation](https://docs.hpc.msoe.edu/#/access).



