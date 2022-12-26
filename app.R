##############################################################################
## Darstellung ausgewaehlter Ortsnamen auf einer Deutschlandkarte mit shiny ##
##############################################################################

## TODO: Funktionen verallgemeinern
## TODO: Bisschen Beschreibung auf die App, insb. was ist klein ohne gross

library(shiny)
library(ggplot2)
library(mapdata)

## Download required data from repository
load("dat.RData")
load("nur_klein.RData")
Orte <- dat[, c("ORT_NAME", "ORT_LAT", "ORT_LON", "POSTLEITZAHL")]
PLZ_0 <- Orte$POSTLEITZAHL %/% 10000 == 0
Orte$POSTLEITZAHL[PLZ_0] <- paste0("0", Orte$POSTLEITZAHL[PLZ_0])
Orte$POSTLEITZAHL <- as.factor(Orte$POSTLEITZAHL)
Orte$ORT_NAME <- tolower(orte$ORT_NAME)

Namen <- sort(c("wenig", "wendisch", "wind", "böhmisch", "welsch", "klein", 
                "winn"))


## Preset colors for considered names (plus one for an arbitrary name) 
colors <- c("#F8766D", "#CD9600", "#7CAE00", "#00BE67", "#00BFC4", "#00A9FF",
            "#C77CFF", "#FF61CC")


## Create a map of Germany
germany <- map_data("worldHires", region = "Germany")
map_de <- ggplot() + 
  geom_polygon(data = germany, 
               aes(x = long, y = lat, group = group), 
               fill = "grey", alpha = 0.8) +
  theme(aspect.ratio = 1) + 
  theme_bw() + 
  theme(aspect.ratio = 1, axis.title.x=element_blank(),
        axis.text.x = element_blank(), axis.ticks.x = element_blank(),
        axis.text.y = element_blank(), axis.ticks.y = element_blank(),
        axis.title.y = element_blank(), panel.border = element_blank(), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "white"))


## ... add some points for 5 big cities
cities <- Orte[Orte$POSTLEITZAHL %in% c(60310, 80333, 10115, 20095, 50676), ]
cities <- cities[!duplicated(cities$POSTLEITZAHL), ]
cities$ORT_NAME <- c("Hamburg", "Köln", "Frankfurt", "München", "Berlin")

mapWithCities <- map_de +
  geom_point(data = cities, mapping = aes(x = ORT_LON, y = ORT_LAT)) +
  geom_text(data = cities, mapping = aes(x = ORT_LON, y = ORT_LAT, 
                                         label = ORT_NAME), vjust = -0.5)


## setInput: Helper for extractOrte; connects place name to respective input
setInput <- function(l, namen) {
  for(i in seq_along(l)) {
    l[[i]]$name <- namen[i] 
  }
  l
}


## extract_orte: extract only places that contain specific character strings in 
##  their names
## input: names, vector of character strings (specific substrings of town names)
## output: data.frame only containing towns with specific names
extractOrte <- function(namen, orte = Orte) {
  extr <- lapply(namen, function(n) orte[grepl(n, orte$ORT_NAME, fixed = TRUE), ])
  extr <- do.call("rbind", setInput(extr, namen))
  extr$name <- factor(extr$name, 
                      levels = c(sort(Namen), 
                                 sort(namen[!(namen %in% Namen)])))
  
  if(anyDuplicated(extr)) {
    warning(paste(sum(duplicated(extr)), "place name(s) suit(s) several inputs.
      Duplicate(s) to be removed."))
  }
  
  extr[!duplicated(extr$ORT_NAME), ]
}


## plotArbitraryNames: plot location of specific towns
## input: namen, vector of character strings (specific substrings of town names)
##        kOG, logical, if TRUE only plot towns with "klein" without
##          corresponding town contraining "groß"
plotArbitraryNames <- function(namen, kOG = FALSE) {
  
  if(length(namen) < 1) {
    mapWithCities
  } else {
    if(all(namen %in% Namen)) {
      namen <- sort(namen)
      nam <- Namen
    } else if(sum(!(namen %in% Namen)) == 1) {
      sonst <- namen[which(!(namen %in% Namen))]
      namen <- sort(namen[-which(!(namen %in% Namen))])
      namen <- c(namen, sonst)
      nam <- c(Namen, sonst)
    }
    
    if((!kOG) | (kOG & !("klein" %in% namen))) {
      orte <- extractOrte(namen)
    } else {
      os <- Orte[!grepl("klein", orte$ORT_NAME, fixed = TRUE), ]
      os <- rbind(os, Orte[orte$ORT_NAME %in% nur_klein, ])
      orte <- extractOrte(namen = namen, orte = os)
    }
    
    index <- sapply(namen, function(n) which(nam == n))
    map_de +
      geom_point(data = orte, aes(x = ORT_LON, y = ORT_LAT, col = name)) +
      labs(col = "Orte mit... im Namen") + 
      scale_color_manual(values = colors[index]) + 
      geom_point(data = cities, mapping = aes(x = ORT_LON, y = ORT_LAT)) +
      geom_text(data = cities, mapping = aes(x = ORT_LON, y = ORT_LAT, 
                                             label = ORT_NAME), vjust = -0.5)
  }
}


# Define UI for application
ui <- fluidPage(
    
    # Application title
    titlePanel("Verteilung bestimmter deutscher Ortsnamen"),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Karte", plotOutput("map")), 
        tabPanel("Liste", dataTableOutput("list")), 
      )
    ),
    
    # Sidebar 
    fixedRow(
      
      column(3, 
             checkboxGroupInput("checkGroup", 
                                h3("Auswahl darzustellender Ortsnamen"), 
                                choices = list("böhmisch" = 1, 
                                               "klein" = 2, 
                                               "welsch" = 3,
                                               "wendisch" = 4,
                                               "wenig" = 5,
                                               "wind" = 6,
                                               "winn" = 7),
                                selected = 5),
             textInput("Sonst", "Anderer Ortsname"),
             br(),
             h3("Klein ohne zugehöriges Groß"),
             checkboxInput("klein", "Klein ohne Groß", value = FALSE),
             br(),
             submitButton("Bestätigen"))
    )
)

# Define server logic required
server <- function(input, output) {
    
    output$map <- renderPlot({
        nms <- Namen[sort(as.numeric(input$checkGroup))]
        sonst <- tolower(as.character(input$Sonst))
        if(sonst != "") {
          nms <- c(nms, sonst)
        }
        plotArbitraryNames(namen = nms, kOG = input$klein)
    })
    
   output$list <- renderDataTable({
     nms <- Namen[sort(as.numeric(input$checkGroup))]
     sonst <- tolower(as.character(input$Sonst))
     if(sonst != "") {
       nms <- c(nms, sonst)
     }
     extr <- extractOrte(namen = nms)[, 1:4]
     colnames(extr) <- c("Ortsname", "Breitengrad", "Längengrad", "PLZ")
     extr
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
