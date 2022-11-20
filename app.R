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
orte <- dat[, c("ORT_NAME", "ORT_LAT", "ORT_LON", "POSTLEITZAHL")]
orte$ORT_NAME <- tolower(orte$ORT_NAME)

namen <- sort(c("wenig", "wendisch", "wind", "böhmisch", "welsch", "klein", 
                "winn"))


## Einstellen der Farben

## gg_color_hue: recieve standard ggplot color palette 
## input: n, integer, number of colors
## output: vector of color hex codes
gg_color_hue <- function(n) {
    hues <- seq(15, 375, length = n + 1)
    hcl(h = hues, l = 65, c = 100)[1:n]
}
colors <- gg_color_hue(7)

## TODO: Am besten Faktor draus machen
## helper for ggplot colors
set_color <- function(data, names) {
    n <- length(names)
    color <- character(nrow(data))
    colors <- gg_color_hue(n)
    for(name in names) {
        pos <- grepl(name, orte$ORT_NAME, fixed = TRUE)
        color[pos] <- ifelse(color[pos] == "", name, color[pos])
    }
    ifelse(color == "", NA, color)
}

orte$color <- set_color(orte, namen)


## create a map of germany
germany <- map_data("worldHires", region = "Germany")
map_de <- ggplot() + 
    geom_polygon(data = germany, 
                 aes(x = long, y = lat, group = group), 
                 fill = "grey", alpha = 0.8) +
    theme_bw() + 
    theme(aspect.ratio = 1, axis.title.x=element_blank(),
          axis.text.x = element_blank(), axis.ticks.x = element_blank(),
          axis.text.y = element_blank(), axis.ticks.y = element_blank(),
          axis.title.y = element_blank(), panel.border = element_blank(), 
          panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
          axis.line = element_line(colour = "white"))


## extract_orte: extract only towns that contain specific character strings in their names
## input: names, vector of character strings (specific substrings of town names)
##        os, data.frame as orte created from dat.RData
## output: data.frame only containing towns with specific names
extract_orte <- function(names = namen, os = orte) {
    o <- data.frame()
    for(n in seq_along(names)) {
        o <- rbind(o, os[grepl(names[n], os$ORT_NAME, fixed = TRUE) & os$color == names[n], ]) 
    }
    o
}

## plotArbitraryNames: plot location of specific towns
## input: names, vector of character strings (specific substrings of town names)
##        kOG, logical, if TRUE only plot towns with "klein" without
##          corresponding town contraining "groß"
##        preset_colors, logical, if TRUE uses a vector named colors with color
##          hex codes
plotArbitraryNames <- function(names, kOG = FALSE, preset_colors = TRUE) {
    if(length(names) < 1) {
        map_de
    } else {
        if((!kOG) | (kOG & !("klein" %in% names))) {
            orte <- extract_orte(names)
        } else {
            os <- orte[!grepl("klein", orte$ORT_NAME, fixed = TRUE), ]
            os <- rbind(os, orte[orte$ORT_NAME %in% nur_klein, ])
            orte <- extract_orte(names = names, os = os)
        }
        plt <- map_de +
            geom_point(data = orte, aes(x = ORT_LON, y = ORT_LAT, col = color)) +
            labs(col = "Orte mit... im Namen") +
            theme(legend.title = element_text(size = 14),
                  legend.text = element_text(size = 12))  
        if(preset_colors & length(names) > 0) {
            index <- sapply(names, function(n) which(namen == n))
            plt + scale_color_manual(values = colors[index])
        } else {
            plt
        }   
    }
}


# Define UI for application
ui <- fluidPage(

    # Application title
    titlePanel("Verteilung bestimmter deutscher Ortsnamen"),
    
    mainPanel(
        plotOutput("map")
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
                                  selected = 5)),
        
        column(3,
               h3("Klein ohne zugehöriges Groß"),
               checkboxInput("klein", "Klein ohne Groß", value = FALSE)),
        
        
        column(3,
               h3("Bestätigen"),
               submitButton("Submit"))
        
    )
)

# Define server logic required
server <- function(input, output) {
    
    output$map <- renderPlot({ 
        plotArbitraryNames(names = namen[sort(as.numeric(input$checkGroup))],
                           kOG = input$klein)

    })
}

# Run the application 
shinyApp(ui = ui, server = server)

                            
                            
