#!/bin/bash

# Este script é responsável por instalar as seguintes ferramentas que são responsáveis no boostraping de um cluster kubernetes
# 1) kubeadm: binário para fazer o bootstrap do cluster
# 2) kubelet: binário que roda em todas as máquinas do cluster e que é responsável por inicializar pods e containers
# 3) kubectl: CLI utilitária para interagir com o cluster

sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Iniciar kubeadm (rodar somente no node master)
#sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.32
#sudo systemctl enable --now kubelet

# Criar uma rede para os pods usando wave.
#kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml 
# tigera calico operator
#kubectl -n kube-system set env ds/weave-net --containers=weave IPALLOC_RANGE="10.244.0.0/16"