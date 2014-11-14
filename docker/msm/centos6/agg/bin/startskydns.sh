#!/bin/bash
#
# Simple script start single container skydns/etcd services.
# 

/usr/bin/supervisorctl start etcd
/usr/bin/supervisorctl start skydns
