## Taller de graficas en R con dataset real de siniestros
## Dataset: extract/files/3.1 NMERO DE SINIESTROS_limpio.csv

# =====================================================
# 0) Preparacion
# =====================================================

required_packages <- c("ggplot2", "reshape2", "corrplot")

# Instala paquetes faltantes para que el script sea autocontenible.
for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        install.packages(pkg, repos = "https://cloud.r-project.org")
    }
}

# Carga de librerias usadas en las visualizaciones.
library(ggplot2)
library(reshape2)
library(corrplot)

# Lectura del CSV limpio que se usa en todo el taller.
csv_path <- "extract/files/3.1 NMERO DE SINIESTROS_limpio.csv"
df <- read.csv(csv_path, stringsAsFactors = FALSE)

cat("\n===============================================\n")
cat("TALLER DE GRAFICAS - SEMANA SANTA\n")
cat("Fuente de datos:", csv_path, "\n")
cat("Filas:", nrow(df), "| Columnas:", ncol(df), "\n")
cat("===============================================\n\n")

# Variables derivadas para analisis y graficas
# FECHA_OCUR se usa para series y agregaciones por fecha.
df$FECHA_OCUR <- as.Date(df$FECHA_OCUR)
# FECHA_HORA se convierte a Date para evitar errores de tipo.
df$FECHA_HORA <- as.Date(df$FECHA_HORA)
# Extrae la hora (0-23) desde la cadena de hora.
df$HORA_NUM <- suppressWarnings(as.numeric(substr(df$HORA_OCURR, 1, 2)))

meses_orden <- c(
    "enero", "febrero", "marzo", "abril", "mayo", "junio",
    "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
)
df$MES_OCURRE <- factor(tolower(df$MES_OCURRE), levels = meses_orden, ordered = TRUE)

# Variable binaria de severidad para comparar "severo" vs "no severo".
df$SEVERO <- ifelse(df$GRAVEDAD %in% c("con heridos", "con muertos"), "severo", "no severo")

# =====================================================
# 1) Problema de analisis y resolucion con 5 graficas
# =====================================================

cat("\n================================================\n")
cat("PROBLEMA DE ANALISIS\n")
cat("================================================\n")
cat(
    "Problema: Identificar en que localidades y en que momentos se concentran\n",
    "los siniestros (con heridos o con muertos) para priorizar acciones de prevencion.\n",
    sep = ""
)

cat("\nJustificacion de las 5 graficas elegidas:\n")
cat("1) Barras: compara volumen de siniestros severos por localidad y facilita priorizacion territorial.\n")
cat("2) Lineas: muestra evolucion mensual y estacionalidad por ano para planear prevencion por temporada.\n")
cat("3) Heatmap: detecta combinaciones criticas de dia/hora para focalizar controles operativos.\n")
cat("4) Boxplot: compara distribucion de la hora por gravedad para evidenciar diferencias en el patron temporal.\n")
cat("5) Barras apiladas proporcionales: compara la composicion de severidad por dia de la semana.\n")

df_severo <- df[df$SEVERO == "severo", ]
# Filtra horas validas para graficas con eje horario.
df_hora <- df[!is.na(df$HORA_NUM) & df$HORA_NUM >= 0 & df$HORA_NUM <= 23, ]

cat("\n--- Analisis G1: Barras (top localidades con mas siniestros) ---\n")
# Cuenta y ordena siniestros severos por localidad para priorizacion territorial.
loc_counts <- sort(table(df_severo$LOCALIDAD), decreasing = TRUE)
barplot(
    head(loc_counts, 10),
    las = 2,
    col = "tomato",
    main = "A1) Top 10 localidades con mas siniestros severos",
    ylab = "Total de siniestros severos"
)
cat(
    "Interpretacion: se uso grafica de barras porque es la forma mas clara de comparar categorias territoriales (localidades) en volumen absoluto. ",
    "El resultado muestra que pocas localidades concentran buena parte de los siniestros severos; por tanto, la priorizacion de recursos debe iniciar en ese top 10.\n",
    sep = ""
)

cat("\n--- Analisis G2: Lineas (tendencia mensual por ano) ---\n")
# Agrega cantidad de registros por ano y mes para observar estacionalidad.
mensual <- aggregate(FID ~ ANO_OCURRE + MES_OCURRE, data = df, FUN = length)
mensual <- mensual[order(mensual$ANO_OCURRE, mensual$MES_OCURRE), ]
ggplot(mensual, aes(x = MES_OCURRE, y = FID, color = as.factor(ANO_OCURRE), group = ANO_OCURRE)) +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    labs(
        title = "A2) Evolucion mensual de siniestros por ano",
        x = "Mes",
        y = "Cantidad",
        color = "Ano"
    ) +
    theme_minimal()
cat(
    "Interpretacion: se uso grafica de lineas porque permite seguir cambios en el tiempo y comparar tendencias entre anos en un mismo eje. ",
    "La curva mensual evidencia periodos de mayor incidencia, lo que sugiere estacionalidad y permite programar intervenciones antes de los picos.\n",
    sep = ""
)

cat("\n--- Analisis G3: Heatmap (dia de semana vs hora) ---\n")
# Construye tabla de frecuencia por combinacion dia-hora.
heat_df <- df_hora[!is.na(df_hora$DIA_OCURRE), c("DIA_OCURRE", "HORA_NUM")]
heat_sev <- as.data.frame(table(heat_df$DIA_OCURRE, heat_df$HORA_NUM))
colnames(heat_sev) <- c("DIA", "HORA", "FRECUENCIA")
ggplot(heat_sev, aes(x = HORA, y = DIA, fill = FRECUENCIA)) +
    geom_tile(color = "white") +
    scale_fill_gradient(low = "white", high = "red") +
    labs(title = "A3) Intensidad de siniestros por dia y hora", x = "Hora", y = "Dia") +
    theme_minimal()
cat(
    "Interpretacion: se uso heatmap porque dos variables temporales categoricas (dia y hora) se entienden mejor por intensidad de color en una matriz. ",
    "Las celdas mas oscuras identifican ventanas criticas de riesgo, utiles para definir horarios de control y vigilancia vial.\n",
    sep = ""
)

cat("\n--- Analisis G4: Boxplot (hora por gravedad) ---\n")
# Conserva categorias comparables de gravedad para el boxplot.
sev_grav <- df_hora[df_hora$GRAVEDAD %in% c("solo danos", "con heridos", "con muertos"), ]
boxplot(
    HORA_NUM ~ GRAVEDAD,
    data = sev_grav,
    col = c("lightgreen", "gold", "firebrick"),
    main = "A4) Distribucion horaria por gravedad",
    xlab = "Gravedad",
    ylab = "Hora"
)
cat(
    "Interpretacion: se uso boxplot porque resume mediana, rango intercuartil y valores extremos, ideal para comparar distribuciones entre grupos de gravedad. ",
    "La diferencia en dispersion y posicion entre cajas indica que la severidad no se comporta igual a lo largo del dia, dato clave para prevenir siniestros graves.\n",
    sep = ""
)

cat("\n--- Analisis G5: Barras apiladas proporcionales (severidad por dia) ---\n")
# Orden explicito de dias para mostrar calendario semanal de forma natural.
dias_orden <- c("lunes", "martes", "miercoles", "jueves", "viernes", "sabado", "domingo")
sev_day <- df[!is.na(df$DIA_OCURRE) & !is.na(df$SEVERO), c("DIA_OCURRE", "SEVERO")]
sev_day$DIA_OCURRE <- factor(tolower(sev_day$DIA_OCURRE), levels = dias_orden, ordered = TRUE)

ggplot(sev_day, aes(x = DIA_OCURRE, fill = SEVERO)) +
    geom_bar(position = "fill") +
    scale_fill_manual(values = c("no severo" = "#4CAF50", "severo" = "#E53935")) +
    labs(
        title = "A5) Proporcion de severidad por dia de la semana",
        x = "Dia",
        y = "Proporcion",
        fill = "Tipo"
    ) +
    theme_minimal()
cat(
    "Interpretacion: se uso barras apiladas proporcionales porque permite comparar composicion (no severo vs severo) entre dias, aun cuando el total diario cambie. ",
    "El grafico revela en que dias aumenta el peso relativo de eventos severos, orientando decisiones de control preventivo por calendario semanal.\n",
    sep = ""
)

# =====================================================
# 2) Conclusion final
# =====================================================

# Extrae indicadores resumen para redactar conclusion automatica.
top_loc_name <- names(loc_counts)[1]
top_loc_value <- as.integer(loc_counts[1])

grav_prop <- prop.table(table(df$GRAVEDAD)) * 100
prop_solo_danos <- round(grav_prop["solo danos"], 2)
prop_heridos <- round(grav_prop["con heridos"], 2)
prop_muertos <- round(grav_prop["con muertos"], 2)

cat("\n================================================\n")
cat("CONCLUSION FINAL\n")
cat("================================================\n")
cat(
    "1) El analisis muestra que los siniestros no se distribuyen de forma uniforme en la ciudad; ",
    "hay concentracion territorial y temporal.\n",
    "2) La localidad con mayor volumen de siniestros severos es ", top_loc_name,
    " con ", top_loc_value, " casos en el periodo analizado.\n",
    "3) En gravedad general, la composicion es: solo danos = ", prop_solo_danos,
    "%, con heridos = ", prop_heridos, "%, con muertos = ", prop_muertos, "%.\n",
    "4) Las franjas de mayor intensidad (dia/hora) y los dias con mayor proporcion de casos severos ",
    "indican donde y cuando priorizar controles de velocidad, gestion semaforica y campanas de prevencion.\n",
    sep = ""
)