## Modul 300, Plattformübergreifende Dienste in ein Netzwerk integrieren
# MYSQL Datenbank 

# Inhaltsverzeichnis

- [Einführung](#Einführung)
- [Umgebung](#Umgebung)


# Einführung
### Projekt Einleitung
Ziel in dieser Leistungsbeurteilung ist es mit VirtualBox/Vagrant eine IaC (Infrastucture as Code) zu erstellen, indem ein Service oder ein Servicedienst automatisiert wird. Die Infrastruktur ist frei wählbar.

### Projekt
Ich habe mich dafür entschieden eine Virtuelle Umgebung mit Hilfe von Vagrant zu erstellen, auf der ein MYSQL-Server läuft, der über phpmyadmin auf die Datenbanken zugreifen kann. Indem Apache2 gestartet wird, kann auf der Weboberfläche zugegriffen werden. 

# Umgebung
### Virtuelle Maschine

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
        '--cpus', '2'
    ] 
  end
end  

Hier wird definiert auf welcher Virtualisierungssoftware die VM laufen wird und auch die Performance wird angepasst.

## Boostrap Inhalt




