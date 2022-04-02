---
layout: post
title: Podman ルートレスコンテナでのネットワークのメモ
date: '2022-04-02T23:43:36+09:00'
tags: podman linux チラシの裏
---

従来の docker では、コンテナに IP アドレスが `172.xxx.xxx.xxx` のように割り当てられていた。
このアドレスは下記で取得可能。

{% raw %}
```bash
docker inspect -f '{{ .NetworkSettings.IPAddress }}' コンテナID
```
{% endraw %}

コンテナ内でポートを開いた時、とくに何もせずとも `172.xxx.xxx.xxx` のポート5432をアクセスすればよい。

しかしルートレスコンテナの場合、IPアドレスが付与されない。

通信するには、明示的に`-p`オプションを使ってコンテナのポートをホストに公開するのが簡単である。

```bash
podman run --name=pg --rm -it \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  docker.io/library/postgres:alpine
```

このときホスト側から `127.0.0.1:5432` にアクセスしてコンテナ内のサーバにアクセスができる。

```bash
psql -h 127.0.0.1 -U postgres -p 5432 postgres
```

コンテナどおしで通信する場合は、単一ポッドに入れる方法と、ポートマッピングを駆使する方法がある。
簡単なのは通信する必要があるコンテナを単一ポッドに入れてしまう方法だ。

```bash
podman run --name=pg --rm -it \
  -e POSTGRES_PASSWORD=mysecretpassword \
  --pod new:mypod \
  docker.io/library/postgres:alpine
```

同様に

```bash
podman run --name=psql --rm -it \
  --pod mypod \
  docker.io/library/postgres:alpine \
  psql -h pg -U postgres
```

こうすると同一のポッド`mypod`内にある２つのコンテナは自然にアクセスできる。
この例では、片方のコンテナから 127.0.0.1 の 5432 ポートを叩くと自然にもう片方のコンテナのサーバにアクセスできる。

さらに、ポートをホストに公開するには、一旦`podman pod create`を実行して、ここで`-p`オプションを使ってコンテナのポートをホストに公開する必要がある。

```bash
podman pod create mypod -p 5432:5432
podman run --name=pg --rm -it
  -e POSTGRES_PASSWORD=mysecretpassword \
  --pod mypod \
  docker.io/library/postgres:alpine
```


## 参考文献

 * Brent Baude, "[Configuring container networking with Podman \| Enable Sysadmin](https://www.redhat.com/sysadmin/container-networking-podman)", Enable Sysadmin, Redhat, Oct 28, 2019


