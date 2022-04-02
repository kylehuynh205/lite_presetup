# Islandora Lite Playbook Deployment

### Download Islandora Lite playbook: 

````
git clone -b islandora_lite https://github.com/digitalutsc/islandora-playbook.git islandora-lite-playbook
````

### Go into islandora-playbook and vagrant up
````
cd islandora-lite-playbook
vagrant up
````

### After installation runs successfully, ssh into the playbook

```` 
vagrant ssh 
````

### Clone this repostory to `/var/www/html/drupal/` directory

````
cd /var/www/html/drupal/
git clone https://github.com/kylehuynh205/lite_presetup
cd lite_presetup
````

### Run the following series of commands:

````
chmod +x *.sh
./init.sh
./micro_services.sh playbook
sudo bash access_control.sh
./block_update.sh
./workbench.sh
./advanced_search.sh
````
