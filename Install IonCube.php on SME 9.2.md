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
    

