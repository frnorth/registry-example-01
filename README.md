---
description: an example of self built registry, with pull-cache and push local images
keywords: registry, pull-cache, push, images, repository, distribution, recipes
title: One example
---

An example list below was a summary of "Docker Registry" documetation, which contains:
1. authenticate proxy with nginx  
2. pull-cache  
3. local storage of self built and pushed images  

# Mechanism

Once a self registry is built as a pull-cache, it can not be used as a local warehouse to push images. The solution is compose another registry on port 442, with the same data volum as the pull-cache registry.

# Setup
1. Docker and docker-compuse should be installed first, and instructions below may be followed then, where `yourname` and `yourpasword` is your id and password to `https://hub.docker.com`, for the purpose of pull-cache   
```
git clone https://github.com/frnorth/registry-example-01.git ~/
cd ~/registry-example-01
sed -i 's/xxxxxx/yourname/' ./pull/config.yml
sed -i 's/******/yourpassword/' ./pull/config.yml
./setup.sh
```
2. A self signed `./pull/auth/my.crt` certificate with a domain name `"https://docker.my.com"` was used as a local test. If you want to use it, then:  
```
cd ~/registry-example-01
cp ./pull/auth/my.crt /etc/pki/ca-trust/source/anchors/
cp ./pull/auth/my.crt /etc/docker/certs.d/
update-ca-trust
systemctl restart docker
```
> Above are in Centos, if want to use Ubuntu:
```
/etc/pki/ca-trust/source/anchors/ --> /usr/local/share/ca-certificates/
```

# Test
Test it with username: `admin`, password `123456` for docker login, and curl:    
1. First you may add record in to `/etc/hosts`, or set up a local `dns server`, or get a real `ca.crt` to replace `my.crt`:
```
echo xxx.xxx.xxx.xxx >> /etc/hosts    # xxx.xxx.xxx.xxx is ip address
```
2. pull-cache:
```
curl -u admin:123456 https://docker.my.com/v2/_catalog
docker login https://docker.my.com
docker pull docker.my.com/library/busybox:latest
curl -u admin:123456 https://docker.my.com/v2/_catalog
```
3. push locally:
```
docker login https://docker.my.com:442
docker tag docker.my.com/library/busybox:latest docker.my.com:442/local/busybox:latest
docker push docker.my.com:442/local/busybox:latest
curl -u admin:123456 https://docker.my.com/v2/_catalog
```
> Now you can push through port 442, and pull through default, be sure to login to both port.
