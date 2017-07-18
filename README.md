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

## Create a template

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

## The Dockerfile

(more to come.)

