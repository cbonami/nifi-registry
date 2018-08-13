# NiFi on OpenShift

## TODO

* Get rid of evil chmod -R 0777 in Dockerfiles --> go (back) to system of original apache image with UID etc
* Find out how we can extract secrets/env vars from files in temporarily mounted volumes (https://livebook.manning.com/#!/book/openshift-in-action/chapter-6/150)

## SetUp OC CLI

```bash
oc config set-cluster rnd --server=https://ocp-sbx.vdab.be:8443
```

Login via login command / token that can be copied from OpenShift UI Dashboard.

oc login https://ocp-sbx.vdab.be:8443 --token=1T0-Di44drqvg2AdkpxaJ3gNGs0z0SK-VFCqBXQ_H9I

## Access Private Docker Registry

The registry from which the ImageStream pulls the image, is a private docker.io registry.
We create a secret called 'dockerhub', as per [these instructions](https://docs.openshift.com/container-platform/3.5/dev_guide/managing_images.html#private-registries).

```bash
oc create secret generic dockerhub \
    --from-file=.dockerconfigjson=/home/bonami/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson
```

## Secrets

```bash
oc create secret generic github-nifi-registry --from-literal=NIFI_REGISTRY_GIT_PASSWORD=85e7756e6112ce7f12d9b4350e8e94924211ac5c
```

## NiFi

```bash
# create the NiFi app from a docker hub image
# openshift ImageStream will be automatically created
oc new-app cbonami/nifi:openshift
oc expose svc/... 

# refresh the OpenShift ImageStream when there's a new version of the docker image available
oc import-image nifi:openshift
```

## NiFi Registry

### Git(Hub) setup

https://bryanbende.com/development/2018/06/20/apache-nifi-registry-0-2-0

### Deploy in OpenShift

```bash
# create a new app simply based on an external docker image;
# openshift ImageStream will be automatically created
oc new-app cbonami/nifi-registry:openshift
oc expose svc/... 

# execute this when underlying image has changed
oc import-image nifi-registry:openshift

# add some env vars to the DeploymentConfig
oc env dc/nifi-registry NIFI_REGISTRY_DB_URL=jdbc:postgresql://172.30.229.191:5432/nifireg \
  NIFI_REGISTRY_DB_CLASS=org.postgresql.Driver \
  NIFI_REGISTRY_DB_DIR=/opt/nifi-registry/jdbc \
  NIFI_REGISTRY_DB_USER=nifireg \
  NIFI_REGISTRY_DB_PASS=verysecret \
  NIFI_REGISTRY_DB_MAX_CONNS=5 \
  NIFI_REGISTRY_DB_DEBUG_SQL=false

oc env dc/nifi-registry NIFI_REGISTRY_FLOW_PROVIDER=git \
    NIFI_REGISTRY_GIT_REMOTE=origin \
    NIFI_REGISTRY_GIT_USER=cbonami \
    NIFI_REGISTRY_FLOW_STORAGE_DIR=./flow_storage
```

I used the dashboard to include the secret 'github-nifi-registry' in the set of env vars.
  
## Backup

```bash
oc export all -o yaml > project.yaml
```
 
## Links

[Spring Boot solo but no build](https://medium.com/@pablo127/deploy-spring-boot-application-to-openshift-3-next-gen-2b311f55f0c5)
[Spring Boot on WildFly](https://blog.openshift.com/using-spring-boot-on-openshift/)
[Fabric 8](http://www.mastertheboss.com/jboss-frameworks/spring/deploy-your-springboot-applications-on-openshift)
[Getting any container running on OpenShift](https://blog.openshift.com/getting-any-docker-image-running-in-your-own-openshift-cluster/)
[OpenShift in 30 mins](http://feedhenry.org/hero-openshift/)
[Image Stream](http://feedhenry.org/hero-openshift/)
[Fabri8 Maven Plugin](https://maven.fabric8.io/)
[Permission denied - runAsUser](https://github.com/openshift/origin/issues/18974)
[Permission Denied issue](https://github.com/moby/moby/issues/1295)
[oc cli](https://docs.openshift.com/enterprise/3.2/cli_reference/manage_cli_profiles.html#cli-reference-manage-cli-profiles)

[PersistentVolumeClaim on OpenShift](https://dzone.com/articles/persistent-storage-with-openshift-or-kubernetes)
[PersistentVolumeClaim on OpenShift](https://docs.openshift.com/enterprise/3.1/dev_guide/persistent_volumes.html)
[PersistentVolumeClaim on Kubernetes](https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/#deploy-mysql)
  
[Port forwarding to connect to database](https://blog.openshift.com/openshift-connecting-database-using-port-forwarding/)