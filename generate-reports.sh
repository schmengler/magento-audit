#!/bin/sh

# Run system check first to see if Magento folder detected (error messages from magerun are printed to STDERR)
if bin/n98-magerun.phar sys:check >/dev/null then;
    exit
fi;

echo "Install addons..."
bin/install-addons.sh
echo ""

MAGENTO_VERSION=$(n98-magerun sys:info --format=csv | \grep Version | sed s/Version,//)
if [ ! -d ~/magento-$MAGENTO_VERSION ]; then;
    echo "Download Magento ${MAGENTO_VERSION}..."
    mkdir ~/magento-$MAGENTO_VERSION || exit
    curl http://www.magentocommerce.com/downloads/assets/$MAGENTO_VERSION/magento-$MAGENTO_VERSION.tar.gz | tar -xz -C ~/magento-$MAGENTO_VERSION
    echo ""
fi;
mkdir -p var/audit || exit
echo "Generate reports..."
bin/n98-magerun.phar sys:module:list --format=csv > audit/modules.csv
php www/downloader/mage.php list-upgrades | sed -r 's/\s+(\w+): (.*) => (.*)/\1;\2;\3/' > audit/module-updates-from-connect.csv
bin/n98-magerun.phar sys:info --format=csv > audit/sysinfo.csv
bin/n98-magerun.phar mpmd:codepooloverrides audit/codepooloverrides.html
bin/n98-magerun.phar mpmd:corehacks ~/magento-$MAGENTO_VERSION/magento audit/corehacks.html
bin/n98-magerun.phar dev:module:rewrite:list --format=csv > audit/rewrites.csv
bin/n98-magerun.phar dev:module:rewrite:conflicts --log-junit=audit/rewrite-conflicts.xml
bin/phpcs.phar --report=csv --report-file=audit/phpcs.csv --ignore=code/core --standard=~/.phpcs/Ecg www/app