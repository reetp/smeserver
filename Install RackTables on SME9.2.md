
* https://github.com/RackTables/racktables/blob/maintenance-0.20.x/README.md

* create ibay

![Create Ibay](https://raw.githubusercontent.com/mmccarn/smeserver/master/img/Screen%20Shot%202019-07-14%20at%208.33.23%20AM.png)

* download and extract (update the filename as new RackTables versions are released)
     
      cd /home/e-smith/files/ibays/racktables/files
      wget https://downloads.sourceforge.net/project/racktables/RackTables-0.21.3.tar.gz
      tar zxvf RackTables-0.21.3.tar.gz 

  
* move into position and fix rights

      'rm' -rf /home/e-smith/files/ibays/racktables/html
      mv /home/e-smith/files/ibays/racktables/files/RackTables-0.21.3/wwwroot /home/e-smith/files/ibays/racktables/html
      chown -R admin:shared /home/e-smith/files/ibays/racktables/*


* Install dependencies

  * remi-safe  (I prefer to have custom repositories disabled, but that's me...)

        /sbin/e-smith/db yum_repositories set remi-safe repository \
        Name 'Remi - safe' \
        BaseURL 'http://rpms.famillecollet.com/enterprise/$releasever/safe/$basearch/' \
        EnableGroups no \
        GPGCheck yes \
        GPGKey http://rpms.famillecollet.com/RPM-GPG-KEY-remi \
        Visible yes \
        status disabled


  * install php-scl 

        yum install smeserver-php-scl --enablerepo=smecontribs --enablerepo=remi-safe
        signal-event php-update; config set UnsavedChanges no


  * set racktables ibay to use php73 in server-manager
	
  * install snmp support

        yum --enablerepo=remi-safe install php73-php-snmp


* Prepare to run install
  * generate a random password to use for racktables_user in mysql and store it in the accounts db

        db accounts setprop racktables DB_PASSWORD $(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)


  * enable InnoDB

        db configuration setprop mysqld InnoDB enabled
        expand-template /etc/my.cnf
        sv t /service/mysqld


  * create "secrets.php" and make it writable for the racktables installer

        touch  '/home/e-smith/files/ibays/racktables/html/inc/secret.php`````
        # set owner to 'www' during install; we'll reset to 'admin' later.
        chown www:shared '/home/e-smith/files/ibays/racktables/html/inc/secret.php'

  * run the installer
	  * https://your-sme-server/racktables/?module=installer
      * specify "Unix Socket" 
      * Default socket is OK (```/var/lib/mysql/mysql.sock```)
      * Get db password from command shell using ```db accounts getprop racktables DB_PASSWORD```
    
		IMPORTANT: create the database at the command prompt before completing the install<br>
		The racktables installer displays a set of mysql commands in a green block - <br>
		you must run these commands at the SME Server command prompt<br>
		   EXCEPT - be sure to replace "MY_SECRET_PASSWORD" with the db password you've saved in your accounts database
			  
			  CREATE DATABASE racktables_db CHARACTER SET utf8 COLLATE utf8_general_ci;
			  CREATE USER racktables_user@localhost IDENTIFIED BY 'MY_SECRET_PASSWORD';
			  GRANT ALL PRIVILEGES ON racktables_db.* TO racktables_user@localhost;

    * The commands below can be pasted into the SME command prompt to execute the required mysql commands
		
          # if you want to start over--
          # mysql -e "drop database IF EXISTS racktables_db;"
          # mysql -e "drop user 'racktables_user'@'localhost';"
          
          # create database
          mysql -e "CREATE DATABASE racktables_db CHARACTER SET utf8 COLLATE utf8_general_ci;"
           
          # create user using the random password generated earlier
          DBPASS=$(db accounts getprop racktables DB_PASSWORD)
          mysql -e "CREATE USER racktables_user@localhost IDENTIFIED BY '$DBPASS';"
           
          # Give the new user access to the db
          mysql -e "GRANT ALL PRIVILEGES ON racktables_db.* TO racktables_user@localhost;"
          
    * reset ownership of secrets.php at the command prompt when prompted by the installer
    
          chown admin /home/e-smith/files/ibays/racktables/html/inc/secret.php

Database creation should succeed

		# prompted for administrator password
			# I used the db password, and tried another password
			# I confirmed that the sha1 of the password was correct using:
			mysql racktables_db -e "select * from UserAccount where user_password_hash = sha1 ('my-password-here');"
			
While working on the login issue from [forums.contribs.org](https://forums.contribs.org/index.php?topic=54022) I also tried running with mysql57 instead of mysql55
* I decided to try mysql57 to see if there was an unstated requirement<br>(especially since the install indicated that php5.6+ was required, but the website indicates php5.1+...)


  * install mysql57<br>

        yum --enablerepo=smecontribs install smeserver-mysql57
        signal-event post-upgrade; signal-event reboot
	
  * reset installation
  
        mysql -e "drop database IF EXISTS racktables_db;"
        mysql -e "drop user 'racktables_user'@'localhost';"
        'rm' /home/e-smith/files/ibays/racktables/html/inc/secret.php
        touch  '/home/e-smith/files/ibays/racktables/html/inc/secret.php'
        chown www:shared '/home/e-smith/files/ibays/racktables/html/inc/secret.php'
        
        # create database and user in mysql57
        mysql57 -e "CREATE DATABASE racktables_db CHARACTER SET utf8 COLLATE utf8_general_ci;"
        DBPASS=$(db accounts getprop racktables DB_PASSWORD)
        mysql57 -e "CREATE USER racktables_user@localhost IDENTIFIED BY '$DBPASS';"
        mysql57 -e "GRANT ALL PRIVILEGES ON racktables_db.* TO racktables_user@localhost;"

  * run web installer
    * https://192.168.200.11/racktables/?module=installer
      * specify "Unix Socket" 
      * Change socket to ```/var/lib/mysql/mysql57.sock```
      * Get db password from command shell using ```db accounts getprop racktables DB_PASSWORD```
      
  * fix ownership of secrets.php

        chown admin /home/e-smith/files/ibays/racktables/html/inc/secret.php

		
