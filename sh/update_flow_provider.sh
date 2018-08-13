#!/bin/sh -e

providers_file=${NIFI_REGISTRY_HOME}/conf/providers.xml
property_xpath='/providers/flowPersistenceProvider'


add_property() {
  property_name=$1
  property_value=$2

  if [ -n "${property_value}" ]; then
    xmlstarlet ed --inplace --subnode "/providers/flowPersistenceProvider" --type elem -n propertytemp -v "${property_value}" "${providers_file}"
    xmlstarlet ed --inplace --subnode "/providers/flowPersistenceProvider/propertytemp" --type attr -v "${property_name}" "${providers_file}"
    xmlstarlet ed --inplace --r "/providers/flowPersistenceProvider/propertytemp" -v "property" "${providers_file}"
  fi
}

xmlstarlet ed --inplace -u "${property_xpath}/property[@name='Flow Storage Directory']" -v "${NIFI_REGISTRY_FLOW_STORAGE_DIR:-./flow_storage}" "${providers_file}"

case ${NIFI_REGISTRY_FLOW_PROVIDER} in
    file)
        xmlstarlet ed --inplace -u "${property_xpath}/class" -v "org.apache.nifi.registry.provider.flow.FileSystemFlowPersistenceProvider" "${providers_file}"
        ;;
    git)
        xmlstarlet ed --inplace -u "${property_xpath}/class" -v "org.apache.nifi.registry.provider.flow.git.GitFlowPersistenceProvider" "${providers_file}"
        #remove all property-s
        xmlstarlet ed --inplace -d "/providers/flowPersistenceProvider/property" "${providers_file}"
        #add new properties
        add_property "Flow Storage Directory"  "${NIFI_REGISTRY_FLOW_STORAGE_DIR:-}"
        add_property "Remote To Push"  "${NIFI_REGISTRY_GIT_REMOTE:-}"
        add_property "Remote Access User"  "${NIFI_REGISTRY_GIT_USER:-}"
        add_property "Remote Access Password"    "${NIFI_REGISTRY_GIT_PASSWORD:-}"
        ;;
esac



xmlstarlet ed --inplace --subnode "/providers/flowPersistenceProvider" --type elem -n property -v "bla" "./test.xml"
xmlstarlet ed --inplace --subnode "/providers/flowPersistenceProvider/property[not(name)]" --type attr -n name -v "Flow Storage Directory" "./test.xml"