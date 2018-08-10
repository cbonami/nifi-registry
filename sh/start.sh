#!/bin/sh -e

scripts_dir='/opt/nifi-registry/scripts'

[ -f "${scripts_dir}/common.sh" ] && . "${scripts_dir}/common.sh"

# Establish baseline properties
prop_replace 'nifi.registry.web.http.port'      "${NIFI_REGISTRY_WEB_HTTP_PORT:-18080}"
prop_replace 'nifi.registry.web.http.host'      "${NIFI_REGISTRY_WEB_HTTP_HOST:-$HOSTNAME}"

. "${scripts_dir}/update_database.sh"

#echo "-------------------------------------------------------------------------------------"
#cat  /opt/nifi-registry/nifi-registry-0.2.0/conf/nifi-registry.properties

# Check if we are secured or unsecured
case ${AUTH} in
    tls)
        echo 'Enabling Two-Way SSL user authentication'
        . "${scripts_dir}/secure.sh"
        ;;
    ldap)
        echo 'Enabling LDAP user authentication'
        # Reference ldap-provider in properties
        prop_replace 'nifi.registry.security.identity.provider' 'ldap-identity-provider'
        prop_replace 'nifi.registry.security.needClientAuth' 'false'

        . "${scripts_dir}/secure.sh"
        . "${scripts_dir}/update_login_providers.sh"
        ;;
esac

. "${scripts_dir}/update_flow_provider.sh"

#echo "-------------------------------------------------------------------------------------"
#cat  /opt/nifi-registry/nifi-registry-0.2.0/conf/nifi-registry.properties

# Continuously provide logs so that 'docker logs' can produce them
tail -F "${NIFI_REGISTRY_HOME}/logs/nifi-registry-app.log" &
"${NIFI_REGISTRY_HOME}/bin/nifi-registry.sh" run &
nifi_registry_pid="$!"

trap "echo Received trapped signal, beginning shutdown...;" KILL TERM HUP INT EXIT;

echo NiFi-Registry running with PID ${nifi_registry_pid}.
wait ${nifi_registry_pid}