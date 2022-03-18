#current site
site_path=/var/www/drupal

public_files_path="${site_path}"/web/sites/default/files
private_files_path="${site_path}"/web/sites/default/private_files

mkdir "${private_files_path}"
chown -Rf www-data:www-data "${private_files_path}"

# update settings.php with path of private file system
sed -i "/file_private_path/c\$settings['file_private_path'] = 'sites/default/private_files';" "${site_path}"/web/sites/default/settings.php

# configure access control fields
drush -y config-import --partial --source=$PWD/config/private_file_system

cd ../web/modules/contrib/file_entity

wget https://raw.githubusercontent.com/digitalutsc/override_permission_file_entity/main/override_file_access.patch

patch -p1 < override_file_access.patch

cd "${site_path}"

# import access control fields
drush -y config-import --partial --source=$PWD/config/access_control
