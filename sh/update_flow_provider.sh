#!/bin/sh -e

echo "update_flow_provider.sh 1"

providers_file=${NIFI_REGISTRY_HOME}/conf/providers.xml
property_xpath='/providers/flowPersistenceProvider'

echo "update_flow_provider.sh $providers_file"
cat $providers_file

add_property() {
  property_name=$1
  property_value=$2

  if [ -n "${property_value}" ]; then
    xmlstarlet ed --subnode "/providers/flowPersistenceProvider" --type elem -n property -v "${property_value}" "${providers_file}" | xmlstarlet ed --subnode "/providers/flowPersistenceProvider/property[not(name)]" --type attr -n name -v "${property_name}"
  fi
}

echo "update_flow_provider.sh 2"

xmlstarlet ed --inplace -u "${property_xpath}/property[@name='Flow Storage Directory']" -v "${NIFI_REGISTRY_FLOW_STORAGE_DIR:-./flow_storage}" "${providers_file}"

case ${NIFI_REGISTRY_FLOW_PROVIDER} in
    file)
        xmlstarlet ed --inplace -u "${property_xpath}/class" -v "org.apache.nifi.registry.provider.flow.FileSystemFlowPersistenceProvider" "${providers_file}"
        ;;
    git)
        echo "update_flow_provider.sh 3"
        xmlstarlet ed --inplace -u "${property_xpath}/class" -v "org.apache.nifi.registry.provider.flow.git.GitFlowPersistenceProvider" "${providers_file}"
        echo "update_flow_provider.sh 4"
        add_property "Remote To Push"  "${NIFI_REGISTRY_GIT_REMOTE:-}"
        echo "update_flow_provider.sh 5"
        add_property "Remote Access User"  "${NIFI_REGISTRY_GIT_USER:-}"
        echo "update_flow_provider.sh 6"
        add_property "Remote Access Password"    "${NIFI_REGISTRY_GIT_PASSWORD:-}"
        echo "update_flow_provider.sh end"
        ;;
esac