# nodejs4synologynas
Running a REST server on Synology NAS using NodeJS and MariaDB (MySQL fork)

There are a lot of good resources for NodeJS projects, REST services etc.  
The purpose of this project is to explain all the steps to get NodeJS up and running on your Synology NAS and to keep it running
even after the server is restarted.

1. Start by logging into DSM and going to Package Manager  
    1. Install the "Node.js v4" package
    1. Install the "MariaDB" package
1. Install [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) or similar SSL client to get console access to your NAS
