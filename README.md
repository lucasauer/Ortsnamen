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
oder:

https://lucasauer.shinyapps.io/ortsnamen/


## Stand

* Darstellung der Lage der Ortschaften mit bestimmten Wortteilen im Namen über R shiny App (Datei app.R)
* Möglichkeit der Darstellung eines zusätzlichen (nicht vorgegebenen) Wortteils
* Darstellung der betrachteten Orte in Tabellenform
* Benötigte Daten in zwei .RData Dateien (Quelle für Daten?)


## Roadmap

* Nur klein gegen groß Vergleich, was ist mit anderen Fällen
* Bsp. Dortmund: Kein Ort in Daten als "Dortmund" eingegeben (nur Orts- bzw. Stadtteile)
* Fehler beheben, wenn keine Auswahl getroffen wurde oder eine Auswahl die keine Ergebnisse liefert
