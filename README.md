# nodejs4synologynas
### Running a REST server on Synology NAS using Node.js and MariaDB (MySQL)  
`Searchterms: NodeJS service on Synology NAS.`

There are a lot of good resources out there for Node.js serivices that do just about anything. So in this project I will be focusing on all the [yak-shaving](https://en.wiktionary.org/wiki/yak_shaving) that goes into making the whole setup actually work. When everything is running it's up to you to make something useful.    

The purpose of this project is to explain all the steps to get NodeJS up and running on your Synology NAS and to keep it running
even after the server is restarted.

1. Start by logging into DSM and going to Package Manager  
    1. Install the "Node.js v8" package or whichever is the lateste at the time. (Located under "Developer Tools")
    1. Install the "MariaDB" package, any version shold be fine.  (Located under "Utilities")
    
1. Still in DSM. Goto Control Panel, and in the File Sharing section select "Shared Folder".
1. Create a new folder named "Server". You can call it anything you'd like (or use an existing folder) but for the sake of this project I'll assume you are using the "Server" folder.
1. In Control Panel, Goto "Terminal & SNMP". Make sure "Enable SSH service" is checked. We need SSH access later in this guide, but you can turn it off after everything is done.
1. Using your PC or Mac open the "Server" folder and make a folder called "Node"
1. Install [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) or similar SSL client to get console access to your NAS
1. To make a connection test. Make a folder for you project inside your Server folder for example "HelloWorldServer" and add a file called "index.js" containing the Example server provided by "NodeJS Express". For editing JS, i recommend using Visual Studio Code - https://code.visualstudio.com/ 
```//index.js
const express = require('express')
const app = express()

app.get('/', (req, res) => res.send('Hello World!'))

app.listen(3000, () => console.log('Example app listening on port 3000!'))```
1. Login to you Synology using Putty (or another SSH client) using you admin account
1. Change to the Server/HelloWorldServer folder - most likely it's called "/Volume1/Server/HelloWorldServer" or somthing similar so the command would be: ```cd /Volume1/Server/HelloWorldServer```
1. If your Node installation is complete - you should be able to use npm to install the dependienciet.
1. Type the commands: ```npm init``` - to init the project. ```npm install express --save``` to install and save the Express server dependency
1. Start the NodeJS project: ```node .``` (Using . will assume "index.js" to be the default entrypoint file)
1. You should see a message saying "Example app listening on port 3000!"
1. In your browser you should now be able to access the app using the URL: ```http://[ip-of-your-NAS]:3000``` (3000 being the Port your Express server is listening to) 

### To keep the process running independent of the SSH client  
1. When you exit the Node process by pressing CTRL+C or exiting the SSH client, you will notice the website goes offline. We will need to keep the process running in the background. 
1. To keep the process runnning we use a Node package called "forever". To install it type ```npm install forever -g``` The -g option installs the package globally - since it's not a dependency of the specific project, but rather a general utility of the server.
1. We can now type ```forever start index.js``` and the server will keep running even after we exit the SSH process.

### Restart the NodeJS server after each restart
It's possible to access the server manually each time we restart or update, but ideally we would like to be able to restart and update and have our Node server start up along side everything else.
1. Create a file called ```nodeserverstart.sh``` with the content:
```
TBA
```
1. Run the command ```chmod TBA``` to make the script executable. 
1. Copy this file into the folder ```TBA```
1. You should now be able to restart your server andthe  bootscript will make sure the service is started.

### Running the NodeJS REST service on port 80 using a custom subdomain name (optional):
Theoretically you could run everything through the NodeJS server. Even serving static files etc. Thus eliminating the need for antoher webserver completely. But the buildt-in Nginx server does offer a lot of flexiblility and ease-of-use that, in NodeJS, would require in a lot of custom code to route everything coming in on port 80 to the correct place. So I'll assume you want to use the standard Nginx webserver in the "Web Station"-package for serving PHP- and static files. We will also be using the Nginx server to route the traffic to the correct NodeJS application based on the requested host-header.

1. If you don't have a domain, or your DNS information has not propagated to your PC you can edit this file: PC: ```C:\Windows\System32\drivers\etc\hosts``` using Notepad in Admin mode. On Mac open a concole and use: ```sudo nano /etc/hosts```
    1. Add a line to the file: ```[SynologyIP] [subdomain.domain.com]```
    1. For example ```192.168.15.32 rest.thierry.com```
    1. This will enable your local machine to resolve the IP of your Synology NAS as that DNS name.
1. Install the "Web Station" package. 
1. Goto Main Menu - "Web Station". 
    1. In General Settings - make sure you are using HTTP back-end server: "Nginx"
1. A standard website would be served using the Virtual Host setting in the Webserver, but your NodeJS services should be configured using the "Reverse proxy" settings in "Control Panel > Application Portal > Reverse Proxy"
1.    Click Create and fill in the form. 
    1. Description: Any description you'd like, 
    1. Source: Your desired hostname (see above) f.x. ```http://rest.thierry.com```
    1. Destination ```http://localhost:3000``` this is the target your host address will be pointing to. Localhost is the name of the NAS itself, :3000 is the port your application is listening to.
    1. This config will route all Port 80 traffice (default http port) sent to your source hostname to port 3000 of the NAS
    1. You can not enter in your browser the URL: ```http://rest.thierry.com``` and acceess the HelloWorld Server running on port 3000.
    
