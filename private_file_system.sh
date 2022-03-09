#current site
site_path=/var/www/html/drupal

public_files_path=/var/www/html/drupal/web/sites/default/files
private_files_path=/var/www/html/drupal/web/sites/default/private_files

mkdir "${private_files_path}"

# configure access control fields
drush -y config-import --partial --source=$PWD/config/private_file_system