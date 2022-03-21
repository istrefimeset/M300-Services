## Modul 300, Plattformübergreifende Dienste in ein Netzwerk integrieren
# MYSQL Datenbank 

# Inhaltsverzeichnis

- [Einführung](#Einführung)
- [Umgebung](#Umgebung)
    - [Maschine](#virtuelle-maschine)
    - [Vagrantfile](#vagrantfile-inhalt)
    - [Boostrapfile](#boostrap-inhalt)
- [Umsetzung](#umgebung-umsetzten)
    - [Anleitung](#anleitung)
    - [Testen](#testen) 
- [Quellenverzeichnis](#quellenverzeichnis)

# Einführung
### Projekt Einleitung
Ziel in dieser Leistungsbeurteilung ist es mit VirtualBox/Vagrant eine IaC (Infrastucture as Code) zu erstellen, indem ein Service oder ein Servicedienst automatisiert wird. Die Infrastruktur ist frei wählbar.

### Projekt
Ich habe mich dafür entschieden eine Virtuelle Umgebung mit Hilfe von Vagrant zu erstellen, auf der ein MYSQL-Server läuft, der über phpmyadmin auf die Datenbanken zugreifen kann. Indem Apache2 gestartet wird, kann auf der Weboberfläche zugegriffen werden. 

# Umgebung
## Virtuelle Maschine

![virtuelle Umgebung](https://github.com/istrefimeset/M300-Services/blob/main/LB2/Images/Umgebung.png)

#### MYSQL-Server:
- OS: ubuntu/xenial64
- CPU: 2 Core
- Memory: 1024
- Access: 127.0.0.1:3306

### Codebeschreibung
Das IaC ist so aufgebaut, dass im Vagrantfile die Grundlegende Infrastruktur aufgebaut wird (Betriebssystem, Hardware, Netzwerkonfiguration, etc.) und im bootstrap.sh File werden die Services eingerichtet, welche auf der VM eingerichtet werden. 

## Vagrantfile Inhalt

>
    Vagrant.configure(2) do |config|

    # OS for VM
    config.vm.box = "ubuntu/xenial64"

    # VM network config
    config.vm.define "db-server" do |db|
        db.vm.network "forwarded_port", guest: 3306, host: 3306
        db.vm.network "forwarded_port", guest: 80, host: 3306
        db.vm.provision "shell", path: "bootstrap.sh"
    end

In diesem Teil des Skriptes wird das OS definiert, welches auf der VM installiert werden soll.
Im Abschnitt der Netzwerkkonfiguration wurden die Ports zum Portforwarding definiert, damit der Benutzer auf das Webinterface von phpmyadmin lokal zugreifen. Mit `db.vm.provision` wurde noch das bootstrap weitergeleitet, damit dies bei der Ausführung vom Vagrantfile mit bezogen wird.

>
    # VM performance config
     config.vm.provider :virtualbox do |vb|
        vb.customize [
        'modifyvm', :id,
        '--natdnshostresolver1', 'on',
        '--memory', '1024',
        '--cpus', '2'    ] 
    end
    end  

Hier wird definiert auf welcher Virtualisierungssoftware die VM laufen wird und auch die Performance wird angepasst.

## Boostrap Inhalt

>
    #!/usr/bin/env bash

    # variable for db
    DBHOST=localhost
    DBNAME=KlasseST19d
    DBUSER=modul
    DBPASSWD=modul
    DBTSCHUELER=Schueler
    TABLE1=Schueler
    TABLE2=Notenbuch

Am Anfang des Skriptes wurden noch die Variabeln definiert. Diese dienen dazu da, dass bei Änderungen des Skriptes dies schneller geht, indem man nur an einem Ort den Wert abändern muss und so werden auch künftige Fehlermeldungen vermieden.

> 
    # all packages getting updated
    apt-get update

    # set up mysql and phpmyadmin with password and connect with db
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"

Mit `apt-get update` werden zu erst die Packages auf dem neusten Stand gesetzt.
Im Abschnitt `debconf-set-selections` werden die Passwörter gesetzt, bzw. der Root-User wird konfiguriert und das Passwort wird gesetzt für die Datenbank.

> 
    # install mysql and admin interface
    apt-get -y install mysql-server phpmyadmin

    # create db and tables
    mysql -uroot -p$DBPASSWD <<%EOF%
	    CREATE USER '$DBUSER'@'$DBHOST' IDENTIFIED BY '$DBPASSWD';
	    GRANT ALL PRIVILEGES ON *.* TO '$DBUSER'@'$DBHOST' IDENTIFIED BY '$DBPASSWD' WITH GRANT OPTION;
	    FLUSH PRIVILEGES;
	    CREATE DATABASE $DBNAME;
	    USE $DBNAME;
	    CREATE TABLE $TABLE1(PersonID INT(50), Vorname VARCHAR(50), Name VARCHAR(50), PRIMARY KEY (PersonID));
	    CREATE TABLE $TABLE2 (NotenID INT(50), Schulfach VARCHAR(50), Note VARCHAR(50), PersonID INT(50), PRIMARY KEY (NotenID), FOREIGN KEY (PersonID) REFERENCES Schueler(PersonID));
	    INSERT INTO $TABLE1 VALUE ("1","Meset","Istrefi");
	    INSERT INTO $TABLE1 VALUE ("2","Benita","Ajdini");
	    INSERT INTO $TABLE1 VALUE ("3","Mark","Zgraggen");
	    INSERT INTO $TABLE1 VALUE ("4","Sam","Jassim");
	    INSERT INTO $TABLE2 VALUE ("1","LB1", "5", "1" );
	    INSERT INTO $TABLE2 VALUE ("2","LB1", "6", "2" );
	    INSERT INTO $TABLE2 VALUE ("3","LB1", "5.5", "3" );
	    INSERT INTO $TABLE2 VALUE ("4","LB1", "5.5", "4" );
	    quit
    %EOF%	

Im folgendem Abschnitt wird der MYSQL-Server und phpmyadmin installiert. Nachdem dies fertig installiert wurde loggt sich das Skript im DB-Server ein (`mysql -uroot -p$DBPASSWD <<%EOF%`) und erstellt eine Datenbank. In der Dantenbank werden noch Tabellen erstellt und auch ihre Relationen werden definiert (mit Primär- und Fremdschlüssel). Zu dem werden noch einige Daten festgehalten, damit man die Realtion auch gut erkenne kann. 

>
    # update mysql conf file to allow remote access to the db
    sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

    sudo service mysql restart

    # setup phpmyadmin

    service apache2 restart

Zum Schluss wird noch der Remote-Zugriff aktiviert zur Datenbank. 
Damit das auch sicherlich umgesetzt wurde, wird noch mysql und apache2 neugestartet.

# Umgebung umsetzten

### Anleitung
1. Das Repository soll auf vom git auf dem lokalen Rechner geklont werden mit folgendem Befehl: git clone (URL)
2. Auf dem git bash `vagrant up` ausführen
3. Nachdem das Skript durchgeführt wurde auf dem Browser `127.0.0.1:3306/phpmyadmin` eingeben
4. Mit Passwort und Benutzernamen einloggen(Passwort und Benutzername wurde beides `modul` gesetzt)

Danach sollte die Datenbank `KlasseST19d` zu sehen sein.

![phpmyadmin](https://github.com/istrefimeset/M300-Services/blob/main/LB2/Images/phpmyadmin.png)

### Testen

Folgende Tests müssen durchgeführt werden für die Richtigkeit der Installation:

- [ ] clonen war erfolgreich
- [ ] vagrant up kann fehlerfrei durchgeführt werden
- [ ] auf `127.0.0.1:3306/phpmyadmin` kann zugegriffen werden
- [ ] Zugriff zu phpmyadmin funktioniert mit folgenen Logindaten: root;modul und modul;modul
- [ ] Datenbank **KlasseST19d** ist vorhanden
- [ ] Tabelle **Schueler** und **Notenbuch** ist vorhanden
- [ ] Einträge in den beiden Tabellen sind vorhanden
- [ ] Relation der Tabellen ist erkennbar (durch der zugewiesenen ID-Attribute)

# Quellenverzeichnis

Projekt Idee: [MYSQL-Server-vagrant](https://www.yourtechy.com/technology/mysql-server-vagrant-virtualbox/)