#!/bin/bash

#inital_path
inital_path=$PWD

#current site
site_path="${inital_path}"/../..

wget https://raw.githubusercontent.com/digitalutsc/isle-dc/islandora_lite/scripts/workbench_integration.patch -P ${site_path}/web/modules/contrib/islandora_workbench_integration
	(cd ${site_path}/web/modules/contrib/islandora_workbench_integration && patch -p1 < workbench_integration.patch)
drush -y pm:enable islandora_workbench_integration
