# =====================================================
# DASHBOARD FINAL PRO - SINIESTROS
# =====================================================

# ---------------------------
# Librerías
# ---------------------------
required_packages <- c(
  "shiny", "shinydashboard", "ggplot2",
  "dplyr", "plotly", "leaflet", "leaflet.extras"
)

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(plotly)
library(leaflet)
library(leaflet.extras)

# ---------------------------
# Datos
# ---------------------------
csv_path <- "extract/files/3.1 NMERO DE SINIESTROS_limpio.csv"
df <- read.csv(csv_path, stringsAsFactors = FALSE)

# Transformaciones
df$FECHA_OCUR <- as.Date(df$FECHA_OCUR)
df$FECHA_HORA <- as.Date(df$FECHA_HORA)
df$HORA_NUM <- suppressWarnings(as.numeric(substr(df$HORA_OCURR, 1, 2)))

df$SEVERO <- ifelse(df$GRAVEDAD %in% c("con heridos", "con muertos"),
                    "severo", "no severo")

meses_orden <- c("enero","febrero","marzo","abril","mayo","junio",
                 "julio","agosto","septiembre","octubre","noviembre","diciembre")

df$MES_OCURRE <- factor(tolower(df$MES_OCURRE),
                        levels = meses_orden, ordered = TRUE)

dias_orden <- c("lunes","martes","miercoles","jueves",
                "viernes","sabado","domingo")

df$DIA_OCURRE <- factor(tolower(df$DIA_OCURRE),
                        levels = dias_orden, ordered = TRUE)

# ---------------------------
# UI
# ---------------------------
ui <- dashboardPage(

  dashboardHeader(title = "🚦 Dashboard PRO de Siniestros"),

  dashboardSidebar(
    sidebarMenu(

      menuItem("Visualización", tabName = "viz", icon = icon("chart-bar")),
      menuItem("Mapa PRO", tabName = "mapa", icon = icon("map")),
      menuItem("Conclusión", tabName = "conclusion", icon = icon("lightbulb")),

      hr(),

      radioButtons("modo", "Modo de análisis:",
                   choices = c("Interactivo", "General (todos los años)")),

      conditionalPanel(
        condition = "input.modo == 'Interactivo'",
        selectInput("anio", "Año:", choices = sort(unique(df$ANO_OCURRE)))
      ),

      checkboxInput("soloSevero", "Solo severos", FALSE),

      selectInput("localidad", "Filtrar por localidad:",
                  choices = c("Todas", sort(unique(df$LOCALIDAD)))),

      selectInput("grafica", "Seleccionar gráfica:",
                  choices = c("Barras","Líneas","Heatmap","Boxplot","Proporciones"))
    )
  ),

  dashboardBody(

    tabItems(

      # =========================
      # TAB VISUALIZACIÓN
      # =========================
      tabItem(tabName = "viz",

        fluidRow(
          valueBoxOutput("kpi_total"),
          valueBoxOutput("kpi_severos"),
          valueBoxOutput("kpi_porcentaje")
        ),

        fluidRow(
          box(width = 12,
              plotlyOutput("grafico", height = "500px"))
        ),

        fluidRow(
          box(width = 12,
              title = "Interpretación",
              status = "primary",
              solidHeader = TRUE,
              verbatimTextOutput("interpretacion"))
        )
      ),

      # =========================
      # TAB MAPA PRO
      # =========================
      tabItem(tabName = "mapa",

        fluidRow(
          box(width = 12,
              title = "Mapa PRO de Siniestros",
              status = "primary",
              solidHeader = TRUE,
              leafletOutput("mapa", height = "650px"))
        )
      ),

      # =========================
      # TAB CONCLUSIÓN
      # =========================
      tabItem(tabName = "conclusion",

        fluidRow(
          box(width = 12,
              title = "Conclusión General",
              status = "success",
              solidHeader = TRUE,
              verbatimTextOutput("conclusion"))
        )
      )
    )
  )
)

# ---------------------------
# SERVER
# ---------------------------
server <- function(input, output) {

  # Datos filtrados
  data_base <- reactive({

    data <- if (input$modo == "General (todos los años)") {
      df
    } else {
      df %>% filter(ANO_OCURRE == input$anio)
    }

    if (input$soloSevero) {
      data <- data %>% filter(SEVERO == "severo")
    }

    if (input$localidad != "Todas") {
      data <- data %>% filter(LOCALIDAD == input$localidad)
    }

    data
  })

  # KPIs
  output$kpi_total <- renderValueBox({
    valueBox(nrow(data_base()), "Total Siniestros", icon = icon("car"), color = "blue")
  })

  output$kpi_severos <- renderValueBox({
    data <- data_base()
    valueBox(sum(data$SEVERO == "severo"), "Siniestros Severos",
             icon = icon("exclamation-triangle"), color = "red")
  })

  output$kpi_porcentaje <- renderValueBox({
    data <- data_base()
    valueBox(paste0(round(mean(data$SEVERO == "severo") * 100, 2), "%"),
             "% Severidad", icon = icon("chart-line"), color = "yellow")
  })

  # GRÁFICAS
  output$grafico <- renderPlotly({

    data <- data_base()

    if (input$grafica == "Barras") {
      d <- data %>% filter(SEVERO == "severo") %>%
        count(LOCALIDAD, sort = TRUE) %>% head(10)

      p <- ggplot(d, aes(reorder(LOCALIDAD, n), n,
                         text = paste("Localidad:", LOCALIDAD, "<br>Total:", n))) +
        geom_bar(stat="identity", fill="tomato") +
        coord_flip()
    }

    else if (input$grafica == "Líneas") {
      d <- data %>% count(ANO_OCURRE, MES_OCURRE)

      p <- ggplot(d, aes(MES_OCURRE, n,
                         color=as.factor(ANO_OCURRE),
                         group=ANO_OCURRE,
                         text = paste("Año:", ANO_OCURRE,"<br>Total:", n))) +
        geom_line() + geom_point()
    }

    else if (input$grafica == "Heatmap") {
      d <- data %>% filter(!is.na(HORA_NUM)) %>%
        count(DIA_OCURRE, HORA_NUM)

      p <- ggplot(d, aes(HORA_NUM, DIA_OCURRE, fill=n,
                         text=paste("Total:",n))) +
        geom_tile()
    }

    else if (input$grafica == "Boxplot") {
      d <- data %>% filter(GRAVEDAD %in% c("solo danos","con heridos","con muertos"))

      p <- ggplot(d, aes(GRAVEDAD, HORA_NUM, fill=GRAVEDAD)) +
        geom_boxplot()
    }

    else {
      p <- ggplot(data, aes(DIA_OCURRE, fill=SEVERO)) +
        geom_bar(position="fill")
    }

    ggplotly(p, tooltip="text")
  })

  # INTERPRETACIÓN
  output$interpretacion <- renderText({
    switch(input$grafica,
           "Barras"="Comparación de localidades.",
           "Líneas"="Tendencias temporales.",
           "Heatmap"="Horas críticas.",
           "Boxplot"="Distribución por gravedad.",
           "Proporciones"="Composición por día.")
  })

  # MAPA PRO
  output$mapa <- renderLeaflet({

    data <- data_base() %>%
      filter(!is.na(LATITUD), !is.na(LONGITUD))

    pal <- colorFactor(c("green","orange","red"), data$GRAVEDAD)

    leaflet(data) %>%
      addProviderTiles(providers$CartoDB.Positron, group="Claro") %>%
      addProviderTiles(providers$CartoDB.DarkMatter, group="Oscuro") %>%

      addCircleMarkers(
        lng=~LONGITUD, lat=~LATITUD,
        color=~pal(GRAVEDAD),
        radius=5, fillOpacity=0.7,
        clusterOptions = markerClusterOptions(),
        popup = ~paste("Localidad:", LOCALIDAD,"<br>Gravedad:",GRAVEDAD),
        group="Cluster"
      ) %>%

      addHeatmap(lng=~LONGITUD, lat=~LATITUD,
                 blur=20, radius=15, group="Heatmap") %>%

      addLayersControl(
        baseGroups=c("Claro","Oscuro"),
        overlayGroups=c("Cluster","Heatmap"),
        options=layersControlOptions(collapsed=FALSE)
      ) %>%

      addLegend("bottomright", pal=pal, values=~GRAVEDAD, title="Gravedad")
  })

  # CONCLUSIÓN FIJA
  output$conclusion <- renderText({
    paste(
      "1) Existe concentración territorial y temporal.\n",
      "2) Kennedy es la localidad con más siniestros.\n",
      "3) Predominan los casos con daños y heridos.\n",
      "4) Se deben priorizar controles en zonas y horarios críticos."
    )
  })
}

# ---------------------------
# RUN
# ---------------------------
shinyApp(ui, server)