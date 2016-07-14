#!/bin/bash

MAGENTO_ROOT=""
MAGERUN_PARAM=""
while getopts :r: FLAG; do
    case $FLAG in
      r)
        MAGENTO_ROOT="$OPTARG/"
        MAGERUN_PARAM="--root-dir=$MAGENTO_ROOT"
        ;;
     esac
done

# Run system check first to see if Magento folder detected (error messages from magerun are printed to STDERR)
if [bin/n98-magerun.phar $MAGERUN_PARAM sys:check >/dev/null]; then
    exit
fi;

echo "Install addons..."
bin/install-addons.sh
echo ""

MAGENTO_VERSION=$(bin/n98-magerun.phar $MAGERUN_PARAM sys:info --format=csv | \grep Version | sed s/Version,//)
if [ ! -d ~/magento-$MAGENTO_VERSION ]; then
    echo "Download Magento ${MAGENTO_VERSION}..."
    mkdir ~/magento-$MAGENTO_VERSION || exit
    curl http://www.magentocommerce.com/downloads/assets/$MAGENTO_VERSION/magento-$MAGENTO_VERSION.tar.gz | tar -xz -C ~/magento-$MAGENTO_VERSION
    echo ""
fi;
mkdir -p ${MAGENTO_ROOT}var/audit || exit
echo "Generate reports..."
bin/n98-magerun.phar $MAGERUN_PARAM sys:module:list --format=csv > ${MAGENTO_ROOT}var/audit/modules.csv
php ${MAGENTO_ROOT}downloader/mage.php list-upgrades | sed -r 's/\s+(\w+): (.*) => (.*)/\1;\2;\3/' > ${MAGENTO_ROOT}var/audit/module-updates-from-connect.csv
bin/n98-magerun.phar $MAGERUN_PARAM sys:info --format=csv > ${MAGENTO_ROOT}var/audit/sysinfo.csv
bin/n98-magerun.phar $MAGERUN_PARAM mpmd:codepooloverrides ${MAGENTO_ROOT}var/audit/codepooloverrides.html
bin/n98-magerun.phar $MAGERUN_PARAM mpmd:corehacks ~/magento-$MAGENTO_VERSION/magento ${MAGENTO_ROOT}var/audit/corehacks.html
bin/n98-magerun.phar $MAGERUN_PARAM dev:module:rewrite:list --format=csv > ${MAGENTO_ROOT}var/audit/rewrites.csv
bin/n98-magerun.phar $MAGERUN_PARAM dev:module:rewrite:conflicts --log-junit=${MAGENTO_ROOT}var/audit/rewrite-conflicts.xml
bin/phpcs.phar --report=csv --report-file=${MAGENTO_ROOT}var/audit/phpcs.csv --ignore=code/core --standard=~/.phpcs/Ecg/Ecg ${MAGENTO_ROOT}app
