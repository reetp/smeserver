https://www.howtoforge.com/tutorial/how-to-install-ioncube-loader/
https://forums.contribs.org/index.php/topic,54013.0/topicseen.html

### ioncube loader with default php 5.3.3
#### Download / "Install" / Enable 
    mkdir -p ~/addons/ioncube
    cd ~/addons/ioncube
    'rm' -rf ioncube
    'rm' *.zip
    wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip
    unzip ioncube_loaders_lin_x86-64.zip
    'cp' -f ioncube/*5.3* /usr/lib64/php/modules
    chmod a+x /usr/lib/php/modules/ion*5.5*
    #
    # create  /etc/e-smith/templates-custom/etc/php.ini/15ioncube
    mkdir -p /etc/e-smith/templates-custom/etc/php.ini/
    echo 'zend_extension                         = /usr/lib64/php/modules/ioncube_loader_lin_5.3.so' \
    > /etc/e-smith/templates-custom/etc/php.ini/15ioncube
    expand-template /etc/php.ini
    sv t httpd-e-smith

#### Create phpinfo file to see if it worked
    echo '<?php phpinfo(); ?>' > /home/e-smith/files/ibays/Primary/html/info.php
    #
    # Open new page in a browser 
    # http://smeserver.tld/info.php
![ioncube information](https://raw.githubusercontent.com/mmccarn/smeserver/master/img/Screen%20Shot%202019-07-21%20at%208.33.47%20AM.png) 

    # remove the new page when you're done with it
    'rm' /home/e-smith/files/ibays/Primary/html/info.php
    

### ioncube loader for php-scl on SME Server 9.2

#### Download and extract the latest ioncube loader

    mkdir -p ~/addons/ioncube
    cd ~/addons/ioncube
    'rm' -rf ioncube
    'rm' *.zip
    wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip
    unzip ioncube_loaders_lin_x86-64.zip

#### Install the ioncube modules into all of the installed php-scl versions (installed as per [PHP Software Collections](https://wiki.contribs.org/PHP_Software_Collections#Installation))

  Note: repeat this step plus ```signal-event php-update``` to update to the latest available version of ioncube.

    cd ~/addons/ioncube
    for phpdir in /opt/remi/php*; do  
      phpver=$(echo $phpdir |sed -e 's|/opt/remi/php||' -e 's/\(.\)\(.\)/\1.\2/')
      'cp' -f "ioncube/ioncube_loader_lin_"${phpver}".so"  $phpdir/root/usr/lib64/php/modules/
      'cp' -f "ioncube/ioncube_loader_lin_"${phpver}"_ts.so"  $phpdir/root/usr/lib64/php/modules/
    done

#### Create template fragments for all installed php-scl versions

    for phpdir in /opt/remi/php*; do  
      phpver=$(echo $phpdir |sed -e 's|/opt/remi/php||' -e 's/\(.\)\(.\)/\1.\2/')
      php=${phpdir/\/opt\/remi\//}
      
      mkdir -p /etc/e-smith/templates-custom${phpdir}/root/etc/php.ini
      cd  /etc/e-smith/templates-custom${phpdir}/root/etc/php.ini
      echo '{' > 15ioncube
      echo '$OUT = "";' >> 15ioncube
      echo 'if (( $'${php}'{IonCube} || "disabled") eq "enabled") {' >> 15ioncube
      echo '    $OUT .= "zend_extension                         = ";' >> 15ioncube
      echo '    $OUT .= "'$phpdir'";' >> 15ioncube
      echo '    $OUT .= "/root/usr/lib64/php/modules/ioncube_loader_lin_";' >> 15ioncube
      echo '    $OUT .= "'$phpver'";' >> 15ioncube
      echo '    $OUT .= ".so\n";' >> 15ioncube
      echo '  }' >> 15ioncube
      echo '}' >> 15ioncube
    done


#### Enable ioncube for any specific version of php using the configuration database

  ```
  config setprop php55 IonCube enabled
  signal-event php-update
  ```
      
  ```
  config setprop php55 IonCube enabled
  signal-event php-update
  ```

  ```
  config setprop php56 IonCube enabled
  signal-event php-update
  ```

  ```
  config setprop php70 IonCube enabled
  signal-event php-update
  ```
  
  ```
  config setprop php71 IonCube enabled
  signal-event php-update
  ```
  
  ```
  config setprop php72 IonCube enabled
  signal-event php-update
  ```
  
  ```
  config setprop php73 IonCube enabled
  signal-event php-update
  ```
  
#### Enable ioncube for all installed php-scl versions
  
  ```
  for phpdir in /opt/remi/php*; do 
    config setprop $(basename $phpdir) IonCube enabled
  done
  signal-event php-update
  ```
  
