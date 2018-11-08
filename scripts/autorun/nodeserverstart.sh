#!/bin/sh
PATH=$PATH:/volume1/@appstore/Node.js_v8/usr/local/lib/node_modules/forever/bin

forever start /volume1/server/HelloWorldServer -l /volume1/server/HelloWorldServer/logs/log.txt  -o /volume1/server/HelloWorldServer/logs/output.txt
