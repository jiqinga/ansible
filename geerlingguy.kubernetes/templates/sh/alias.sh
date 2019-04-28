#!/bin/bash
echo "alias k='kubectl'" >>/root/.bashrc
echo "alias kpod='kubectl get po -n kube-system'" >>/root/.bashrc
