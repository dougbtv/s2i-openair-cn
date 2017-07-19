## s2i-openair-cn

An s2i ([source-to-image](https://github.com/openshift/source-to-image)) template for building the OpenAirInterface openair-cn images.

## OAI s2i building scheme

I'm referencing my [blog article on using s2i custom builders](http://dougbtv.com/nfvpe/2016/12/09/openshift-s2i-custom-builder/)

## Install the s2i tool

Seeing the s2i tool doesn't come with an OpenShift Origin install by default, we'll need to install it ourself.

```
[centos@openshift-master ~]$ curl -L -O https://github.com/openshift/source-to-image/releases/download/v1.1.7/source-to-image-v1.1.7-226afa1-linux-386.tar.gz
[centos@openshift-master ~]$ tar -xzvf source-to-image-v1.1.7-226afa1-linux-386.tar.gz 
[centos@openshift-master ~]$ sudo mv {s2i,sti} /usr/bin/
[centos@openshift-master ~]$ s2i version
s2i v1.1.7
```

## Building with s2i

Clone this repo.

```
[centos@openshift-master tmp]$ git clone https://github.com/dougbtv/s2i-openair-cn.git
[centos@openshift-master tmp]$ cd s2i-openair-cn/
```

Clone the openair-cn into `/tmp` (in this example, could be anywhere). Then checkout the version you want to build.

```
[centos@openshift-master tmp]$ git clone https://gitlab.eurecom.fr/oai/openair-cn.git
[centos@openshift-master tmp]$ cd openair-cn/
[centos@openshift-master openair-cn]$ git checkout -b to_build 724542d0b59797b010af8c5df15af7f669c1e838
```

Before we kick off the build, we build the base image.

```
[root@openshift-master s2i-openair-cn]# docker build -t nfvpe/oai .
```

Then we can kick off the s2i build

```
[root@openshift-master s2i-openair-cn]# s2i build test/openair-cn/ nfvpe/oai nfvpe/oai-hss-poc
```

## Pushing the image to a registry

For more information you may reference [this openshift blog article](https://blog.openshift.com/remotely-push-pull-container-images-openshift/) on using the OpenShift registry.

Create a service account (SA), called `pusher`

```
[root@openshift-master centos]# oc create -f - << API

apiVersion: v1

kind: ServiceAccount

metadata:

  name: pusher

API
serviceaccount "pusher" created
```

```
[root@openshift-master centos]# oc policy add-role-to-user system:image-builder system:serviceaccount:pushed:pusher
role "system:image-builder" added: "system:serviceaccount:pushed:pusher"
```

Describe that service account

```
[root@openshift-master centos]# oc describe sa pusher
Name:       pusher
Namespace:  default
Labels:     <none>

Image pull secrets: pusher-dockercfg-gphjp

Mountable secrets:  pusher-dockercfg-gphjp
                    pusher-token-40qhx

Tokens:             pusher-token-40qhx
                    pusher-token-zn8mf
```

Describe the token, the resulting token will be our password when we login.

```
[root@openshift-master centos]# oc describe secret pusher-token-40qhx
Name:       pusher-token-40qhx
Namespace:  default
Labels:     <none>
Annotations:    kubernetes.io/service-account.name=pusher
        kubernetes.io/service-account.uid=1b8fe54d-6cc4-11e7-a1f9-525400191ddd

Type:   kubernetes.io/service-account-token

Data
====
token:      eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InB1c2hlci10b2tlbi00MHFoeCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJwdXNoZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIxYjhmZTU0ZC02Y2M0LTExZTctYTFmOS01MjU0MDAxOTFkZGQiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpwdXNoZXIifQ.BLARfQ9Amw7KuOUmdxBz2yjqmaP4AGmXfkow9r71VdXWbz96T6gkD4ezQLQZWFim3_vhBoCt9IeFuyy0rX9s3NoEWoKtoZHF5LqnY0kbuHiROyeoyidg2WNZqjunKND16jYVRtVcgu4f7PX4cnG16mZV0KAl7dmNmH9WLDghXYRjIiOhAOxX9yeXzFjTTMIYZBYjIitTPY1Tf8HpaECAsWloiLOiRTTW6FEXf_qCeDBdqLD_J4r1lmjDXwLvtFV7Ze6t604-mLB2k6RJbd-vQ0w2xG3hzA4gw0KanHW9VBSarxhCs6iuko-g_ghNmlPdpMr34znEYOH_A8d0qJBNeg
ca.crt:     1070 bytes
namespace:  7 bytes
service-ca.crt: 2186 bytes
```



```
[root@openshift-master centos]# oc create -f - <<API

apiVersion: v1

kind: ImageStream

metadata:

  annotations:

    description: Keeps track of changes in the application image

  name: myimage

API
imagestream "myimage" created
```

Discovery the registry location (if you have a better DNS setup, this might be more simple)...

```
[centos@openshift-master ~]$ registrylocation=$(echo "$(oc describe service docker-registry --namespace=default | grep "^IP" | awk '{print $2}'):5000")
```

Login, using anything for the username, and password should be the token from above.

```
[root@openshift-master centos]# docker login $registrylocation
Username: anything
Password: 
Login Succeeded
```

You can now tag an image built with s2i...

```
[root@openshift-master centos]# docker tag nfvpe/oai-hss-poc $registrylocation/default/oai-hss-poc
[root@openshift-master centos]# docker push $registrylocation/default/oai-hss-poc
```

(Currently bombs out for me.)

## Creating an s2i template

This is how the templates here were created.

```
[centos@openshift-master ~]$ s2i create openair-cn s2i-openair-cn
[centos@openshift-master ~]$ cd s2i-openair-cn/
[centos@openshift-master s2i-openair-cn]$ find .
.
./s2i
./s2i/bin
./s2i/bin/assemble
./s2i/bin/run
./s2i/bin/usage
./s2i/bin/save-artifacts
./Dockerfile
./README.md
./test
./test/test-app
./test/test-app/index.html
./test/run
./Makefile
```

(That's this repo, now)
