library(shiny)
library(tidyverse)


# Rtsudio workaround to make sure path isn't hard-coded
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
base_path <- system('git rev-parse --show-toplevel', intern = T)

# read in massive data
df <- 
  read.csv(paste0(base_path, '/data/datasets/all_games_players.csv')) %>% 
  mutate(season = substr(SEASON_ID, 2, 5)) %>% 
  select(season, PTS)

# ui shiny section
ui <- fluidPage(
  titlePanel("Hobby Data Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      # Slider input for adjusting the number of points in the graph
      sliderInput(inputId = "num_points", 
                  label = "Number of points:",
                  min = 0,
                  max = 80, 
                  value = 50),
      sliderInput(inputId = "earliest_year", 
                  label = "Earliest Year",
                  min = 1940,
                  max = 2010, 
                  value = 1980)
    ),
    # Output for the graph
    mainPanel(
      plotOutput(outputId = "graph")
    )
  )
)

server <- function(input, output, session) {

  
  # Render the graph based on the reactive expression and color input
  output$graph <- renderPlot({
    df %>% 
      mutate(points_dummy = ifelse(PTS >= input$num_points, 1, 0)) %>% 
      group_by(season) %>% 
      summarize(number = sum(points_dummy)) %>% 
      filter(season >= input$earliest_year) %>% 
      ggplot(aes(x = season, y = number)) +
      geom_bar(stat = 'identity') +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 80,
                                       hjust = 1))
    
  })

  # output$graph <- renderPlot({
  #   ggplot(graph_data(), aes(x = x, y = y)) +
  #     geom_line(color = input$color)
}

shinyApp(ui, server)

