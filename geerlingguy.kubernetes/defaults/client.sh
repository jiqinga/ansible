#!/bin/bash
#此脚本生成k8s-apiserver证书,运行后把kubecfg.p12文件导入计算机重启浏览器即可.
passwd=123456
grep 'client-certificate-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.crt
grep 'client-key-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.key
rpm -q expect
if [ $? -eq 0 ];then
  echo "生成证书"
else
  yum -y install expect
fi
expect <<EOF
spawn openssl pkcs12 -export -clcerts -inkey kubecfg.key -in kubecfg.crt -out kubecfg.p12 -name "kubernetes-client"
expect "Password:"   {send "$passwd\n"}
expect "Password:"   {send "$passwd\n"}
expect "Password:"   {send "exit"}
EOF
