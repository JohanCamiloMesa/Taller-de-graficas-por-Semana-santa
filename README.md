# Análisis de Datos de Siniestros - Taller de Gráficas

Un proyecto integral que combina un pipeline ETL en Python con un análisis exploratorio de datos en R, enfocado en la visualización y análisis de reportes de siniestros.

---

## 📋 Descripción del Proyecto

Este proyecto implementa un sistema completo de extracción, transformación y carga (ETL) de datos de siniestros, seguido por un análisis exploratorio con 5 gráficas seleccionadas estratégicamente para resolver un problema de análisis específico.

**Problema de análisis planteado:**  
*¿Cuáles son los patrones de severidad temporal y geográfica en los siniestros reportados, y qué relación existe entre la hora del día, el día de la semana y la severidad de los incidentes?*

---

## 🏗️ Estructura del Proyecto

```
Taller-de-graficas-por-Semana-santa/
│
├── main.py                          # Orquestador principal del pipeline ETL
├── graficas.r                        # Ejemplos de 15 tipos de gráficas en R
├── taller.r                          # Análisis completo: 5 gráficas comentadas + conclusiones
├── README.md                         # Este archivo
├── requeriments.txt                  # Dependencias de Python
├── LICENSE                           # Licencia MIT
│
├── config/
│   └── LimpiezaConfig.py            # Configuración de rutas y parámetros del ETL
│
├── extract/
│   ├── LimpiezaExtract.py           # Extracción de datos desde Excel/CSV
│   └── files/
│       └── 3.1 NMERO DE SINIESTROS_limpio.csv  # Dataset limpio (salida principal)
│
├── transform/
│   └── LimpiezaTransform.py         # Transformación y limpieza de datos
│
├── load/
│   └── LimpiezaLoader.py            # Exportación a CSV, Excel y SQLite
│
└── .vscode/
    ├── launch.json                  # Configuración de depuración
    └── settings.json                # Configuración del editor
```

---

## 📊 Componentes del Proyecto

### 1. Pipeline ETL (Python)

#### **Extracción (Extract)**
- Lee datos desde archivos Excel (.xlsx) o CSV
- Soporta múltiples codificaciones (UTF-8, CP1252, Latin-1)
- Manejo automático de errores de lectura

#### **Transformación (Transform)**
- Limpia filas y columnas vacías
- Normaliza valores faltantes (`n/a`, `sin dato`, `null`, etc.)
- Valida integridad de datos
- Genera resumen de limpieza con estadísticas

#### **Carga (Load)**
- Exporta datos limpios a:
  - CSV (`3.1 NMERO DE SINIESTROS_limpio.csv`)
  - Excel (`3.1 NMERO DE SINIESTROS_limpio.xlsx`)
  - Base de datos SQLite (`Limpieza.db`)

### 2. Análisis Exploratorio (R - `taller.r`)

**5 Gráficas Seleccionadas:**

1. **Gráfica de Barras: Siniestros por Localidad**
   - **Por qué:** Identifica dónde ocurren más siniestros
   - **Método:** Agregación por localidad y ordenamiento descendente

2. **Gráfica de Líneas: Evolución Temporal Mensual**
   - **Por qué:** Detecta tendencias estacionales y cambios en el tiempo
   - **Método:** Series de tiempo por mes y año

3. **Mapa de Calor: Día de Semana vs Hora**
   - **Por qué:** Revela patrones frecuenciales (qué día/hora hay más siniestros)
   - **Método:** Matriz de densidad con degradado de colores

4. **Boxplot: Distribución de Severidad por Hora**
   - **Por qué:** Compara distribuciones y detecta outliers
   - **Método:** Análisis de cuartiles de severidad por rangos horarios

5. **Gráfica de Barras Apiladas: Severidad por Día de Semana**
   - **Por qué:** Muestra composición de severidades en cada día
   - **Método:** Proporciones apiladas para ver el mix de severidad

---

## 📦 Requisitos

### Python
- Python 3.8+
- pandas
- openpyxl

### R
- R 4.0+
- Librerías: base (nativas de R)

---

## 🚀 Instalación

### 1. Clonar o descargar el repositorio

```bash
cd "Taller-de-graficas-por-Semana-santa"
```

### 2. Configurar entorno Python

#### Opción A: Virtual Environment

```bash
# Crear entorno virtual
python -m venv .venv

# Activar (Windows)
.\.venv\Scripts\Activate.ps1

# Activar (Mac/Linux)
source .venv/bin/activate

# Instalar dependencias
pip install -r requeriments.txt
```

#### Opción B: Conda

```bash
conda create -n taller-graficas python=3.10
conda activate taller-graficas
pip install -r requeriments.txt
```

### 3. Instalar R (si no lo tienes)

Descarga desde [https://www.r-project.org/](https://www.r-project.org/)

---

## 🔧 Uso

### Opción 1: Ejecutar el Pipeline ETL Completo

```bash
# Asegúrate de que el entorno virtual/conda esté activado
python main.py
```

**Salida esperada:**
- Dataset limpio: `extract/files/3.1 NMERO DE SINIESTROS_limpio.csv`
- Dataset Excel: `extract/files/3.1 NMERO DE SINIESTROS_limpio.xlsx`
- Base SQLite: `extract/files/Limpieza.db`

### Opción 2: Ejecutar Análisis en R

#### En RStudio

```r
# Abre RStudio
# Ve a File > Open File
# Selecciona: taller.r
# Ejecuta: Ctrl + A, Ctrl + Enter (o Run)
```

#### En VS Code + R Extension

```bash
# Abre el archivo taller.r
# Selecciona todo: Ctrl + A
# Ejecuta: Ctrl + Enter
```

#### En terminal (R directamente)

```bash
Rscript taller.r
```

### Opción 3: Ver Ejemplos de 15 Tipos de Gráficas

```bash
Rscript graficas.r
```

---

## 📈 Análisis de Resultados

### Hallazgos Principales (del archivo `taller.r`)

El análisis de las 5 gráficas revela:

1. **Concentración Geográfica:** Las siniestros se concentran en 3-5 localidades principales
2. **Patrones Temporales:** Existe variabilidad significativa entre meses, indicando estacionalidad
3. **Frecuencia Horaria:** Ciertas horas del día registran mayor densidad de siniestros
4. **Variabilidad de Severidad:** La severidad presenta distribuciones diferentes según la hora
5. **Composición Semanal:** El día de la semana influye en el tipo y severidad de incidentes

### Conclusión

*Los siniestros no ocurren aleatoriamente. Existe una clara relación entre el día/hora y la severidad, así como concentración geográfica. Estas patrones pueden aprovecharse para:*
- Asignar recursos preventivos en horarios/localidades de alto riesgo
- Implementar estrategias de mitigación diferenciadas por día/hora
- Priorizar investigaciones en zonas de alta concentración

---

## 📝 Componentes del Taller Entregable

El archivo `taller.r` contiene:

✅ **Planteamiento del problema** (explícito en comentarios)  
✅ **Código en R** (comentado línea por línea)  
✅ **5 gráficas seleccionadas** (con justificación de cada una)  
✅ **Interpretación breve** (con explicación de por qué se usa esa gráfica)  
✅ **Conclusión final** (hallazgos principales consolidados)  

---

## 🔍 Formato de Datos

### Columnas Principales del Dataset Limpio

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `Fecha` | Date | Fecha del siniestro (YYYY-MM-DD) |
| `Hora` | Time | Hora del siniestro (HH:MM) |
| `Localidad` | String | Ubicación geográfica del siniestro |
| `Severidad` | Numeric | Nivel de severidad (1-5) |
| `Descripción` | String | Detalles del incidente |

*Nota: Las columnas exactas dependen del archivo Excel original. Revisa el resumen de limpieza en consola después de ejecutar `main.py`.*

---

## 🛠️ Configuración

Todos los parámetros del proyecto se encuentran en:

**`config/LimpiezaConfig.py`**

```python
BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / 'extract' / 'files'
INPUT_PATH = str(DATA_DIR / '3.1 NMERO DE SINIESTROS.XLSX')
OUTPUT_PATH = str(DATA_DIR / '3.1 NMERO DE SINIESTROS_limpio.csv')
```

Para cambiar rutas o parámetros, edita este archivo.

---

## 📚 Referencias

- **Matplotlib en R:** [ggplot2 Documentation](https://ggplot2.tidyverse.org/)
- **Pandas Documentation:** [pandas.pydata.org](https://pandas.pydata.org/docs/)
- **R Language:** [r-project.org](https://www.r-project.org/)

---

## 👤 Autor

**Johan Camilo Mesa Rios**

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para detalles.

---

## 💡 Notas de Uso

1. **Primero ejecuta el ETL:** `python main.py` genera el CSV limpio
2. **Luego abre R:** Usa `taller.r` para el análisis completo
3. **Para referencia:** `graficas.r` muestra ejemplos de 15 tipos de gráficas

---

**Última actualización:** 31 de marzo de 2026