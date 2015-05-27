#!/bin/sh
#
# ~/.n98-magerun/modules is automatically used by n98-magerun for plugins
#
[ -d ~/.n98-magerun/modules/ ] || mkdir -p ~/.n98-magerun/modules/
[ -d ~/.n98-magerun/modules/mpdm ] || git clone https://github.com/AOEpeople/mpmd.git ~/.n98-magerun/modules/mpmd
[ -d ~/.n98-magerun/modules/magerun-addons ] || git clone https://github.com/kalenjordan/magerun-addons.git ~/.n98-magerun/modules/magerun-addons
#
# coding standard must be in a directory called "Ecg" anywhere
#
[ -d ~/.phpcs/Ecg ] || git clone https://github.com/magento-ecg/coding-standard.git ~/.phpcs/Ecg