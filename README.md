# nodejs4synologynas
Running a REST server on Synology NAS using NodeJS and MariaDB (MySQL)

There are a lot of good resources for NodeJS projects, REST services etc.  
The purpose of this project is to explain all the steps to get NodeJS up and running on your Synology NAS and to keep it running
even after the server is restarted.

1. Start by logging into DSM and going to Package Manager  
    1. Install the "Node.js v4" package
    1. Install the "MariaDB" package
    
1. Still in DSM. Goto Control Panel, and in the File Sharing section select "Shared Folder".
1. Create a new folder named "Server". You can call it anything you'd like (or use an existing folder) but for the sake of this project I'll assume you are using the "Server" folder.
1. In Control Panel, Goto "Terminal & SNMP". Make sure "Enable SSH service" is checked. We need SSH access later in this guide, but you can turn it off after everything is done.
1. Using your PC or Mac open the "Server" folder and make a folder called "Node"
1. Install [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) or similar SSL client to get console access to your NAS
1. 

### Running the NodeJS REST service on port 80 using a custom subdomain name (optional):
Theoretically you could run everything through the NodeJS server. Even serving static files etc. Thus eliminating the need for antoher webserver completely. But the buildt-in Nginx server does offer a lot of flexiblility and ease-of-use that, in NodeJS, would require in a lot of custom code to route everything coming in on port 80 to the correct place. So I'll assume you want to use the standard Nginx webserver in the "Web Station"-package for serving PHP- and static files. We will also be using the Nginx server to route the traffic to the correct NodeJS application based on the requested host-header.

1. Install the "Web Station" package. 
1. Goto Main Menu - "Web Station". 
    1. In General Settings - make sure you are using HTTP back-end server: "Nginx"
    1. A standard website would be served using the Virtual Host setting
