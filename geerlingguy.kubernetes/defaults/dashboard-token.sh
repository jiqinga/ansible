#!/bin/bash
#执行此脚本获得dashboard-token
 kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') |  grep token:
