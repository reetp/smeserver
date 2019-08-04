Forum Post: [Install phpIPAM](https://forums.contribs.org/index.php?topic=54036.0;topicseen)

[phpIPAM](https://www.phpipam.net/)

* Install php-scl and php dependencies listed [phpIPAM Installation](https://www.phpipam.net/documents/installation/)

  * remi-safe  (I prefer to have custom repositories disabled, but that's me...)

        /sbin/e-smith/db yum_repositories set remi-safe repository \
        Name 'Remi - safe' \
        BaseURL 'http://rpms.famillecollet.com/enterprise/$releasever/safe/$basearch/' \
        EnableGroups no \
        GPGCheck yes \
        GPGKey http://rpms.famillecollet.com/RPM-GPG-KEY-remi \
        Visible yes \
        status disabled
        
        expand-template /etc/yum.smerepos.d/sme-base.repo 


  * install php-scl 

        yum install smeserver-php-scl --enablerepo=smecontribs --enablerepo=remi-safe
        signal-event php-update; config set UnsavedChanges no

	
  * install extra php modules
  
        yum --enablerepo=remi-safe install php73-php-pecl-mcrypt php73-php-cli php73-php-gmp

* ibay configruation

  * Create ibay
  
        db accounts set ipam ibay \
        CgiBin enabled \
        Gid 5000 \
        Group admin \
        Name phpIPAM \
        PasswordSet no \
        PublicAccess global \
        SSL disabled \
        Uid 5000 \
        UserAccess wr-admin-rd-group
        
        signal-event ibay-create ipam
  
  * Customize ibay settings
  
        # set ibay to use php73
        db accounts setprop ipam PhpVersion php73
        signal-event php-update


* Enable mysql access on port 3306

      config setprop mysqld LocalNetworkingOnly no
      expand-template /etc/my.cnf
      sv t /service/mysqld

* Install phpipam

  * Download
  
        cd /home/e-smith/files/ibays/ipam/files
        wget https://downloads.sourceforge.net/project/phpipam/phpipam-1.4.tar
        tar xvf phpipam-1.4.tar
                
        # delete any existing html folder
        'rm' -rf /home/e-smith/files/ibays/ipam/html
        
        # move the new ipam content into <ibay>/html
        mv phpipam /home/e-smith/files/ibays/ipam/html
        chown -R admin:www /home/e-smith/files/ibays/ipam/html
  
  * Store mysql settings in SME accounts db for reference
  
        db accounts setprop ipam DB_NAME phpipam
        db accounts setprop ipam DB_USER phpipam
        # IMPORTANT - re-running the next command will change the db password stored in the SME accounts db
        db accounts setprop ipam DB_PASSWORD $(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
        db accounts setprop ipam DB_HOST localhost
        db accounts setprop ipam DB_PORT 3306
  
  * Create the database and default config file
  
        DBNAME=$(db accounts getprop ipam DB_NAME)
        DBUSER=$(db accounts getprop ipam DB_USER)
        DBPASS=$(db accounts getprop ipam DB_PASSWORD)
        DBHOST=$(db accounts getprop ipam DB_HOST)
        DBPORT=$(db accounts getprop ipam DB_PORT)
        
        mysql -e "create database ${DBNAME};"
        mysql -e "GRANT ALL on ${DBNAME}.* to ${DBUSER}@${DBHOST} identified by "\'${DBPASS}\'";"
        
        cd /home/e-smith/files/ibays/ipam/html
        # set db values from accounts db
        # set the http BASE to the ibayname
        # and remove any existing config for php_cli_binary
        sed -e "s/\(^\$db\['host'\] = '\)[^']*\(.*\)/\1${DBHOST}\2/" \
            -e "s/\(^\$db\['user'\] = '\)[^']*\(.*\)/\1${DBUSER}\2/" \
            -e "s/\(^\$db\['pass'\] = '\)[^']*\(.*\)/\1${DBPASS}\2/" \
            -e "s/\(^\$db\['name'\] = '\)[^']*\(.*\)/\1${DBNAME}\2/" \
            -e "s/\(^\$db\['port'\] = \)[^;]*\(.*\)/\1${DBPORT}\2/" \
            -e "s/\(^define('BASE'...\)[^\"]*\(.*\)/\1\/ipam\/\2/" \
            config.dist.php \
            | grep -v '^$php_cli_binary =' \
            >config.php
        
        # add php_cli_binary for php73
        echo "\$php_cli_binary = '/usr/bin/php73';" >> config.php        
        
  * Create the db schema
  
        mysql ${DBNAME} < db/SCHEMA.sql

* Change the admin password

Login at http://ip-address/ipam

  * username: ```admin```
  * default password: ```ipamadmin```
  * enter a new password when prompted
  


