# Criando cluster com Kubeadm

## Etapas necessárias:

1) Criar 3 máquinas virtuais com no mínimo 2cpus e 2GB de memória. Neste repo estou utilizando o Vagrant.
2) Configurar uma rede local que permita comunicação entre as 3 máquinas e também conexão com a internet.
    
    2.1) O script `configura-host.sh` é executado em cada um dos hosts para basicamente definir os DNS locais no /etc/hosts de todas as máquinas.
    
    2.2) O script `dns.sh` seta o DNS 8.8.8.8 para resolver endereços da internet.

3) Instalar um container runtime. Neste setup utilizei o containerd, que segue a especificação CRI (Container Runtime Interface). O script de instalação está sendo aplicado para cada VM: `containerd-install.sh`

4) Instalar o trio `kubeadm`, `kubelet` e `kubectl`. Isso está definido no script `install-kubeadm.sh`.
---

# Problemas enfrentados:
* No momento de fazer o join dos worker nodes com o master node, o serviço do kubelet não estava rodando por ausência do arquivo `/var/lib/kubelet/config.yaml`.
Lendo a documentação oficial, este arquivo só é criado ao rodar o comando kubeadm init (que teoricamente só deveria ser executado no node master), como pode ser visto no seguinte output:
```
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
```

Ainda assim, ocorre o seguinte erro: 

`
E1012 14:39:46.136969   44102 memcache.go:265] couldn't get current server API group list: Get "https://192.168.56.2:6443/api?timeout=32s": dial tcp 192.168.56.2:6443: connect: protocol not available`

Para juntar-se ao node master, precisa rodar o comando:

`sudo kubeadm join <ip master node>:<porta master node> --token <token> \
        --discovery-token-ca-cert-hash sha256:<hash do certificado>`

Para tentar automatizar o processo, podemos rodar o comando `kubeadm token list` (no node master) e via script pegar somente a saída do token na coluna `TOKEN`, e guardar em uma variável. Lembrando que o token expira em 24h, se for o caso pode gerar um token novo usando o comando `kubeadm token create`.

Caso precisar do hash do certificado, rodar o seguinte comando: 

`openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'`
