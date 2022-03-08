#current site
site_path=/var/www/html/drupal
#configure_search_api_solr_module
SOLR_CORE=ISLANDORA
solr_host=localhost:8983
solr_core=multisite
cantaloupe_url= http://localhost:8080/cantaloupe/iiif/2
#blazegraph
blazegraph_url=http://localhost:8080/bigdata
blazegraph_namespace=islandora
#fits
fits_url=/opt/fits-1.4.1/fits.sh
fits_remote_url=http://localhost:8080/fits/examine


drush -y pm:enable search_api_solr
drush -y pm:uninstall search
drush -y pm:enable search_api_solr_defaults

drush -y config-set search_api.server.default_solr_server backend_config.connector_config.scheme https
drush -y config-set search_api.server.default_solr_server backend_config.connector_config.host ${solr_host}
drush -y config-set search_api.server.default_solr_server backend_config.connector_config.core ${solr_core}

#Enable modules
drush -y pm:enable responsive_image syslog devel admin_toolbar pdf matomo restui controlled_access_terms_defaults jsonld field_group field_permissions features file_entity view_mode_switch islandora_defaults islandora_marc_countries chart_suite openseadragon chart_suite ableplayer islandora_iiif islandora_display advanced_search media_thumbnails media_thumbnails_pdf media_thumbnails_video csv_importer advancedqueue_runner triplestore_indexer fits

# configure_openseadragon
drush -y config-set --input-format=yaml media.settings standalone_url true
drush -y config-set --input-format=yaml openseadragon.settings iiif_server "${cantaloupe_url}"
drush -y config-set --input-format=yaml openseadragon.settings manifest_view iiif_manifest
drush -y config-set --input-format=yaml islandora_iiif.settings iiif_server "${cantaloupe_url}"

# configure access control fields
drush -y config-import --partial --source=$PWD/config/access_control

# configure Advanced Queue
drush -y config-import --partial --source=$PWD/config/advanced_queue

# configure advanced queue runner
drush -y config-set --input-format=yaml advancedqueue_runner.runnerconfig drush_path "${site_path}"/vendor/drush/drush/drush
drush -y config-set --input-format=yaml advancedqueue_runner.runnerconfig root_path "${site_path}"
drush -y config-set --input-format=yaml advancedqueue_runner.runnerconfig auto-restart-in-cron 1
drush -y config-set --input-format=yaml advancedqueue_runner.runnerconfig queues "
- default: default
- triplestore: triplestore
- fits:fits
"
drush -y config-set --input-format=yaml advancedqueue_runner.runnerconfig interval '5'
drush -y config-set --input-format=yaml advancedqueue_runner.runnerconfig mode limit

# Configure Rest Services (enable jsonld endpoint)
drush -y config-import --partial --source=$PWD/config/rest

#configure triplestore_indexer
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig server-url "${blazegraph_url}"
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig namespace "${blazegraph_namespace}"
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig method-of-op advanced_queue
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig aqj-max-retries 5
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig aqj-retry_delay 120
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig select-auth-method
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig advancedqueue-id triplestore
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig content-type-to-index "islandora_object: islandora_object"

# configure fits
drush -y config-set --input-format=yaml fits.fitsconfig fits-method remote
drush -y config-set --input-format=yaml fits.fitsconfig fits-server-url "${fits_remote_url}"
drush -y config-set --input-format=yaml fits.fitsconfig fits-advancedqueue_id fits
drush -y config-set --input-format=yaml fits.fitsconfig fits-extract-ingesting 1
drush -y config-set --input-format=yaml fits.fitsconfig aqj-max-retries  5
drush -y config-set --input-format=yaml fits.fitsconfig aqj-retry_delay 120
drush -y config-set --input-format=yaml fits.fitsconfig fits-default-fields "
- field_fits_checksum
- field_fits_file_format
- field_fits
"

# configure document mimetypes
drush -y --input-format=yaml config:set file_entity.type.document mimetypes "
- text/plain
- application/msword
- application/vnd.ms-excel
- application/pdf
- application/vnd.ms-powerpoint
- application/vnd.oasis.opendocument.text
- application/vnd.oasis.opendocument.spreadsheet
- application/vnd.oasis.opendocument.presentation
- application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
- application/vnd.openxmlformats-officedocument.presentationml.presentation
- application/vnd.openxmlformats-officedocument.wordprocessingml.document
- text/csv
- text/vtt"

drush -y --input-format=yaml config:set file_entity.type.image mimetypes "
- image/*
- image/tiff
- image/tif
- image/jp2"


drush -y config:set field.field.media.document.field_media_document settings.file_extensions "txt rtf doc docx ppt pptx xls xlsx pdf odf odg odp ods odt fodt fods fodp fodg key numbers pages csv vtt"
drush -y config:set field.field.media.image.field_media_image settings.file_extensions "png gif jpg jpeg tif tiff jp2"

wget --output-file="logs.csv" "https://docs.google.com/spreadsheets/d/1DduGYHGL6Z3p0TsdhrnspUJtNyLWvXdnY18hQ9KDNFE/export?format=csv&gid=284163204" -O "resource_types.csv"
wget --output-file="logs.csv" "https://docs.google.com/spreadsheets/d/1DduGYHGL6Z3p0TsdhrnspUJtNyLWvXdnY18hQ9KDNFE/export?format=csv&gid=802375737" -O "islandora_models.csv"

drush -y --input-format=yaml config:set core.entity_form_display.media.audio.media_library content "
ableplayer_caption:
  type: file_generic
  weight: 1
  region: content
  settings:
    progress_indicator: throbber
  third_party_settings: {}
bleplayer_caption:
  type: file_generic
  weight: 7
  region: content
  settings:
    progress_indicator: throbber
  third_party_settings: {}
field_media_use:
  type: entity_reference_autocomplete
  weight: 2
  region: content
  settings:
    match_operator: CONTAINS
    match_limit: 10
    size: 60
    placeholder: ''
  third_party_settings: {}
name:
  type: string_textfield
  weight: 0
  region: content
  settings:
    size: 60
    placeholder: ''
  third_party_settings: {}"

drush -y --input-format=yaml config:set core.entity_form_display.media.document.media_library content "
field_media_use:
  type: entity_reference_autocomplete
  weight: 1
  region: content
  settings:
    match_operator: CONTAINS
    match_limit: 10
    size: 60
    placeholder: ''
  third_party_settings: {}
name:
  type: string_textfield
  weight: 0
  region: content
  settings:
    size: 60
    placeholder: ''
  third_party_settings: {}"

drush -y --input-format=yaml config:set core.entity_form_display.media.file.media_library content "
field_media_use:
  type: entity_reference_autocomplete
  weight: 1
  region: content
  settings:
    match_operator: CONTAINS
    match_limit: 10
    size: 60
    placeholder: ''
  third_party_settings: {}
name:
  type: string_textfield
  weight: 0
  region: content
  settings:
    size: 60
    placeholder: ''
  third_party_settings: {}"

drush -y --input-format=yaml config:set core.entity_form_display.media.image.media_library content "
field_media_use:
  type: entity_reference_autocomplete
  weight: 1
  region: content
  settings:
    match_operator: CONTAINS
    match_limit: 10
    size: 60
    placeholder: ''
  third_party_settings: {}
name:
  type: string_textfield
  weight: 0
  region: content
  settings:
    size: 60
    placeholder: ''
  third_party_settings: {}"

drush -y --input-format=yaml config:set core.entity_form_display.media.video.media_library content "
ableplayer_caption:
  type: file_generic
  weight: 1
  region: content
  settings:
    progress_indicator: throbber
  third_party_settings: {}
field_media_use:
  type: entity_reference_autocomplete
  weight: 2
  region: content
  settings:
    match_operator: CONTAINS
    match_limit: 10
    size: 60
    placeholder: ''
  third_party_settings: {}
name:
  type: string_textfield
  weight: 0
  region: content
  settings:
    size: 60
    placeholder: ''
  third_party_settings: {}"

drush -y --input-format=yaml config:set core.entity_form_display.media.web_archive.media_library content "
  field_base_url:
    type: link_default
    weight: 1
    region: content
    settings:
      placeholder_url: ''
      placeholder_title: ''
    third_party_settings: {  }
  field_media_use:
    type: entity_reference_autocomplete
    weight: 2
    region: content
    settings:
      match_operator: CONTAINS
      match_limit: 10
      size: 60
      placeholder: ''
    third_party_settings: {  }
  name:
    type: string_textfield
    weight: 0
    region: content
    settings:
      size: 60
      placeholder: ''
    third_party_settings: {  }"

