```
说明： 使用ansible部署k8s整个过程约为16分钟左右（包含下载镜像时间），其中Initialize Kubernetes master with kubeadm init
任务需要下载k8s镜像需要十分钟左右，具体时间根据网速变化。

1.创建虚拟机（至少一台，超过一台无限制）
实验环境：  （所做操作均在master节点，确保各节点之间能够ssh，各节点都要联网）
    192.168.1.1  master
    192.168.1.2  node2
    192.168.1.3  node3

2.下载ansible自动化部署文件
在master节点上执行
#  curl https://raw.githubusercontent.com/woshijiqinga/test/master/install.sh | bash

3.修改配置文件
#  pwd
#  /etc/ansible
#  cat hosts 
[k8s-master]
192.168.1.1     #master节点ip地址
[k8s-node]
192.168.1.2     #node节点ip地址
192.168.1.3
[k8s-cluster:children]
k8s-master
k8s-node
[k8s-cluster:vars]
ansible_ssh_pass=password   #主机密码

#  vim k8s.yaml
- hosts: k8s-cluster
  serial: "100%"
  any_errors_fatal: true
  vars:
     - ipnames:
        '192.168.1.1': 'master'  #此处为主机名解析
        '192.168.1.2': 'node2'
        '192.168.1.3': 'node3'
  roles:
    - hostnames
    - repo-epel
    - docker

- hosts: k8s-master
  vars:
    kubernetes_allow_pods_on_master: True
    kubernetes_role: master
    kubernetes_version: '1.13'    #此处为k8s版本  (此处填写1.12，下面则为1.12.1或1.12.2或1.12.3。。。以此类推)
    kubernetes_version_rhel_package: '1.13.1'    #  '1.12.1~7'   '1.13.1~5'   '1.14.0'  #此处为k8s组件版本，要和上面一致  
    kubernetes_apiserver_advertise_address: 192.168.1.1   #master节点IP地址
    api_port: 8086                   #api-proxy端口号  可通过http://192.168.1.1(master节点IP地址)：8086  访问k8s集群api接口
  roles:
    - geerlingguy.kubernetes

- hosts: k8s-node
  vars:
    kubernetes_role: node
    kubernetes_version: '1.13'       #此处同上面保持一致
    kubernetes_version_rhel_package: '1.13.1'    #  '1.12.1~7'   '1.13.1~5'   '1.14.0'   #此处同上面保持一致
  roles:
    - geerlingguy.kubernetes

4.使用playbook部署k8s集群
#  pwd
#  /etc/ansible
#  ansible-playbook k8s.yaml   （此过程约为16分钟，若出现错误导致停止，重新执行即可）

5.检测集群状态
#  kubectl get cs
#  kubectl get node

#  kubectl  get pod -n kube-system  （等待所有pod全部running）

6.生成证书 （由于k8s集群加密限制，需要导入证书才能正常访问）
#  curl https://raw.githubusercontent.com/woshijiqinga/ansible/master/geerlingguy.kubernetes/defaults/client.sh  | bash
执行完成后会在当前路径下生成kubecfg.p12文件，把此文件拷贝至本地计算机后双击打开，点击下一步---下一步---输入密码123456---下一步---下一步---完成
重启谷歌浏览器

7.查看说明文件 （安装完成后会在/root/生成k8s.txt文件）
#  cat  /root/k8s.txt 或 kubectl cluster-info
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLTlnbHhxIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJkODUzMGM5Ny02OTk1LTExZTktOGNmMS0wMDUwNTZhNDRjZDQiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.d8aV00zX8442L7NGDjK4P9FJSEUPo_ubqLr4_k-LVizy--qzSvkRnAJBwTfKaPqgnWg7ITrL5_pGLLU1uD-6Fbm1HWqJYGGFJilU3v7C5T8A_Ph1zmUo79N6AmI9OUTQsPSXAj36JgzuUdRz4YV7KH4X0mja05aW5U8BEqRHx2fBCnf--U8iyemqr3bVPg_r2pNswBOv7J7qPS13jMbTa1RLP2hA15YQCl8EwXeP6BUxeQNVMpC-Z55iLEL2-DoihNmgeHWZDVtD9hkELf8qfeIt8kIjxpwL5819bh-9x5aRQeXSlWy15waaUVyB7ERdEkRTHYU455byUfPPWBU9nA     #dashboard令牌
Kubernetes master is running at https://182.10.1.78:6443
Elasticsearch is running at https://182.10.1.78:6443/api/v1/namespaces/kube-system/services/elasticsearch-logging/proxy
Heapster is running at https://182.10.1.78:6443/api/v1/namespaces/kube-system/services/heapster/proxy
Kibana is running at https://182.10.1.78:6443/api/v1/namespaces/kube-system/services/kibana-logging/proxy  #kibana访问地址
KubeDNS is running at https://182.10.1.78:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
monitoring-grafana is running at https://182.10.1.78:6443/api/v1/namespaces/kube-system/services/monitoring-grafana/proxy  #grafana访问地址
monitoring-influxdb is running at https://182.10.1.78:6443/api/v1/namespaces/kube-system/services/monitoring-influxdb/proxy
https://182.10.1.78:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/  #dashboard访问地址

8.访问dashboard
#  https://192.168.1.1:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
选择令牌登录，粘贴k8s.txt文件中token

9.访问grafana
#  https://192.168.1.1:6443/api/v1/namespaces/kube-system/services/monitoring-grafana/proxy

10.访问kibana
#  https://192.168.1.1:6443/api/v1/namespaces/kube-system/services/kibana-logging/proxy



说明： 使用playbook使新节点加入集群用时约为三分钟，下面操作均在master主节点执行

1.创建一台新的虚拟机 (确保能够ssh，需要联网)
实验环境：
    192.168.1.4   node4
2.修改配置文件
#  pwd
#  /etc/ansible
#  cat hosts                  
[k8s-master]
192.168.1.1
[k8s-node]
192.168.1.2
192.168.1.3
192.168.1.4    #在node子组里面加入新节点的ip地址
[k8s-cluster:children]
k8s-master
k8s-node
[k8s-cluster:vars]
ansible_ssh_pass=password

#  vim node.yaml
- hosts: k8s-cluster
  vars:
   - ipnames:
      '192.168.1.1': 'master'   #hosts地址解析
      '192.168.1.2': 'node2'
      '192.168.1.3': 'node3'
      '192.168.1.4': 'node4'
  roles:
    - hostnames

- hosts: 192.168.1.4    #此处为新节点ip地址
  serial: "100%"
  any_errors_fatal: true
  vars:
    kubernetes_role: node
    kubernetes_version: '1.13'     #节点安装k8s版本，建议与集群版本一致
    kubernetes_version_rhel_package: '1.13.1'    #  '1.12.1~7'   '1.13.1~5'   '1.14.0' #节点安装kubectl，kubeadm，kubelet组件版本
  roles:
    - repo-epel
    - docker
    - geerlingguy.kubernetes
3.执行playbook使新节点加入集群
#  ansible-playbook node.yaml

4.查看新节点
#  kubectl get node   （等待新节点状态为ready）
```
