library(shiny)
library(tidyverse)
library(shinyWidgets)
library(rsconnect)
library(arrow)


# Rtsudio workaround to make sure path isn't hard-coded
# setwd(dirname(rstudioapi::getSourceEditorContext()$path))
# base_path <- system('git rev-parse --show-toplevel', intern = T)

# read in and cleaning
# df <-
#   read_parquet(paste0(
#     base_path, 
#     '/data/datasets/all_games_players_all_stats.parquet'),
#     as_tibble = TRUE) %>% 
#   rename_all(tolower) %>% 
#   mutate(season = substr(season_id, 2, 5))

df <-
  read_parquet('data/all_games_players_all_slimmer.parquet',
    as_tibble = TRUE) %>% 
  rename_all(tolower) %>% 
  mutate(season = substr(season_id, 2, 5))

df$name[df$name == 'Eddie Johnson' & df$player_id == '77144'] <- 'Eddie Johnson (2)'


# ui shiny section
ui <- fluidPage(
  titlePanel("Hobby Data Dashboard"),

  # next section of page
  fluidRow(h3('Performance Finder'),
           sidebarLayout(
             sidebarPanel(width = 6,
               p('Shows 10 players with the most instances of playing a game
                 with at least the statline entered in the boxes below.'),
              fluidRow(
                column(width = 3,
                       numericInput("points", 
                                    label = h4("Points"),
                                    value = 0,
                                    width = '100%')
                       ),
                 column(width = 3,
                        numericInput("rebounds",
                                    label = h4("Rebounds"),
                                    value = 0,
                                    width = '100%')
                        ),
                        
                        column(width = 3,
                               numericInput("assists", 
                                            label = h4("Assists"),
                                            value = 0,
                                            width = '100%')
                               ),
                        column(width = 3,
                               numericInput("steals",
                                            label = h4("Steals"),
                                            value = 0,
                                            width = '100%')
                               )
                ),
              
              fluidRow(
                column(width = 3,
                       numericInput("blocks", 
                                    label = h4("Blocks"),
                                    value = 0,
                                    width = '100%')
                       ),
                column(width = 3,
                       numericInput("turnovers",
                                    label = h4("Turnovers"),
                                    value = 0,
                                    width = '100%')
                       ),
                
                column(width = 3,
                       numericInput("fg_attempts", 
                                    label = h4("FG Attempts"),
                                    value = 0,
                                    width = '100%')
                       ),
                column(width = 3,
                       numericInput("fg_makes",
                                    label = h4("FG Makes"),
                                    value = 0,
                                    width = '100%')
                       )
              ),
              fluidRow(
                column(width = 3,
                       numericInput("fg_percent", 
                                    label = h4("FG %"),
                                    value = 0,
                                    width = '100%')
                       ),
                column(width = 3,
                       numericInput("fg3_attempts",
                                    label = h4("3PT Attempts"),
                                    value = 0,
                                    width = '100%')
                       ),
                
                column(width = 3,
                       numericInput("fg3_makes", 
                                    label = h4("3PT Makes"),
                                    value = 0,
                                    width = '100%')
                       ),
                column(width = 3,
                       numericInput("fg3_percent",
                                    label = h4("3PT %"),
                                    value = 0,
                                    width = '100%')
                       )
                )
              ),
             mainPanel(tableOutput(outputId = 'table'), 
                       width = 6,
                       position = 'right')
             )
           ),
  
  # next fluid row
  fluidRow(h3('X Point Games per Season'),
    sidebarLayout(
      sidebarPanel(
        p('This graph displays how many times in a season a player scored
          more than X points.'),
        # Slider input for adjusting the number of points in the graph
        chooseSliderSkin('Round'),
        sliderInput(inputId = "num_points", 
                    label = "Number of points:",
                    min = 0,
                    max = 70, 
                    value = 50,
                    ticks = F),
        sliderInput(inputId = "earliest_year", 
                    label = "Earliest Year",
                    min = 1940,
                    max = 2010, 
                    value = 1980,
                    ticks = F,
                    sep = '')),
      mainPanel(plotOutput(outputId = "graph")
      )
    )
  )
  
)

# ui server section
server <- function(input, output, session) {

  
  output$table <- renderTable({
    
    df %>% 
      # temporary fix to the NA problems
      replace(is.na(.), 0) %>% 
      
      filter(pts >= input$points,
             ast >= input$assists,
             reb >= input$rebounds,
             stl >= input$steals,
             blk >= input$blocks,
             tov >= input$turnovers,
             fga >= input$fg_attempts,
             fgm >= input$fg_makes,
             fg_pct >= input$fg3_percent,
             fg3a >= input$fg3_attempts,
             fg3m >= input$fg3_makes,
             fg3_pct >= input$fg3_percent) %>% 
      group_by(name) %>% 
      summarise(Number = n()) %>% 
      arrange(desc(Number)) %>% 
      head(10)
    }, 
    striped = T,
    hover = T,
    bordered = T,
    spacing = 's')
  
  
  
  # Render the graph based on the reactive expression and color input
  output$graph <- renderPlot({
    df %>% 
      mutate(points_dummy = ifelse(pts >= input$num_points, 1, 0)) %>% 
      group_by(season) %>% 
      summarize(number = sum(points_dummy)) %>% 
      filter(season >= input$earliest_year) %>% 
      ggplot(aes(x = season, y = number)) +
      geom_bar(stat = 'identity') +
      theme_minimal() +
      labs(y = 'Occurrences',
           x = 'Season') +
      theme(axis.text.x = element_text(angle = 80,
                                       hjust = 1,
                                       size = 12),
            axis.text.y = element_text(size = 15))
    

    #theme(axis.text.x=element_text(size=15))
  })
}

shinyApp(ui, server)


# runApp(
#   display.mode = "showcase",
#   #display.mode = c("auto", "normal", "showcase"),
#   test.mode = getOption("shiny.testmode", TRUE)
# )
#shinyApp(ui = ui, server = server, options=c(launch.browser = .rs.invokeShinyPaneViewer))

