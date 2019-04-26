#!/bin/bash
kubectl proxy --address='0.0.0.0' --accept-hosts='^*$' --port $1 &
echo "kubectl proxy --address='0.0.0.0' --accept-hosts='^*$' --port $1 &" >>/etc/rc.local 
chmod +x /etc/rc.local
