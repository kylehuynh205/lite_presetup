#current site
site_path=/var/www/html/drupal

public_files_path=/var/www/html/drupal/web/sites/default/files
private_files_path=/var/www/html/drupal/web/sites/default/private_files

mkdir "${private_files_path}"

# configure access control fields
drush -y config-import --partial --source=$PWD/config/private_file_system

cd ../web/modules/contrib/file_entity

wget https://raw.githubusercontent.com/digitalutsc/override_permission_file_entity/main/override_file_access.patch

patch -p1 < override_file_access.patch

cd /var/www/html/drupal/
