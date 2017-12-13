# Install on OpenShift with EnMasse

This document requires a dedicated OpenShift 3.7 cluster setup.

Things to do:

 - [X] Separate EnMasse from Hono project/namespace
 - [X] Separate Grafana from Hono project/namespace
 - [ ] Enable Grafana "Guest"
 - [ ] Switch to Grafana 4.7
 - [ ] Enable datasource provisioning (requires Grafana 4.7)
 - [ ] Enable dashboard provisioning (requires Grafana 4.7)

## Deploy EnMasse

Login in to OpenShift and create a new EnMasse project:

~~~sh
oc login
oc new-project enmasse --display-name='EnMasse Instance'
~~~

Download and unpack EnMasse:

~~~sh
wget https://github.com/EnMasseProject/enmasse/releases/download/0.13.2/enmasse-0.13.2.tgz
tar xzf enmasse-0.13.2.tgz
cd enmasse-0.13.2
~~~

Deploy EnMasse:

~~~sh
./deploy-openshift.sh -n enmasse -m https://dchp153.coe:8443 -u developer
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

## Create configuration in EnMasse

~~~sh
PROJECT=enmasse
curl -X PUT -T "addresses.json" -H "content-type: application/json" http://$(oc -n "$PROJECT" get route restapi -o jsonpath='{.spec.host}')/v1/addresses/default
~~~

## Deploy Hono template

Create a new project for Hono:

~~~sh
oc new-project hono --display-name='Eclipse Hono™'
~~~

Create the InfluxDB ConfigMap from a local file:

~~~sh
oc -n hono create configmap influxdb-config --from-file="../example/target/config/influxdb.conf"
~~~

The Hono template is located at: [hono.yml](hono.yml). It needs to be processed and executed.

This can be done from the command line like this:

~~~sh
oc process -f hono.yml | oc create -f -
~~~

You can set template parameters like that:

~~~sh
oc process -f hono.yml \
   -p "ENMASSE_NAMESPACE=enmasse" \
   -p "GIT_REPOSITORY=https://github.com/ctron/hono" \
   -p "GIT_BRANCH=feature/support_s2i"| oc create -f -
~~~

**Note:** Currently you will need to set the following parameters:

* `ENMASSE_NAMESPACE=enmasse`
* `GIT_REPOSITORY=https://github.com/ctron/hono`
* `GIT_BRANCH=feature/support_s2i`

See also:
* [OpenShift: Templates](https://docs.openshift.org/latest/dev_guide/templates.html) 

## Deploy Grafana template

Create a new project for Grafana:

~~~sh
oc new-project grafana --display-name='Grafana Dashboard'
~~~

The Hono template is located at: [grafana.yml](grafana.yml). It needs to be processes and executed.
Please see [Deploy Hono template](#deploy-hono-template) for more information about deploying a
template.

~~~sh
oc process -f grafana.yml | oc create -f -
~~~

If you want to stick to the default "admin" password use:

~~~sh
oc process -f grafana.yml -p ADMIN_PASSWORD=admin | oc create -f -
~~~
