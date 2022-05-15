## Leistungsbeurteilung 3, Docker Compose
# Wordpress and Database

# Inhaltsverzeichnis
- []
- []
- []


# Einführung
### Projekteinleitung
In den letzten Wochen vom Modul 300 - PLattformübergreifende Dienste im Netzwerk integrieren haben wir uns hauptsächlich auf die Containervirtualisierung konzentriert. Uns wurde Docker vorgestellt und auch Kuberenetes und ihre Funktionen. 

## Auftrag
In der Leistungsbeurteilung 3 wird uns frei gestellt, ob wir mit Docker oder mit Kubernetes unser Projekt erarbeiten wollen. 
Da ich mich mit beiden gut auskenne, viel mir die Entscheidung leicht und habe mich dafür entschlossen ein Docker-Compose File zu erstellen.

## Projekt Thema
Ich habe mich dafür entschieden mit einem Docker-Compose File eine Abhängigkeit zwischen MYSQL und Phpmyadmin zu erstellen, so dass wenn man sich auf dem Webinterface von Phpmyadmin einloggt, eine Datenbank zu sehen ist. Ausserdem wird noch ein Wordpress Container konfiguriert und in Betrieb genommen. 

# Umgebung
## virtuelle Umgebung
![Umgebung](https://github.com/istrefimeset/M300-Services/blob/main/LB3/Images/Umgebung.png)

## Container Hardware
### MYSQL
- OS/image: mysql:latest
- CPU: 0.5 - 1 Core
- Memory: 512M - 1024M

### PHPmyadmin
- OS/image: phpmyadmin:latest
- CPU: 0.5 - 1 Core
- Memory: 512M - 1024
- Ports: 3306:80

### Wordpress
- OS/image: wordpress:latest
- CPU: 0.5 - 1 Core
- Memory: 512M - 1024
- Ports 8081:80

# Docker Compose File

## Codebeschreibung
### MYSQL Code

>
version: '3'

services:
    # Database
  db:
    image: mysql:latest
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    deploy:
        resources:
            limits:
              cpus: '1'
              memory: 1024M
            reservations:
              cpus: '0.5'
              memory: 512M     
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: mysql
      MYSQL_PASSWORD: mysql
    networks:
      - wpsite

In diesem Teil des Codes wurde die Datenbank konfiguriert. Hier wurde das letzte Image von mysql bezogen und das Volumen wird im Pfad `/var/lib/mysql` bespeichert.
Im Deploy Teil wurden noch die Hardware konfiguriert, also das Limit an Hardware und die minimale Reservation für den Container. Beim Environment Teil wurden noch Benutzername und Passwörter gesetzt für einen Benutzer mit und ohne Adminrechte. 

### Phpmyadmin Code

>
    # phpmyadmin
  phpmyadmin:
    depends_on:
      - db
    image: phpmyadmin:latest
    restart: always
    deploy:
        resources:
            limits:
              cpus: '1'
              memory: 1024M
            reservations:
              cpus: '0.5'
              memory: 512M           
    ports:
      - '3306:80'
    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: password 
    networks:
      - wpsite

Am Anfang des Codes wird bei `depends_on` definiert, dass dieser Container vom Container `db` abhängt. Auch hier wird das zu letzt realeste Image von phpmyadmin verwendet. Hier wurde die Hardware ebenfalls wie beim Mysql Container definiert. 

### Wordpress Code

>
    # Wordpress
  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - '8081:80'
    restart: always
    deploy:
        resources:
            limits:
              cpus: '1'
              memory: 1024M
            reservations:
              cpus: '0.5'
              memory: 512M       
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: mysql
      WORDPRESS_DB_PASSWORD: mysql
    volumes: ['./:/var/www/html']
    networks:
      - wpsite
networks:
  wpsite:
volumes:
  db_data:

Hier ist alles ebenfalls ähmlich wie bei den vorherigen beiden Codes. Das Environment hängt hier jedoch von der Datenbank ab, deshalb muss man hier die Login Daten angeben, damit der Wordpress Container zugriff auf dem Datenbank Container







