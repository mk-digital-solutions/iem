# Erro: porta 53 em Uso

Caso a porta 53 esteja em uso (Linux), provavelmente é devido ao `systemd-resolved`. 
Para garantir que a porta realmente esteja em uso, rode

```
sudo lsof -i :53
```

Provavelmente o resultado será esse:
```
COMMAND   PID            USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
systemd-r 610 systemd-resolve   12u  IPv4  19377      0t0  UDP localhost:domain 
systemd-r 610 systemd-resolve   13u  IPv4  19378      0t0  TCP localhost:domain (LISTEN)
```

Para desabilitar o systemd-resolve, abra `/etc/systemd/resolved.conf` como root

```
sudo nano /etc/systemd/resolved.conf
```

E retire o `#` da linha `DNS=` e da linha `DNSStubListener=`. 
Depois, coloque o valor `DNS=` para o servidor DNS desejado (`127.0.0.1`)
e altere `DNSStubListener=` de `yes` para `no`

```
[Resolve]
DNS=127.0.0.1
#FallbackDNS=
#Domains=
#LLMNR=no
#MulticastDNS=no
#DNSSEC=no
#DNSOverTLS=no
#Cache=no
DNSStubListener=no
#ReadEtcHosts=yes
```

Salve as mudanças (`Ctrl + X`, `y`, `Enter`)

Crie um link simbólico para `/run/systemd/resolve/resolv.conf` com `/etc/resolv.conf` sendo o destino:

```
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
```

Reinicie o sistema

```
sudo reboot
```
