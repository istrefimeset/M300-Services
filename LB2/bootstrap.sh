#!/usr/bin/env bash

DBHOST=localhost
DBNAME=KlasseST19d
DBUSER=meset	
DBPASSWD=meset
DBTSCHUELER=Schueler
COLUMNNAME=Name
COLUMNVORNAME=Vorname

apt-get update

debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"

# install mysql and admin interface

apt-get -y install mysql-server phpmyadmin

mysql -uroot -p$DBPASSWD <<%EOF%
	CREATE USER 'meset'@'localhost' IDENTIFIED BY 'meset';
	GRANT ALL PRIVILEGES ON *.* TO 'meset'@'localhost' IDENTIFIED BY 'meset' WITH GRANT OPTION;
	FLUSH PRIVILEGES;
	CREATE DATABASE KlasseST19d;
	USE KlasseST19d;
	CREATE TABLE Schueler(PersonID INT(50), Vorname VARCHAR(50), Name VARCHAR(50), PRIMARY KEY (PersonID));
	CREATE TABLE Notenbuch (NotenID INT(50), Schulfach VARCHAR(50), Note INT(50), PersonID INT(50), PRIMARY KEY (NotenID), FOREIGN KEY (PersonID) REFERENCES Schueler(PersonID));
	INSERT INTO Schueler VALUE ("1","Meset","Istrefi");
	INSERT INTO Schueler VALUE ("2","Benita","Ajdini");
	INSERT INTO Schueler VALUE ("3","Mark","Zgraggen");
	INSERT INTO Schueler VALUE ("4","Sam","Jassim");
	INSERT INTO Notenbuch VALUE ("1","LB1", "5", "1" );
	INSERT INTO Notenbuch VALUE ("2","LB1", "6", "2" );
	INSERT INTO Notenbuch VALUE ("3","LB1", "5.5", "3" );
	INSERT INTO Notenbuch VALUE ("4","LB1", "5.5", "4" );
	quit
%EOF%	

cd /vagrant

# update mysql conf file to allow remote access to the db

sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

sudo service mysql restart

# setup phpmyadmin

service apache2 restart