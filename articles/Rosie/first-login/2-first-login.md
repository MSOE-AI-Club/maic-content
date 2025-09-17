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

<p style='color: white; margin-top: 2px;'>By reading this article, you will be able to successfully log into ROSIE for the first time by reseting your password, allowing you to use ROSIE through the web portal.</p>

</div>

<br/>

<br/>

## Logging In For the First Time

Logging into ROSIE for the first time is a bit of a pain and requires a few steps. This guide will walk you through the process of logging in for the first time and resetting your password.

ROSIE can only be accessed through MSOE's campus network. If you are anywhere else, including the ITC, you need to use Global Protect, MSOE's VPN. This should come with your MSOE issued laptop, however if you would rather use a personal machine, you can install Global Protect by reading [this](https://msoe-maic.com/library/?nav=Articles&article=global-protect) article.


In order to log in to Rosie for the first time, you must do so via SSH (Secure Shell)
SSH-ing to a computer cluster provides secure remote access, enabling efficient management, data analysis, and collaboration, crucial for scalable, high-performance computing and research in various fields.

However, in order to use SSH, you will need an SSH client. Our tool of choice (that you'll later learn to use in-class as well) is Git.

Start by downloading and installing Git from [here](https://git-scm.com/downloads). Please download the corresponding version for your machine. If using the MSOE provided laptop, use the 64-bit Git for Windows Setup under the section Standalone Installer. Below are instructions on what you should make sure to check off when installing git. 

If on Mac, git might already by installed if you have xcode. If you are not sure, the easiest way to check is to open terminal and run the command "git --version". If it shows a version number, you are good to go, if not, it should prompt you to install git via Xcode Command Line Tools. 


### Installing Git Bash Correctly 
Open the download and accept all changes, you will then see the below screen...

![alt text](/images/article_content/git_bash_setup.png)


In the following screens, accept all default selections


## Logging into ROSIE

Here's an overview of what we will be doing throughout the rest of the article:

1. SSH into Rosie `ssh "username@ad.msoe.edu"@dh-mgmt2.hpc.msoe.edu`
2. Enter your password.  

### 1. SSH Into ROSIE
Once you have Git Bash open, type the following command, replacing username with your username (your email without the msoe.edu)
Look at the console entries next to the red stars *

#### Using Git Bash (if on Windows)
Open up the new program by typing git in your search bar, and clicking git bash. Then enter the following command, replacing username with your username (your email without the msoe.edu)
`ssh "username@ad.msoe.edu"@dh-mgmt2.hpc.msoe.edu`

#### Using Terminal (if on mac)
Open up terminal if not already open and then enter the following command, replacing username with your username (your email without the msoe.edu)
`ssh "username@ad.msoe.edu"@dh-mgmt2.hpc.msoe.edu`


Regardless of your machine's OS, you should be shown something like the following, where you are prompted for your password: 

![alt text](/images/article_content/ssh_1.png)


### 2. Enter your password
Rosie has switched to using your default msoe login. Enter this password into your terminal/git bash. As you're entering your password you will not see you password appear. That's OK, the characters will not appear due to security reasons, so please keep entering your password and hit enter when you're done.

## You're In!
You should see the following screen! You're in! You can now use ROSIE!

![alt text](/images/article_content/rosie_success.png)


Once you see the message that it's creating directory 'home/username@ad.msoe.edu' followed by the big ROSIE, you're all set!


## What To Do Moving Forward?
Now, we aren't actually going to use this terminal interface to interact with ROSIE (that's gross 🤧); instead, we'll be using the online interface, using Jupyter Notebooks and starting up your own ROSIE instances. Find out more in the next article: [Using The ROSIE Dev Page](https://msoe-maic.com/library/?nav=Articles&article=3-rosie-web).



