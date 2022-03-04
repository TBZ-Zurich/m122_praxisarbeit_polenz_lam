# Projekt Dokumentation

  

[[_TOC_]]

  

## Solution design

Based on the analysis, the following solution design was created.

  

### Calling the scripts

**Script 2:**

The script is executed in a cronjob. The cronjob is always executed at a certain time (defined in the cronjob configs by the user). All configurations do not have to be passed as parameters, but can be written into the config files.

  

### Ablauf der Automation
![[/assets/Diagram 2022-03-04 10-10-29.png]]​

  

### Konfigurationsdateien


**backup.config.sample**

```
<groupname>
/path/
name

```


**dontbackup.config.sample**

```
<groupname>
/path/
name
```

**backupdata.config.sample**

```

filename=NameOfTheFile-{timestamp}
keepindays=5
backuplocation=/backup

```
  

## Abgrenzungen zum Lösungsdesign

  

TODO: Nachdem das Programm verwirklicht wurde, hier die Unterschiede von der Implementation zum Lösungsdesign beschreiben (was wurde anders gemacht, was wurde nicht gemacht, was wurde zusaetzlich gemacht)