#!/bin/bash
token=`kubeadm token create`
sha256=`openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'`
echo "kubeadm join master:6443 --token $token --discovery-token-ca-cert-hash sha256:$sha256" 
