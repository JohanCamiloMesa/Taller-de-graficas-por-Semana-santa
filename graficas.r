#1. Histograma

edades <- c(18,22,25,30,30,35,40,41,45,50,50,60,65,70,72,80)
hist(edades, col="lightblue", main="Distribucion de Edades",
     xlab="Edad", ylab="Frecuencia", breaks=8)

#2. Diagrama de barras

productos <- c("A", "B", "C", "D")
ventas <- c(50, 70, 30, 90)
barplot(ventas, names.arg=productos, col="orange", main="Ventas por producto", ylab="Unidades")

#3. Graficas de lineas

meses <- c("Ene", "Feb", "Mar", "Abr", "May", "Jun")
usuarios <- c(100, 150, 200, 250, 300, 400)
plot(usuarios, type="o", col="blue", xaxt="n", main="Crecimiento de Usuarios", ylab="Usuarios")
axis(1, at=1:6, labels = meses)

#4. Diagramas de dispersion

horas <- c(1,2,3,4,5,6,7,8)
nota <- c(50,60,65,70,75,80,85,90)
plot(horas, nota, col="red", main="Relacion entre Estudio y Nota",
     xlab="Horas de estudio", ylab="Nota")

#5. Boxplots (Caja y bigotes)

salarios <- list(TI=c(2000,2200,2500,2700,2900,3500),
                 Ventas=c(1500,1600,1700,2000,2200,2500))
boxplot(salarios, col=c("lightblue","lightgreen"), main="Salarios por Area")

#6. Graficas de densidad
set.seed(123)
datos <- rnorm(1000, mean=170, sd=10)
plot(density(datos), col="purple", main="Densidad de estaturas", xlab="Estaturas (cm)")

#7. Mapas de calor
mat <- matrix(rnorm(25), nrow=5)
heatmap(mat, main="Mapa de calor de datos aleatorios")

# Instalar si no lo tienes
# install.packages ("ggplot2")
# install. packages ("reshape2")

install.packages("reshape2") # Solo la primera vez
install.packages("ggplot2")
library(ggplot2)
library(reshape2)

# Crear matriz de datos (10 x 10)
set.seed(123)
mat <- matrix(rnorm(100), nrow=10)
rownames (mat) <- paste0("obs", 1:10)
colnames (mat) <- paste0("var", 1:10)

# Convertir la matriz a formato largo
df <- melt (mat)

# Revisar el data frame
head (df)

#7. Graficar mapa de calor
ggplot(data=df, aes(x=Var2, y=Var1, fill=value)) +
  geom_tile(color="white") +
  scale_fill_gradient2(low="blue", mid="white", high="red", midpoint=0) +
theme_minimal() +
labs(title="Mapa de calor con ggplot2", x="variables", y="observaciones")

#8. Diagramas de dispersión
library(ggplot2)
set.seed(123)
datos <- data.frame(
  grupo=rep(c("A","B"), each=200),
  valores=c(rnorm(200, mean=50), rnorm(200, mean=60))
)
  ggplot(datos, aes(x=grupo, y=valores, fill=grupo)) +
    geom_violin() +
    ggtitle("Diagrama de violin")
  
#9. Gráficas de area
ventas <- c(10,20,30,50,80,120)
plot (ventas, type="n", main="ventas Acumuladas", xlab="Tiempo", ylab="ventas")
polygon(c(1:6,6,1), c(ventas,0,0), col="lightblue")
lines (ventas, col="blue", lwd=2)

#10. Gráficas de torta(Pie charts)
valores <- c(40, 25, 20, 15)
categorias <- c("carrera A","carrera B", "carrera c","carrera D")
pie(valores, labels=categorias, main="Distribucion de Estudiantes", col=rainbow(4))

#11. Pair plots (Matrices de dispersión)
pairs(iris[,1:4], main="Pair Plot de Iris")

#12. Gráficas de correlación
install.packages("corrplot")
library(corrplot)
matriz <- cor (mtcars)
corrplot(matriz, method="color", type="upper", tl.col="black")

#13. Gráficas de regresión
x <- c(1,2,3,4,5,6,7,8)
y <- c(2,4,5,4,5,7,8,9)
modelo <- lm(y ~ x)
plot (x, y, pch=16, main="Regresion lineal")
abline(modelo, col="blue", lwd=2)

#14. Series de tiempol
datos <- ts(c(100,120,130,125,140,160), start=2020, frequency=1)
plot (datos, col="darkgreen", main="Serie de Tiempo: Ventas Anuales")

#15. Gráficas de burbujas
x <- c(5,10,15,20)
y <- c(3,7,8,12)
tam <- c(2,5,10,15)
symbols(x, y, circles=tam, inches=0.2, bg="lightblue", main="Grafico de Burbujas")