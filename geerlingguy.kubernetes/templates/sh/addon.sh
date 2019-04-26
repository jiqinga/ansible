#!/bin/bash
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') |  grep token:  >/root/k8s.txt
kubectl  cluster-info  | grep -v 'kubectl cluster-info dump'   >>/root/k8s.txt
echo "https://`hostname -I | awk '{print $1}'`:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"  >> /root/k8s.txt
