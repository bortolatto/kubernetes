# Criando cluster com Kubeadm

## Etapas necessárias:

1) Criar 3 máquinas virtuais com no mínimo 2cpus e 2GB de memória. Neste repo estou utilizando o Vagrant.
2) Configurar uma rede local que permita comunicação entre as 3 máquinas e também conexão com a internet.
    
    2.1) O script `dns.sh` seta o DNS 8.8.8.8 para resolver endereços da internet.

3) Instalar um container runtime. Neste setup utilizei o containerd, que segue a especificação CRI (Container Runtime Interface). O script de instalação está sendo aplicado para cada VM: `containerd-install.sh`

4) Instalar os binários necessários para criação do cluster, comunicação com a API server e comunicação com o cluster, respectivamente: `kubeadm`, `kubelet` e `kubectl`. Isso está definido no script `install-kubeadm.sh`.

5) **SOMENTE NO NODE MASTER**: iniciar a criação do cluster executando o seguinte comando: `sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.32`. O primeiro parâmetro indica a rede interna dos pods, e o segundo indica o ip do servidor da API do Kubernetes, que deverá ser o ip configurado no node master.

    5.1)  O comando acima irá gerar uma saída com o comando `kubeadm join`. Certifique-se de copiar este comando caso queira juntar os worker nodes ao node master. Se por acaso perder o comando, pode gerar um token novo usando o comando `kubeadm token create`.

    Caso precisar do hash do certificado, rodar o seguinte comando: 

    `openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
       openssl dgst -sha256 -hex | sed 's/^.* //'` 
   
   Após isso, executar o seguinte comando:
   `sudo kubeadm join <ip master node>:<porta master node> --token <token> \
        --discovery-token-ca-cert-hash sha256:<hash do certificado>`

6) **SOMENTE NO NODE MASTER**: copiar o kubeconfig para a pasta do usuário para ser possível executar comandos com o `kubectl` sem a necessidade de sudo:

```bash
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
7) **SOMENTE NO NODE MASTER**: Instalar um componente de rede via add-on para que os pods possam comunicar-se entre eles. Neste setup estou utilizando o Weave, mas outros podem ser encontrados [neste link](https://kubernetes.io/docs/concepts/cluster-administration/addons/).
    
    7.1) Após fazer o apply do Weave, é necessário adicionar a variável de ambiente `IPALLOC_RANGE` no container `weave` com o mesmo range de ip escolhido ao criar o cluster com o `kubeadm` no parâmetro `--pod-network-cidr=10.244.0.0/16`.

8) **Opcional**: copiar o kubeconfig para os worker nodes. Usar o seguinte comando no node master para copiar o conteúdo do kube config: `kubectl config view --minify --flatten > config`.


---

# Problemas enfrentados:
## Erro ao efetuar join no master node
* No momento de fazer o join dos worker nodes com o master node, o serviço do kubelet não estava rodando por ausência do arquivo `/var/lib/kubelet/config.yaml`.
Lendo a documentação oficial, este arquivo só é criado ao rodar o comando kubeadm init (que teoricamente só deveria ser executado no node master), como pode ser visto no seguinte output:
```
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
```

Ainda assim, ocorre o seguinte erro: 

`
E1012 14:39:46.136969   44102 memcache.go:265] couldn't get current server API group list: Get "https://192.168.56.2:6443/api?timeout=32s": dial tcp 192.168.56.2:6443: connect: protocol not available`

## Solução encontrada
O ip utilizado para iniciar a API no node master estava conflitando com o servidor dhcp que é habilitado por padrão no virtualbox. No caso o ip do DHCP é 192.168.56.2. Ao escolher um IP diferente para o node master (192.168.56.32), o worker node conseguiu juntar-se ao cluster normalmente.

---

## Erro ao rodar comandos como `exec` ou `logs`
Mesmo que os pods sejam criados com sucesso, não era possível verificar os logs do pod pois apresentava o seguinte erro:
```
vagrant@kubenode01:~$ kubectl logs nginx
Error from server (NotFound): the server could not find the requested resource ( pods/log nginx)
```

## Solução encontrada
Por padrão o kubelet não configura o ip do worker node para que o api server consiga recuperar os resources. 
Resumindo, em cada worker node, adicionar a seguinte variável de ambiente no arquivo de configuração do systemd (kubelet):

```
sudo vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```

`Environment="KUBELET_EXTRA_ARGS=--node-ip=<ip do worker node>"`

Após isso, fazer o reload/restart do systemd:
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

PS: Também fiz isso no node master, com o ip do node master

**Links sobre este problema:**

https://github.com/kubernetes/kubernetes/issues/60835

https://medium.com/@joatmon08/playing-with-kubeadm-in-vagrant-machines-part-2-bac431095706

---

### TODO: NodePort respondendo somente no node em que o service foi criado
https://github.com/kubernetes/kubernetes/issues/58908

https://github.com/kubernetes/kubernetes/issues/70222#issuecomment-450433659
