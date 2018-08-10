FROM openjdk:8-jdk-slim

ARG NIFI_REGISTRY_VERSION=0.2.0
ARG MIRROR=https://archive.apache.org/dist

ENV NIFI_REGISTRY_BASE_DIR=/opt/nifi-registry
ENV NIFI_REGISTRY_HOME=${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION} \
    NIFI_REGISTRY_BINARY_URL=nifi/nifi-registry/nifi-registry-${NIFI_REGISTRY_VERSION}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz

ADD sh/ ${NIFI_REGISTRY_BASE_DIR}/scripts/
RUN chmod +x ${NIFI_REGISTRY_BASE_DIR}/scripts/*.sh

# jdbc driver
ADD lib/ ${NIFI_REGISTRY_BASE_DIR}/jdbc/

# Setup NiFi-Registry user
RUN apt-get update -y \
    && apt-get install -y curl jq xmlstarlet git

# Download, validate, and expand Apache NiFi-Registry binary.
RUN curl -fSL ${MIRROR}/${NIFI_REGISTRY_BINARY_URL} -o ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz \
    && echo "$(curl ${MIRROR}/${NIFI_REGISTRY_BINARY_URL}.sha256) *${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz" | sha256sum -c - \
    && tar -xvzf ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz -C ${NIFI_REGISTRY_BASE_DIR} \
    && rm ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz

# unfortunately nifi registry wants the folder to be git-initialized up front
RUN mkdir -p ${NIFI_REGISTRY_HOME}/flow_storage && git init ${NIFI_REGISTRY_HOME}/flow_storage

# prevent 'Permission Denied' on OpenShift
RUN chmod -R 0777 ${NIFI_REGISTRY_HOME}

# Web HTTP(s) ports
EXPOSE 18080 18443

WORKDIR ${NIFI_REGISTRY_HOME}

# Apply configuration and start NiFi Registry
CMD ${NIFI_REGISTRY_BASE_DIR}/scripts/start.sh