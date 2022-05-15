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
![Umgebung] ()

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

## Docker Compose File

### Codebeschreibung


