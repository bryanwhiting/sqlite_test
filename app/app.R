#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(argonDash)
library(argonR)
library(tidyverse)
library(reactable)
library(ggplot2)
library(plotly)

df <- readr::read_csv(here::here('data-raw/data.csv')) %>%
    mutate(
        x = str_extract(s, "\\w[0-9]*"),
        s_clean = ifelse(is.na(x), s, x)
    ) %>%
    select(id, s_clean, s, everything()) %>%
    select(-x)


process_data <- function(df, keep){
    df %>%
        # filter(str_detect(s, paste(keep, collapse="|"))) %>%
        filter(!(s %in% (df %>% filter(p == "sub") %>% distinct(s) %>% pull()))) %>%
        group_by(s_clean) %>%
        mutate(keep_s = row_number() == 1) %>%
        group_by(s) %>%
        filter(max(keep_s) == TRUE) %>%
        select(s, s_clean, p, v) %>%
        pivot_wider(names_from=p, values_from=v)
}

sb <- argonDashSidebar(
    vertical = TRUE,
    skin = "light",
    background = "white",
    size = "md",
    side = "left",
    id = "my_sidebar",
    argonSidebarHeader(title = "Main Menu"),
    argonSidebarMenu(
        argonSidebarItem(
            tabName = "data",
            icon = argonIcon(name = "bullet-list-67", color = "red"),
            "Data"
        ),
        argonSidebarItem(
            tabName = "charts",
            icon = argonIcon(name = "chart-bar-32", color = "green"),
            "Charts"
        )
    )
)


data_tab <- argonTabItem(
    tabName = "data",
    argonH1("Data", display = 4),
    argonCard(
        width=12,
        icon = icon("cogs"),
        status = "success",
        shadow = TRUE,
        border_level = 2,
        hover_shadow = TRUE,
        title = "Learn more about your serial number",
        column(12, tags$h3("Please select your desired serial number below:")),
        column(12, tags$p("By default, this app shows the raw data. If you click the Tranform button or select serial numbers, it will present the data to you in a cleaner, user-friendly format.")),
        argonCard(
            # argonRow(
                # width=12,
                # tableOutput('raw_data'),
                # dataTableOutput('raw_data1'),
                # reactableOutput('raw_data2'),
            # ),
            argonRow(
                # width = 12,
                fluidRow(
                    column(6,
                checkboxInput(
                    # width=4,
                    inputId = 'transform',
                    label = 'Transform Output?'
                )),
                column(6,
                selectizeInput(
                    # width=8,
                    inputId='serials',
                    label= "Serial Numbers",
                    choices = unique(df$s_clean),
                    selected = NULL,
                    multiple = TRUE,
                    options = list(
                        placeholder = 'Select serial numbers...'
                    )
                )
                )),
                br(),
                reactableOutput('react_tab')
            )
            # argonRow(width = 12, plotOutput("distPlot"))
        )
    )
)

chart_tab <- argonTabItem(
    tabName = "charts",
    # plotlyOutput('histplot')
    argonH1("Charts", display = 4),
    argonCard(
        width=12,
        "Plot of serial numbers by time:",
        argonColumn(
            plotlyOutput('histPlot')
            ),
        "Some other random data:",
        argonColumn(plotOutput('distPlot'))
    )
)

shiny::shinyApp(
    ui = argonDashPage(
        title = "Serial Numbers",
        author = "Bryan",
        description = "Dash Test",
        sidebar = sb,
        body = argonDashBody(
            argonTabItems(
                data_tab,
                chart_tab
            )
        )
    ),
    server = function(input, output, session) {

        df_r <- reactive({
            df_out <- df

            if (length(input$serials) > 0){
                cat('hello')
                df_out <- df %>%
                    filter(s_clean %in% as.vector(input$serials))
                cat('finished')
            }

            # Transform the code
            if (input$transform){
                cat('processing')
                df_out <- df_out %>%
                    process_data()
            }

            return(df_out)

        })
        # output$raw_data <- renderTable({
            # df
        # })
        # output$raw_data1 <- renderDataTable({
        #     DT::datatable(df, style='bootstrap')
        # })
        output$react_tab <- renderReactable({
            reactable(
                df_r(),
                theme=reactablefmtr::journal(),
                searchable=T
            )
        })


        output$distPlot <- renderPlot({
            hist(rnorm(10))
        })

        output$histPlot <- renderPlotly({
            p <- df %>%
                group_by(t) %>%
                count() %>%
                ggplot(aes(x = t, y = n)) +
                geom_bar(stat='identity') +
                theme_minimal() +
                labs(
                    title = "Interactive chart of Events over Time",
                    y = 'Count of Events',
                    x = 'Time'
                )
            pp <- ggplotly(p)
            return(pp)
        })

    }
)
