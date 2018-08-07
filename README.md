# NIFI Registry

## Build cbonami/nifi-registry

Currently the docker image for the NIFI Registry is built by Travis CI, and pushed to Docker Hub.

* See [.travis.yml](./.travis.yml)
* See [Dockerfile](./Dockerfile)

## Unsecurely run Apache [NIFI registry](https://hub.docker.com/r/apache/nifi-registry/)

Before we can run Apache NIFI itself, we need to have a NIFI Registry up & running.

> Preferably we should run the NIFI Registry securely (TLS-authentication), but I encountered some exceptions. See next section. 

Start the container:

```bash
# we log in to Docker Hub (or any other registry, like VDAB's private registry)
$ sudo docker login

Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username (cbonami): 
Password: 
Login Succeeded

# we run the NIFI registry
$ sudo docker-compose -f ./docker-compose-registry-unsecure.yml up
```

Point your browser to [http://nifi-registry:18080/nifi-registry](http://nifi-registry:18080/nifi-registry).

## Securely Run Apache [NIFI registry](https://hub.docker.com/r/apache/nifi-registry/)

> !!! Not working yet due to [some weird Kerberos-exception](https://community.hortonworks.com/questions/186317/unable-to-obtain-listing-of-buckets.html?childToView=210127#answer-210127); result is that the Nifi Registry UI doesn't show all the protected widgets. I think it is related to the usage of 'localhost' as a hostname in combination with docker.

Before we can run Apache NIFI itself, we need to have a NIFI Registry up & running.
The NIFI Registry is protected by Client Certificate Authentication (2-way SSL/TLS).

The following is partially based on [video instructions here](https://youtu.be/qD03ao3R-a4) and on the [Hortonworks Documentation](https://community.hortonworks.com/content/kbentry/171173/setting-up-a-secure-nifi-to-integrate-with-a-secur.html).

In order to generate the client certificates, execute the following command:

```bash
$ ./nifi-toolkit-1.7.1/bin/tls-toolkit.sh standalone -n "nifi-registry" -C "CN=sys_admin, OU=NIFI" -o ./nifi-reg/certs -O
```
dedicated, reserved
In [./nifi-reg/certs/](./nifi-reg/certs/) and [./nifi-reg/certs/nifi-registry/](./nifi-reg/certs/nifi-registry/), some files are generated:

* keystore/truststore.jks : these files will be copied into the docker image
* nifi.properties: there you can find values for KEYSTORE_PASSWORD and TRUSTSTORE_PASSWORD that need to be provided in docker-compose-registry.yml.
* CN=sys_admin_OU=NIFI.p12 : this is the certificate that you need to import in Chrome
* CN=sys_admin_OU=NIFI.password : this is the password that you will need to use while importing the p12 certificate

Import the p12 certificate in your local Chrome browser, as explained [here](https://support.globalsign.com/customer/portal/articles/1215006-install-pkcs-12-file---linux-ubuntu-using-chrome).
You will have to provide the password in the .password file.

Make sure that you have copied the right values of KEYSTORE_PASSWORD and TRUSTSTORE_PASSWORD in _docker-compose-registry.yml_.
See _nifi.security.*_ in the generated nifi.properties.

Now let's start the container hosting the NIFI-registry: 
```bash
# we log in to Docker Hub (or any other registry, like VDAB's private registry)
$ sudo docker login

# we start the container(s)
$ sudo docker-compose -f ./docker-compose-registry-tls.yml up
```

Point Chrome to [https://nifi-registry:18443/nifi-registry](https://nifi-registry:18443/nifi-registry).
You'll be prompted to select the certificate that you imported in Chrome before. Select it.
You're in.

## Links

* [NIFI Registry SysAdmin Guide](https://nifi.apache.org/docs/nifi-registry-docs/html/administration-guide.html)
* [Using Git with NIFI Registry](https://dzone.com/articles/quick-tip-using-git-with-nifi-registry-in-docker)
* https://pierrevillard.com/2018/04/09/automate-workflow-deployment-in-apache-nifi-with-the-nifi-registry/
