#!/bin/bash

#current site
site_path=$PWD/..


#Enable modules
drush -y pm:enable responsive_image syslog devel admin_toolbar pdf matomo restui controlled_access_terms_defaults jsonld field_group field_permissions features file_entity view_mode_switch islandora_defaults islandora_marc_countries chart_suite openseadragon chart_suite ableplayer islandora_iiif islandora_display advanced_search media_thumbnails media_thumbnails_pdf media_thumbnails_video csv_importer advancedqueue_runner triplestore_indexer fits


