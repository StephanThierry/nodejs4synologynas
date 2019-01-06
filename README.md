# nodejs4synologynas
### Running a REST server on Synology NAS using Node.js and MariaDB (MySQL)  
`Searchterms: NodeJS service on Synology NAS, Running Node.JS on Synology NAS, Node on Synology NAS.`

There are a lot of good resources out there for Node.js services that do just about anything. So in this project I will be focusing on all the [yak-shaving](https://en.wiktionary.org/wiki/yak_shaving) that goes into making the whole setup actually work. When everything is running it's up to you to make something useful. This guide should work on most Synology NAS servers from the smallest ones with an old ARM processer and 512MB RAM like the DS214se, to the larger versions with a newer Intel CPU and +4GB RAM like the DS918+. 

The purpose of this project is to explain all the steps to get Node.js up and running on your Synology NAS and to keep it running
even after the server is restarted.

1. Start by logging into DSM and going to Package Manager  
    1. Install the "Node.js v8" package or whichever is the lateste at the time. (On older version of DSM it might be located under "Developer Tools", the latest version just has an "All packages" tab.)
    1. Install the "MariaDB" package, any version shold be fine, just be aware that version 5 uses the default MySQL port (3306) and version 10 uses 3307. So when using v10, you'll need to specify the port on all connections.  (Used to be under "Utilities")
    
1. Still in DSM. Goto Control Panel, and in the File Sharing section select "Shared Folder".
1. Create a new folder named "server". You can call it anything you'd like (or use an existing folder) but for the sake of this project I'll assume you are using the "server" folder.
1. In Control Panel, Goto "Terminal & SNMP". Make sure "Enable SSH service" is checked. We need SSH access later in this guide, but you can turn it off after everything is done.
1. Using your PC or Mac open the "server" folder and make a folder called "HelloWorldServer"
1. Install [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) or similar SSH client to get console access to your NAS
1. To make a connection test application, add a file called "index.js" containing the example server provided by "Node.js Express" (pasted in below). https://expressjs.com/en/starter/hello-world.html 
1. For editing JS, I recommend using Visual Studio Code - https://code.visualstudio.com/ 
1. VS Code can create files directly from the commandline - so if you are in the correct folder, running `code index.js` will create the file and start the editor in one go.
```
const express = require('express')
const app = express()

app.get('/', (req, res) => res.send('Hello World!'))

app.listen(3000, () => console.log('Example app listening on port 3000!'))
```

1. Login to a command-shell on your Synology using Putty (or another SSH client - if you are on a Mac there is one built into the Terminal app) using your admin account
1. Change to the Server/HelloWorldServer folder - most likely it's called "/volume1/server/HelloWorldServer" or something similar, so the command would be: ```cd /volume1/server/HelloWorldServer```
1. If your Node installation is complete - you should be able to use npm to install the dependiencies.
1. Type the commands: ```npm init --yes``` - to init the project with all default values. ```npm install express --save``` to install and save the Express server dependency
1. Start the Node project: ```node .``` (Using . will execute the default start-document "index.js")
1. You should see a message saying "Example app listening on port 3000!"
1. In your browser you should now be able to access the app using the URL: ```http://[ip-of-your-NAS]:3000``` (3000 being the Port your Express server is listening to) 

### To keep the process running independent of the SSH client  
1. When you exit the Node process by pressing CTRL+C or closing the SSH client, you will notice the website goes offline. We will need to keep the process running in the background. 
1. To keep the process runnning we use a Node package called "forever". To install it type ```npm install forever -g``` The -g option installs the package globally - since it's not a dependency of the specific project, but rather a general utility we need on the server.
1. We can now type ```sudo forever start index.js``` and the server will keep running even after we exit the SSH process.
1. If you are getting an error: `bash: forever: command not found` check that forever is installed with the "-g" (global) option
1. If you have installed forever globally, and you are still seeing this error. Edit the `/etc/profile` file and add the full path to the forever binary to the PATH statement in you boot-profile. You can use the built-in editor "vim". `sudo vim /etc/profile`  
1. For me the "forever"-binary was located in `/volume1/@appstore/Node.js_v8/usr/local/lib/node_modules/forever/bin` it might be different for you. You will need to close you shell and re-open it to use the changes in the PATH variable.
1. For general filemanagement and editing I recommend installing and using "Midnight Commander" from https://synocommunity.com/. (Installation instructions are on the site) When it's installed start it using ```sudo mc```.

### Restart the Node.js server after each NAS restart (recommended)
It's possible to access the server manually each time we restart or update, but ideally we would like to be able to restart and update and have our Node server start up along side everything else.
1. Create a file in `/volume1/server` called ```nodeservercontrol.sh``` with the content: (Located in the repo `/scripts`)
```
#!/bin/sh
PATH=$PATH:/volume1/@appstore/Node.js_v8/usr/local/lib/node_modules/forever/bin

start() {
        forever start --workingDir /volume1/server/HelloWorldServer --sourceDir /volume1/server/HelloWorldServer -l /volume1/server/HelloWorldServer/logs/log.txt -o /volume1/server/HelloWorldServer/logs/output.txt .

}

stop() {
        killall -9 node
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  *)
    echo "Usage: $0 {start|stop}"

```
> Improvements to forever command-call provided by [Nedguy](https://github.com/nedguy)  

1. Check the "PATH" statement in the above script and make sure the binaries of your version of "forever" is in that folder. It might change depending on you version of Node or forever. Correct it, if it is not accurate.  
1. Copy this file into the folder ```/usr/local/etc/rc.d``` "rc.d" means run commands directory, and contains customs scrips that will be executed with a "start" parameter at boot and a "stop" parameter at shutdown of the NAS.
1. Using the command `sudo cp /volume1/server/nodeservercontrol.sh /usr/local/etc/rc.d` will copy the script.
1. Run the command ```sudo chmod +x /usr/local/etc/rc.d/nodeservercontrol.sh``` to make the script executable, otherwise it won't actually be executed. 
1. You should now be able to restart your server and the bootscript will make sure the service is started.

**However...**  
...this approach might not always work. So there is an alternative solution which was provided to me by Stephen Hamilton (https://github.com/pieshop)   

Instead of using one script to take care of both stop and start - and relying on the Linux automation of the `rc.d` folder it's possible to use the Synology "Control Panel -> Task Scheduler" (Both scripts mentioned are in the `/scripts/autorun` folder of the repo)  


1. Create the script `nodeserverstart.sh` below and place it in a folder for example: `/volume1/server/autorun/`   
1. Make the script executable: `sudo chmod +x /volume1/server/autorun/nodeserverstart.sh`  
    ```shell
    #!/bin/sh
    PATH=$PATH:/volume1/@appstore/Node.js_v8/usr/local/lib/node_modules/forever/bin

    forever start --workingDir /volume1/server/HelloWorldServer --sourceDir /volume1/server/HelloWorldServer -l /volume1/server/HelloWorldServer/logs/log.txt -o /volume1/server/HelloWorldServer/logs/output.txt .
    
    ```

1. Then, create the script `nodeserverstop.sh` below and place it in a folder for example: `/volume1/server/autorun/`    
1. Make that script executable too: `sudo chmod +x /volume1/server/autorun/nodeserverstop.sh`  
    ```shell
    #!/bin/sh

    killall -9 node
    ```

1. Login into DSM and goto  "Control Panel -> Task Scheduler"  
1. Create -> Triggered Task (User:root, Event:Boot-up)  
   * Run command: `sh /volume1/server/autorun/nodeserverstart.sh`  

1. Create -> Triggered Task (User:root, Event:Shutdown)  
   * Run command: `sh /volume1/server/autorun/nodeserverstop.sh`

This has the added benefit of being able to start/stop the Node server via the DSM GUI.

### Stopping Node
When developing your NodeJS application you will often need to make changes, thus stopping and starting the service. The easiest is to keep the Node process in the shell so you can close it easily. But if you need to stop a "forever"-Node process it should be enough to run `sudo forever stopall`  but that might not always be the case. Sometimes you need to use a more drastic appraoch and use the command `sudo killall -9 node` to be sure all node-processes are stopped.  

A good indication that a process is still running in the background is the error `EADDRINUSE`. Which indicated that the system still thinks there is a process listening to the specified port.  

### Running the Node.js REST service on port 80 using a custom subdomain name (optional):
Theoretically you could run everything through the Node.js server. Even serving static files etc. Thus eliminating the need for another webserver completely. But the built-in Nginx server does offer a lot of flexiblility and ease-of-use that, in Node, would require in a lot of custom code to route everything coming in on port 80 to the correct place. So I'll assume you want to use the standard Nginx webserver in the "Web Station"-package for serving PHP- and static files. We will also be using the Nginx server to route the traffic to the correct Node application based on the requested host-header.

1. If you don't have a domain, or your DNS information has not yet propagated, you can edit this file: PC: ```C:\Windows\System32\drivers\etc\hosts``` using Notepad in Admin mode (or just use VS Code). On Mac open a concole and use: ```sudo nano /etc/hosts```
    1. Add a line to the file: ```[SynologyIP] [subdomain.domain.com]```
    1. For example ```192.168.15.32 rest.thierry.com```
    1. This will enable your local machine to resolve the IP of your Synology NAS using that DNS name.
1. Install the "Web Station" package. 
1. Goto Main Menu - "Web Station". 
    1. In General Settings - make sure you are using HTTP back-end server: "Nginx"
1. A standard website would be served using the Virtual Host setting in the Webserver, but your NodeJS services should be configured using the "Reverse proxy" settings in "Control Panel > Application Portal > Reverse Proxy"
1.    Click Create and fill in the form.   
    * Description: Any description you'd like,   
    * Source: Your desired hostname (see above) f.x. ```http://rest.thierry.com```  
    * Destination ```http://localhost:3000``` this is the target your host address will be pointing to. Localhost is the name of the NAS itself, :3000 is the port your Node server application is listening to.  
    * This config will re-route all Port 80 traffic (default http port) sent to your source hostname to port 3000 of the NAS  
    * You can now enter the URL: ```http://rest.thierry.com``` in your browser and acceess the HelloWorldServer running on port 3000.  
    
### Next step
Well, now you have a stable HelloWorld server running, you can update and restart your server without killing your appliction - and a MySQL database service with no databases (that doesn't do anything yet). You can go on to all the great articles about how to program Node.js services like this one by Avanthika Meenakshi: https://medium.com/@avanthikameenakshi/building-restful-api-with-nodejs-and-mysql-in-10-min-ff740043d4be 


### Are you new to Node.js
If you've gotten this far, then probably not. But just in case, check out my very basic tutorial project: https://github.com/StephanThierry/node-tutorialgallery that explains some of the basic concepts of setting a Node.js server inside a functioning (ugly) app. Don't use this project for it's amazing features, but for the comments that go with each line of the server application, explaining what they do and why. 
