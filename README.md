# Ortsnamen

Untersuche die Lage von Ortschaften mit bestimmten Wortteilen im Ortsnamen.

Hintergrund: Vermutete Fehlübersetzung von Ortsnamen aus dem lateinischen ins 
Deutsche in Bezug auf Ortschaften, die auf eine Gründung von slawischen Siedlern
(Wenden) zurückzuführen sind (https://de.wikipedia.org/wiki/Ortsname#Namenszusätze)

How to:
```
## Run in R 
## (install shiny package first if necessary)
library(shiny)
runGitHub("lucasauer/Ortsnamen")
```

## Stand (WiP)

* Darstellung der Lage der Ortschaften mit bestimmten Wortteilen im Namen über R shiny App (Datei app.R)
* Benötigte Daten in zwei .RData Dateien (Quelle für Daten?)


## Roadmap

* Code verallgemeinern
* Encoding anpassen wg. windows?
* Nur klein gegen groß Vergleich, was ist mit anderen Fällen
* Beschreibung in der App zum besseren Verständnis