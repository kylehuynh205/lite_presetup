# How to enable Reversed Proxy in Playbook:

* Enable Proxy PHP module
````
sudo a2enmod proxy_http
````

* Modify the islandora.conf
````
sudo nano /etc/apache2/sites-enabled/islandora.conf
````

* Add the following code within <<VirtualHost *:8000></VirtualHost>, and after `</Directory>` tag:

````
  ProxyRequests Off
  ProxyPreserveHost On
  AllowEncodedSlashes NoDecode
  <Proxy *>
     AddDefaultCharset off
     Order deny,allow
     Allow from all
  </Proxy>

  ProxyPass "/iiif/2" "http://localhost:8080/cantaloupe/iiif/2" nocanon
  ProxyPassReverse "/iiif/2" "http://localhost:8080/cantaloupe/iiif/2"
  ProxyPass /cantaloupe/iiif/2 http://localhost:8080/cantaloupe/iiif/2 nocanon
  ProxyPassReverse /cantaloupe/iiif/2 http://localhost:8080/cantaloupe/iiif/2
  ````
  
  * Restart Apache Server: 
  
  ````
  sudo service apache2 restart
  ````
