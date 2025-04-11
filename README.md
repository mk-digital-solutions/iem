## Instalar o k3s

```
sudo apt-get update
sudo apt upgrade
sudo apt install curl
curl -sfL https://get.k3s.io | sh -
mkdir ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config
sudo chown $USER /etc/rancher/k3s/k3s.yaml
```

## Na pasta do iem, instalar o ieprovision

```
chmod +x ieprovision
sudo install ieprovision /usr/local/bin/
```


## Apagar o traefik do kube-system

```
sudo touch /var/lib/rancher/k3s/server/manifests/traefik.yaml.skip
sudo kubectl delete -f /var/lib/rancher/k3s/server/manifests/traefik.yaml -n kube-system
```

| Gerar certificado IP | Gerar certificado DNS |
|----------------------|-----------------------|
| ```bash<br>cd certs-generator_IP_Ubuntu22<br>chmod +x gen_with_ca-IP.sh<br>./gen_with_ca-IP.sh 192.168.249.146<br>cd ..<br>``` | ```bash<br>cd certs-generator_IP_Ubuntu22<br>chmod +x gen_with_ca-DNS.sh<br>./gen_with_ca-DNS.sh nome.do.hostname<br>cd ..<br>``` |



OBS: necessário um servidor DNS. Caso não tenha, verifique o [Tutorial do Pi-hole](dns-server/pihole.md).

## Criar o namespace iem e setar o certificado

```
kubectl create ns iem
kubectl -n iem create secret tls iemcert --cert=./certs-generator_IP_Ubuntu22/out/myCert.crt --key=./certs-generator_IP_Ubuntu22/out/myCert.key
```

## Substitua o nome do arquivo `configuration-[].json` e o ip `192.168.0.10` (ou `iem.edge.local` se for DNS)

```
ieprovision install configuration-26fda20cd8e64fc990ef8d1615c5b1e0.json -n iem -v \
--set global.hostname="192.168.0.10" \
--set global.storageClassPg="local-path" \
--set global.storageClass="local-path" \
--set global.certChain="$(cat ./certs-generator_IP_Ubuntu22/out/certChain.crt | base64 -w 0)" \
--set kong.deployment.hostNetwork=true \
--set kong.dnsPolicy=ClusterFirstWithHostNet \
--set kong.proxy.tls.hostPort=443 \
--set kong.proxy.tls.containerPort=443 \
--set kong.containerSecurityContext.capabilities.add={NET_BIND_SERVICE} \
--set kong.containerSecurityContext.runAsGroup=0 \
--set kong.containerSecurityContext.runAsNonRoot=false \
--set kong.containerSecurityContext.runAsUser=0 \
--set kong.deployment.daemonset=true \
--set kong.env.SSL_CERT=/etc/secrets/iemcert/tls.crt \
--set kong.env.SSL_CERT_KEY=/etc/secrets/iemcert/tls.key \
--set kong.secretVolumes.kong-proxy-tls=iemcert
```
