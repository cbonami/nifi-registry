#!/bin/sh -e
prop_replace 'nifi.registry.db.url'                         "${NIFI_REGISTRY_DB_URL:-jdbc:h2:./database/nifi-registry-primary;AUTOCOMMIT=OFF;DB_CLOSE_ON_EXIT=FALSE;LOCK_MODE=3;LOCK_TIMEOUT=25000;WRITE_DELAY=0;AUTO_SERVER=FALSE}"
prop_replace 'nifi.registry.db.driver.class'                "${NIFI_REGISTRY_DB_CLASS:-org.h2.Driver}"
prop_replace 'nifi.registry.db.driver.directory'            "${NIFI_REGISTRY_DB_DIR:-}"

echo "postgres_pasword ${POSTGRES_PASSWORD}"
echo "NIFI_REGISTRY_DB_PASS ${NIFI_REGISTRY_DB_PASS}"

prop_replace 'nifi.registry.db.driver.username'             "${NIFI_REGISTRY_DB_USER:-nifireg}"
prop_replace 'nifi.registry.db.driver.password'             "${NIFI_REGISTRY_DB_PASS:-nifireg}"
prop_replace 'nifi.registry.db.driver.maxConnections'       "${NIFI_REGISTRY_DB_MAX_CONNS:-5}"
prop_replace 'nifi.registry.db.sql.debug'                   "${NIFI_REGISTRY_DB_DEBUG_SQL:-false}"