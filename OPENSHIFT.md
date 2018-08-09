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


$ oc config set-cluster rnd --server=https://ocp-sbx.vdab.be:8443
$ oc new-app cbonami/nifi:openshift 
$ oc import-image nifi:openshift
