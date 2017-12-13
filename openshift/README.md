# Install on OpenShift with EnMasse

This document requires a dedicated OpenShift 3.7 cluster setup.

Things to do:

 - [ ] Separate EnMasse from Hono project/namespace
 - [ ] Separate Grafana from Hono project/namespace
 - [ ] Enable Grafana "Guest"
 - [ ] Switch to Grafana 4.7
 - [ ] Enable datasource provisioning (requires Grafana 4.7)
 - [ ] Enable dashboard provisioning (requires Grafana 4.7)

## Deploy EnMasse

Download: https://github.com/EnMasseProject/enmasse/releases/tag/0.13.2

~~~sh
wget https://github.com/EnMasseProject/enmasse/releases/download/0.13.2/enmasse-0.13.2.tgz
tar xzf enmasse-0.13.2.tgz
cd enmasse-0.13.2
~~~

## Create PVs

You need to create a set of PVs. Grafana, InfluxDB and the Hono Device registry need a persistent storage.

**Note:** Creating PVs is a cluster admin task.

This setup provides examples for two storage types: NFS and local disk. The examples are located
in the directory [admin/](admin/). You only need to create one type.

Adapt the files to your needs and execute them like this:

~~~sh
oc create -f admin hono-pv-nfs.yml
oc create -f admin grafana-pv-nfs.yml
…
~~~

**Note:** Local disk PVs only work in a single node OpenShift setup

Also see:

* [OpenShift: Persistent Storage](https://docs.openshift.org/latest/architecture/additional_concepts/storage.html)

## Deploy Hono template

The Hono template is located at: [hono.yml](hono.yml). It needs to be processes and executed.

This can be done from the command line like this:

~~~sh
oc process -f hono.yml | oc create -f -
~~~

You can set template parameters like that:

~~~sh
oc process -f hono.yml \
   -p "GIT_REPOSITORY=https://github.com/ctron/hono" 
   -p "GIT_BRANCH=feature/enable_s2i"| oc create -f -
~~~

**Note:** Currently you will need to set the following parameters:

* `GIT_REPOSITORY=https://github.com/ctron/hono`
* `GIT_BRANCH=feature/enable_s2i`

See also:
* [OpenShift: Templates](https://docs.openshift.org/latest/dev_guide/templates.html) 

## Deploy Grafana template

The Hono template is located at: [grafana.yml](grafana.yml). It needs to be processes and executed.
Please see [Deploy Hono template](#deploy-hono-template) for more information about deploying a
template. 