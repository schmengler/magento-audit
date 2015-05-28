#!/bin/sh

# Run system check first to see if Magento folder detected (error messages from magerun are printed to STDERR)
if [bin/n98-magerun.phar sys:check >/dev/null]; then
    exit
fi;

echo "Install addons..."
bin/install-addons.sh
echo ""

MAGENTO_VERSION=$(bin/n98-magerun.phar sys:info --format=csv | \grep Version | sed s/Version,//)
if [ ! -d ~/magento-$MAGENTO_VERSION ]; then
    echo "Download Magento ${MAGENTO_VERSION}..."
    mkdir ~/magento-$MAGENTO_VERSION || exit
    curl http://www.magentocommerce.com/downloads/assets/$MAGENTO_VERSION/magento-$MAGENTO_VERSION.tar.gz | tar -xz -C ~/magento-$MAGENTO_VERSION
    echo ""
fi;
mkdir -p var/audit || exit
echo "Generate reports..."
bin/n98-magerun.phar sys:module:list --format=csv > var/audit/modules.csv
php downloader/mage.php list-upgrades | sed -r 's/\s+(\w+): (.*) => (.*)/\1;\2;\3/' > var/audit/module-updates-from-connect.csv
bin/n98-magerun.phar sys:info --format=csv > var/audit/sysinfo.csv
bin/n98-magerun.phar mpmd:codepooloverrides var/audit/codepooloverrides.html
bin/n98-magerun.phar mpmd:corehacks ~/magento-$MAGENTO_VERSION/magento var/audit/corehacks.html
bin/n98-magerun.phar dev:module:rewrite:list --format=csv > var/audit/rewrites.csv
bin/n98-magerun.phar dev:module:rewrite:conflicts --log-junit=var/audit/rewrite-conflicts.xml
bin/phpcs.phar --report=csv --report-file=var/audit/phpcs.csv --ignore=code/core --standard=~/.phpcs/Ecg app